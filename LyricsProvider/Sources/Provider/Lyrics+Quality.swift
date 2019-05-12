//
//  Lyrics+Quality.swift
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


private let translationFactor = 0.1
private let wordTimeTagFactor = 0.1
private let matchedArtistFactor = 1.3
private let matchedTitleFactor = 1.5
private let noArtistFactor = 0.7
private let noTitleFactor = 0.7
private let noDurationFactor = 0.7

extension Lyrics {
    
    public var quality: Double {
        if let quality = metadata.quality {
            return quality
        }
        var quality = artistQuality + titleQuality + durationQuality
        if metadata.hasTranslation {
            quality += translationFactor
        }
        if metadata.attachmentTags.contains(.timetag) {
            quality += wordTimeTagFactor
        }
        metadata.quality = quality
        return quality
    }
    
    public func isMatched() -> Bool {
        guard let artist = idTags[.artist],
            let title = idTags[.title] else {
            return false
        }
        switch metadata.request?.searchTerm {
        case let .info(searchTitle, searchArtist)?:
            return title.isCaseInsensitiveSimilar(to: searchTitle)
                && artist.isCaseInsensitiveSimilar(to: searchArtist)
        case let .keyword(keyword)?:
            return title.isCaseInsensitiveSimilar(to: keyword)
                && artist.isCaseInsensitiveSimilar(to: keyword)
        case nil:
            return false
        }
    }
    
    private var artistQuality: Double {
        guard let artist = idTags[.artist] else { return noArtistFactor }
        switch metadata.request?.searchTerm {
        case let .info(_, searchArtist)?:
            if artist == searchArtist { return matchedArtistFactor }
            return similarity(s1: artist, s2: searchArtist)
        case let .keyword(keyword)?:
            if keyword.contains(artist) { return matchedArtistFactor }
            return similarity(s1: artist, in: keyword)
        case nil:
            return noArtistFactor
        }
    }
    
    private var titleQuality: Double {
        guard let title = idTags[.title] else { return noTitleFactor }
        switch metadata.request?.searchTerm {
        case let .info(searchTitle, _)?:
            if title == searchTitle { return matchedTitleFactor }
            return similarity(s1: title, s2: searchTitle)
        case let .keyword(keyword)?:
            if keyword.contains(title) { return matchedTitleFactor }
            return similarity(s1: title, in: keyword)
        case nil:
            return noTitleFactor
        }
    }
    
    private var durationQuality: Double {
        guard let duration = length,
            let searchDuration = metadata.request?.duration else {
                return noDurationFactor
        }
        let dt = searchDuration - duration
        switch abs(dt) {
        case 0...1:
            return 1
        case 1...4:
            return 0.9
        case 4...10:
            return 0.8
        case _:
            return 0.7
        }
    }
}

private extension String {
    
    func distance(to other: String, substitutionCost: Int = 1, insertionCost: Int = 1, dedeletionCostl: Int = 1) -> Int {
        var d = Array(0...other.count)
        var t = 0
        for c1 in self {
            t = d[0]
            d[0] += 1
            for (i, c2) in other.enumerated() {
                let t2 = d[i+1]
                if c1 == c2 {
                    d[i+1] = t
                } else {
                    d[i+1] = Swift.min(t + substitutionCost, d[i] + insertionCost, t2 + dedeletionCostl)
                }
                t = t2
            }
        }
        return d.last!
    }
    
    func isCaseInsensitiveSimilar(to string: String) -> Bool {
        let s1 = lowercased()
        let s2 = string.lowercased()
        return s1.contains(s2) || s2.contains(s1)
    }
}

private func similarity(s1: String, s2: String) -> Double {
    let len = min(s1.count, s2.count)
    let diff = min(s1.distance(to: s2, insertionCost: 0), s1.distance(to: s2, dedeletionCostl: 0))
    return Double(len - diff) / Double(len)
}

private func similarity(s1: String, in s2: String) -> Double {
    let len = max(s1.count, s2.count)
    guard len > 0 else { return 1 }
    let diff = s1.distance(to: s2, insertionCost: 0)
    return Double(len - diff) / Double(len)
}
