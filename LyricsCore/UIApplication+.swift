//
//  UIApplication+.swift
//  LyricsCore
//
//  Created by Jonny Kuang on 9/6/22.
//  Copyright © 2022 Jonny Kuang. All rights reserved.
//

public extension UIApplication {
    
    static let kjy_shared = value(forKey: "sharedApplication") as! UIApplication
    
    func kjy_open(_ url: URL, options: [OpenExternalURLOptionsKey : Any] = [:], completionHandler: ((Bool) -> Void)? = nil) {
        Self.configureOpenURLSwizzle
        kjy_swizzle_open(url, options: options, completionHandler: completionHandler)
    }
}

private extension UIApplication {
    
    static let configureOpenURLSwizzle: Void = {
        let aClass = UIApplication.self
        let originalMethod = NSSelectorFromString("openURL:options:completionHandler:")
        let swizzledSelector = #selector(UIApplication.kjy_swizzle_open)
        
        if let originalMethod = class_getInstanceMethod(aClass, originalMethod),
           let swizzledMethod = class_getInstanceMethod(aClass, swizzledSelector)
        {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        } else {
            assertionFailure()
        }
    }()
    
    @objc func kjy_swizzle_open(_ url: URL, options: [OpenExternalURLOptionsKey : Any], completionHandler: ((Bool) -> Void)?) {
        kjy_swizzle_open(url, options: options, completionHandler: completionHandler)
    }
}
