//
//  UIViewController+performIfViewSizeChanged.swift
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

public extension UIViewController {
    
    private static var cachedViewSizeToken = 0
    
    private var cachedViewSizesByTaskNames: [String : CGSize] {
        get {
            return objc_getAssociatedObject(self, &UIViewController.cachedViewSizeToken) as? [String : CGSize] ?? [:]
        }
        set {
            objc_setAssociatedObject(self, &UIViewController.cachedViewSizeToken, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func performIfViewSizeChanged(file: String = #file, line: Int = #line, handler: () -> Void) {
        let taskName = file.components(separatedBy: "/").last! + "\(line)"
        guard cachedViewSizesByTaskNames[taskName] != view.bounds.size else { return }
        cachedViewSizesByTaskNames[taskName] = view.bounds.size
        handler()
    }
}
