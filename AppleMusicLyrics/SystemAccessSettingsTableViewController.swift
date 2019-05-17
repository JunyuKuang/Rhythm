//
//  SystemAccessSettingsTableViewController.swift
//  AppleMusicLyrics
//
//  Created by Jonny Kuang on 5/16/19.
//  Copyright © 2019 Jonny Kuang. All rights reserved.
//

import UIKit
import MediaPlayer
import UserNotifications
import CoreLocation

class SystemAccessSettingsTableViewController: UITableViewController {
    
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
    
    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        return locationManager
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        updateSettings()
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
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
                    setting.title = NSLocalizedString("Allow Access Apple Music", comment: "")
                    setting.usageDescription = infoDictionary["NSAppleMusicUsageDescription"] as? String ?? ""
                    
                    switch MPMediaLibrary.authorizationStatus() {
                    case .notDetermined:
                        setting.accessLevel = .notDetermined
                        setting.handler = {
                            MPMediaLibrary.requestAuthorization { _ in
                                DispatchQueue.main.async {
                                    self?.updateSettings()
                                }
                            }
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
                    setting.title = NSLocalizedString("Enable Notifications", comment: "")
                    setting.usageDescription = NSLocalizedString("This allows the app to show lyrics on the Lock Screen and Notification Center.", comment: "")
                    
                    switch notificationSettings.authorizationStatus {
                    case .notDetermined:
                        setting.accessLevel = .notDetermined
                        setting.handler = {
                            UNUserNotificationCenter.current().requestAuthorization(options: .alert) { _, _ in
                                DispatchQueue.main.async {
                                    self?.updateSettings()
                                }
                            }
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
                    setting.title = NSLocalizedString("Enable Location Services", comment: "")
                    setting.usageDescription = infoDictionary["NSLocationWhenInUseUsageDescription"] as? String ?? ""
                    
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


extension SystemAccessSettingsTableViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.updateSettings()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    }
}
