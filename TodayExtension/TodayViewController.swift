//
//  TodayViewController.swift
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

import UIKit
import NotificationCenter
import LyricsUI

class TodayViewController : UIViewController, NCWidgetProviding {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil, queue: .main) { [weak self] _ in
            guard let self = self,
                let extensionContext = self.extensionContext else { return }
            self.updateBarVisibility(for: extensionContext.widgetActiveDisplayMode, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.tintColor = .globalTint
        
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
    
    // MARK: - UI Updates
    
    private lazy var lyricsContainer = LyricsContainerViewController()
    private lazy var lyricsNavigationController = UINavigationController(rootViewController: lyricsContainer)
    
    private func showLyricsController() {
        guard let extensionContext = extensionContext,
            lyricsNavigationController.parent != self else { return }
        
        lyricsNavigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        lyricsNavigationController.toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        lyricsContainer.edgesForExtendedLayout = []
        
        addChild(lyricsNavigationController)
        view.addSubview(lyricsNavigationController.view)
        lyricsNavigationController.view.addConstraintsToFitSuperview()
        lyricsNavigationController.didMove(toParent: self)
        
        lyricsContainer.view.backgroundColor = nil
        lyricsContainer.showsPlaybackProgressBar = false
        lyricsContainer.tableViewController.tableView.showsVerticalScrollIndicator = false
        
        extensionContext.widgetLargestAvailableDisplayMode = .expanded
        updateBarVisibility(for: extensionContext.widgetActiveDisplayMode, animated: false)
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
        extensionContext?.widgetLargestAvailableDisplayMode = .compact
    }
    
    private func updateBarVisibility(for mode: NCWidgetDisplayMode, animated: Bool) {
        guard let navigationController = children.first as? UINavigationController,
            navigationController == lyricsNavigationController else { return }
        
        let hidden = mode == .compact && MPMusicPlayerController.systemMusicPlayer.nowPlayingItem != nil
        navigationController.setNavigationBarHidden(hidden, animated: animated)
        navigationController.setToolbarHidden(hidden, animated: animated)
    }
    
    // MARK: - NCWidgetProviding
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        switch activeDisplayMode {
        case .compact:
            preferredContentSize.height = maxSize.height
        case .expanded:
            if let extensionContext = extensionContext {
                preferredContentSize.height = min(extensionContext.widgetMaximumSize(for: .compact).height * 3 + 44 * 2, maxSize.height)
            }
        @unknown default:
            break
        }
        updateBarVisibility(for: activeDisplayMode, animated: true)
    }
}
