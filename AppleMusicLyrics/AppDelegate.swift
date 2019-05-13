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
import LyricsUI


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        _ = LyricsNotificationController.shared
        
        let window = UIWindow()
        self.window = window
        window.tintColor = UIColor(red: 1, green: 45/255, blue: 85/255, alpha: 1) // match Apple Music
        window.rootViewController = UIViewController()
        window.rootViewController?.view.backgroundColor = .white
        window.makeKeyAndVisible()
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        _ = requestPermissions
    }
    
    private lazy var requestPermissions: Void = {
        MPMediaLibrary.requestAuthorization { _ in
            DispatchQueue.main.async {
                _ = SystemPlayerLyricsController.shared
                UNUserNotificationCenter.current().requestAuthorization(options: .alert) { _, _ in
                    DispatchQueue.main.async {
                        LocationManager.shared.start()
                        self.configureWindow()
                    }
                }
            }
        }
    }()
    
    private func configureWindow() {
        let lyricsTVC = LyricsTableViewController()
        window?.rootViewController = UINavigationController(rootViewController: lyricsTVC)
        window?.makeKeyAndVisible()
    }
}
