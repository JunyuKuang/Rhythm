//
//  LyricsLine.swift
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

public struct LyricsLine {
    
    public var content: String
    public var position: TimeInterval
    public var attachments: Attachments
    public var enabled: Bool = true
    
    public weak var lyrics: Lyrics?
    
    public var timeTag: String {
        let min = Int(position / 60)
        let sec = position - TimeInterval(min * 60)
        return String(format: "%02d:%06.3f", min, sec)
    }
    
    public init(content: String, position: TimeInterval, attachments: Attachments = Attachments()) {
        self.content = content
        self.position = position
        self.attachments = attachments
    }
}

extension LyricsLine: Equatable {
    
    public static func ==(lhs: LyricsLine, rhs: LyricsLine) -> Bool {
        return lhs.content == rhs.content &&
            lhs.position == rhs.position &&
            // TODO: check attachments
            // lhs.attachments == rhs.attachments &&
            lhs.enabled == rhs.enabled
    }
}

extension LyricsLine: CustomStringConvertible {
    
    public var description: String {
        return ([content] + attachments.content.map { "[\($0.key)]\($0.value)" }).map {
            "[\(timeTag)]\($0)"
        }.joined(separator: "\n")
    }
}
