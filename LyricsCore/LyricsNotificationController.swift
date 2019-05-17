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

public class LyricsNotificationController : NSObject {
    
    private struct PendingLyricsInfo {
        let line: LyricsLine
        let creationDate = Date()
    }
    private var pendingInfo: PendingLyricsInfo?
    
    private let center = UNUserNotificationCenter.current()
    
    private var kvoObservers = [NSKeyValueObservation]()
    
    public static let shared = LyricsNotificationController()
    
    
    private override init() {
        super.init()
        
        let springboardNotificationObserver = SpringboardNotificationObserver.shared
        
        kvoObservers = [
            springboardNotificationObserver.observe(\.isDeviceSleepModeEnabled) { _, _ in
                self.postPendingLyricsIfNeeded()
            },
            springboardNotificationObserver.observe(\.isCoverSheetVisible) { _, _ in
                self.postPendingLyricsIfNeeded()
            },
        ]
        
        center.delegate = self
        
        let category: UNNotificationCategory = {
            let actions = LyricsProviderSource.allCases.map {
                UNNotificationAction(identifier: $0.rawValue, title: $0.rawValue)
            }
            let options: UNNotificationCategoryOptions = [.hiddenPreviewsShowTitle, .hiddenPreviewsShowSubtitle]
            
            if #available(iOS 12.0, *) {
                return UNNotificationCategory(
                    identifier: LyricsNotificationController.categoryIdentifier,
                    actions: actions,
                    intentIdentifiers: [],
                    hiddenPreviewsBodyPlaceholder: "lyricsNotificationHiddenPreview",
                    categorySummaryFormat: "lyricsNotificationSummary",
                    options: options
                )
            } else {
                return UNNotificationCategory(
                    identifier: LyricsNotificationController.categoryIdentifier,
                    actions: actions,
                    intentIdentifiers: [],
                    options: options
                )
            }
        }()
        center.setNotificationCategories([category])
    }
    
    private func postPendingLyricsIfNeeded() {
        if isPostable, let pendingInfo = pendingInfo, Date().timeIntervalSince(pendingInfo.creationDate) < 5 {
            self.pendingInfo = nil
            _postIfNeeded(lyricsLine: pendingInfo.line)
        }
    }
    
    static let categoryIdentifier = "lyrics"
    
    /// Can we post lyrics notification right now?
    ///
    /// Returns true only if A. iOS Notification Center (a.k.a. Cover Sheet) is on the front and B. the device is not in sleep mode.
    var isPostable: Bool {
        let observer = SpringboardNotificationObserver.shared
        return observer.isCoverSheetVisible && !observer.isDeviceSleepModeEnabled
    }
    
    private var previousLine: LyricsLine?
    
    /// Default is 1.
    var maximumNotificationCount = 1
    
    private var notificationIndex = 0
    
    private let notificationIdentifierPrefix = "lyrics"
    
    private func notificationIdentifier(withIndex index: Int) -> String {
        return "\(notificationIdentifierPrefix)\(index)"
    }
    
    func postIfNeeded(lyricsLine: LyricsLine) {
        if previousLine == lyricsLine {
            return
        }
        previousLine = lyricsLine
        
        if !isPostable {
            pendingInfo = PendingLyricsInfo(line: lyricsLine)
            return
        }
        pendingInfo = nil
        
        _postIfNeeded(lyricsLine: lyricsLine)
    }
    
    private func _postIfNeeded(lyricsLine: LyricsLine) {
        let lyricsLineContent = lyricsLine.content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !lyricsLineContent.isEmpty else {
            return
        }
        let showsTranslation = UserDefaults.appGroup.showsLyricsTranslationIfAvailable
        let translation = !showsTranslation ? "" : (lyricsLine.attachments.translation()?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
        
        let content = UNMutableNotificationContent()
        if !translation.isEmpty {
            content.title = lyricsLineContent
            content.subtitle = translation
        } else {
            content.title = lyricsLineContent
        }
        content.categoryIdentifier = LyricsNotificationController.categoryIdentifier
        
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
        let prefix = notificationIdentifierPrefix
        center.getDeliveredNotifications { notifications in
            let lyricsNotifications = notifications.filter { $0.request.identifier.hasPrefix(prefix) }
            self.center.removeDeliveredNotifications(withIdentifiers: lyricsNotifications.map { $0.request.identifier })
        }
    }
}


extension LyricsNotificationController : UNUserNotificationCenterDelegate {
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler(UIApplication.shared.applicationState != .active ? .alert : [])
    }
}
