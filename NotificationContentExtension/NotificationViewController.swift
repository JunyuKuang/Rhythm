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
}

