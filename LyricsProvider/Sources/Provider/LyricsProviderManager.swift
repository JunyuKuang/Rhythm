//
//  LyricsProviderManager.swift
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

public class LyricsProviderManager {
    
    let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        return URLSession(configuration: configuration)
    }()
    
    public init() {}
    
    public func searchLyrics(withRequest request: LyricsSearchRequest,
                             sources: [LyricsProviderSource] = LyricsProviderSource.allCases,
                             updateHandler: @escaping (Lyrics) -> Void) -> Progress
    {
        let progress = Progress(totalUnitCount: Int64(sources.count))
        for source in sources {
            let provider = source.cls.init(session: session)
            let childProgress = provider.lyricsTask(request: request, using: updateHandler)
            progress.addChild(childProgress, withPendingUnitCount: 1)
        }
        return progress
    }
}
