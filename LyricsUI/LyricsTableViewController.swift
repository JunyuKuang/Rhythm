//
//  LyricsTableViewController.swift
//  LyricsUI
//
//  Created by Jonny Kuang on 5/13/19.
//  Copyright © 2019 Jonny Kuang. All rights reserved.
//

public class LyricsTableViewController: UITableViewController {

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
        var showsLyricsTranslation = false
        var prefersCenterAlignment = false
    }
    private var configuration = Configuration()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 56
        tableView.rowHeight = UITableView.automaticDimension
        
        configureLyricsChangeObservers()
        
        configuration.showsLyricsTranslation = UserDefaults.appGroup.showsLyricsTranslationIfAvailable
        configuration.prefersCenterAlignment = UserDefaults.appGroup.prefersCenterAlignedLayout
        
        let kvoUpdateHandler = { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.configuration.showsLyricsTranslation = UserDefaults.appGroup.showsLyricsTranslationIfAvailable
                self.configuration.prefersCenterAlignment = UserDefaults.appGroup.prefersCenterAlignedLayout
                
                let indexPath = self.tableView.indexPathForSelectedRow
                self.tableView.reloadData()
                self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .middle)
            }
        }
        kvoObservers = [
            UserDefaults.appGroup.observe(\.showsLyricsTranslationIfAvailable) { _, _ in kvoUpdateHandler() },
            UserDefaults.appGroup.observe(\.prefersCenterAlignedLayout) { _, _ in kvoUpdateHandler() },
        ]
    }
    
    private var kvoObservers = [NSKeyValueObservation]()

    
    // MARK: - UITableViewDataSource

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lyrics?.lines.count ?? 0
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let lyricsLine = lyrics!.lines[indexPath.row]
        let lyricsLineContent = lyricsLine.content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let translation = !configuration.showsLyricsTranslation ? "" : (lyricsLine.attachments.translation()?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
        
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
        
        cell.selectionStyle = .none
        
        return cell
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
    
    private static let idleDuration: TimeInterval = 3
    private var lastInteractionDate = Date.distantPast
    
    public override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging {
            lastInteractionDate = Date()
        }
    }
    
    // forbidden user interaction initiated selection.
    public override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}


class LyricsTableViewCell : UITableViewCell {
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        let textColor = selected ? tintColor! : .darkText
        textLabel?.textColor = textColor
        detailTextLabel?.textColor = textColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let labels = [textLabel, detailTextLabel].compactMap { $0 }
        labels.forEach {
            let inset = $0.frame.origin.x
            $0.frame.size.width = contentView.bounds.width - inset * 2
        }
    }
}


private extension LyricsTableViewController {
    
    func configureLyricsChangeObservers() {
        let lyricsUpdateHandler = { [weak self] in
            if let nowPlaying = SystemPlayerLyricsController.shared.nowPlaying {
                self?.lyrics = nowPlaying.lyrics
                self?.title = [nowPlaying.item.title, nowPlaying.item.artist].compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }.joined(separator: " - ")
            } else {
                self?.lyrics = nil
                self?.title = "Not Playing"
            }
        }
        lyricsUpdateHandler()
        
        NotificationCenter.default.addObserver(forName: SystemPlayerLyricsController.nowPlayingLyricsDidChangeNotification, object: nil, queue: .main) { _ in
            lyricsUpdateHandler()
        }
        NotificationCenter.default.addObserver(forName: SystemPlayerLyricsController.lyricsLineDidChangeNotification, object: nil, queue: .main) { [weak self] _ in
            if let line = SystemPlayerLyricsController.shared.currentLyricsLine {
                self?.moveFocus(to: line)
            }
        }
    }
    
    func moveFocus(to line: LyricsLine) {
        guard let lyrics = lyrics,
            let index = lyrics.lines.firstIndex(where: { $0.position == line.position }) else { return }
        
        let indexPath = IndexPath(row: index, section: 0)
        guard indexPath != tableView.indexPathForSelectedRow else { return }
        
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        self.scrollToSelectedRowWhenIdle()
    }
}
