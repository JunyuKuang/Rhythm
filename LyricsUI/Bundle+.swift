//
//  Bundle+.swift
//
//  Rhythm <https://github.com/JunyuKuang/Rhythm>
//  Copyright (C) 2019-2020  Junyu Kuang
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
