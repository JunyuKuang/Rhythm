//
//  Then.swift
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

protocol Then {}

extension Then where Self: Any {
    
    func with(_ block: (inout Self) throws -> Void) rethrows -> Self {
        var copy = self
        try block(&copy)
        return copy
    }
    
    func `do`<T>(_ block: (Self) throws -> T) rethrows -> T {
        return try block(self)
    }
}

extension Then where Self: AnyObject {
    
    func then(_ block: (Self) throws -> Void) rethrows -> Self {
        try block(self)
        return self
    }
}

#if canImport(Foundation)

import Foundation

extension NSObject: Then {}

#endif

#if canImport(CoreGraphics)

import CoreGraphics

extension CGPoint: Then {}
extension CGVector: Then {}
extension CGSize: Then {}
extension CGRect: Then {}
extension CGAffineTransform: Then {}

#endif

#if canImport(UIKit)

import UIKit.UIGeometry

extension UIEdgeInsets: Then {}
extension UIOffset: Then {}
extension UIRectEdge: Then {}

#endif

#if canImport(AppKit)

import AppKit

extension NSRectEdge: Then {}
extension NSEdgeInsets: Then {}
extension AlignmentOptions: Then {}

#endif

