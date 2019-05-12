//
//  Dictionary+HttpParameter.swift
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

extension Dictionary where Key == String {
    
    var stringFromHttpParameters: String {
        let parameterArray = self.map { (key, value) -> String in
            let escapedKey = key.addingPercentEncoding(withAllowedCharacters: .uriComponentAllowed)!
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .uriComponentAllowed)!
            return escapedKey + "=" + escapedValue
        }
        return parameterArray.joined(separator: "&")
    }
}

extension CharacterSet {
    
    static var uriComponentAllowed: CharacterSet {
        // [-._~0-9a-zA-Z] in RFC 3986
        let unsafe = CharacterSet(charactersIn: "!*'();:&=+$,[]~")
        return CharacterSet.urlHostAllowed.subtracting(unsafe)
    }
}
