//
//  LyricsMetadata.swift
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
    public static var source        = Lyrics.MetaData.Key("source")
    public static var attachmentTags = Lyrics.MetaData.Key("attachmentTags")
}

extension Lyrics.MetaData {
    
    public var source: LyricsProviderSource? {
        get { return data[.source] as? LyricsProviderSource }
        set { data[.source] = newValue }
    }
    
    public var attachmentTags: Set<LyricsLine.Attachments.Tag> {
        get { return data[.attachmentTags] as? Set<LyricsLine.Attachments.Tag> ?? [] }
        set { data[.attachmentTags] = newValue }
    }
    
    public var hasTranslation: Bool {
        return attachmentTags.contains { tag in
            tag.isTranslation
        }
    }
}
