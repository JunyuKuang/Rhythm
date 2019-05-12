//
//  LyricsXiami.swift
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

private let xiamiSearchBaseURLString = "http://api.xiami.com/web?"

public final class LyricsXiami: _LyricsProvider {
    
    public static let source: LyricsProviderSource = .xiami
    
    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func searchTask(request: LyricsSearchRequest, completionHandler: @escaping ([XiamiResponseSearchResult.Data.Song]) -> Void) -> Progress {
        let parameter: [String : Any] = [
            "key": request.searchTerm.description,
            "limit": 10,
            "r": "search/songs",
            "v": "2.0",
            "app_key": 1,
        ]
        let url = URL(string: xiamiSearchBaseURLString + parameter.stringFromHttpParameters)!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("http://h.xiami.com/", forHTTPHeaderField: "Referer")
        return session.startDataTask(with: req, type: XiamiResponseSearchResult.self) { model, error in
            let songs = model?.data.songs.filter { $0.lyric != nil } ?? []
            completionHandler(songs)
        }
    }
    
    func fetchTask(token: XiamiResponseSearchResult.Data.Song, completionHandler: @escaping (Lyrics?) -> Void) -> Progress {
        guard let lrcURLStr = token.lyric,
            let lrcURL = URL(string: lrcURLStr) else {
            completionHandler(nil)
            return Progress.completedProgress()
        }
        return session.startDataTask(with: lrcURL) { data, resp, error in
            guard let data = data,
                let lrcStr = String.init(data: data, encoding: .utf8),
                let lrc = Lyrics(ttpodXtrcContent:lrcStr) else {
                completionHandler(nil)
                return
            }
            lrc.idTags[.title] = token.song_name
            lrc.idTags[.artist] = token.artist_name
            
            lrc.metadata.remoteURL = lrcURL
            lrc.metadata.source = .xiami
            lrc.metadata.artworkURL = token.album_logo
            lrc.metadata.providerToken = token.lyric
            completionHandler(lrc)
        }
    }
}
