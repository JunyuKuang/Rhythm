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
        _ = LyricsNotificationController.shared
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
