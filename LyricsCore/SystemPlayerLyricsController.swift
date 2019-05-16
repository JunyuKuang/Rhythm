//
//  SystemPlayerLyricsController.swift
//  AppleMusicLyrics
//
//  Created by Jonny Kuang on 5/12/19.
//  Copyright © 2019 Jonny Kuang. All rights reserved.
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
            if let nowPlayingItem = player.nowPlayingItem {
                self.update(for: nowPlayingItem)
            }
        }
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.updateLyricsLineIfNeeded()
        }
        
        userSpecifiedSourceObserver = UserDefaults.appGroup.observe(\.userSpecifiedSourcesByMediaIDs) { _, _ in
            DispatchQueue.main.async {
                guard let nowPlaying = self.nowPlaying,
                    let source = nowPlaying.item.kjy_userSpecifiedSource,
                    source != nowPlaying.userSpecifiedSource else { return }
                self.updateNowPlaying(withUserSpecifiedSource: source)
            }
        }
    }
    
    private var userSpecifiedSourceObserver: NSKeyValueObservation?
    
    private let lyricsManager = LyricsProviderManager()
    
    public class NowPlaying {
        public let item: MPMediaItem
        public let searchRequest: LyricsSearchRequest
        public fileprivate(set) var lyrics: Lyrics
        public fileprivate(set) var userSpecifiedSource: LyricsProviderSource?
        
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
        
        var sources = LyricsProviderSource.allCases
        let userSpecifiedSource = nowPlayingItem.kjy_userSpecifiedSource
        if let userSpecifiedSource = userSpecifiedSource {
            sources = [userSpecifiedSource]
        }
        
        _ = lyricsManager.searchLyrics(withRequest: request, sources: sources) { lyrics in
            guard nowPlayingItem == MPMusicPlayerController.systemMusicPlayer.nowPlayingItem else { return }
            
            if let nowPlaying = self.nowPlaying, nowPlaying.item == nowPlayingItem {
                if nowPlaying.userSpecifiedSource == nil, lyrics.quality > nowPlaying.lyrics.quality {
                    nowPlaying.lyrics = lyrics
                    nowPlaying.availableLyricsArray.append(lyrics)
                    
                    NotificationCenter.default.post(name: SystemPlayerLyricsController.nowPlayingLyricsDidChangeNotification, object: self)
                    self.updateLyricsLineIfNeeded()
                }
            } else {
                let nowPlaying = NowPlaying(item: nowPlayingItem, searchRequest: request, lyrics: lyrics)
                nowPlaying.userSpecifiedSource = userSpecifiedSource
                nowPlaying.availableLyricsArray.append(lyrics)
                
                self.nowPlaying = nowPlaying
                
                NotificationCenter.default.post(name: SystemPlayerLyricsController.nowPlayingLyricsDidChangeNotification, object: self)
                self.updateLyricsLineIfNeeded()
            }
        }
    }
    
    private func updateNowPlaying(withUserSpecifiedSource source: LyricsProviderSource) {
        guard let nowPlaying = nowPlaying else { return }
        nowPlaying.userSpecifiedSource = source
        
        guard nowPlaying.lyrics.metadata.source != source else { return }
        
        let update = {
            NotificationCenter.default.post(name: SystemPlayerLyricsController.nowPlayingLyricsDidChangeNotification, object: self)
            self.updateLyricsLineIfNeeded()
        }
        
        if let lyrics = nowPlaying.availableLyricsArray.first(where: { $0.metadata.source == source }) {
            nowPlaying.lyrics = lyrics
            update()
        } else {
            _ = lyricsManager.searchLyrics(withRequest: nowPlaying.searchRequest, sources: [source]) { lyrics in
                guard self.nowPlaying === nowPlaying else { return }
                nowPlaying.lyrics = lyrics
                update()
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
}
