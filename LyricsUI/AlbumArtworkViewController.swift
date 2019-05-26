//
//  AlbumArtworkViewController.swift
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
        
        artworkView.artworkButton.addTarget(self, action: #selector(tapArtworkButton), for: .touchUpInside)
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
    
    @objc private func tapArtworkButton(_ button: UIButton) {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: localized("saveImage"), style: .default) { _ in
            if let image = button.image(for: .normal) {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
        })
        controller.addAction(UIAlertAction(title: localized("cancel"), style: .cancel))
        
        let popover = controller.popoverPresentationController
        popover?.sourceView = button
        popover?.sourceRect = button.bounds
        
        present(controller, animated: true) {
            popover?.passthroughViews = []
        }
    }
}
