//
//  Lyrics.swift
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

//private let id3TagPattern = "^(?!\\[[+-]?\\d+:\\d+(?:\\.\\d+)?\\])\\[(.+?):(.+)\\]$"
//private let id3TagRegex = try! NSRegularExpression(pattern: id3TagPattern, options: .anchorsMatchLines)

private let lyricsLinePattern = "^(\\[[+-]?\\d+:\\d+(?:\\.\\d+)?\\])+(?!\\[)([^【\\n\\r]*)(?:【(.*)】)?"
private let lyricsLineRegex = try! Regex(lyricsLinePattern, options: .anchorsMatchLines)

private let lyricsLineAttachmentPattern = "^(\\[[+-]?\\d+:\\d+(?:\\.\\d+)?\\])+\\[(.+?)\\](.*)"
private let lyricsLineAttachmentRegex = try! Regex(lyricsLineAttachmentPattern, options: .anchorsMatchLines)

final public class Lyrics: LosslessStringConvertible {
    
    public var lines: [LyricsLine] = []
    public var idTags: [IDTagKey: String] = [:]
    public var metadata: MetaData = MetaData()
    
    public init() {}
    
    public init?(_ description: String) {
        id3TagRegex.matches(in: description).forEach { match in
            if let key = match[1]?.content.trimmingCharacters(in: .whitespaces),
                let value = match[2]?.content.trimmingCharacters(in: .whitespaces),
                !value.isEmpty {
                idTags[.init(key)] = value
            }
        }
        
        lines = lyricsLineRegex.matches(in: description).flatMap { match -> [LyricsLine] in
            let timeTagStr = match[1]!.string
            let timeTags = resolveTimeTag(timeTagStr)
            
            let lyricsContentStr = match[2]!.string
            var line = LyricsLine(content: lyricsContentStr, position: 0)
            
            if let translationStr = match[3]?.string, !translationStr.isEmpty {
                line.attachments.setTranslation(translationStr)
            }
            
            return timeTags.map { timeTag in
                var l = line
                l.position = timeTag
                l.lyrics = self
                return l
            }
        }.sorted {
            $0.position < $1.position
        }
        
        var tags: Set<LyricsLine.Attachments.Tag> = []
        lyricsLineAttachmentRegex.matches(in: description).forEach { match in
            let timeTagStr = match[1]!.string
            let timeTags = resolveTimeTag(timeTagStr)
            
            let attachmentTagStr = match[2]!.string
            
            let attachmentStr = match[3]?.string ?? ""
            
            for timeTag in timeTags {
                if case let .found(at: index) = lineIndex(of: timeTag) {
                    lines[index].attachments[attachmentTagStr] = attachmentStr
                }
            }
            tags.insert(.init(attachmentTagStr))
        }
        metadata.data[.attachmentTags] = tags
        
        guard !lines.isEmpty else {
            return nil
        }
    }
    
    public var description: String {
        let components = idTags.map { "[\($0.key.rawValue):\($0.value)]" }
            + lines.map { $0.description }
        return components.joined(separator: "\n")
    }
    
    public var legacyDescription: String {
        let components = idTags.map { "[\($0.key.rawValue):\($0.value)]" } + lines.map { "[\($0.timeTag)]\($0.content)" + ($0.attachments.translation().map { "【\($0)】" } ?? "") }
        return components.joined(separator: "\n")
    }
    
    public struct IDTagKey: RawRepresentable, Hashable {
        
        public var rawValue: String
        
        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public static let title     = IDTagKey("ti")
        public static let album     = IDTagKey("al")
        public static let artist    = IDTagKey("ar")
        public static let author    = IDTagKey("au")
        public static let lrcBy     = IDTagKey("by")
        public static let offset    = IDTagKey("offset")
        public static let length    = IDTagKey("length")
    }
    
    public struct MetaData {
        
        public var data: [Key: Any] = [:]
        
        public struct Key: RawRepresentable, Hashable {
            
            public var rawValue: String
            
            public init(_ rawValue: String) {
                self.rawValue = rawValue
            }
            
            public init(rawValue: String) {
                self.rawValue = rawValue
            }
        }
    }
}

extension Lyrics {
    
    public var offset: Int {
        get {
            return idTags[.offset].flatMap { Int($0) } ?? 0
        }
        set {
            idTags[.offset] = "\(newValue)"
        }
    }
    
    public var timeDelay: TimeInterval {
        get {
            return TimeInterval(offset) / 1000
        }
        set {
            offset = Int(newValue * 1000)
        }
    }
    
    private static let base60TimePattern = "^\\s*(?:(\\d+):)?(\\d+(?:.\\d+)?)\\s*$"
    private static let base60TimeRegex = try! Regex(base60TimePattern)
    
    public var length: TimeInterval? {
        get {
            guard let len = idTags[.length],
                let match = Lyrics.base60TimeRegex.firstMatch(in: len) else {
                    return nil
            }
            let min = (match[1]?.content).flatMap(Double.init) ?? 0
            let sec = Double(match[2]!.content) ?? 0
            return min * 60 + sec
        }
        set {
            guard let newValue = newValue else {
                idTags.removeValue(forKey: .length)
                return
            }
            let fmt = NumberFormatter()
            fmt.minimumFractionDigits = 0
            fmt.maximumFractionDigits = 2
            let str = fmt.string(from: newValue as NSNumber)
            idTags[.length] = str
        }
    }
    
    fileprivate enum Match {
        case found(at: Int)
        case notFound(insertAt: Int)
    }
    
    fileprivate func lineIndex(of position: TimeInterval) -> Match {
        var left = 0
        var right = lines.count - 1
        
        while left <= right {
            let mid = (left + right) / 2
            let candidate = lines[mid]
            if candidate.position < position {
                left = mid + 1
            } else if position < candidate.position {
                right = mid - 1
            } else {
                return .found(at: mid)
            }
        }
        return .notFound(insertAt: left)
    }
    
    public subscript(_ position: TimeInterval) -> (currentLineIndex:Int?, nextLineIndex:Int?) {
        let index: Int
        switch lineIndex(of: position) {
        case let .found(at: i): index = i + 1
        case let .notFound(insertAt: i): index = i
        }
        let current = (0..<index).reversed().first { lines[$0].enabled }
        let next = lines[index...].firstIndex { $0.enabled }
        return (current, next)
    }
}

extension Lyrics {
    
    public func filtrate(isIncluded predicate: NSPredicate) {
        for (index, lyric) in lines.enumerated() {
            if !predicate.evaluate(with: lyric) {
                lines[index].enabled = false
            }
        }
    }
}

// MARK: CustomStringConvertible

extension Lyrics.MetaData: CustomStringConvertible {
    
    public var description: String {
        return Mirror(reflecting: self).children.map { "[\($0!):\($1)]" }.joined(separator: "\n")
    }
}

extension Lyrics.IDTagKey: CustomStringConvertible {
    
    public var description: String {
        return rawValue
    }
}
