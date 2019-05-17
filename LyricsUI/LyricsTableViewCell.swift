//
//  LyricsTableViewCell.swift
//  LyricsUI
//
//  Created by Jonny Kuang on 5/17/19.
//  Copyright © 2019 Jonny Kuang. All rights reserved.
//

class LyricsTableViewCell : UITableViewCell {
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        updateTextColor()
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        updateTextColor()
    }
    
    private func updateTextColor() {
        let textColor = isSelected ? tintColor! : .darkText
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
