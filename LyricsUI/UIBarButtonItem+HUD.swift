//
//  UIBarButtonItem+HUD.swift
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

public extension UIBarButtonItem {
    
    /// The title for VoiceOver and iOS 11 accessibility HUD view.
    var hudTitle: String? {
        get {
            return accessibilityLabel
        }
        set {
            accessibilityLabel = newValue
            if #available(iOS 11.0, *) {
                self.title = newValue
            }
        }
    }
}
