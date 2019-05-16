//
//  NotificationViewController.swift
//  NotificationContentExtension
//
//  Created by Jonny Kuang on 5/13/19.
//  Copyright © 2019 Jonny Kuang. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI
import LyricsUI


class NotificationViewController: UIViewController, UNNotificationContentExtension {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.tintColor = .globalTint
        
        let controller = LyricsTableViewController()
        addChild(controller)
        view.addSubview(controller.view)
        controller.view.addConstraintsToFitSuperview()
        controller.didMove(toParent: self)
        
        title = controller.title
        titleObserver = controller.observe(\.title) { [weak self] controller, _ in
            self?.title = controller.title
        }
    }
    
    private var titleObserver: NSKeyValueObservation?
    
    func didReceive(_ notification: UNNotification) {
    }
    
    func didReceive(_ response: UNNotificationResponse, completionHandler: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        if let source = LyricsProviderSource(rawValue: response.actionIdentifier) {
            MPMusicPlayerController.systemMusicPlayer.nowPlayingItem?.kjy_userSpecifiedSource = source
        }
        completionHandler(.doNotDismiss)
    }
}

