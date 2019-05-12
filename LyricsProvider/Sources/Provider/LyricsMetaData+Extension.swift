//
//  LyricsMetaData+Extension.swift
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

extension Lyrics.MetaData.Key {
    public static var request       = Lyrics.MetaData.Key("request")
    public static var searchIndex   = Lyrics.MetaData.Key("searchIndex")
    public static var remoteURL     = Lyrics.MetaData.Key("remoteURL")
    public static var artworkURL    = Lyrics.MetaData.Key("artworkURL")
    public static var providerToken = Lyrics.MetaData.Key("providerToken")
    static var quality              = Lyrics.MetaData.Key("quality")
}

extension Lyrics.MetaData {
    
    public var request: LyricsSearchRequest? {
        get { return data[.request] as? LyricsSearchRequest }
        set { data[.request] = newValue }
    }
    
    public var searchIndex: Int {
        get { return data[.searchIndex] as? Int ?? 0 }
        set { data[.searchIndex] = newValue }
    }
    
    public var remoteURL: URL? {
        get { return data[.remoteURL] as? URL }
        set { data[.remoteURL] = newValue }
    }
    
    public var artworkURL: URL? {
        get { return data[.artworkURL] as? URL }
        set { data[.artworkURL] = newValue }
    }
    
    public var providerToken: String? {
        get { return data[.providerToken] as? String }
        set { data[.providerToken] = newValue }
    }
    
    var quality: Double? {
        get { return data[.quality] as? Double }
        set { data[.quality] = newValue }
    }
}
