//
//  NotificationViewController.swift
//  NotificationContentExtension
//
//  Created by Jonny Kuang on 5/13/19.
//  Copyright © 2019 Jonny Kuang. All rights reserved.
//

import LyricsUI
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    
    private let lyricsController = LyricsTableViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.tintColor = .globalTint
        
        addChild(lyricsController)
        view.addSubview(lyricsController.view)
        lyricsController.view.addConstraintsToFitSuperview()
        lyricsController.didMove(toParent: self)
        
        lyricsController.tableView.showsVerticalScrollIndicator = false
        
        titleObserver = lyricsController.observe(\.title) { [weak self] controller, _ in
            self?.title = controller.title
        }
    }
    
    private var titleObserver: NSKeyValueObservation?
    
    func didReceive(_ notification: UNNotification) {
        title = lyricsController.title
    }
    
    func didReceive(_ response: UNNotificationResponse, completionHandler: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        if let source = LyricsProviderSource(rawValue: response.actionIdentifier) {
            MPMusicPlayerController.systemMusicPlayer.nowPlayingItem?.kjy_userSpecifiedSource = source
        }
        completionHandler(.doNotDismiss)
    }
}

