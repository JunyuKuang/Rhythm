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


@objc public extension UserDefaults {
    
    /// KVO observable.
    dynamic var showsLyricsTranslationIfAvailable: Bool {
        get {
            return value(forKey: "showsLyricsTranslationIfAvailable") as? Bool ?? true
        }
        set {
            set(newValue, forKey: "showsLyricsTranslationIfAvailable")
        }
    }
    
    /// KVO observable. Use `MPMediaItem.kjy_userSpecifiedSources` to retrieve latest update.
    dynamic var userSpecifiedSourcesByMediaIDs: [String : Any] {
        get {
            return dictionary(forKey: "userSpecifiedSourcesByMediaIDs") ?? [:]
        }
        set {
            set(newValue, forKey: "userSpecifiedSourcesByMediaIDs")
        }
    }
    
    dynamic var maximumNotificationCount: Int {
        get {
            return value(forKey: "maximumNotificationCount") as? Int ?? 3
        }
        set {
            set(newValue, forKey: "maximumNotificationCount")
        }
    }
    
    dynamic var allowsNowPlayingItemNotification: Bool {
        get {
            return value(forKey: "allowsNowPlayingItemNotification") as? Bool ?? true
        }
        set {
            set(newValue, forKey: "allowsNowPlayingItemNotification")
        }
    }
    
    dynamic var prefersCenterAlignedLayout: Bool {
        get {
            return bool(forKey: "prefersCenterAlignedLayout")
        }
        set {
            set(newValue, forKey: "prefersCenterAlignedLayout")
        }
    }
}


public extension MPMediaItem {
    
    var kjy_userSpecifiedSource: LyricsProviderSource? {
        get {
            guard let sourceValue = UserDefaults.appGroup.userSpecifiedSourcesByMediaIDs["\(persistentID)"] as? String,
                let source = LyricsProviderSource(rawValue: sourceValue) else { return nil }
            return source
        }
        set {
            UserDefaults.appGroup.userSpecifiedSourcesByMediaIDs["\(persistentID)"] = newValue?.rawValue
        }
    }
}
