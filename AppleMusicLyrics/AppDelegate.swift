//
//  AppDelegate.swift
//  AppleMusicLyrics
//
//  Created by Jonny Kuang on 5/11/19.
//  Copyright © 2019 Jonny Kuang. All rights reserved.
//

import LyricsUI

@UIApplicationMain
class AppDelegate : UIResponder, UIApplicationDelegate {
    
    var window: UIWindow? { get { return mainWindow } set {} }
    
    private lazy var mainWindow = UIWindow()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        LyricsNotificationController.shared.openSettingsHandler = { _ in
            application.open(URL(string: UIApplication.openSettingsURLString)!)
        }
        
        mainWindow.tintColor = .globalTint
        
        let accessSettingsController = SystemAccessSettingsTableViewController()
        
        accessSettingsController.preparationHandler = { [weak accessSettingsController] in
            accessSettingsController?.view.isHidden = false
            accessSettingsController?.title = NSLocalizedString("permissionSettings", comment: "")
            accessSettingsController?.navigationController?.isToolbarHidden = true
            accessSettingsController?.navigationController?.navigationBar.prefersLargeTitles = true
        }
        accessSettingsController.completionHandler = { [weak self] in
            LocationManager.shared.start()
            _ = SystemPlayerLyricsController.shared
            _ = NowPlayingNotificationManager.shared
            self?.updateWindowForLyricsUI()
        }
        
        let navigationController = UINavigationController(rootViewController: accessSettingsController)
        navigationController.isToolbarHidden = false
        navigationController.view.backgroundColor = .white
        accessSettingsController.view.isHidden = true
        
        mainWindow.rootViewController = navigationController
        mainWindow.makeKeyAndVisible()
        
        return true
    }
    
    private func updateWindowForLyricsUI() {
        let lyricsTVC = LyricsContainerViewController()
        let navigationController = UINavigationController(rootViewController: lyricsTVC)
        navigationController.isToolbarHidden = false
        
        mainWindow.rootViewController = navigationController
        mainWindow.makeKeyAndVisible()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return true
    }
}
