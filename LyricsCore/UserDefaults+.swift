//
//  UserDefaults+.swift
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

public extension UserDefaults {
    static let appGroup = UserDefaults(suiteName: "group.com.jonny.lyrics")!
}


@objc public extension UserDefaults {
    
    dynamic var disablesIdleTimer: Bool {
        get {
            if let value = value(forKey: "disablesIdleTimer") as? Bool {
                return value
            }
            self.disablesIdleTimer = false
            return false
        }
        set {
            set(newValue, forKey: "disablesIdleTimer")
        }
    }
    
    dynamic var showsLyricsTranslationIfAvailable: Bool {
        get {
            if let value = value(forKey: "showsLyricsTranslationIfAvailable") as? Bool {
                return value
            }
            self.showsLyricsTranslationIfAvailable = true
            return true
        }
        set {
            set(newValue, forKey: "showsLyricsTranslationIfAvailable")
        }
    }
    
    dynamic var maximumNotificationCount: Int {
        get {
            if let value = value(forKey: "maximumNotificationCount") as? Int {
                return value
            }
            self.maximumNotificationCount = 3
            return 3
        }
        set {
            set(newValue, forKey: "maximumNotificationCount")
        }
    }
    
    dynamic var allowsNowPlayingItemNotification: Bool {
        get {
            if let value = value(forKey: "allowsNowPlayingItemNotification") as? Bool {
                return value
            }
            self.allowsNowPlayingItemNotification = true
            return true
        }
        set {
            set(newValue, forKey: "allowsNowPlayingItemNotification")
        }
    }
    
    dynamic var prefersCenterAlignedLayout: Bool {
        get {
            if let value = value(forKey: "prefersCenterAlignedLayout") as? Bool {
                return value
            }
            self.prefersCenterAlignedLayout = false
            return false
        }
        set {
            set(newValue, forKey: "prefersCenterAlignedLayout")
        }
    }
    
    /// Use `MPMediaItem.kjy_userSpecifiedSources` to set and get actual value.
    fileprivate(set) dynamic var userSpecifiedLyricsByMediaIDs: [String : Any] {
        get {
            if let value = dictionary(forKey: "userSpecifiedLyricsByMediaIDs") {
                return value
            }
            self.userSpecifiedLyricsByMediaIDs = [:]
            return [:]
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
