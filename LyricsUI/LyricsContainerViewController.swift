//
//  LyricsContainerViewController.swift
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

public class LyricsContainerViewController : UIViewController {
    
    private let artworkViewController = AlbumArtworkViewController()
    private let tableViewController = LyricsTableViewController()
    
    private let player = MPMusicPlayerController.systemMusicPlayer
    private let progressView = UIProgressView()
    private var titleObserver: NSKeyValueObservation?
    private var showsTranslationObserver: NSKeyValueObservation?
    
    private var constraintsForRegularLayout = [NSLayoutConstraint]()
    private var constraintsForCompactLayout = [NSLayoutConstraint]()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        player.beginGeneratingPlaybackNotifications()
        
        [artworkViewController, tableViewController].forEach {
            addChild($0)
            $0.didMove(toParent: self)
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        player.endGeneratingPlaybackNotifications()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .kjy_systemBackground
        
        title = tableViewController.title
        titleObserver = tableViewController.observe(\.title, options: .new) { [weak self] _, change in
            self?.title = change.newValue ?? ""
        }
        
        [artworkViewController, tableViewController].forEach {
            $0.additionalSafeAreaInsets.bottom = progressView.intrinsicContentSize.height
            view.addSubview($0.view)
            $0.view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        constraintsForRegularLayout = [
            artworkViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableViewController.view.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
        ]
        constraintsForCompactLayout = [
            artworkViewController.view.trailingAnchor.constraint(equalTo: view.leadingAnchor),
            tableViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        ]
        let commonConstraints = [
            artworkViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            artworkViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            artworkViewController.view.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),
            
            tableViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            tableViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ]
        NSLayoutConstraint.activate(commonConstraints)
        
        view.addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        navigationItem.leftBarButtonItem = {
            let icon: UIImage?
            if #available(iOS 13, *) {
                icon = UIImage(systemName: "ellipsis.circle")
            } else {
                icon = img("More")
            }
            let item = UIBarButtonItem(image: icon, style: .plain, target: self, action: #selector(tapMoreButtonItem))
            item.hudTitle = localized("more")
            return item
        }()
        
        let composeButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(tapComposeButtonItem))
        composeButtonItem.isEnabled = player.nowPlayingItem != nil
        NotificationCenter.default.addObserver(forName: .MPMusicPlayerControllerNowPlayingItemDidChange, object: player, queue: .main) { [weak self, weak composeButtonItem] _ in
            composeButtonItem?.isEnabled = self?.player.nowPlayingItem != nil
        }
        navigationItem.rightBarButtonItem = composeButtonItem
        
        configureToolbars()
        
        NotificationCenter.default.addObserver(self, selector: #selector(playbackStateDidChange), name: .MPMusicPlayerControllerPlaybackStateDidChange, object: player)
        
        let timer = Timer(timeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            guard UIApplication.shared.applicationState != .background else { return }
            
            var progress: Float = 0
            if let nowPlayingItem = self.player.nowPlayingItem {
                progress = Float(self.player.currentPlaybackTime / nowPlayingItem.playbackDuration)
            }
            self.progressView.progress = progress
        }
        RunLoop.main.add(timer, forMode: .common)
        
        showsTranslationObserver = UserDefaults.appGroup.observe(\.showsLyricsTranslationIfAvailable) { [weak self] _, _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.updateState(forTranslationButtonItem: self.translationButtonItem)
            }
        }
        
        let translationAvailabilityUpdateHandler = { [weak self] in
            var isEnabled = false
            if let lyrics = SystemPlayerLyricsController.shared.nowPlaying?.lyrics, lyrics.metadata.hasTranslation {
                isEnabled = true
            }
            self?.translationButtonItem.isEnabled = isEnabled
        }
        translationAvailabilityUpdateHandler()
        NotificationCenter.default.addObserver(forName: SystemPlayerLyricsController.nowPlayingLyricsDidChangeNotification, object: nil, queue: .main) { _ in
            translationAvailabilityUpdateHandler()
        }
        
