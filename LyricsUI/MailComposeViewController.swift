//
//  MailComposeViewController.swift
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
        static let mailAddress = "Rhythm Support<LightScreen.app@gmail.com>"
        static let subject = "Feedback - Rhythm (\(Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? ""))"
    }
}
