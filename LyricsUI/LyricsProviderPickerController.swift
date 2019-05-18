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
        
        cell.textLabel?.text = lyrics.idTags[.title]?.trimmingCharacters(in: .whitespacesAndNewlines)
        cell.detailTextLabel?.text = {
            let detailInfo = [
                [lyrics.idTags[.album], lyrics.idTags[.artist]],
                [lyrics.idTags[.lrcBy], lyrics.metadata.source?.localizedName]
            ]
            let compactDetailInfo = detailInfo.map { $0.compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) } }
            return compactDetailInfo.map { $0.joined(separator: " - ") } .joined(separator: "\n")
        }()
        
        cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        cell.detailTextLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
        cell.detailTextLabel?.textColor = .darkGray
        
        let labels = [cell.textLabel, cell.detailTextLabel].compactMap { $0 }
        labels.forEach { $0.numberOfLines = 0 }
        
        if let imageView = cell.imageView {
            let hasTranslation = lyrics.metadata.hasTranslation
            imageView.isHidden = !hasTranslation
            imageView.image = img("Translate")
            imageView.adjustsImageSizeForAccessibilityContentSizeCategory = true
            
            if !hasTranslation, traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
                imageView.image = nil
            }
        }
        
        if lyrics.idTags == SystemPlayerLyricsController.shared.nowPlaying?.lyrics.idTags {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SystemPlayerLyricsController.shared.nowPlaying?.item.kjy_userSpecifiedLyrics = lyricsArray[indexPath.row]
        dismiss(animated: true)
    }
}
