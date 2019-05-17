//
//  Bundle+.swift
//  LyricsUI
//
//  Created by Jonny Kuang on 5/17/19.
//  Copyright © 2019 Jonny Kuang. All rights reserved.
//

extension Bundle {
    private class Placeholder {}
    static let current = Bundle(for: Placeholder.self)
}


/// Equivalent to `NSLocalizedString(key, tableName: tableName, bundle: bundle, comment: "")`.
///
/// - Parameters:
///   - key: The key for a string.
///   - tableName: Default is nil.
///   - bundle: Default is `Bundle.current`.
/// - Returns: A localized string.
func localized(_ key: String, tableName: String? = nil, bundle: Bundle = .current) -> String {
    return NSLocalizedString(key, tableName: tableName, bundle: bundle, comment: "")
}


/// Equivalent to `UIImage(named: name, in: Bundle.current, compatibleWith: nil)`.
///
/// - Parameter name: The name of the image. For images in asset catalogs, specify the name of the image asset. For PNG image files, specify the filename without the filename extension. For all other image file formats, include the filename extension in the name.
/// - Returns: The image object with the given name, or nil if no suitable image was found.
func img(_ name: String) -> UIImage? {
    return UIImage(named: name, in: Bundle.current, compatibleWith: nil)
}
