//
//  String+XMLDecode.swift
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

extension String {
    
    func decodingXMLEntities() -> String {
        #if os(macOS)
            return CFXMLCreateStringByUnescapingEntities(kCFAllocatorDefault, self as CFString, nil) as String
        #else
            // FIXME: low performance
            return String.xmlEntities.reduce(self) { $0.replacingOccurrences(of: $1.0, with: $1.1) }
        #endif
    }
    
    func encodingXMLEntities() -> String {
        #if os(macOS)
            return CFXMLCreateStringByEscapingEntities(kCFAllocatorDefault, self as CFString, nil) as String
        #else
            // FIXME: low performance
            return String.xmlEntities.reversed().reduce(self) { $0.replacingOccurrences(of: $1.1, with: $1.0) }
        #endif
    }
    
    static let xmlEntities = [
        "&quot;":   "\"",
        "&apos;":   "'",
        "&lt;":     "<",
        "&gt;":     ">",
        "&amp;":    "&",
        ]
}
