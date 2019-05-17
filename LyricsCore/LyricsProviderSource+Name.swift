//
//  LyricsProviderSource+Name.swift
//  LyricsUI
//
//  Created by Jonny Kuang on 5/17/19.
//  Copyright © 2019 Jonny Kuang. All rights reserved.
//

extension LyricsProviderSource {
    var localizedName: String {
        return NSLocalizedString(rawValue, bundle: .current, comment: "")
    }
}

extension Bundle {
    private class Placeholder {}
    static let current = Bundle(for: Placeholder.self)
}
