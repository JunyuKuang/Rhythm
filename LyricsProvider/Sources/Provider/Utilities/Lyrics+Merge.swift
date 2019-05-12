//
//  Lyrics+Merge.swift
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

private let mergeTimetagThreshold = 0.02

extension Lyrics {
    
    func merge(translation: Lyrics) {
        var index = lines.startIndex
        var transIndex = translation.lines.startIndex
        while index < lines.endIndex, transIndex < translation.lines.endIndex {
            if abs(lines[index].position - translation.lines[transIndex].position) < mergeTimetagThreshold {
                let transStr = translation.lines[transIndex].content
                if !transStr.isEmpty {
                    lines[index].attachments.setTranslation(transStr)
                }
                lines.formIndex(after: &index)
                translation.lines.formIndex(after: &transIndex)
            } else if lines[index].position > translation.lines[transIndex].position {
                translation.lines.formIndex(after: &transIndex)
            } else {
                lines.formIndex(after: &index)
            }
        }
        metadata.attachmentTags.insert(.translation)
    }
    
    /// merge without maching timetag
    func forceMerge(translation: Lyrics) {
        guard lines.count == translation.lines.count else {
            return
        }
        for idx in lines.indices {
            let transStr = translation.lines[idx].content
            if !transStr.isEmpty {
                lines[idx].attachments.setTranslation(transStr)
            }
        }
        metadata.attachmentTags.insert(.translation)
    }
}
