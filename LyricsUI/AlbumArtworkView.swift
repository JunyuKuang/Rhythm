//
//  AlbumArtworkView.swift
//  LyricsUI
//
//  Created by Jonny Kuang on 5/18/19.
//  Copyright © 2019 Jonny Kuang. All rights reserved.
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
