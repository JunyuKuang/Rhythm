//
//  DebugPrint.swift
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

#if DEBUG

public func dprint(file: String = #file, line: Int = #line, function: String = #function) {
    print(file.components(separatedBy: "/").last!, "\(line)", function)
}

public func dprint(file: String = #file, line: Int = #line, function: String = #function, _ item: @autoclosure () -> Any) {
    print(file.components(separatedBy: "/").last!, "\(line)", function, "\(item())")
}

public func dprint(file: String = #file, line: Int = #line, function: String = #function, _ items: Any...) {
    var itemStrings = ""
    if items.count > 1 {
        items.forEach {
            itemStrings += "\($0) "
        }
    } else if let item = items.first {
        itemStrings = "\(item)"
    }
    print(file.components(separatedBy: "/").last!, "\(line)", function, itemStrings)
}

#else

public func dprint() {
}

public func dprint(_ item: @autoclosure () -> Any) {
}

public func dprint(_ items: Any...) {
}

#endif
