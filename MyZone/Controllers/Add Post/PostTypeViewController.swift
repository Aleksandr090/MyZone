//
//  PostTypeViewController.swift
//  MyZone
//

import UIKit
import GoogleMaps
import CoreLocation

class PostTypeViewController: UIViewController {

    @IBOutlet var mapView: GMSMapView!
    @IBOutlet weak var searchTextField: MZTextField!
    @IBOutlet weak var typeCollectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!

    var locationManager: CLLocationManager!
    var coordinates : CLLocationCoordinate2D!
    var centerCoordinates : CLLocationCoordinate2D!
    
    var zoom: Float = 10.5
    var radius: Float = 10.0
    var cityName = ""
    var address = ""
    
    var isDefaultLoaction = false
    var isLocationSelected = false
    var arrData = [TopicData.Data]()
    var selectTopic: TopicData.Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getTopicList()
        
        self.setupNavigationBar()

        if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        hasLocationPermission()
        
        let searchImage = searchTextField.setView(.left, image: UIImage(named:"search"), selectedImage: UIImage(named: "search"), width: 50)
        searchImage.isUserInteractionEnabled = false
        
        setupNextButton(isEnable:false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setDefaultLocation()
    }
    
    func setupNextButton(isEnable:Bool) {
        nextButton.isUserInteractionEnabled = isEnable
        
        let textColor = isEnable ? UIColor.AppTheme.PostNextButtonSelectTitleColor : UIColor.AppTheme.PostNextButtonTitleColor
        let backgroundColor = isEnable ? UIColor.AppTheme.PinkColor :UIColor.AppTheme.PostNextButtonBgColor
        
        nextButton.setTitleColor(textColor, for: .normal)
        nextButton.backgroundColor = backgroundColor
        
    }
    
    func setupNavigationBar() {
        let cancelButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "cancel"), style: .plain, target:  self, action: #selector(didTouchBackButton))
        
        let logoButtonItem = UIBarButtonItem(image:UIImage(named: "AppIcon"), style: .plain, target:  self, action: #selector(didTouchLogoButton))
        logoButtonItem.tintColor = UIColor.clear

        self.title = "New Community Post"
        navigationItem.rightBarButtonItem = cancelButtonItem
        navigationItem.leftBarButtonItem = logoButtonItem
        
    }
    
    func getTopicList() {
        MZProgressLoader.show()
        
        APIController.makeRequestReturnJSON(.topicList(language: L102Language.currentAppleLanguage())) { data, error, headerDic in
            
            MZProgressLoader.hide()
            
            if error == nil {
                guard let responseData = data, let jsonArray = responseData["data"] as? [JSONDictionary] else {
                    return
                }                
                self.arrData = jsonArray.compactMap{ TopicData.Data.init(json: $0) }
                
                self.typeCollectionView.reloadData()
                
            }else{
                MZUtilManager.showAlertWith(vc: self, title: "", message: (error?.desc)!, actionTitle: "OK")
            }            
        }
    }
    
    @objc func didTouchLogoButton() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    @objc func didTouchBackButton() {
        self.navigationController?.dismiss(animated: true, completion: nil)
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
    
    func setDefaultLocation() {
        // Riyadh city
//        coordinates = CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753)
//        centerCoordinates = coordinates
//
//        ApplicationPreference.sharedManager.write(type: .userLat, value: 24.7136)
//        ApplicationPreference.sharedManager.write(type: .userLong, value: 46.6753)
        
        let latitude = ApplicationPreference.sharedManager.read(type: .userLat)
        let longitude = ApplicationPreference.sharedManager.read(type: .userLong)
        coordinates = CLLocationCoordinate2D(latitude: latitude as! CLLocationDegrees, longitude: longitude as! CLLocationDegrees)
        centerCoordinates = coordinates
        
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
    
    @IBAction func pickPostZoneAction(_ sender:UIButton) {
        let vc: FilterLocationViewController = UIStoryboard(storyboard: .home).instantiateVC()
        vc.delegate = self
        vc.forPost = false
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func nextAction(_ sender:UIButton) {
        guard let selectTopic = selectTopic else { return }
        let vc: AddPostViewController = UIStoryboard(storyboard: .home).instantiateVC()
        vc.selectTopic = selectTopic
        vc.city = self.cityName
        //vc.selectedAddress = self.address
        vc.radius = self.radius
        vc.selectedLocation = self.coordinates
        vc.from = 0
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .overCurrentContext
        self.present(navVC, animated: true, completion: nil)
    }
}

extension PostTypeViewController: FilterLocationDelegate {    
    
    func locationForPost(location: CLLocationCoordinate2D, city: String, address: String, radius: Float) {
        isLocationSelected = true
        setupNextButton(isEnable: true)
        coordinates = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        centerCoordinates = coordinates
        
        self.cityName = city
        self.radius = radius
        self.address = address
        
        self.mapView.camera = GMSCameraPosition(target: coordinates, zoom: self.zoom, bearing: 0, viewingAngle: 0)
        self.createCirculerAreaOnMap(self.coordinates)
        
    }
}

extension PostTypeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostTypeCollectionCell", for: indexPath) as! PostTypeCollectionCell

        cell.contentView.addShadow(color: UIColor.AppTheme.ShadowColor,
                                   opacity:0.5,
                                   shadowRadius: 4)
        cell.imageView.sd_setImage(with: URL(string: arrData[indexPath.row].icon))
        cell.titleLabel.text = L102Language.currentAppleLanguage() == "en" ?  arrData[indexPath.row].topicNameEnglish : arrData[indexPath.row].topicNameArabic

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemHeight = (collectionView.frame.size.height/3.0)
        return CGSize(width: itemHeight , height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectTopic = arrData[indexPath.row]
        pickPostZoneAction(UIButton())
        //if isLocationSelected {
        //    setupNextButton(isEnable: true)
        //}
    }
}


extension PostTypeViewController : CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let latitude = ApplicationPreference.sharedManager.read(type: .userLat)
        let longitude = ApplicationPreference.sharedManager.read(type: .userLong)
        
        if ("\(latitude)" != "" && "\(longitude)" != "") {
            coordinates = CLLocationCoordinate2D(latitude: latitude as! CLLocationDegrees, longitude: longitude as! CLLocationDegrees)
            centerCoordinates = coordinates
            
            locationManager.stopUpdatingLocation()
            
        } else {
            let location = locations.last! as CLLocation
            
            ApplicationPreference.sharedManager.write(type: .userLong, value: location.coordinate.longitude)
            ApplicationPreference.sharedManager.write(type: .userLat, value: location.coordinate.latitude)
            
            coordinates = location.coordinate
            centerCoordinates = coordinates
        }
        self.mapView.camera = GMSCameraPosition(target: self.coordinates, zoom: self.zoom, bearing: 0, viewingAngle: 0)
        self.createCirculerAreaOnMap(self.coordinates)

       locationManager.stopUpdatingLocation()
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

class PostTypeCollectionCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                containerView.backgroundColor = UIColor.AppTheme.PinkColor.withAlphaComponent(0.4)
            }
            else {
                //containerView.backgroundColor = UIColor.AppTheme.CardBackground
                containerView.backgroundColor = UIColor.white
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
