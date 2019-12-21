//
//  SystemPlayerLyricsController.swift
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

public class SystemPlayerLyricsController {
    
    public static let shared = SystemPlayerLyricsController()
    
    private init() {
        let player = MPMusicPlayerController.systemMusicPlayer
        if let nowPlayingItem = player.nowPlayingItem {
            self.update(for: nowPlayingItem)
        }
        player.beginGeneratingPlaybackNotifications()
        NotificationCenter.default.addObserver(forName: .MPMusicPlayerControllerNowPlayingItemDidChange, object: player, queue: .main) { _ in
            self.nowPlaying = nil
            NotificationCenter.default.post(name: SystemPlayerLyricsController.nowPlayingLyricsDidChangeNotification, object: self)
            NotificationCenter.default.post(name: SystemPlayerLyricsController.availableLyricsArrayDidChangeNotification, object: self)
            
            if let nowPlayingItem = player.nowPlayingItem {
                self.update(for: nowPlayingItem)
            }
        }
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.updateLyricsLineIfNeeded()
        }
        
        _ = UserDefaults.appGroup.userSpecifiedLyricsByMediaIDs
        userSpecifiedLyricsObserver = UserDefaults.appGroup.observe(\.userSpecifiedLyricsByMediaIDs) { _, _ in
            DispatchQueue.main.async {
                guard let nowPlaying = self.nowPlaying,
                    let lyrics = nowPlaying.item.kjy_userSpecifiedLyrics else { return }
                nowPlaying.lyrics = lyrics
                nowPlaying.isLyricsUserSpecified = true
                
                NotificationCenter.default.post(name: SystemPlayerLyricsController.nowPlayingLyricsDidChangeNotification, object: self)
                self.updateLyricsLineIfNeeded()
            }
        }
    }
    
    private var userSpecifiedLyricsObserver: NSKeyValueObservation?
    
    private let lyricsManager = LyricsProviderManager()
    
    public class NowPlaying {
        public let item: MPMediaItem
        public let searchRequest: LyricsSearchRequest
        public fileprivate(set) var lyrics: Lyrics
        public fileprivate(set) var isLyricsUserSpecified = false
        
        public fileprivate(set) var availableLyricsArray = [Lyrics]()
        
        fileprivate init(item: MPMediaItem, searchRequest: LyricsSearchRequest, lyrics: Lyrics) {
            self.item = item
            self.searchRequest = searchRequest
            self.lyrics = lyrics
        }
    }
    public private(set) var nowPlaying: NowPlaying?
    public private(set) var currentLyricsLine: LyricsLine?
    
    private func update(for nowPlayingItem: MPMediaItem) {
        
        let title = (nowPlayingItem.title ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let artist = (nowPlayingItem.artist ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !title.isEmpty else { return }
        
        let duration = nowPlayingItem.playbackDuration
        
        dprint(title, artist, duration)
        
        let request = LyricsSearchRequest(searchTerm: .info(title: title, artist: artist), title: title, artist: artist, duration: duration)
        
        if let userSpecifiedLyrics = nowPlayingItem.kjy_userSpecifiedLyrics {
            nowPlaying = NowPlaying(item: nowPlayingItem, searchRequest: request, lyrics: userSpecifiedLyrics)
            nowPlaying?.isLyricsUserSpecified = true
            
            NotificationCenter.default.post(name: SystemPlayerLyricsController.nowPlayingLyricsDidChangeNotification, object: self)
            updateLyricsLineIfNeeded()
        }
        
        _ = lyricsManager.searchLyrics(withRequest: request) { lyrics in
            guard nowPlayingItem == MPMusicPlayerController.systemMusicPlayer.nowPlayingItem else { return }
            
            if let nowPlaying = self.nowPlaying, nowPlaying.item == nowPlayingItem {
                nowPlaying.availableLyricsArray.append(lyrics)
                
                if !nowPlaying.isLyricsUserSpecified, lyrics.quality > nowPlaying.lyrics.quality {
                    nowPlaying.lyrics = lyrics
                    
                    NotificationCenter.default.post(name: SystemPlayerLyricsController.nowPlayingLyricsDidChangeNotification, object: self)
                    self.updateLyricsLineIfNeeded()
                }
                NotificationCenter.default.post(name: SystemPlayerLyricsController.availableLyricsArrayDidChangeNotification, object: self)
            } else {
                let nowPlaying = NowPlaying(item: nowPlayingItem, searchRequest: request, lyrics: lyrics)
                nowPlaying.availableLyricsArray.append(lyrics)
                
                self.nowPlaying = nowPlaying
                
                NotificationCenter.default.post(name: SystemPlayerLyricsController.nowPlayingLyricsDidChangeNotification, object: self)
                self.updateLyricsLineIfNeeded()
                NotificationCenter.default.post(name: SystemPlayerLyricsController.availableLyricsArrayDidChangeNotification, object: self)
            }
        }
    }
    
    private func updateLyricsLineIfNeeded() {
        let player = MPMusicPlayerController.systemMusicPlayer
        
        guard let nowPlaying = nowPlaying,
            player.playbackState == .playing,
            nowPlaying.item == player.nowPlayingItem else { return }
        
        let currentPosition = player.currentPlaybackTime + 0.25 // add 0.25 second to compensate notification animation
        
        if let line = nowPlaying.lyrics.lines.reversed().first(where: { $0.position < currentPosition }) {
            currentLyricsLine = line
            NotificationCenter.default.post(name: SystemPlayerLyricsController.lyricsLineDidChangeNotification, object: self)
        }
    }
}


public extension SystemPlayerLyricsController {
    static let nowPlayingLyricsDidChangeNotification = Notification.Name("SystemPlayerLyricsController.nowPlayingLyricsDidChangeNotification")
    static let lyricsLineDidChangeNotification = Notification.Name("SystemPlayerLyricsController.lyricsLineDidChangeNotification")
    static let availableLyricsArrayDidChangeNotification = Notification.Name("SystemPlayerLyricsController.availableLyricsArrayDidChangeNotification")
}
