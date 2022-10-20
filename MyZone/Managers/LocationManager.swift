//
//  LocationManager.swift
//  MyZone
//

import UIKit
import MapKit

enum LocationResult <T> {
    case success(T)
    case failure(Error)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    
    static let shared: LocationManager = LocationManager()
    
    typealias Callback = (LocationResult <LocationManager>) -> Void
    
    var requests: Array <Callback> = Array <Callback>()
    
    var location: CLLocation? { return sharedLocationManager.location  }
    
    lazy var sharedLocationManager: CLLocationManager = {
        let newLocationmanager = CLLocationManager()
        newLocationmanager.delegate = self
        // ...
        return newLocationmanager
    }()
    
    // MARK: - Authorization
    
    class func authorize() { shared.authorize() }
    func authorize() { sharedLocationManager.requestWhenInUseAuthorization() }
    
    // MARK: - Helpers
    
    func locate(callback: @escaping Callback) {
        self.requests.append(callback)
        sharedLocationManager.startUpdatingLocation()
    }
    
    func reset() {
        self.requests = Array <Callback>()
        sharedLocationManager.stopUpdatingLocation()
    }
    
    // MARK: - Delegate
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        for request in self.requests { request(.failure(error)) }
        self.reset()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for request in self.requests { request(.success(self)) }
        self.reset()
    }
    
}
