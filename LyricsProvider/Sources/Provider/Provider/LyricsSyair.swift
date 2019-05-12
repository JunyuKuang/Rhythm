//
//  LyricsSyair.swift
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

private let syairSearchBaseURLString = "https://syair.info/search"
private let syairLyricsBaseURL = URL(string: "https://syair.info")!

public final class LyricsSyair: _LyricsProvider {
    
    public static let source: LyricsProviderSource = .syair
    
    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func searchTask(request: LyricsSearchRequest, completionHandler: @escaping ([String]) -> Void) -> Progress {
        var parameter: [String: Any] = ["page": 1]
        switch request.searchTerm {
        case let .info(title: title, artist: artist):
            parameter["artist"] = artist
            parameter["title"] = title
        case let .keyword(keyword):
            parameter["q"] = keyword
        }
        let url = URL(string: syairSearchBaseURLString + "?" + parameter.stringFromHttpParameters)!
        return session.startDataTask(with: url) { data, resp, error in
            guard let data = data,
                let str = String(data: data, encoding: .utf8) else {
                    completionHandler([])
                    return
            }
            let tokens = syairSearchResultRegex.matches(in: str).compactMap { ($0.captures[1]?.content).map(String.init) }
            completionHandler(tokens)
        }
    }
    
    func fetchTask(token: String, completionHandler: @escaping (Lyrics?) -> Void) -> Progress {
        guard let url = URL(string: token, relativeTo: syairLyricsBaseURL) else {
            completionHandler(nil)
            return Progress.completedProgress()
        }
        var req = URLRequest(url: url)
        req.addValue("https://syair.info/", forHTTPHeaderField: "Referer")
        return session.startDataTask(with: req) { data, resp, error in
            guard let data = data,
                let str = String(data: data, encoding: .utf8),
                let lrcData = syairLyricsContentRegex.firstMatch(in: str)?.captures[1]?.content.data(using: .utf8),
                let lrcString = try? NSAttributedString(data: lrcData, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil).string,
                let lrc = Lyrics(lrcString) else {
                completionHandler(nil)
                return
            }
            
            lrc.metadata.source = .syair
            lrc.metadata.providerToken = token
            
            completionHandler(lrc)
        }
    }
}
