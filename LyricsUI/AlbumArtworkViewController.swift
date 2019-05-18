//
//  AlbumArtworkViewController.swift
//  LyricsUI
//
//  Created by Jonny Kuang on 5/18/19.
//  Copyright © 2019 Jonny Kuang. All rights reserved.
//

class AlbumArtworkViewController : UIViewController {

    private let artworkView = AlbumArtworkView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(artworkView)
        
        artworkView.translatesAutoresizingMaskIntoConstraints = false
        
        let trailingMarginConstraint = artworkView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        trailingMarginConstraint.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            artworkView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 2),
            artworkView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            artworkView.heightAnchor.constraint(equalTo: artworkView.widthAnchor),
            trailingMarginConstraint,
            view.safeAreaLayoutGuide.bottomAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: artworkView.bottomAnchor, multiplier: 2),
        ])
        
        updateArtworkIfNeeded()
        NotificationCenter.default.addObserver(forName: SystemPlayerLyricsController.nowPlayingLyricsDidChangeNotification, object: nil, queue: .main) { [weak self] _ in
            self?.updateArtworkIfNeeded()
        }
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil) { [weak self] _ in
            // willEnterForegroundNotification posted shortly **before** an app leaves the background state.
            DispatchQueue.main.async {
                self?.updateArtworkIfNeeded()
            }
        }
    }
    
    /// Default is false.
    var updatesArtwork = false {
        didSet {
            guard updatesArtwork != oldValue else { return }
            updateArtworkIfNeeded()
        }
    }
    
    private var mediaItem: MPMediaItem?
    
    private func updateArtworkIfNeeded() {
        guard updatesArtwork, UIApplication.shared.applicationState != .background else { return }
        
        guard let nowPlayingItem = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem else {
            artworkView.artwork = nil
            return
        }
        guard nowPlayingItem != mediaItem || artworkView.artwork == nil else {
            return
        }
        mediaItem = nowPlayingItem
        
        if let mpArtwork = nowPlayingItem.artwork, let artwork = mpArtwork.image(at: mpArtwork.bounds.size) {
            artworkView.artwork = artwork
        } else {
            artworkView.artwork = nil
            downloadArtwork()
        }
    }
    
    private func downloadArtwork() {
        guard let nowPlaying = SystemPlayerLyricsController.shared.nowPlaying, let artworkURL = nowPlaying.lyrics.metadata.artworkURL else {
            return
        }
        let mediaItem = nowPlaying.item
        guard mediaItem == self.mediaItem else { return }
        
        AlbumArtworkViewController.urlSession.dataTask(with: artworkURL) { [weak self] data, response, error in
            guard let self = self,
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                guard mediaItem == self.mediaItem else { return }
                self.artworkView.artwork = image
            }
        }.resume()
    }
    
    private static let urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        return URLSession(configuration: configuration)
    }()
}
