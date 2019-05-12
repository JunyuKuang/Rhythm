//
//  DebugPrint.swift
//  Screenshots
//
//  Created by Jonny on 3/13/16.
//  Copyright © 2016 Jonny. All rights reserved.
//

#if !os(watchOS)

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

#else

public func dprint(file: String = #file, line: Int = #line, function: String = #function) {
    let log = [file.components(separatedBy: "/").last!, "\(line)", function].joined(separator: " ")
    printForDebug(log)
    Log.add(log)
}

public func dprint(file: String = #file, line: Int = #line, function: String = #function, _ item: @autoclosure () -> Any) {
    let log = [file.components(separatedBy: "/").last!, "\(line)", function, "\(item())"].joined(separator: " ")
    printForDebug(log)
    Log.add(log)
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
    let log = [file.components(separatedBy: "/").last!, "\(line)", function, itemStrings].joined(separator: " ")
    printForDebug(log)
    Log.add(log)
}

private func printForDebug(_ log: String) {
    #if DEBUG
    print(log)
    #endif
}

#endif
