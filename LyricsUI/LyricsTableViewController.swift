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
    
    public var showsLyricsTranslationIfAvailable = true {
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
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsSelection = false
        tableView.estimatedRowHeight = 56
        tableView.rowHeight = UITableView.automaticDimension
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            if let self = self {
                self.scrollToSelectedRowWhenIdle()
            } else {
                timer.invalidate()
            }
        }
    }

    
    // MARK: - UITableViewDataSource

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lyrics?.lines.count ?? 0
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let lyricsLine = lyrics!.lines[indexPath.row]
        let lyricsLineContent = lyricsLine.content.trimmingCharacters(in: .whitespacesAndNewlines)
        let translation = !showsLyricsTranslationIfAvailable ? "" : (lyricsLine.attachments.translation()?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
        
        let requiresDetailLabel = showsLyricsTranslationIfAvailable && !translation.isEmpty
        let cellStyle: UITableViewCell.CellStyle = requiresDetailLabel ? .subtitle : .default
        let cellIdentifier = "\(cellStyle.rawValue)"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? LyricsTableViewCell(style: cellStyle, reuseIdentifier: cellIdentifier)
        cell.textLabel?.text = lyricsLineContent
        cell.detailTextLabel?.text = translation
        
        cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        cell.detailTextLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
        cell.detailTextLabel?.alpha = 0.7
        
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
}


private class LyricsTableViewCell : UITableViewCell {
    
    override var isSelected: Bool {
        didSet {
            let textColor = isSelected ? UIColor(red: 0, green: 122/255, blue: 1, alpha: 1) : .darkText
            textLabel?.textColor = textColor
            detailTextLabel?.textColor = textColor
        }
    }
}
