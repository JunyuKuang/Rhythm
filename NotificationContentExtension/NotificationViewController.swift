//
//  NotificationViewController.swift
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

import LyricsUI
import UserNotificationsUI

class NotificationViewController : UIViewController, UNNotificationContentExtension {
    
    private lazy var lyricsContainer = LyricsContainerViewController()
    private lazy var lyricsNavigationController = UINavigationController(rootViewController: lyricsContainer)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.tintColor = .globalTint
        
        addChild(lyricsNavigationController)
        defer {
            lyricsNavigationController.didMove(toParent: self)
        }
        do {
            let controller = lyricsNavigationController
            controller.navigationBar.isTranslucent = false
            controller.toolbar.isTranslucent = false
            controller.isToolbarHidden = false
            
            if #available(iOS 13, *) {
                setOverrideTraitCollection(UITraitCollection(userInterfaceLevel: .elevated), forChild: controller)
                controller.navigationBar.barTintColor = .systemBackground
                controller.toolbar.barTintColor = .systemBackground
            }
        }
        view.addSubview(lyricsNavigationController.view)
        lyricsNavigationController.view.addConstraintsToFitSuperview()
        
        let tableView = lyricsContainer.tableViewController.tableView!
        tableView.showsVerticalScrollIndicator = false
        tableView.isScrollEnabled = false
        
        var screenBounds = UIScreen.main.bounds
        updateContentSize(with: screenBounds)
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            if let self = self {
                let newBounds = UIScreen.main.bounds
                if screenBounds != newBounds {
                    screenBounds = newBounds
                    self.updateContentSize(with: screenBounds)
                }
            } else {
                timer.invalidate()
            }
        }
    }
    
    func didReceive(_ notification: UNNotification) {
        updateContentSize(with: UIScreen.main.bounds)
    }
    
    private func updateContentSize(with screenBounds: CGRect) {
        var contentSize = CGSize(width: 9999, height: screenBounds.height - 100)
        contentSize.height -= UIDevice.current.userInterfaceIdiom == .pad ? 16 : 8
        if UITraitCollection.kjy_displayNotched {
            contentSize.height -= 40 // align bottom edge with screen safe area
        }
        preferredContentSize = contentSize
    }
}

