//
//  ProviderProtocol.swift
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

protocol LyricsProvider {
    
    init(session: URLSession)
    
    func lyricsTask(request: LyricsSearchRequest, using: @escaping (Lyrics) -> Void) -> Progress
}

protocol _LyricsProvider: LyricsProvider {
    
    associatedtype LyricsToken
    
    func searchTask(request: LyricsSearchRequest, completionHandler: @escaping ([LyricsToken]) -> Void) -> Progress
    
    func fetchTask(token: LyricsToken, completionHandler: @escaping (Lyrics?) -> Void) -> Progress
}

private let subProgressUnitCount: Int64 = 100
private let portionOfSearchTask: Int64 = 20
private let portionOfFetchTask = subProgressUnitCount - portionOfSearchTask

extension _LyricsProvider {
    
    public func lyricsTask(request: LyricsSearchRequest, using: @escaping (Lyrics) -> Void) -> Progress {
        let progress = Progress(parent: Progress.current())
        progress.totalUnitCount = subProgressUnitCount
        let searchProgress = searchTask(request: request) { tokens in
            let tokens = tokens.prefix(request.limit)
            let unit = Int64(tokens.count) * subProgressUnitCount
            let fetchProgress = Progress(totalUnitCount: unit,
                                         parent: progress,
                                         pendingUnitCount: portionOfFetchTask)
            tokens.enumerated().forEach { (idx, token) in
                let child = self.fetchTask(token: token) { lrc in
                    guard let lrc = lrc else { return }
                    lrc.metadata.request = request
                    lrc.metadata.searchIndex = idx
                    using(lrc)
                }
                fetchProgress.addChild(child, withPendingUnitCount: subProgressUnitCount)
            }
        }
        progress.addChild(searchProgress, withPendingUnitCount: portionOfSearchTask)
        return progress
    }
}
