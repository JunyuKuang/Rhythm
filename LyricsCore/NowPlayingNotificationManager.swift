//
//  NowPlayingNotificationManager.swift
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

public class NowPlayingNotificationManager {
    
    public static let shared = NowPlayingNotificationManager()
    
    private init() {
        let player = MPMusicPlayerController.systemMusicPlayer
        let lyricsController = SystemPlayerLyricsController.shared
        let notificationController = LyricsNotificationController.shared
        
        player.beginGeneratingPlaybackNotifications()
        notificationController.clearNotifications()
        
        NotificationCenter.default.addObserver(forName: .MPMusicPlayerControllerNowPlayingItemDidChange, object: player, queue: .main) { _ in
            notificationController.clearNotifications()
            if let item = player.nowPlayingItem {
                self.postNotificationIfAllowed(forNowPlayingItem: item)
            }
        }
        NotificationCenter.default.addObserver(forName: .MPMusicPlayerControllerPlaybackStateDidChange, object: player, queue: .main) { _ in
            switch player.playbackState {
            case .seekingBackward, .seekingForward, .stopped:
                LyricsNotificationController.shared.clearNotifications()
            default:
                break
            }
        }
        NotificationCenter.default.addObserver(forName: SystemPlayerLyricsController.nowPlayingLyricsDidChangeNotification, object: nil, queue: .main) { _ in
            notificationController.clearNotifications()
        }
        NotificationCenter.default.addObserver(forName: SystemPlayerLyricsController.lyricsLineDidChangeNotification, object: nil, queue: .main) { _ in
            if let line = lyricsController.currentLyricsLine {
                notificationController.postIfNeeded(lyricsLine: line)
            }
        }
        
        _ = UserDefaults.appGroup.allowsNowPlayingItemNotification
        kvoObservers = [
            UserDefaults.appGroup.observe(\.allowsNowPlayingItemNotification) { _, _ in
                self.allowsNowPlayingItemNotification = UserDefaults.appGroup.allowsNowPlayingItemNotification
            },
        ]
    }
    
    private var kvoObservers = [NSKeyValueObservation]()
    
    private var allowsNowPlayingItemNotification = UserDefaults.appGroup.allowsNowPlayingItemNotification {
        didSet {
            if !allowsNowPlayingItemNotification {
                UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [nowPlayingNotificationIdentifier])
            } else if let item = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem {
                postNotificationIfAllowed(forNowPlayingItem: item)
            }
        }
    }
    
    private let nowPlayingNotificationIdentifier = "nowPlayingItem"
    
    private func postNotificationIfAllowed(forNowPlayingItem item: MPMediaItem) {
        guard allowsNowPlayingItemNotification else { return }
        
        let content = UNMutableNotificationContent()
        content.title = item.title?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        content.subtitle = item.artist?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        content.categoryIdentifier = LyricsNotificationController.categoryIdentifier
        
        let request = UNNotificationRequest(identifier: nowPlayingNotificationIdentifier, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
