//
//  UserDefaults+.swift
//  LyricsCore
//
//  Created by Jonny Kuang on 5/16/19.
//  Copyright © 2019 Jonny Kuang. All rights reserved.
//

public extension UserDefaults {
    static let appGroup = UserDefaults(suiteName: "group.com.jonny.lyrics")!
}


public extension UserDefaults {
    
    /// KVO observable.
    @objc dynamic var showsLyricsTranslationIfAvailable: Bool {
        get {
            return value(forKey: "showsLyricsTranslationIfAvailable") as? Bool ?? true
        }
        set {
            set(newValue, forKey: "showsLyricsTranslationIfAvailable")
        }
    }
    
    /// KVO observable. Use `MPMediaItem.kjy_userSpecifiedSources` to retrieve latest update.
    @objc dynamic var userSpecifiedSourcesByMediaIDs: [String : String] {
        get {
            return dictionary(forKey: "userSpecifiedSourcesByMediaIDs") as? [String : String] ?? [:]
        }
        set {
            set(newValue, forKey: "userSpecifiedSourcesByMediaIDs")
        }
    }
}


public extension MPMediaItem {
    
    var kjy_userSpecifiedSources: LyricsProviderSource? {
        get {
            guard let sourceValue = UserDefaults.appGroup.userSpecifiedSourcesByMediaIDs["\(persistentID)"],
                let source = LyricsProviderSource(rawValue: sourceValue) else { return nil }
            return source
        }
        set {
            UserDefaults.appGroup.userSpecifiedSourcesByMediaIDs["\(persistentID)"] = newValue?.rawValue
        }
    }
}