        LyricsNotificationController.shared.changeLyricsHandler = { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let presented = self.presentedViewController {
                    if !(presented is LyricsProviderPickerController) {
                        self.dismiss(animated: false) {
                            self.present(LyricsProviderPickerController(), animated: true)
                        }
                    }
                } else {
                    self.present(LyricsProviderPickerController(), animated: true)
                }
            }
        }
        NotificationCenter.default.addObserver(forName: UIContentSizeCategory.didChangeNotification, object: nil, queue: .main) { [weak self] _ in
            self?.updateLayout()
        }
        view.addGestureRecognizer(tableViewController.tableView.panGestureRecognizer)
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateLayout()
    }
    
    private func updateLayout() {
        // 480: minimum point width on iPhone Landscape mode (iPhone 4s)
        if view.bounds.width < 480 || traitCollection.horizontalSizeClass == .compact && traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
            // compact layout
            artworkViewController.updatesArtwork = false
            NSLayoutConstraint.deactivate(constraintsForRegularLayout)
            NSLayoutConstraint.activate(constraintsForCompactLayout)
        } else {
            // regular layout
            artworkViewController.updatesArtwork = true
            NSLayoutConstraint.deactivate(constraintsForCompactLayout)
            NSLayoutConstraint.activate(constraintsForRegularLayout)
        }
    }
    
    
    private lazy var translationButtonItem: UIBarButtonItem = {
        let buttonItem = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(toggleTranslation))
        updateState(forTranslationButtonItem: buttonItem)
        return buttonItem
    }()
    
    private func updateState(forTranslationButtonItem buttonItem: UIBarButtonItem) {
        let showsTranslation = UserDefaults.appGroup.showsLyricsTranslationIfAvailable
        
        let iconNames: [String]
        if showsTranslation {
            iconNames = ["Translate", "Translate-compact"]
        } else {
            iconNames = ["Translate-Disabled", "Translate-Disabled-compact"]
        }
        let icons = iconNames.map { img($0)! }
        buttonItem.image = icons.first
        buttonItem.landscapeImagePhone = icons.last
        
        buttonItem.hudTitle = localized(showsTranslation ? "hideTranslation" : "showTranslation")
    }
    
    private var playPauseButtonItem: UIBarButtonItem?
    
    private func updatePlayPauseButtonItemIfNeeded() {
        var itemType: UIBarButtonItem.SystemItem?
        
        if playPauseButtonItem == nil {
            itemType = player.playbackState == .playing ? .pause : .play
        } else {
            switch player.playbackState {
            case .playing:
                itemType = .pause
            case .paused, .stopped, .interrupted:
                itemType = .play
            default:
                break
            }
        }
        if let itemType = itemType {
            var index: Int?
            if let playPauseButtonItem = playPauseButtonItem {
                index = toolbarItems?.firstIndex(of: playPauseButtonItem)
            }
            playPauseButtonItem = UIBarButtonItem(barButtonSystemItem: itemType, target: self, action: #selector(togglePlayPauseState))
            if let index = index {
                toolbarItems![index] = playPauseButtonItem!
            }
        }
    }
}


private extension LyricsContainerViewController {
    
    func configureToolbars() {
        let openMusicAppButtonItem: UIBarButtonItem = {
            let icons = ["AppleMusic", "AppleMusic-compact"].map { img($0)! }
            let buttonItem = UIBarButtonItem(
                image: icons.first,
                landscapeImagePhone: icons.last,
                style: .plain,
                target: self,
                action: #selector(openMusicApp)
            )
            buttonItem.hudTitle = localized("appleMusic")
            return buttonItem
        }()
        
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 32
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        updatePlayPauseButtonItemIfNeeded() // setup playPauseButtonItem
        
        toolbarItems = [
            openMusicAppButtonItem,
            flexibleSpace,
            UIBarButtonItem(barButtonSystemItem: .rewind, target: self, action: #selector(skipToPreviousItem)),
            fixedSpace,
            playPauseButtonItem!,
            fixedSpace,
            UIBarButtonItem(barButtonSystemItem: .fastForward, target: self, action: #selector(skipToNextItem)),
            flexibleSpace,
            translationButtonItem,
        ]
    }
}


@objc private extension LyricsContainerViewController {
    
    func playbackStateDidChange() {
        updatePlayPauseButtonItemIfNeeded()
    }
    
    func togglePlayPauseState() {
        if player.currentPlaybackRate == 0 {
            player.play()
        } else {
            player.pause()
        }
    }
    
    func skipToPreviousItem() {
        if player.currentPlaybackTime > 4 {
            player.skipToBeginning()
        } else {
            player.skipToPreviousItem()
        }
    }
    
    func skipToNextItem() {
        player.skipToNextItem()
    }
    
    func openMusicApp() {
        let url = URL(string: "music://")!
        UIApplication.shared.open(url)
    }
    
    func toggleTranslation() {
        UserDefaults.appGroup.showsLyricsTranslationIfAvailable.toggle()
    }
    
    func tapMoreButtonItem(_ buttonItem: UIBarButtonItem) {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let actions = [
            UIAlertAction(title: localized("settings"), style: .default) { _ in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            },
            UIAlertAction(title: localized("sendFeedback"), style: .default) { _ in
                if let controller = MailComposeViewController(text: "") {
                    self.present(controller, animated: true)
                }
            },
            UIAlertAction(title: localized("followOnWeibo"), style: .default) { _ in
                UIApplication.shared.open(URL(string: "https://weibo.com/lightscreen")!)
            },
            UIAlertAction(title: localized("followOnTwitter"), style: .default) { _ in
                UIApplication.shared.open(URL(string: "https://twitter.com/kuangjunyu")!)
            },
            UIAlertAction(title: localized("followOnGitHub"), style: .default) { _ in
                UIApplication.shared.open(URL(string: "https://github.com/JunyuKuang/Rhythm")!)
            },
            UIAlertAction(title: localized("cancel"), style: .cancel),
        ]
        actions.forEach(controller.addAction)
        
        controller.popoverPresentationController?.barButtonItem = buttonItem
        present(controller, animated: true) {
            controller.popoverPresentationController?.passthroughViews = []
        }
    }
    
    func tapComposeButtonItem(_ buttonItem: UIBarButtonItem) {
        present(LyricsProviderPickerController(), animated: true)
    }
}
