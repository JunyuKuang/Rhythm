//
//  KugouKrcDecrypter.swift
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

private let decodeKey: [UInt8] = [64, 71, 97, 119, 94, 50, 116, 71, 81, 54, 49, 45, 206, 210, 110, 105]
private let flagKey = "krc1".data(using: .ascii)!

func decryptKugouKrc(_ data: Data) -> String? {
    guard data.starts(with: flagKey) else {
        return nil
    }
    
    let decrypted = data.dropFirst(4).enumerated().map { index, byte in
        return byte ^ decodeKey[index & 0b1111]
    }
    
    guard let unarchivedData = try? Data(decrypted).gunzipped() else {
        return nil
    }
    
    return String(bytes: unarchivedData, encoding: .utf8)
}
