//
//  QQResponseSearchResult.swift
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

struct QQResponseSearchResult: Decodable {
    let data: Data
    let code: Int
    
    /*
    let message: String
    let notice: String
    let subcode: Int
    let time: Int // time stamp
    let tips: String
     */
    
    struct Data: Decodable {
        let song: Song
        
        /*
        let keyword: String
         ...
         */
        
        struct Song: Decodable {
            let list: [Item]
            
            /*
            let curnum: Int
            let curpage: Int
            let totalnum: Int
             */
            
            struct Item: Decodable {
                let songmid: String
                let songname: String
                let albumname: String
                let singer: [Singer]
                let interval: Int
                
                /*
                let albummid: String
                let albumname_hilight: String
                let alertid: Int
                let belongCD: Int
                let cdIdx: Int
                let chinesesinger: Int
                let docid: String
                let format: String
                let isonly: Int
                let lyric: String
                let lyric_hilight: String
                let media_mid: String
                let msgid: Int
                let newStatus: Int
                let nt: Int
                let pay: Pay
                let preview: Preview
                let pubtime: Int
                let pure: Int
                let size128: Int
                let size320: Int
                let sizeape: Int
                let sizeflac: Int
                let sizeogg: Int
                let songid: Int
                let songname_hilight: String
                let songurl: URL?
                let strMediaMid: String
                let stream: Int
                let `switch`: Int
                let t: Int
                let tag: Int
                let type: Int
                let ver: Int
                let vid: String
                 */
                
                // let grp: [Any]
                
                struct Pay: Decodable {
                    let payalbum: Int
                    let payalbumprice: Int
                    let paydownload: Int
                    let payinfo: Int
                    let payplay: Int
                    let paytrackmouth: Int
                    let paytrackprice: Int
                }
                
                struct Preview: Decodable {
                    let trybegin: Int
                    let tryend: Int
                    let trysize: Int
                }
                
                struct Singer: Decodable {
                    let name: String
                    
                    /*
                    let id: Int
                    let mid: String
                    let name_hilight: String
                     */
                }
            }
        }
    }
}

extension QQResponseSearchResult {
    
    var songs: [Data.Song.Item] {
        return data.song.list
    }
}
