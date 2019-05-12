//
//  LyricsGecimi.swift
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

private let gecimiLyricsBaseURL = URL(string: "http://gecimi.com/api/lyric")!
private let gecimiCoverBaseURL = URL(string:"http://gecimi.com/api/cover")!

public final class LyricsGecimi: _LyricsProvider {
    
    public static let source: LyricsProviderSource = .gecimi
    
    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func searchTask(request: LyricsSearchRequest, completionHandler: @escaping ([GecimiResponseSearchResult.Result]) -> Void) -> Progress {
        guard case let .info(title, artist) = request.searchTerm else {
            // cannot search by keyword
            completionHandler([])
            return Progress.completedProgress()
        }
        let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .uriComponentAllowed)!
        let encodedArtist = artist.addingPercentEncoding(withAllowedCharacters: .uriComponentAllowed)!
        
        let url = gecimiLyricsBaseURL.appendingPathComponent("\(encodedTitle)/\(encodedArtist)")
        let req = URLRequest(url: url)
        return session.startDataTask(with: req, type: GecimiResponseSearchResult.self) { model, error in
            completionHandler(model?.result ?? [])
        }
    }
    
    func fetchTask(token: GecimiResponseSearchResult.Result, completionHandler: @escaping (Lyrics?) -> Void) -> Progress {
        return session.startDataTask(with: token.lrc) { data, resp, error in
            guard let data = data,
                let lrcContent = String(data: data, encoding: .utf8),
                let lrc = Lyrics(lrcContent) else {
                completionHandler(nil)
                return
            }
            lrc.metadata.remoteURL = token.lrc
            lrc.metadata.source = .gecimi
            lrc.metadata.providerToken = "\(token.aid),\(token.lrc)"
            
            let url = gecimiCoverBaseURL.appendingPathComponent("\(token.aid)")
            let task = self.session.dataTask(with: url, type: GecimiResponseCover.self) { model, error in
                if let model = model {
                    lrc.metadata.artworkURL = model.result.cover
                }
            }
            task.resume()
            
            completionHandler(lrc)
        }
    }
}
