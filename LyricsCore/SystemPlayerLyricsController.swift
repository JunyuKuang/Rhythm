//
//  SystemPlayerLyricsController.swift
//  AppleMusicLyrics
//
//  Created by Jonny Kuang on 5/12/19.
//  Copyright © 2019 Jonny Kuang. All rights reserved.
//

import Foundation
import MediaPlayer
import LyricsProvider

public class SystemPlayerLyricsController {
    
    public static let shared = SystemPlayerLyricsController()
    
    public var nowPlayingUpdateHandler: ((NowPlaying?) -> Void)?
    public var lyricsLineUpdateHandler: ((LyricsLine) -> Void)?
    
    private init() {
        LyricsNotificationController.shared.lyricsProviderChangeRequestHandler = { source in
            DispatchQueue.main.async {
                self.updateNowPlaying(withUserSpecifiedSource: source)
            }
        }
        
        let player = MPMusicPlayerController.systemMusicPlayer
        if let nowPlayingItem = player.nowPlayingItem {
            self.update(for: nowPlayingItem)
        }
        NotificationCenter.default.addObserver(forName: .MPMusicPlayerControllerNowPlayingItemDidChange, object: player, queue: .main) { _ in
            if let nowPlayingItem = player.nowPlayingItem {
                self.update(for: nowPlayingItem)
            } else {
                LyricsNotificationController.shared.clearNotifications()
                self.nowPlayingUpdateHandler?(nil)
            }
        }
        NotificationCenter.default.addObserver(forName: .MPMusicPlayerControllerPlaybackStateDidChange, object: player, queue: .main) { _ in
            switch player.playbackState {
            case .playing:
                self.updateLyricsNotificationIfNeeded()
            case .seekingBackward, .seekingForward, .stopped:
                LyricsNotificationController.shared.clearNotifications()
            default:
                break
            }
        }
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.updateLyricsNotificationIfNeeded()
        }
    }
    
    private let lyricsManager = LyricsProviderManager()
    
    public class NowPlaying {
        public let item: MPMediaItem
        public let searchRequest: LyricsSearchRequest
        public var lyrics: Lyrics
        public var userSpecifiedSource: LyricsProviderSource?
        
        public var availableLyricsArray = [Lyrics]()
        
        fileprivate init(item: MPMediaItem, searchRequest: LyricsSearchRequest, lyrics: Lyrics) {
            self.item = item
            self.searchRequest = searchRequest
            self.lyrics = lyrics
        }
    }
    public private(set) var nowPlaying: NowPlaying?
    
    private func update(for nowPlayingItem: MPMediaItem) {
        guard nowPlayingItem != nowPlaying?.item else { return }
        
        LyricsNotificationController.shared.clearNotifications()
        
        let title = (nowPlayingItem.title ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let artist = (nowPlayingItem.artist ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !title.isEmpty else { return }
        
        let duration = nowPlayingItem.playbackDuration
        
        dprint(title, artist, duration)
        
        let request = LyricsSearchRequest(searchTerm: .info(title: title, artist: artist), title: title, artist: artist, duration: duration)
        
        _ = lyricsManager.searchLyrics(withRequest: request) { lyrics in
            guard nowPlayingItem == MPMusicPlayerController.systemMusicPlayer.nowPlayingItem else { return }
            
            if let nowPlaying = self.nowPlaying, nowPlaying.item == nowPlayingItem {
                if nowPlaying.userSpecifiedSource == nil, lyrics.quality > nowPlaying.lyrics.quality {
                    LyricsNotificationController.shared.clearNotifications()
                    nowPlaying.lyrics = lyrics
                    self.updateLyricsNotificationIfNeeded()
                }
            } else {
                self.nowPlaying = NowPlaying(item: nowPlayingItem, searchRequest: request, lyrics: lyrics)
                self.updateLyricsNotificationIfNeeded()
            }
            if let nowPlaying = self.nowPlaying {
                nowPlaying.availableLyricsArray.append(lyrics)
                self.nowPlayingUpdateHandler?(nowPlaying)
            }
        }
    }
    
    private func updateNowPlaying(withUserSpecifiedSource source: LyricsProviderSource) {
        guard let nowPlaying = nowPlaying else { return }
        nowPlaying.userSpecifiedSource = source
        
        guard nowPlaying.lyrics.metadata.source != source else { return }
        
        let update = {
            LyricsNotificationController.shared.clearNotifications()
            self.updateLyricsNotificationIfNeeded()
            self.nowPlayingUpdateHandler?(nowPlaying)
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
    
    private func updateLyricsNotificationIfNeeded() {
        let player = MPMusicPlayerController.systemMusicPlayer
        
        guard let nowPlaying = nowPlaying,
            player.playbackState == .playing,
            nowPlaying.item == player.nowPlayingItem else { return }
        
        let currentPosition = player.currentPlaybackTime + 0.25 // add 0.25 second to compensate notification animation
        
        if let line = nowPlaying.lyrics.lines.reversed().first(where: { $0.position < currentPosition }) {
            LyricsNotificationController.shared.postIfNeeded(lyricsLine: line)
            lyricsLineUpdateHandler?(line)
        }
    }
}

