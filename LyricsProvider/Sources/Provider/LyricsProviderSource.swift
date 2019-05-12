//
//  LyricsProviderSource.swift
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

public enum LyricsProviderSource: String, CaseIterable {
    case netease = "163"
    case qq = "QQMusic"
    case kugou = "Kugou"
    case xiami = "Xiami"
    case gecimi = "Gecimi"
    case viewLyrics = "ViewLyrics"
    case syair = "Syair"
}

extension LyricsProviderSource {
    
    var cls: LyricsProvider.Type {
        switch self {
        case .netease:  return LyricsNetEase.self
        case .qq:       return LyricsQQ.self
        case .kugou:    return LyricsKugou.self
        case .xiami:    return LyricsXiami.self
        case .gecimi:   return LyricsGecimi.self
        case .viewLyrics: return ViewLyrics.self
        case .syair:    return LyricsSyair.self
        }
    }
}
