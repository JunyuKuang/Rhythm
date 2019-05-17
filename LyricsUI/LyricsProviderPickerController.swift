//
//  LyricsProviderPickerController.swift
//  LyricsUI
//
//  Created by Jonny Kuang on 5/17/19.
//  Copyright © 2019 Jonny Kuang. All rights reserved.
//

class LyricsProviderPickerController : UIViewController {

    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .formSheet
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tableViewController = LyricsProviderPickerTableViewController()
        tableViewController.title = localized("changeLyrics")
        tableViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(tapCancelButtonItem))
        
        let childNavigationController = UINavigationController(rootViewController: tableViewController)
        
        addChild(childNavigationController)
        view.addSubview(childNavigationController.view)
        childNavigationController.view.addConstraintsToFitSuperview()
        childNavigationController.didMove(toParent: self)
    }
    
    @objc private func tapCancelButtonItem() {
        dismiss(animated: true)
    }
}


private class LyricsProviderPickerTableViewController : UITableViewController {
    
    private var lyricsArray = [Lyrics]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLyricsArray()
        NotificationCenter.default.addObserver(forName: SystemPlayerLyricsController.availableLyricsArrayDidChangeNotification, object: nil, queue: .main) { [weak self] _ in
            self?.updateLyricsArray()
        }
    }
    
    private func updateLyricsArray() {
        lyricsArray = (SystemPlayerLyricsController.shared.nowPlaying?.availableLyricsArray ?? []).sorted { $0.quality > $1.quality }
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lyricsArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        
        let lyrics = lyricsArray[indexPath.row]
        
        cell.textLabel?.text = lyrics.idTags[.title]
        
        var detailText = [lyrics.idTags[.album], lyrics.idTags[.artist]].compactMap { $0 } .joined(separator: " - ")
        if lyrics.metadata.hasTranslation {
            detailText += "\n" + localized("translated")
        }
        cell.detailTextLabel?.text = detailText
        
        cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        cell.detailTextLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        
        let labels = [cell.textLabel, cell.detailTextLabel].compactMap { $0 }
        labels.forEach { $0.numberOfLines = 0 }
        
        if lyrics.idTags == SystemPlayerLyricsController.shared.nowPlaying?.lyrics.idTags {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let lyrics = lyricsArray[indexPath.row]
        if let source = lyrics.metadata.source, let nowPlaying = SystemPlayerLyricsController.shared.nowPlaying {
            nowPlaying.item.kjy_userSpecifiedSource = source
        }
        dismiss(animated: true)
    }
}
