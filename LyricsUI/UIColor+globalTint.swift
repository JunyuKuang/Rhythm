//
//  UIColor+globalTint.swift
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

public extension UIColor {
    /// match Apple Music
    static var globalTint: UIColor = {
        if #available(iOS 13, *) {
            return .systemPink
        }
        return UIColor(red: 1, green: 45/255, blue: 85/255, alpha: 1)
    }()
    
    static let highContrastiveGlobalTint = UIColor.kjy_label
}
