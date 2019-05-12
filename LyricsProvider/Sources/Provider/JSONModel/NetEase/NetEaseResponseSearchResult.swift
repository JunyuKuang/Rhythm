//
//  NetEaseResponseSearchResult.swift
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

struct NetEaseResponseSearchResult: Decodable {
    let result: Result
    let code: Int
    
    struct Result: Decodable {
        let songs: [Song]
        let songCount: Int
        
        struct Song: Decodable {
            let name: String
            let id: Int
            let duration: Int // msec
            let artists: [NetEaseResponseModelArtist]
            let album: NetEaseResponseModelAlbum
            
            /*
            let position: Int
            let status: Int
            let fee: Int
            let copyrightId: Int
            let disc: String // Int
            let no: Int
            let starred: Bool
            let popularity: Int
            let score: Int
            let starredNum: Int
            let playedNum: Int
            let dayPlays: Int
            let hearTime: Int
            let copyFrom: String
            let commentThreadId: String
            let ftype: Int
            let copyright: Int
            let mvid: Int
            let hMusic: NetEaseResponseModelMusic
            let mMusic: NetEaseResponseModelMusic
            let lMusic: NetEaseResponseModelMusic
            let bMusic: NetEaseResponseModelMusic
            let mp3Url: URL?
            let rtype: Int
             */
            
            // let alias: [Any],
            // let ringtone: Any?
            // let crbt: Any?
            // let audition: Any?
            // let rtUrl: Any?
            // let rtUrls: [Any]
//            let rurl: Any?
        }
    }
}

struct NetEaseResponseModelArtist: Decodable {
    let name: String
    let id: Int
    
    /*
    let picId: Int
    let img1v1Id: Int
    let briefDesc: String
    let picUrl: URL?
    let img1v1Url: URL?
    let albumSize: Int
    let trans: String
    let musicSize: Int
     */
    
    //  let alias: [Any]
}

struct NetEaseResponseModelAlbum: Decodable {
    let name: String
    let id: Int
    let picUrl: URL?
    
    /*
    let type: String
    let size: Int
    let picId: Int
    let blurPicUrl: URL?
    let companyId: Int
    let pic: Int
    let publishTime: Int
    let description: String
    let tags: String
    let company: String
    let briefDesc: String
    let artist: NetEaseResponseModelArtist
    let status: Int
    let copyrightId: Int
    let commentThreadId: String
    let artists: [NetEaseResponseModelArtist]
     */
 
    // let songs: [Any]
    // let alias: [Any]
}

struct NetEaseResponseModelMusic: Decodable {
    /*
    let id: Int
    let size: Int
    let `extension`: String
    let sr: Int
    let dfsId: Int
    let bitrate: Int
    let playTime: Int
    let volumeDelta: Double
     */
    
    // let name: Any?
}

extension NetEaseResponseSearchResult {
    var songs: [Result.Song] {
        return result.songs
    }
}
