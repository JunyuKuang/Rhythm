//
//  SystemAccessSettingsTableViewController.swift
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

import LyricsUI
import CoreLocation

class SystemAccessSettingsTableViewController : UITableViewController {
    
    var preparationHandler: (() -> Void)?
    var completionHandler: (() -> Void)?
    
    private struct Setting {
        var title = ""
        var usageDescription = ""
        var accessLevel = AccessLevel.notDetermined
        var handler = {}
        
        enum AccessLevel {
            case notDetermined, authorized, denied
        }
    }
    
    private var settings = [Setting]()
    
    private lazy var locationManager = CLLocationManager()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.cellLayoutMarginsFollowReadableWidth = false
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        updateSettings()
    }
    
    
    @objc private func appDidBecomeActive() {
        updateSettings()
    }
    
    private func updateSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] notificationSettings in
            DispatchQueue.main.async {
                let openSystemSettingsHandler = {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }
                let infoDictionary = Bundle.main.localizedInfoDictionary ?? Bundle.main.infoDictionary ?? [:]
                
                var settings = [Setting]()
                
                do {
                    var setting = Setting()
                    setting.title = NSLocalizedString("allowAccessAppleMusic", comment: "")
                    setting.usageDescription = infoDictionary["NSAppleMusicUsageDescription"] as? String ?? ""
                    
                    switch MPMediaLibrary.authorizationStatus() {
                    case .notDetermined:
                        #if targetEnvironment(simulator)
                        // MPMediaLibrary.requestAuthorization is unusable on simulator
                        setting.accessLevel = .authorized
                        #else
                        setting.accessLevel = .notDetermined
                        setting.handler = {
                            MPMediaLibrary.requestAuthorization { _ in }
                        }
                        #endif
                    case .authorized:
                        setting.accessLevel = .authorized
                    default:
                        setting.accessLevel = .denied
                        setting.handler = openSystemSettingsHandler
                    }
                    settings.append(setting)
                }
                do {
                    var setting = Setting()
                    setting.title = NSLocalizedString("enableNotifications", comment: "")
                    setting.usageDescription = NSLocalizedString("enableNotificationsDescription", comment: "")
                    
                    switch notificationSettings.authorizationStatus {
                    case .notDetermined:
                        setting.accessLevel = .notDetermined
                        setting.handler = {
                            var options = UNAuthorizationOptions.alert
                            if #available(iOS 12.0, *) {
                                options.insert(.providesAppNotificationSettings)
                            }
                            UNUserNotificationCenter.current().requestAuthorization(options: options) { _, _ in }
                        }
                    case .authorized:
                        setting.accessLevel = .authorized
                    default:
                        setting.accessLevel = .denied
                        setting.handler = openSystemSettingsHandler
                    }
                    settings.append(setting)
                }
                do {
                    var setting = Setting()
                    setting.title = NSLocalizedString("enableLocation", comment: "")
                    setting.usageDescription = infoDictionary["NSLocationWhenInUseUsageDescription"] as? String ?? ""
                    if #available(iOS 13, *) {
                        setting.usageDescription += "\n" + NSLocalizedString("enableLocationAdditionalDescriptionForIOS13", comment: "")
                    }
                    
                    switch CLLocationManager.authorizationStatus() {
                    case .notDetermined:
                        setting.accessLevel = .notDetermined
                        setting.handler = {
                            self?.locationManager.requestAlwaysAuthorization()
                        }
                    case .authorizedAlways, .authorizedWhenInUse:
                        setting.accessLevel = .authorized
                    default:
                        setting.accessLevel = .denied
                        setting.handler = openSystemSettingsHandler
                    }
                    settings.append(setting)
                }
                
                if settings.contains(where: { $0.accessLevel != .authorized }) {
                    self?.preparationHandler?()
                    self?.preparationHandler = nil
                    
                    self?.settings = settings
                    self?.tableView.reloadData()
                } else {
                    self?.completionHandler?()
                    self?.completionHandler = nil
                }
            }
        }
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return settings.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        let setting = settings[indexPath.section]
        
        cell.textLabel?.text = setting.title
        cell.detailTextLabel?.text = setting.usageDescription
        cell.accessoryType = setting.accessLevel == .authorized ? .checkmark : .none
        
        cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        cell.detailTextLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
        
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let setting = settings[indexPath.section]
        setting.handler()
        
        if setting.accessLevel == .authorized {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
