//
//  NetEaseResponseSingleLyrics.swift
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

struct NetEaseResponseSingleLyrics: Decodable {
    let lrc: Lyric?
    let klyric: Lyric?
    let tlyric: Lyric?
    let lyricUser: User?
    
    /*
    let sgc: Bool
    let sfy: Bool
    let qfy: Bool
    let code: Int
    let transUser: User
     */
    
    struct User: Decodable {
        let nickname: String
        
        /*
        let id: Int
        let status: Int
        let demand: Int
        let userid: Int
        let uptime: Int
         */
    }
    
    struct Lyric: Decodable {
        let lyric: String?
        
        /*
        let version: Int
         */
    }
}
