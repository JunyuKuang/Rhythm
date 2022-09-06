//
//  AppDelegate.swift
//
//  Rhythm <https://github.com/JunyuKuang/Rhythm>
//  Copyright (C) 2019-2020  Junyu Kuang
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

import LyricsUI

@UIApplicationMain
class AppDelegate : UIResponder, UIApplicationDelegate {
    
    var window: UIWindow? { get { return mainWindow } set {} }
    
    private lazy var mainWindow = UIWindow()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        LyricsNotificationController.shared.openSettingsHandler = { _ in
            application.kjy_open(URL(string: UIApplication.openSettingsURLString)!)
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
        navigationController.view.backgroundColor = .kjy_systemBackground
        accessSettingsController.view.isHidden = true
        
        mainWindow.rootViewController = navigationController
        mainWindow.makeKeyAndVisible()
        
        return true
    }
    
    private func updateWindowForLyricsUI() {
        let lyricsController = LyricsContainerViewController()
        let navigationController = UINavigationController(rootViewController: lyricsController)
        navigationController.isToolbarHidden = false
        
        mainWindow.rootViewController = navigationController
        mainWindow.makeKeyAndVisible()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        handleApplicationURL(url)
        return true
    }
    
    private func handleApplicationURL(_ url: URL) {
        if let navigationController = mainWindow.rootViewController as? UINavigationController,
            let lyricsController = navigationController.viewControllers.first as? LyricsContainerViewController,
            lyricsController.view.window != nil
        {
            _ = lyricsController.handleApplicationURL(url)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                dprint("retry")
                self?.handleApplicationURL(url)
            }
        }
    }
}
