//
//  UIView+Constraints.swift
//
//  Rhythm <https://github.com/JunyuKuang/Rhythm>
//  Copyright (C) 2019  Junyu Kuang
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

#if os(iOS)

import UIKit
public typealias AutoLayoutView = UIView

#elseif os(macOS)

import AppKit
public typealias AutoLayoutView = NSView

#endif

#if os(iOS) || os(macOS)
public extension AutoLayoutView {
    
    @discardableResult
    func addConstraintsToFitSuperview() -> (leading: NSLayoutConstraint, top: NSLayoutConstraint, trailing: NSLayoutConstraint, bottom: NSLayoutConstraint) {
        
        guard let superview = superview else {
			fatalError("\(self): No superview.")
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        let leading  = leadingAnchor.constraint(equalTo: superview.leadingAnchor)
        let top      = topAnchor.constraint(equalTo: superview.topAnchor)
        let trailing = superview.trailingAnchor.constraint(equalTo: trailingAnchor)
        let bottom   = superview.bottomAnchor.constraint(equalTo: bottomAnchor)
        
        NSLayoutConstraint.activate([leading, top, trailing, bottom])
        
        return (leading, top, trailing, bottom)
    }
}
#endif
