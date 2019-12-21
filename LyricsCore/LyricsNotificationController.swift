//
//  LyricsNotificationController.swift
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

public class LyricsNotificationController : NSObject {
    
    public static let shared = LyricsNotificationController()
    
    private struct PendingLyricsInfo {
        let line: LyricsLine
        let creationDate = Date()
    }
    private var pendingInfo: PendingLyricsInfo?
    
    private let center = UNUserNotificationCenter.current()
    private var kvoObservers = [NSKeyValueObservation]()
    
    private var maximumNotificationCount = UserDefaults.appGroup.maximumNotificationCount {
        didSet {
            clearNotifications()
            notificationIndex = 0
            if maximumNotificationCount == 0 {
                pendingInfo = nil
            }
        }
    }
    
    public var openSettingsHandler: ((UNNotification?) -> Void)?
    public var changeLyricsHandler: ((UNNotificationResponse) -> Void)?
    
    private let changeLyricsActionIdentifier = "changeLyrics"
    
    private override init() {
        super.init()
        
        _ = UserDefaults.appGroup.maximumNotificationCount
        kvoObservers = [
            UserDefaults.appGroup.observe(\.maximumNotificationCount, options: .new) { _, change in
                self.maximumNotificationCount = change.newValue ?? 1
            },
            SpringboardNotificationObserver.shared.observe(\.isDeviceSleepModeEnabled) { _, _ in
                self.postPendingLyricsIfNeeded()
            },
            SpringboardNotificationObserver.shared.observe(\.isCoverSheetVisible) { _, _ in
                self.postPendingLyricsIfNeeded()
            },
        ]
        
        center.delegate = self
        
        let category: UNNotificationCategory = {
            let actions = [
                UNNotificationAction(identifier: changeLyricsActionIdentifier, title: NSLocalizedString("changeLyrics", bundle: .current, comment: ""), options: .foreground),
            ]
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
    
    private var notificationIndex = 0
    
    private let notificationIdentifierPrefix = "lyrics"
    
    private func notificationIdentifier(withIndex index: Int) -> String {
        return "\(notificationIdentifierPrefix)\(index)"
    }
    
    func postIfNeeded(lyricsLine: LyricsLine) {
        guard maximumNotificationCount > 0 else { return }
        
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
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void)
    {
        if response.actionIdentifier == changeLyricsActionIdentifier {
            changeLyricsHandler?(response)
        }
        completionHandler()
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        openSettingsHandler?(notification)
    }
}
