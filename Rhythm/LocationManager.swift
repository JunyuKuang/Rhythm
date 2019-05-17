//
//  LocationManager.swift
//
//  Created by Jonny on 5/22/18.
//  Copyright © 2018 Junyu Kuang <lightscreen.app@gmail.com>. All rights reserved.
//

import LyricsCore
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
            
            dprint("startUpdatingLocation")
            
        default:
            dprint("location services unavailable")
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
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            dprint("location access granted")
        default:
            dprint("location access denied")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        dprint("locations.count", locations.count)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        dprint(error)
        isRunning = false
    }
}
