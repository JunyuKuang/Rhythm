//
//  LyricsTableViewController.swift
//
//  Rhythm <https://github.com/JunyuKuang/Rhythm>
//  Copyright (C) 2019-2020  Junyu Kuang
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

public class LyricsTableViewController : UITableViewController {

    public var lyrics: Lyrics? {
        didSet {
            tableView.reloadData()
        }
    }
    
    public init() {
        super.init(style: .plain)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private struct Configuration {
        var showsTranslation = false
        var prefersCenterAlignment = false
    }
    private var configuration = Configuration()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 56
        tableView.rowHeight = UITableView.automaticDimension
        
        configureLyricsChangeObservers()
        
        configuration.showsTranslation = UserDefaults.appGroup.showsLyricsTranslationIfAvailable
        configuration.prefersCenterAlignment = UserDefaults.appGroup.prefersCenterAlignedLayout
        
        let kvoUpdateHandler = { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.configuration.showsTranslation = UserDefaults.appGroup.showsLyricsTranslationIfAvailable
                self.configuration.prefersCenterAlignment = UserDefaults.appGroup.prefersCenterAlignedLayout
                
                let indexPath = self.tableView.indexPathForSelectedRow
                self.tableView.reloadData()
                self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .middle)
            }
        }
        
        // Avoid KVO failure
        _ = [
            UserDefaults.appGroup.showsLyricsTranslationIfAvailable,
            UserDefaults.appGroup.prefersCenterAlignedLayout,
        ]
        kvoObservers = [
            UserDefaults.appGroup.observe(\.showsLyricsTranslationIfAvailable) { _, _ in kvoUpdateHandler() },
            UserDefaults.appGroup.observe(\.prefersCenterAlignedLayout) { _, _ in kvoUpdateHandler() },
        ]
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        performIfViewSizeChanged {
            tableView.tableFooterView = nil
            tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: view.bounds.height / 2 - view.safeAreaInsets.bottom))
            
            if let indexPath = tableView.indexPathForSelectedRow {
                tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
            }
        }
    }
    
    private var kvoObservers = [NSKeyValueObservation]()

    
    // MARK: - UITableViewDataSource

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lyrics?.lines.count ?? 0
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let lyricsLine = lyrics!.lines[indexPath.row]
        let lyricsLineContent = lyricsLine.content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let translation = !configuration.showsTranslation ? "" : (lyricsLine.attachments.translation()?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
        
        let requiresDetailLabel = !translation.isEmpty
        let cellStyle: UITableViewCell.CellStyle = requiresDetailLabel ? .subtitle : .default
        let cellIdentifier = "\(cellStyle.rawValue)"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? LyricsTableViewCell(style: cellStyle, reuseIdentifier: cellIdentifier)
        cell.textLabel?.text = lyricsLineContent
        cell.detailTextLabel?.text = translation
        
        cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        cell.detailTextLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        
        let labels = [cell.textLabel, cell.detailTextLabel].compactMap { $0 }
        labels.forEach { $0.numberOfLines = 0 }
        
        if configuration.prefersCenterAlignment {
            labels.forEach { $0.textAlignment = .center }
        } else {
            labels.forEach { $0.textAlignment = .natural }
        }
        
        class BackgroundView : UIView {}
        if !(cell.selectedBackgroundView is BackgroundView) {
            cell.selectedBackgroundView = BackgroundView()
        }
        
        return cell
    }
    
    
    // MARK: - UITableViewDelegate
    
    public override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let content = lyrics!.lines[indexPath.row].content.trimmingCharacters(in: .whitespacesAndNewlines)
        return !content.isEmpty
    }
    
    /// This works around an iOS bug where currentPlaybackTime sometimes seek back and cause selection flashing after we adjust it.
    private struct PlaybackTimeOverride {
        let time: TimeInterval
        let id = UUID()
    }
    private var playbackTimeOverride: PlaybackTimeOverride?
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let player = MPMusicPlayerController.systemMusicPlayer
        
        guard let lyrics = lyrics,
            let nowPlayingItem = player.nowPlayingItem else { return }
        
        var playbackTime = lyrics.lines[indexPath.row].position
        playbackTime = max(0, min(playbackTime, nowPlayingItem.playbackDuration))
        
        let override = PlaybackTimeOverride(time: playbackTime)
        self.playbackTimeOverride = override
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            if let self = self, self.playbackTimeOverride?.id == override.id {
                self.playbackTimeOverride = nil
            }
        }
        player.currentPlaybackTime = playbackTime
        
        if player.currentPlaybackRate == 0 {
            player.play()
        }
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
    }
    
    
    // MARK: - Auto Scroll
    
    private var isDeferredScrollingScheduled = false
    
    private func scrollToActiveContentIfNeeded() {
        if !isDeferredScrollingScheduled {
            scrollToSelectedRowWhenIdle()
        }
    }
    
    private func scrollToSelectedRowWhenIdle() {
        if Date().timeIntervalSince(lastInteractionDate) > type(of: self).idleDuration {
            if let indexPath = tableView.indexPathForSelectedRow {
                tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
            }
            isDeferredScrollingScheduled = false
        } else {
            isDeferredScrollingScheduled = true
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
                self?.scrollToSelectedRowWhenIdle()
            }
        }
    }
    
    private static let idleDuration: TimeInterval = 1.5
    private var lastInteractionDate = Date.distantPast
    
    public override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging {
            lastInteractionDate = Date()
        }
    }
}


private extension LyricsTableViewController {
    
    func configureLyricsChangeObservers() {
        let lyricsUpdateHandler = { [weak self] in
            if let nowPlayingItem = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem {
                self?.title = [nowPlayingItem.title, nowPlayingItem.artist].compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }.joined(separator: " - ")
            } else {
                self?.title = localized("notPlaying")
            }
            self?.lyrics = SystemPlayerLyricsController.shared.nowPlaying?.lyrics
        }
        NotificationCenter.default.addObserver(forName: SystemPlayerLyricsController.nowPlayingLyricsDidChangeNotification, object: nil, queue: .main) { _ in
            lyricsUpdateHandler()
        }
        lyricsUpdateHandler()
        
        let lineUpdateHandler = { [weak self] in
            if let line = SystemPlayerLyricsController.shared.currentLyricsLine {
                self?.moveFocus(to: line)
            }
        }
        NotificationCenter.default.addObserver(forName: SystemPlayerLyricsController.lyricsLineDidChangeNotification, object: nil, queue: .main) { _ in
            lineUpdateHandler()
        }
        lineUpdateHandler()
    }
    
    func moveFocus(to line: LyricsLine) {
        guard playbackTimeOverride == nil,
            let lyrics = lyrics,
            let index = lyrics.lines.firstIndex(where: { $0.position == line.position }) else { return }
        
        let indexPath = IndexPath(row: index, section: 0)
        guard indexPath != tableView.indexPathForSelectedRow else { return }
        
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        self.scrollToSelectedRowWhenIdle()
    }
}
