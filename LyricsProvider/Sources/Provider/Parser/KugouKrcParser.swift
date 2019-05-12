//
//  KugouKrcParser.swift
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
    
    convenience init?(kugouKrcContent content: String) {
        self.init()
        var languageHeader: KugouKrcHeaderFieldLanguage?
        id3TagRegex.matches(in: content).forEach { match in
            guard let key = match[1]?.content.trimmingCharacters(in: .whitespaces),
                let value = match[2]?.content.trimmingCharacters(in: .whitespaces),
                !key.isEmpty,
                !value.isEmpty else {
                    return
            }
            if key == "language" {
                if let data = Data(base64Encoded: value) {
                    // TODO: error handler
                    languageHeader = try? JSONDecoder().decode(KugouKrcHeaderFieldLanguage.self, from: data)
                }
            } else {
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
            kugouInlineTagRegex.matches(in: content, range: match[3]!.range).forEach { m in
                let t1 = Int(m[1]!.content)!
                let t2 = Int(m[2]!.content)!
                let t = TimeInterval(t1 + t2) / 1000
                let fragment = m[3]!.content
                lineContent += fragment
                attachment.tags.append(.init(timeTag: t, index: lineContent.count))
            }
            
            let att = LyricsLine.Attachments(attachments: [.timetag: attachment])
            var line = LyricsLine(content: lineContent, position: timeTag, attachments: att)
            line.lyrics = self
            return line
        }
        metadata.attachmentTags.insert(.timetag)
        
        // TODO: multiple translation
        if let transContent = languageHeader?.content.first?.lyricContent {
            transContent.prefix(lines.count).enumerated().forEach { index, item in
                guard !item.isEmpty else { return }
                let str = item.joined(separator: " ")
                lines[index].attachments.setTranslation(str)
            }
            metadata.attachmentTags.insert(.translation)
        }
        
        guard !lines.isEmpty else {
            return nil
        }
    }
}
