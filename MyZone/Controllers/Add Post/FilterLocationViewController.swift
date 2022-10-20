//
//  FilterLocationViewController.swift
//  MyZone
//


import UIKit
import GoogleMaps
import CoreLocation
import GooglePlaces


protocol FilterLocationDelegate {
    func locationForPost(location: CLLocationCoordinate2D, city: String, address: String, radius: Float)
}

class FilterLocationViewController: UIViewController {

    @IBOutlet weak var serchTextField: MZTextField!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var lbltxt: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var backButton: UIButton!

    var delegate: FilterLocationDelegate?

    var locationManager: CLLocationManager!
    var coordinates : CLLocationCoordinate2D!
    var centerCoordinates : CLLocationCoordinate2D!
    var addressString: String!

    var zoom: Float = 10.5
    var radius: Float = 10.0
    var cityName : String!
    
    var isDefaultLoaction = false

    var isSearch:Bool = false
    var isMyLocation = false
    var forPost = false

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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupUI() {
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.delegate = self
        
        doneButton.layer.cornerRadius = 4
        
        if let radius = ApplicationPreference.sharedManager.read(type: .userRadius) as? Float {
            self.radius = radius
        } else {
            self.radius = 10
            ApplicationPreference.sharedManager.write(type: .userRadius, value: 10.0)
        }
        
        self.slider.value = Float(self.radius)
        self.lbltxt.text = "Feed Radius: \(Int(self.slider.value)) KM"
        
        let searchImage = serchTextField.setView(.left, image: UIImage(named:"search"), selectedImage: UIImage(named: "search"), width: 50)
        searchImage.isUserInteractionEnabled = false
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
        if self.coordinates != nil {
            
            ApplicationPreference.sharedManager.write(type: .userLong, value: self.coordinates.longitude)
            ApplicationPreference.sharedManager.write(type: .userLat, value: self.coordinates.latitude)
            if self.addressString != nil {
                self.dismiss(animated: true, completion: { [self] in
                    self.delegate?.locationForPost(location: self.centerCoordinates, city: cityName, address: addressString ?? "", radius: radius)
                })
            } else {
                getAddressFromLatLon(pdblLatitude: "\(coordinates.latitude)", withLongitude: "\(coordinates.longitude)")
            }
        }
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
            
            if forPost {
                if let position = self.coordinates {
                    lbltxt.isHidden = true
                    slider.isHidden = true
                    let marker = GMSMarker(position: position)
                    
                    marker.map = self.mapView
                }
            } else {
                lbltxt.isHidden = false
                slider.isHidden = false
                let circ = GMSCircle(position: centerPosition, radius: Double(self.radius) * 1000)
                circ.fillColor = #colorLiteral(red: 1, green: 0.7827125192, blue: 0.9890199304, alpha: 0.5)
                circ.strokeColor = UIColor(red: 226/255, green: 55/255, blue: 255/255, alpha: 1)
                circ.strokeWidth = 1
                circ.map = self.mapView
            }
        }
    }
    
    @objc private func showPlacesSearch() {
        self.mapView.clear()
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        if ApplicationPreference.sharedManager.read(type: .isDark) as! String == "true"{
            autocompleteController.primaryTextColor = .darkGray
            autocompleteController.secondaryTextColor = .lightGray
            autocompleteController.primaryTextHighlightColor = .black
            
        }
        
        //autocompleteController.placeFields = config.placeFields
        //autocompleteController.autocompleteFilter = config.placesFilter
        
        present(autocompleteController, animated: true, completion: nil)
    }
}

extension FilterLocationViewController: UITextFieldDelegate {
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        self.showPlacesSearch()
        textField.resignFirstResponder()
    }
}



extension FilterLocationViewController: GMSMapViewDelegate {
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

extension FilterLocationViewController : CLLocationManagerDelegate {
    
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


extension FilterLocationViewController: GMSAutocompleteViewControllerDelegate {
    public func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        isSearch = true
        var i = 0
        for component in place.addressComponents! {
            i = i+1
            print(component)
            if i==1
            {
                self.cityName = component.shortName ?? "Riyadh"
            }
            
        }

        self.coordinates = place.coordinate
        serchTextField.text = place.name
        self.addressString = place.formattedAddress
        self.mapView.camera = GMSCameraPosition(target: place.coordinate, zoom: self.zoom, bearing: 0, viewingAngle: 0)
        createCirculerAreaOnMap(place.coordinate)
//        self.focusOn(coordinate: place.coordinate)
        viewController.dismiss(animated: true, completion: nil)
    }
    
    public func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    public func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}

extension FilterLocationViewController {
    
    func getAddressFromLatLon(pdblLatitude: String, withLongitude pdblLongitude: String) {
            var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
            let lat: Double = Double("\(pdblLatitude)")!
            //21.228124
            let lon: Double = Double("\(pdblLongitude)")!
            //72.833770
            let ceo: CLGeocoder = CLGeocoder()
            center.latitude = lat
            center.longitude = lon

            let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)


            ceo.reverseGeocodeLocation(loc, completionHandler:
                {(placemarks, error) in
                    if (error != nil)
                    {
                        print("reverse geodcode fail: \(error!.localizedDescription)")
                    }
                guard let placemark = placemarks else {
                    self.dismiss(animated: true, completion: { [self] in
                        self.delegate?.locationForPost(location: self.centerCoordinates, city: cityName ?? "", address: addressString ?? "", radius: radius)
                    })
                    return
                }
                    let pm = placemark as [CLPlacemark]

                    if pm.count > 0 {
                        let pm = placemarks![0]
//                        print(pm.country)
//                        print(pm.locality)
//                        print(pm.subLocality)
//                        print(pm.thoroughfare)
//                        print(pm.postalCode)
//                        print(pm.subThoroughfare)
                        var addressString : String = ""
                        if pm.subLocality != nil {
                            addressString = addressString + pm.subLocality! + ", "
                        }
                        if pm.thoroughfare != nil {
                            addressString = addressString + pm.thoroughfare! + ", "
                        }
                        if pm.locality != nil {
                            addressString = addressString + pm.locality! + ", "
                        }
                        if pm.country != nil {
                            addressString = addressString + pm.country! + ", "
                        }
                        if pm.postalCode != nil {
                            addressString = addressString + pm.postalCode! + " "
                        }

                        self.addressString = addressString
                        self.cityName = pm.locality ?? "Riyadh"
                        print(addressString)
                        
                        self.dismiss(animated: true, completion: { [self] in
                            self.delegate?.locationForPost(location: self.centerCoordinates, city: cityName, address: addressString ?? "", radius: radius)
                        })
                  }
            })

        }
}
