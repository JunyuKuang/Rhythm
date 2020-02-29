//
//  LyricsTableViewCell.swift
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
        let textColor = isSelected ? tintColor! : UIColor.globalTint == .highContrastiveGlobalTint ? .kjy_secondaryLabel : .kjy_label
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
    
    private weak var highlightView: UIView?
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            let highlightView = UIView()
            highlightView.clipsToBounds = true
            
            let layer = highlightView.layer
            layer.cornerRadius = 12
            if #available(iOS 13, *) {
                layer.cornerCurve = .continuous
            } else {
                layer.setValue(true, forKey: "continuousCorners")
            }
            highlightView.backgroundColor = UIColor.globalTint.withAlphaComponent(0.3)
            
            contentView.addSubview(highlightView)
            
            highlightView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                highlightView.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.safeAreaLayoutGuide.leadingAnchor, multiplier: 1),
                highlightView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
                contentView.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: highlightView.trailingAnchor, multiplier: 1),
                highlightView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor),
            ])
            self.highlightView = highlightView
        }
        else if let highlightView = highlightView {
            let animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 1) {
                highlightView.alpha = 0
            }
            animator.addCompletion { _ in
                highlightView.removeFromSuperview()
            }
            animator.startAnimation()
        }
    }
}
