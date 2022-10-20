//
//  SelectLocationViewController.swift
//  MyZone
//


import UIKit
import GoogleMaps
import CoreLocation

class SelectLocationViewController: UIViewController {
    
    enum SelectLocationVCType {
        case fromAuth
        case fromHome
    }
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var lbltxt: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    var locationManager: CLLocationManager!
    var coordinates : CLLocationCoordinate2D!
    var centerCoordinates : CLLocationCoordinate2D!
    
    var zoom: Float = 10.5
    var radius: Float = 10.0
    var cityName = ""
    
    var isDefaultLoaction = false
    var vcType = SelectLocationVCType.fromAuth
    
    var isMyLocation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        hasLocationPermission()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        /* if vcType == .fromHome {
         backButton.isHidden = false
         } else {
         backButton.isHidden = true
         }*/
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
//        setDefaultLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        //        self.navigationController?.popViewController(animated: true)
    }
    
    func setupUI() {
        topView.cornerRadiusValue = 8
        topView.addShadow(color: UIColor.AppTheme.ShadowColor,
                          opacity: 1,
                          shadowRadius: 8)
        
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.delegate = self
        
        let latitude = ApplicationPreference.sharedManager.read(type: .userLat)
        let longitude = ApplicationPreference.sharedManager.read(type: .userLong)
        
        if ("\(latitude)" == "" && "\(longitude)" == "") {
            self.setDefaultLocation()
        }
        doneButton.layer.cornerRadius = 4
        
        if let radius = ApplicationPreference.sharedManager.read(type: .userRadius) as? Float {
            self.radius = radius
        } else {
            self.radius = 10
            ApplicationPreference.sharedManager.write(type: .userRadius, value: 10.0)
        }
        self.slider.value = Float(self.radius)
        self.lbltxt.text = "Feed Radius: \(Int(self.slider.value)) KM"
    }
    
    @objc func appMovedToForeground() {
        print("App moved to Foreground!")
        hasLocationPermission()
    }
    
    @IBAction func sliderChange(_ sender: UIButton) {
        if self.centerCoordinates != nil {
            DispatchQueue.main.async {
                self.radius = self.slider.value
                self.mapView.clear()
                self.lbltxt.text = "Feed Radius: \(Int(self.slider.value)) KM"
                
                self.createCirculerAreaOnMap(self.centerCoordinates)
            }
        } else {
            self.lbltxt.text = "Feed Radius: \(Int(self.slider.value)) KM"
        }
    }
    
    @IBAction func doneBtn(_ sender:UIButton) {
        
        ApplicationPreference.sharedManager.write(type: .userRadius, value: radius)
        ApplicationPreference.sharedManager.write(type: .userLong, value: coordinates.longitude)
        ApplicationPreference.sharedManager.write(type: .userLat, value: coordinates.latitude)
        
        if let window = UIApplication.shared.windows.first {
            let vc: TabBarController = UIStoryboard(storyboard: .main).instantiateVC()
            window.rootViewController = vc
            window.makeKeyAndVisible()
        }
        
        //        sceneDelegate.openHomeWithMenu(index: 0)
        //        let vc: LoginViewController = UIStoryboard(storyboard: .authentication).instantiateVC()
        //        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setDefaultLocation() {
        // Riyadh city
        coordinates = CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753)
        centerCoordinates = coordinates

        ApplicationPreference.sharedManager.write(type: .userLat, value: 24.7136)
        ApplicationPreference.sharedManager.write(type: .userLong, value: 46.6753)
          
        self.mapView.camera = GMSCameraPosition(target: coordinates, zoom: self.zoom, bearing: 0, viewingAngle: 0)
        self.createCirculerAreaOnMap(self.coordinates)
    }
    
    func showLocationAlert() {
        let alertController = UIAlertController(title: "Location Permission Required", message: "Please enable location permissions in settings.", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Settings", style: .default, handler: {(cAlertAction) in
            //Redirect to Settings app
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {(alertAction) in
            self.setDefaultLocation()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func hasLocationPermission() {
        if CLLocationManager.locationServicesEnabled() {
            if #available(iOS 14.0, *) {
                switch locationManager.authorizationStatus {
                case .notDetermined:
                    // show default alert here
                    locationManager.delegate = self
                    locationManager.requestWhenInUseAuthorization()
                case .authorizedAlways, .authorizedWhenInUse:
                    isDefaultLoaction = false
                case .restricted, .denied:
                    isDefaultLoaction = true
                    self.showLocationAlert()
                @unknown default:
                    break
                }
            } else {
                // Fallback on earlier versions
            }
        } else {
            self.showLocationAlert()
        }
    }
    
    func createCirculerAreaOnMap(_ centerPosition: CLLocationCoordinate2D) {
        self.mapView.clear()
        DispatchQueue.main.async { [self] in
            let circ = GMSCircle(position: centerPosition, radius: Double(self.radius) * 1000)
            circ.fillColor = #colorLiteral(red: 1, green: 0.7827125192, blue: 0.9890199304, alpha: 0.5)
            circ.strokeColor = UIColor(red: 226/255, green: 55/255, blue: 255/255, alpha: 1)
            circ.strokeWidth = 1
            circ.map = self.mapView
            
            //            if let position = self.coordinates, self.isDefaultLoaction {
            //                // Default location marker
            //                let marker = GMSMarker(position: position)
            //                marker.map = self.mapView
            //            }
        }
    }
}


extension SelectLocationViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        centerCoordinates = position.target
        createCirculerAreaOnMap(position.target)
        coordinates = position.target
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        isMyLocation = true
        hasLocationPermission()
        locationManager.startUpdatingLocation()
        return true
    }
}

extension SelectLocationViewController : CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let latitude = ApplicationPreference.sharedManager.read(type: .userLat)
        let longitude = ApplicationPreference.sharedManager.read(type: .userLong)
        
        if ("\(latitude)" != "" && "\(longitude)" != "" && !isMyLocation) {
            coordinates = CLLocationCoordinate2D(latitude: latitude as! CLLocationDegrees, longitude: longitude as! CLLocationDegrees)
            centerCoordinates = coordinates
            locationManager.stopUpdatingLocation()
        } else {
            let location = locations.last! as CLLocation
            isMyLocation = false
            ApplicationPreference.sharedManager.write(type: .userLong, value: location.coordinate.longitude)
            ApplicationPreference.sharedManager.write(type: .userLat, value: location.coordinate.latitude)
            
            coordinates = location.coordinate
            centerCoordinates = coordinates
        }
        self.mapView.camera = GMSCameraPosition(target: self.coordinates, zoom: self.zoom, bearing: 0, viewingAngle: 0)
        self.createCirculerAreaOnMap(self.coordinates)        
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if #available(iOS 14.0, *) {
            switch manager.authorizationStatus {
            case .notDetermined:
                // show default alert here
                locationManager.delegate = self
                locationManager.requestWhenInUseAuthorization()
            case .authorizedAlways, .authorizedWhenInUse:
                isDefaultLoaction = false
            case .restricted, .denied:
                isDefaultLoaction = true
                self.showLocationAlert()
            @unknown default:
                break
            }
        } else {
            // Fallback on earlier versions
        }
    }
}
