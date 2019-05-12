//
//  AppDelegate.swift
//  AppleMusicLyrics
//
//  Created by Jonny Kuang on 5/11/19.
//  Copyright © 2019 Jonny Kuang. All rights reserved.
//

import UIKit
import MediaPlayer
import UserNotifications

import LyricsProvider
import Darwin


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        _ = DarwinNotificationObserver.shared
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        _ = requestPermissions
    }
    
    lazy var requestPermissions: Void = {
        MPMediaLibrary.requestAuthorization { _ in
            DispatchQueue.main.async {
                _ = SystemPlayerLyricsController.shared
                UNUserNotificationCenter.current().requestAuthorization(options: .alert) { _, _ in
                    DispatchQueue.main.async {
                        LocationManager.shared.start()
                    }
                }
            }
        }
    }()
}


extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
}


/// Init at app startup.
class SystemPlayerLyricsController {
    
    static let shared = SystemPlayerLyricsController()
    
    private init() {
        _ = LyricsNotificationController.shared
        
        let player = MPMusicPlayerController.systemMusicPlayer
        if let nowPlayingItem = player.nowPlayingItem {
            self.update(for: nowPlayingItem)
        }
        NotificationCenter.default.addObserver(forName: .MPMusicPlayerControllerNowPlayingItemDidChange, object: player, queue: .main) { _ in
            if let nowPlayingItem = player.nowPlayingItem {
                self.update(for: nowPlayingItem)
            } else {
                LyricsNotificationController.shared.clearNotifications()
            }
        }
        NotificationCenter.default.addObserver(forName: .MPMusicPlayerControllerPlaybackStateDidChange, object: player, queue: .main) { _ in
            switch player.playbackState {
            case .playing:
                self.updateLyricsNotificationIfNeeded()
            case .seekingBackward, .seekingForward, .stopped:
                LyricsNotificationController.shared.clearNotifications()
            default:
                break
            }
        }
        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
            self.updateLyricsNotificationIfNeeded()
        }
    }
    
    private let lyricsManager = LyricsProviderManager()
    
    private struct NowPlaying {
        let item: MPMediaItem
        let lyrics: Lyrics
    }
    private var nowPlaying: NowPlaying?
    
    private func update(for nowPlayingItem: MPMediaItem) {
        LyricsNotificationController.shared.clearNotifications()
        
        guard nowPlayingItem != nowPlaying?.item else { return }
        let title = (nowPlayingItem.title ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let artist = (nowPlayingItem.artist ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !title.isEmpty else { return }
        
        let duration = nowPlayingItem.playbackDuration
        
        dprint(title, artist, duration)
        
        let request = LyricsSearchRequest(searchTerm: .info(title: title, artist: artist), title: title, artist: artist, duration: duration)
        
        _ = lyricsManager.searchLyrics(request: request) { lyrics in
            guard nowPlayingItem == MPMusicPlayerController.systemMusicPlayer.nowPlayingItem else { return }
            
            if let nowPlaying = self.nowPlaying, nowPlaying.item == nowPlayingItem {
                if lyrics.quality > nowPlaying.lyrics.quality {
                    LyricsNotificationController.shared.clearNotifications()
                    self.nowPlaying = NowPlaying(item: nowPlayingItem, lyrics: lyrics)
                    self.updateLyricsNotificationIfNeeded()
                }
            } else {
                self.nowPlaying = NowPlaying(item: nowPlayingItem, lyrics: lyrics)
                self.updateLyricsNotificationIfNeeded()
            }
        }
    }
    
    private func updateLyricsNotificationIfNeeded() {
        let notificationController = LyricsNotificationController.shared
        let player = MPMusicPlayerController.systemMusicPlayer
        
        guard let nowPlaying = nowPlaying,
            notificationController.isPostable,
            player.playbackState == .playing,
            nowPlaying.item == player.nowPlayingItem else { return }
        
        let currentPosition = player.currentPlaybackTime + 0.25
        
        for line in nowPlaying.lyrics.lines.reversed() {
            if line.position < currentPosition {
                notificationController.postIfNeeded(lyricsLine: line)
                break
            }
        }
    }
}

class LyricsNotificationController {
    
    private struct PendingLyricsInfo {
        let line: LyricsLine
        let creationDate = Date()
    }
    private var pendingInfo: PendingLyricsInfo?
    
    private let center = UNUserNotificationCenter.current()
    
    private var kvoObservers = [NSKeyValueObservation]()
    
    static let shared = LyricsNotificationController()
    
    private init() {
        let observer = DarwinNotificationObserver.shared
        
        kvoObservers = [
            observer.observe(\.isDeviceSleepModeEnabled) { observer, _ in
                self.postPendingLyricsIfNeeded()
            },
            observer.observe(\.isCoverSheetVisible) { observer, _ in
                self.postPendingLyricsIfNeeded()
            },
        ]
        
        let category = UNNotificationCategory(identifier: categoryIdentifier, actions: [], intentIdentifiers: [], options: [.hiddenPreviewsShowTitle, .hiddenPreviewsShowSubtitle])
        center.setNotificationCategories([category])
    }
    
    private func postPendingLyricsIfNeeded() {
        if isPostable, let pendingInfo = pendingInfo, Date().timeIntervalSince(pendingInfo.creationDate) < 5 {
            postIfNeeded(lyricsLine: pendingInfo.line)
        }
    }
    
    private let categoryIdentifier = "lyrics"
    
    var isPostable: Bool {
        let observer = DarwinNotificationObserver.shared
        return observer.isCoverSheetVisible && !observer.isDeviceSleepModeEnabled
    }
    
    private var previousLine: LyricsLine?
    
    private var notificationIndex = 0
    var maximumNotificationCount = 5
    
    private func notificationIdentifier(withIndex index: Int) -> String {
        return "lyrics\(index)"
    }
    
    func postIfNeeded(lyricsLine: LyricsLine) {
        if !isPostable {
            pendingInfo = PendingLyricsInfo(line: lyricsLine)
            return
        }
        pendingInfo = nil
        
        if previousLine == lyricsLine {
            return
        }
        previousLine = lyricsLine
        
        let lyricsLineContent = lyricsLine.content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !lyricsLineContent.isEmpty else {
            return
        }
        let translation = lyricsLine.attachments.translation()?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        let index = notificationIndex
        let identifier = notificationIdentifier(withIndex: index)
        
        notificationIndex += 1
        
        let content = UNMutableNotificationContent()
        
        if !translation.isEmpty {
            content.title = lyricsLineContent
            content.body = translation
        } else {
            content.body = lyricsLineContent
        }
        content.categoryIdentifier = categoryIdentifier
        content.threadIdentifier = identifier // avoid automatic grouping
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
        
        if index >= maximumNotificationCount {
            let identifierToRemove = notificationIdentifier(withIndex: index - maximumNotificationCount)
            center.removeDeliveredNotifications(withIdentifiers: [identifierToRemove])
        }
        center.add(request)
    }
    
    func clearNotifications() {
        center.removeAllDeliveredNotifications()
    }
}
