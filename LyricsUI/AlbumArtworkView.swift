//
//  AlbumArtworkView.swift
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

import AVFoundation

class AlbumArtworkView : UIView {

    private let button = AlbumArtworkButton()
    var artworkButton: UIButton { return button }
    
    init() {
        super.init(frame: .zero)
        addSubview(button)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let image = button.artwork {
            button.frame = AVMakeRect(aspectRatio: image.size, insideRect: bounds)
        } else {
            button.frame = bounds
        }
    }
    
    var artwork: UIImage? {
        get { return button.artwork }
        set { button.artwork = newValue }
    }
}

private class AlbumArtworkButton : UIButton {
    
    private let placeholderImage = img("PlaceholderAlbumArtwork")
    
    var artwork: UIImage? {
        didSet {
            setImage(artwork ?? placeholderImage, for: .normal)
            setNeedsLayout()
        }
    }
    
    override var buttonType: ButtonType {
        return .system
    }
    
    init() {
        super.init(frame: .zero)
        
        clipsToBounds = true
        if #available(iOS 13, *) {
            layer.cornerCurve = .continuous
        } else {
            layer.setValue(true, forKey: "continuousCorners")
        }
        setImage(artwork ?? placeholderImage, for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = round(min(bounds.width, bounds.height) / 30)
        imageView?.frame = bounds
    }
}
