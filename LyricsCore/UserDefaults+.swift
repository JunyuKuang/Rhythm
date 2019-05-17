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
    
    dynamic var showsLyricsTranslationIfAvailable: Bool {
        get {
            return value(forKey: "showsLyricsTranslationIfAvailable") as? Bool ?? true
        }
        set {
            set(newValue, forKey: "showsLyricsTranslationIfAvailable")
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
    
    /// Use `MPMediaItem.kjy_userSpecifiedSources` to set and get actual value.
    fileprivate(set) dynamic var userSpecifiedLyricsByMediaIDs: [String : Any] {
        get {
            return dictionary(forKey: "userSpecifiedLyricsByMediaIDs") ?? [:]
        }
        set {
            set(newValue, forKey: "userSpecifiedLyricsByMediaIDs")
        }
    }
}


public extension MPMediaItem {
    
    var kjy_userSpecifiedLyrics: Lyrics? {
        get {
            guard let rawLyrics = UserDefaults.appGroup.userSpecifiedLyricsByMediaIDs["\(persistentID)"] as? String,
                let lyrics = Lyrics(rawLyrics) else { return nil }
            return lyrics
        }
        set {
            UserDefaults.appGroup.userSpecifiedLyricsByMediaIDs["\(persistentID)"] = newValue?.description
        }
    }
}
