//
//  NetEaseKLyricParser.swift
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

extension Lyrics {
    
    convenience init?(netEaseKLyricContent content: String) {
        self.init()
        id3TagRegex.matches(in: content).forEach { match in
            if let key = match[1]?.content.trimmingCharacters(in: .whitespaces),
                let value = match[2]?.content.trimmingCharacters(in: .whitespaces),
                !key.isEmpty,
                !value.isEmpty {
                idTags[.init(key)] = value
            }
        }
        
        lines = krcLineRegex.matches(in: content).map { match in
            let timeTagStr = match[1]!.string
            let timeTag = TimeInterval(timeTagStr)! / 1000
            
            let durationStr = match[2]!.string
            let duration = TimeInterval(durationStr)! / 1000
            
            var lineContent = ""
            var attachment = LyricsLine.Attachments.WordTimeTag(tags: [.init(timeTag: 0, index: 0)], duration: duration)
            var dt = 0.0
            netEaseInlineTagRegex.matches(in: content, range: match[3]!.range).forEach { m in
                let timeTagStr = m[1]!.string
                var timeTag = TimeInterval(timeTagStr)! / 1000
                var fragment = m[2]!.string
                if m[3] != nil {
                    timeTag += 0.001
                    fragment += " "
                }
                lineContent += fragment
                dt += timeTag
                attachment.tags.append(.init(timeTag: dt, index: lineContent.count))
            }
            
            let att = LyricsLine.Attachments(attachments: [.timetag: attachment])
            var line = LyricsLine(content: lineContent, position: timeTag, attachments: att)
            line.lyrics = self
            return line
        }
        metadata.attachmentTags.insert(.timetag)
        
        guard !lines.isEmpty else {
            return nil
        }
    }
}
