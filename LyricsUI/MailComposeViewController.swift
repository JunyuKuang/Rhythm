//
//  MailComposeViewController.swift
//
//  Created by Jonny on 12/30/17.
//  Copyright © 2017 Junyu Kuang <lightscreen.app@gmail.com>. All rights reserved.
//

import MessageUI

public class MailComposeViewController : MFMailComposeViewController, MFMailComposeViewControllerDelegate {
    
    /// Called once the view controller is fully dismissed.
    public var completionHandler: (() -> Void)?
    
    public init?(text: String) {
        
        if !MFMailComposeViewController.canSendMail() {
            let mailAddress = FeedbackPlaceholders.mailAddress.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let additional = text.isEmpty ? "" : "?body=" + (text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
            let url = URL(string: "mailto:\(mailAddress)" + additional)!
            UIApplication.shared.open(url)
            return nil
        }
        
        super.init(nibName: nil, bundle: nil)
        
        setToRecipients([FeedbackPlaceholders.mailAddress])
        setSubject(FeedbackPlaceholders.subject)
        setMessageBody(text, isHTML: false)
        
        mailComposeDelegate = self
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        presentingViewController?.dismiss(animated: true) {
            self.completionHandler?()
            self.completionHandler = nil
        }
    }
}


private extension MailComposeViewController {
    
    struct FeedbackPlaceholders {
        static let mailAddress = "Lyrics Support<LightScreen.app@gmail.com>"
        static let subject = "Feedback - Lyrics (\(Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? ""))"
    }
}
