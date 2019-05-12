//
//  ViewLyrics.swift
//
//  This file is part of LyricsX
//  Copyright (C) 2017  Xander Deng
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

private let viewLyricsSearchURL = URL(string: "http://search.crintsoft.com/searchlyrics.htm")!
private let viewLyricsItemBaseURL = URL(string: "http://viewlyrics.com/")!

public final class ViewLyrics: _LyricsProvider {
    
    public static let source: LyricsProviderSource = .viewLyrics
    
    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func assembleQuery(artist: String, title: String, page: Int = 0) -> Data {
        let watermark = "Mlv1clt4.0"
        let queryForm = "<?xml version='1.0' encoding='utf-8'?><searchV1 artist='\(artist)' title='\(title)' OnlyMatched='1' client='MiniLyrics' RequestPage='\(page)'/>"
        let queryhash = md5(queryForm + watermark)
        let header = Data([2, 0, 4, 0, 0, 0])
        return header + queryhash + queryForm.data(using: .utf8)!
    }
    
    func searchTask(request: LyricsSearchRequest, completionHandler: @escaping ([ViewLyricsResponseSearchResult]) -> Void) -> Progress {
        guard case let .info(title, artist) = request.searchTerm else {
            // cannot search by keyword
            completionHandler([])
            return Progress.completedProgress()
        }
        var req = URLRequest(url: viewLyricsSearchURL)
        req.httpMethod = "POST"
        req.addValue("MiniLyrics", forHTTPHeaderField: "User-Agent")
        req.httpBody = assembleQuery(artist: artist, title: title)
        
        return session.startDataTask(with: req) { data, resp, err in
            guard let data = data else {
                completionHandler([])
                return
            }
            let magic = data[1]
            let decrypted = Data(data[22...].map { $0 ^ magic })
            let parser = ViewLyricsResponseXMLParser()
            try? parser.parseResponse(data: decrypted)
            completionHandler(parser.result)
        }
    }
    
    func fetchTask(token: ViewLyricsResponseSearchResult, completionHandler: @escaping (Lyrics?) -> Void) -> Progress {
        guard let url = URL(string: token.link, relativeTo: viewLyricsItemBaseURL) else {
            completionHandler(nil)
            return Progress.completedProgress()
        }
        return session.startDataTask(with: url) { data, resp, error in
            guard let data = data,
                let lrcContent = String(data: data, encoding: .utf8),
                let lrc = Lyrics(lrcContent) else {
                    completionHandler(nil)
                    return
            }
            lrc.metadata.remoteURL = url
            lrc.metadata.source = .viewLyrics
            lrc.metadata.providerToken = token.link
            if let length = token.timelength, lrc.length == nil {
                lrc.length = TimeInterval(length)
            }
            
            completionHandler(lrc)
        }
    }
}

private class ViewLyricsResponseXMLParser: NSObject, XMLParserDelegate {
    
    var result: [ViewLyricsResponseSearchResult] = []
    
    func parseResponse(data: Data) throws {
        let parser = XMLParser(data: data)
        parser.delegate = self
        guard parser.parse() else {
            throw parser.parserError!
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        guard elementName == "fileinfo" else {
            return
        }
        guard let link = attributeDict["link"],
            let artist = attributeDict["artist"],
            let title = attributeDict["title"],
            let album = attributeDict["album"] else {
                return
        }
        let uploader = attributeDict["uploader"]
        let timelength = attributeDict["timelength"].flatMap(Int.init).filter { $0 != 65535 }
        let rate = attributeDict["rate"].flatMap(Double.init)
        let ratecount = attributeDict["ratecount"].flatMap(Int.init)
        let downloads = attributeDict["downloads"].flatMap(Int.init)
        let item = ViewLyricsResponseSearchResult(link: link, artist: artist, title: title, album: album, uploader: uploader, timelength: timelength, rate: rate, ratecount: ratecount, downloads: downloads)
        result.append(item)
    }
}
