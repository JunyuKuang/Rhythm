//
//  LyricsTableViewCell.swift
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
        let textColor = isSelected ? tintColor! : .kjy_label
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
