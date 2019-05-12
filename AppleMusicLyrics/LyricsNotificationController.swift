//
//  LyricsNotificationController.swift
//  AppleMusicLyrics
//
//  Created by Jonny Kuang on 5/12/19.
//  Copyright © 2019 Jonny Kuang. All rights reserved.
//

import Foundation
import UserNotifications
import LyricsProvider

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
            observer.observe(\.isDeviceSleepModeEnabled) { _, _ in
                self.postPendingLyricsIfNeeded()
            },
            observer.observe(\.isCoverSheetVisible) { _, _ in
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
    
    /// Can we post lyrics notification right now?
    ///
    /// Returns true only if A. iOS Notification Center (a.k.a. Cover Sheet) is on the front and B. the device is not in sleep mode.
    var isPostable: Bool {
        let observer = DarwinNotificationObserver.shared
        return observer.isCoverSheetVisible && !observer.isDeviceSleepModeEnabled
    }
    
    private var previousLine: LyricsLine?
    
    /// Default is true.
    var showsLyricsTranslationIfAvailable = true
    
    /// Default is 5.
    var maximumNotificationCount = 5
    
    private var notificationIndex = 0
    
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
        let translation = !showsLyricsTranslationIfAvailable ? "" : (lyricsLine.attachments.translation()?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
        
        let content = UNMutableNotificationContent()
        if !translation.isEmpty {
            content.title = lyricsLineContent
            content.body = translation
        } else {
            content.body = lyricsLineContent
        }
        content.categoryIdentifier = categoryIdentifier
        
        let identifier = notificationIdentifier(withIndex: notificationIndex)
        content.threadIdentifier = identifier // avoid automatic grouping
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
        center.add(request)
        
        if maximumNotificationCount > 1 {
            if notificationIndex >= maximumNotificationCount {
                let identifierToRemove = notificationIdentifier(withIndex: notificationIndex - maximumNotificationCount)
                center.removeDeliveredNotifications(withIdentifiers: [identifierToRemove])
            }
            notificationIndex += 1
        }
    }
    
    func clearNotifications() {
        center.removeAllDeliveredNotifications()
    }
}
