//
//  KugouResponseSearchResult.swift
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

struct KugouResponseSearchResult: Decodable {
    let candidates: [Item]
    
    /*
    let info: String
    let status: Int
    let proposal: String
    let keyword: String
     */
    
    struct Item: Decodable {
        let id: String
        let accesskey: String
        let song: String
        let singer: String
        let duration: Int // in msec
        
        /*
        let adjust: Int
        let hitlayer: Int
        let krctype: Int
        let language: String
        let nickname: String
        let originame: String
        let origiuid: String
        let score: Int
        let soundname: String
        let sounduid: String
        let transname: String
        let transuid: String
        let uid: String
         */
        
        // let parinfo: [Any]
    }
}
