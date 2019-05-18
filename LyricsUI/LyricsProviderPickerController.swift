//
//  LyricsProviderPickerController.swift
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
    private var isTranslatedLyricsExist = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateContent()
        NotificationCenter.default.addObserver(forName: SystemPlayerLyricsController.availableLyricsArrayDidChangeNotification, object: nil, queue: .main) { [weak self] _ in
            self?.updateContent()
        }
    }
    
    private func updateContent() {
        lyricsArray = (SystemPlayerLyricsController.shared.nowPlaying?.availableLyricsArray ?? []).sorted { $0.quality > $1.quality }
        isTranslatedLyricsExist = lyricsArray.contains { $0.metadata.hasTranslation }
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
            if isTranslatedLyricsExist {
                let hasTranslation = lyrics.metadata.hasTranslation
                imageView.isHidden = !hasTranslation
                imageView.image = img("Translate")
                imageView.adjustsImageSizeForAccessibilityContentSizeCategory = true
                
                if !hasTranslation, traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
                    imageView.image = nil
                }
            } else {
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
