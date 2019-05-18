//
//  LocationManager.swift
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

import CoreLocation

class LocationManager : NSObject {
    
    static let shared = LocationManager()
    
    private override init() {
        super.init()
        manager.delegate = self
    }
    
    private let manager = CLLocationManager()
    
    private(set) var isRunning = false
    
    /// Start the location updates so the app can be constantly running in background.
    func start() {
        guard !isRunning else { return }
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            manager.requestAlwaysAuthorization()
            fallthrough
            
        case .authorizedAlways, .authorizedWhenInUse:
            isRunning = true
            
            manager.allowsBackgroundLocationUpdates = true
            manager.pausesLocationUpdatesAutomatically = false
            
            manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            manager.distanceFilter = CLLocationDistanceMax
            
            manager.startUpdatingLocation()
            
        default:
            break
        }
    }
    
    /// Stop the location updates to preserve battery life.
    func stop() {
        manager.stopUpdatingLocation()
        isRunning = false
    }
}

extension LocationManager : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isRunning = false
    }
}
