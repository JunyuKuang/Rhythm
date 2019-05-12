//
//  LyricsSourceIconDrawing+Image.swift
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

#if canImport(CoreGraphics)

    import CoreGraphics

    @available(OSX 10.10, iOS 8, tvOS 2, *)
    private extension LyricsProviderSource {
        
        var drawingMethod: ((CGRect) -> Void)? {
            switch self {
            case .netease:
                return LyricsSourceIconDrawing.drawNetEaseMusic
            case .gecimi:
                return LyricsSourceIconDrawing.drawGecimi
            case .kugou:
                return LyricsSourceIconDrawing.drawKugou
            case .qq:
                return LyricsSourceIconDrawing.drawQQMusic
            case .xiami:
                return LyricsSourceIconDrawing.drawXiami
            default:
                return nil
            }
        }
        
    }
    
#endif

#if canImport(Cocoa)
    
    import Cocoa
    
    extension LyricsSourceIconDrawing {
        
        public static let defaultSize = CGSize(width: 48, height: 48)
        
        public static func icon(of source: LyricsProviderSource, size: CGSize = defaultSize) -> NSImage {
            return NSImage(size: size, flipped: false) { (NSRect) -> Bool in
                source.drawingMethod?(CGRect(origin: .zero, size: size))
                return true
            }
        }
    }
    
#elseif canImport(UIKit)
    
    import UIKit
    
    extension LyricsSourceIconDrawing {
        
        public static let defaultSize = CGSize(width: 48, height: 48)
        
        public static func icon(of source: LyricsProviderSource, size: CGSize = defaultSize) -> UIImage {
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            source.drawingMethod?(CGRect(origin: .zero, size: size))
            let image = UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(.alwaysOriginal)
            UIGraphicsEndImageContext()
            return image ?? UIImage()
        }
    }

#endif
