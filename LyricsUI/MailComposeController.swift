//
//  MailComposeController.swift
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

public struct MailComposeController {
    
    static func compose() {
        let mailAddress = FeedbackPlaceholders.mailAddress.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let subject = FeedbackPlaceholders.subject.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        let url = URL(string: "mailto:\(mailAddress)?subject=\(subject)")!
        UIApplication.shared.open(url)
    }
}


private extension MailComposeController {
    
    struct FeedbackPlaceholders {
        static let mailAddress = "Rhythm Support<LightScreen.app@gmail.com>"
        static let subject = "Feedback - Rhythm (\(Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? ""))"
    }
}
