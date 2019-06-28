//
//  TodayViewController.swift
//  TodayExtension
//
//  Created by Jonny Kuang on 6/28/19.
//  Copyright © 2019 Jonny Kuang. All rights reserved.
//

import UIKit
import NotificationCenter
import LyricsUI

class TodayViewController: UIViewController, NCWidgetProviding {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.tintColor = .globalTint
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
        #if targetEnvironment(simulator)
        // MPMediaLibrary.requestAuthorization is unusable on simulator
        showNoMusicAccessButton()
        #else
        switch MPMediaLibrary.authorizationStatus() {
        case .notDetermined:
            MPMediaLibrary.requestAuthorization { [weak self] status in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if status == .authorized {
                        self.showLyricsController()
                    } else {
                        self.showNoMusicAccessButton()
                    }
                }
            }
        case .authorized:
            showLyricsController()
        default:
            showNoMusicAccessButton()
        }
        #endif
    }
    
    private lazy var lyricsController = LyricsTableViewController()
    
    private func showLyricsController() {
        guard lyricsController.parent != self else { return }
        
        addChild(lyricsController)
        view.addSubview(lyricsController.view)
        lyricsController.view.addConstraintsToFitSuperview()
        lyricsController.didMove(toParent: self)
        
        lyricsController.tableView.showsVerticalScrollIndicator = false
    }
    
    private lazy var noMusicAccessButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("enableMusicAccess", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(openMainApp), for: .touchUpInside)
        if let titleLabel = button.titleLabel {
            titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
            titleLabel.adjustsFontForContentSizeCategory = true
            titleLabel.adjustsFontSizeToFitWidth = true
            titleLabel.minimumScaleFactor = 0.1
        }
        return button
    }()
    
    @objc private func openMainApp() {
        extensionContext?.open(URL(string: "com.jonny.lyrics://")!)
    }
    
    private func showNoMusicAccessButton() {
        guard noMusicAccessButton.superview != view else { return }
        
        view.addSubview(noMusicAccessButton)
        noMusicAccessButton.addConstraintsToFitSuperview()
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        switch activeDisplayMode {
        case .compact:
            preferredContentSize.height = maxSize.height
        case .expanded:
            if let extensionContext = extensionContext {
                preferredContentSize.height = extensionContext.widgetMaximumSize(for: .compact).height * 2
            }
        @unknown default:
            break
        }
    }
}
