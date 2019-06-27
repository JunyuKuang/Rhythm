//
//  UIColor+.swift
//  LyricsUI
//
//  Created by Jonny Kuang on 6/27/19.
//  Copyright © 2019 Jonny Kuang. All rights reserved.
//

public extension UIColor {
    
    static let kjy_systemBackground: UIColor = {
        guard #available(iOS 13, *) else { return .white }
        return .systemBackground
    }()
    
    static let kjy_label: UIColor = {
        guard #available(iOS 13, *) else { return .darkText }
        return .label
    }()
}
