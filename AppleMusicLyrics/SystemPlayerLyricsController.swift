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

class SystemPlayerLyricsController {
    
    static let shared = SystemPlayerLyricsController()
    
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
    
    private class NowPlaying {
        let item: MPMediaItem
        let searchRequest: LyricsSearchRequest
        var lyrics: Lyrics
        var userSpecifiedSource: LyricsProviderSource?
        
        init(item: MPMediaItem, searchRequest: LyricsSearchRequest, lyrics: Lyrics) {
            self.item = item
            self.searchRequest = searchRequest
            self.lyrics = lyrics
        }
    }
    private var nowPlaying: NowPlaying?
    
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
        }
    }
    
    private func updateNowPlaying(withUserSpecifiedSource source: LyricsProviderSource) {
        guard let nowPlaying = nowPlaying else { return }
        nowPlaying.userSpecifiedSource = source
        
        guard nowPlaying.lyrics.metadata.source != source else { return }
        
        _ = lyricsManager.searchLyrics(withRequest: nowPlaying.searchRequest, sources: [source]) { lyrics in
            guard self.nowPlaying === nowPlaying else { return }
            LyricsNotificationController.shared.clearNotifications()
            nowPlaying.lyrics = lyrics
            self.updateLyricsNotificationIfNeeded()
        }
    }
    
    private func updateLyricsNotificationIfNeeded() {
        let notificationController = LyricsNotificationController.shared
        let player = MPMusicPlayerController.systemMusicPlayer
        
        guard let nowPlaying = nowPlaying,
            notificationController.isPostable,
            player.playbackState == .playing,
            nowPlaying.item == player.nowPlayingItem else { return }
        
        let currentPosition = player.currentPlaybackTime + 0.25 // add 0.25 second to compensate notification animation
        
        if let line = nowPlaying.lyrics.lines.reversed().first(where: { $0.position < currentPosition }) {
            notificationController.postIfNeeded(lyricsLine: line)
        }
    }
}

