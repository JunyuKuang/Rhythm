//
//  AlbumArtworkView.swift
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

import AVFoundation

class AlbumArtworkView : UIView {

    private let placeholderImage = img("PlaceholderAlbumArtwork")
    private lazy var imageView = AlbumArtworkImageView(image: placeholderImage)
    
    init() {
        super.init(frame: .zero)
        addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        if let image = imageView.image {
            imageView.frame = AVMakeRect(aspectRatio: image.size, insideRect: bounds)
        } else {
            imageView.frame = bounds
        }
    }
    
    var artwork: UIImage? {
        didSet {
            imageView.image = artwork ?? placeholderImage
            setNeedsLayout()
        }
    }
}

private class AlbumArtworkImageView : UIImageView {
    
    override init(image: UIImage?) {
        super.init(image: image)
        
        backgroundColor = UIColor(white: 0.95, alpha: 1)
        clipsToBounds = true
        layer.setValue(true, forKey: "continuousCorners")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        layer.cornerRadius = round(min(bounds.width, bounds.height) / 30)
    }
}
