//
//  LyricsSearchRequest.swift
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

public struct LyricsSearchRequest: Equatable {
    
    public var searchTerm: SearchTerm
    public var title: String
    public var artist: String
    public var duration: TimeInterval
    public var limit: Int
    public var timeout: TimeInterval
    
    public enum SearchTerm: Equatable {
        case keyword(String)
        case info(title: String, artist: String)
    }
    
    public init(searchTerm: SearchTerm, title: String, artist: String, duration: TimeInterval, limit: Int = 6, timeout: TimeInterval = 10) {
        self.searchTerm = searchTerm
        self.title = title
        self.artist = artist
        self.duration = duration
        self.limit = limit
        self.timeout = timeout
    }
}

extension LyricsSearchRequest.SearchTerm: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case let .keyword(keyword):
            return keyword
        case let .info(title: title, artist: artist):
            return title + " " + artist
        }
    }
}
