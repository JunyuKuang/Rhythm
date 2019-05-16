//
//  AppDelegate.swift
//  AppleMusicLyrics
//
//  Created by Jonny Kuang on 5/11/19.
//  Copyright © 2019 Jonny Kuang. All rights reserved.
//

import UIKit
import UserNotifications
import LyricsUI


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow? { get { return mainWindow } set {} }
    
    private lazy var mainWindow = UIWindow()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        _ = LyricsNotificationController.shared // register observers to track the visible state of iOS Notification Center
        
        mainWindow.tintColor = .globalTint
        
        let placeholderNavigationController = UINavigationController(rootViewController: UIViewController())
        placeholderNavigationController.isToolbarHidden = false
        placeholderNavigationController.view.backgroundColor = .white
        
        mainWindow.rootViewController = placeholderNavigationController
        mainWindow.makeKeyAndVisible()
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        _ = requestPermissions
    }
    
    private lazy var requestPermissions: Void = {
        MPMediaLibrary.requestAuthorization { status in
            let canAccessMediaLibrary = status == .authorized
            UNUserNotificationCenter.current().requestAuthorization(options: .alert) { canPostNotification, _ in
                DispatchQueue.main.async {
                    if canAccessMediaLibrary, canPostNotification {
                        LocationManager.shared.start()
                        _ = SystemPlayerLyricsController.shared
                        _ = NowPlayingNotificationManager.shared
                        self.configureWindow()
                    } else {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!) { _ in
                            exit(0)
                        }
                    }
                }
            }
        }
    }()
    
    private func configureWindow() {
        let lyricsTVC = LyricsContainerViewController()
        let navigationController = UINavigationController(rootViewController: lyricsTVC)
        navigationController.isToolbarHidden = false
        
        mainWindow.rootViewController = navigationController
        mainWindow.makeKeyAndVisible()
    }
}
