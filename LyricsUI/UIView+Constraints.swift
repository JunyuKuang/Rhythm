//
//  UIView+Constraints.swift
//
//  Created by Jonny on 3/3/17.
//  Copyright © 2017 Jonny. All rights reserved.
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
