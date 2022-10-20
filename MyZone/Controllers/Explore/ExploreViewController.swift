//
//  ExploreViewController.swift
//  MyZone
//

import UIKit
import GoogleMaps
import CoreLocation
import AVFoundation
import MapKit

class ExploreViewController: BaseViewController {
    
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet weak var searchTextField: MZTextField!
    @IBOutlet weak var typeCollectionView: UICollectionView!
    
    var locationManager: CLLocationManager!
    var coordinates : CLLocationCoordinate2D!
    var centerCoordinates : CLLocationCoordinate2D!
    
    var zoom: Float = 10.5
    var radius: Int = 18
    var cityName = ""
    
    var isDefaultLoaction = false
    
    var arrData = [TopicData.Data]()
    
    var cancleBotton:UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        hasLocationPermission()
        
        let searchImage = searchTextField.setView(.left, image: UIImage(named: "search"), selectedImage: UIImage(named: "search"), width: 60)
        
        searchImage.addTarget(self, action: #selector(clickSearch), for: .touchUpInside)
        
        cancleBotton = searchTextField.setView(.right, image: UIImage(named: "cancel"), selectedImage: UIImage(named: "cancel"), width: 60)
        cancleBotton.isHidden = true
        cancleBotton.isUserInteractionEnabled = true
        cancleBotton.addTarget(self, action: #selector(didButtonClick), for: .touchUpInside)
        
        self.navigationItem.title = "Explore"
        
        mapView.delegate = self
        mapView.setMinZoom(4.5, maxZoom: 12)
        
        setupSideMenu()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !SharedPreference.isUserLogin {
            MZUtilManager.showLoginAlert()
            return
        }
        
        getTopicList()
    }
    
    func getTopicList() {
        MZProgressLoader.show()
        
        APIController.makeRequestReturnJSON(.topicList(language: L102Language.currentAppleLanguage())) { data, error, headerDic in
            
            MZProgressLoader.hide()
            
            if error == nil {
                guard let responseData = data, let jsonArray = responseData["data"] as? [JSONDictionary] else {
                    return
                }
                self.arrData = jsonArray.compactMap{ TopicData.Data.init(json: $0) }.sorted(by: { $0.topicNameEnglish.firstUppercased < $1.topicNameEnglish.firstUppercased })
                
                self.typeCollectionView.reloadData()
                
            }else{
                MZUtilManager.showAlertWith(vc: self, title: "", message: (error?.desc)!, actionTitle: "OK")
            }
        }
    }
    
    //Action
    @objc func clickSearch() {
        showPostsByType()
    }
    
    @objc func didButtonClick(){
        searchTextField.text = ""
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
            
            let radius: Double = calculateCircleRadiusMeterForMapCircle(_targetRadiusDip: self.radius, _circleCenterLatitude: centerPosition.latitude, _currentMapZoom: self.zoom)
            
            let circ = GMSCircle(position: centerPosition, radius: radius * 10)
            circ.fillColor = #colorLiteral(red: 1, green: 0.7827125192, blue: 0.9890199304, alpha: 0.5)
            circ.strokeColor = UIColor(red: 226/255, green: 55/255, blue: 255/255, alpha: 1)
            circ.strokeWidth = 1
            circ.map = self.mapView
        }
    }
    
    func showPostsByType() {
        
        ApplicationPreference.sharedManager.write(type: .userLong, value: self.coordinates.longitude)
        ApplicationPreference.sharedManager.write(type: .userLat, value: self.coordinates.latitude)
        
        let vc: SearchResultViewController = UIStoryboard(storyboard: .home).instantiateVC()
        vc.postListType = searchTextField.text!        
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func calculateCircleRadiusMeterForMapCircle(_targetRadiusDip: Int, _circleCenterLatitude: Double, _currentMapZoom: Float) -> Double {
        let arbitraryValueForDip = 156000.0
        let oneDipDistance = abs(cos(_circleCenterLatitude.degreesToRadians)) * arbitraryValueForDip / pow(2.0, Double(_currentMapZoom))
        return oneDipDistance * Double(_targetRadiusDip)
    }
}

extension BinaryInteger {
    var degreesToRadians: CGFloat { CGFloat(self) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { self * .pi / 180 }
    var radiansToDegrees: Self { self * 180 / .pi }
}

extension ExploreViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrData.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostTypeCollectionCell", for: indexPath) as! PostTypeCollectionCell
        
        cell.contentView.addShadow(color: UIColor.AppTheme.ShadowColor, opacity: 0.5,   shadowRadius: 4)
        if indexPath.row == 0 {
            cell.titleLabel.text = "All"
        } else {
            let text = L102Language.isRTL ? arrData[indexPath.row-1].topicNameArabic : arrData[indexPath.row-1].topicNameEnglish
            cell.titleLabel.text = text
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var text = "All"
        if indexPath.row > 0 {
            text = L102Language.isRTL ? arrData[indexPath.row-1].topicNameArabic : arrData[indexPath.row-1].topicNameEnglish
        }
        let size: CGSize = CGSize(width: text.size(withAttributes: [NSAttributedString.Key.font : UIFont.init(name: "SFProDisplay-Regular", size: 18) as Any]).width + 40, height: collectionView.frame.size.height)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if arrData.count > 1 {
            searchTextField.text = indexPath.row == 0 ? "All" :  L102Language.currentAppleLanguage() == "en" ?  arrData[indexPath.row-1].topicNameEnglish : arrData[indexPath.row-1].topicNameArabic
            cancleBotton.isHidden = false
            showPostsByType()
        }
    }
}

extension ExploreViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        centerCoordinates = position.target
        self.zoom = position.zoom
        createCirculerAreaOnMap(position.target)
        coordinates = position.target
    }
    
}

extension ExploreViewController : CLLocationManagerDelegate {
    
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

class CollectionViewFlowLayout: UICollectionViewFlowLayout {
    var tempCellAttributesArray = [UICollectionViewLayoutAttributes]()
    let leftEdgeInset: CGFloat = 10
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let cellAttributesArray = super.layoutAttributesForElements(in: rect)
        //Oth position cellAttr is InConvience Emoji Cell, from 1st onwards info cells are there, thats why we start count from 2nd position.
        if(cellAttributesArray != nil && cellAttributesArray!.count > 1) {
            for i in 1..<(cellAttributesArray!.count) {
                let prevLayoutAttributes: UICollectionViewLayoutAttributes = cellAttributesArray![i - 1]
                let currentLayoutAttributes: UICollectionViewLayoutAttributes = cellAttributesArray![i]
                let maximumSpacing: CGFloat = 8
                let prevCellMaxX: CGFloat = prevLayoutAttributes.frame.maxX
                //UIEdgeInset 30 from left
                let collectionViewSectionWidth = self.collectionViewContentSize.width - leftEdgeInset
                let currentCellExpectedMaxX = prevCellMaxX + maximumSpacing + (currentLayoutAttributes.frame.size.width )
                if currentCellExpectedMaxX < collectionViewSectionWidth {
                    var frame: CGRect? = currentLayoutAttributes.frame
                    frame?.origin.x = prevCellMaxX + maximumSpacing
                    frame?.origin.y = prevLayoutAttributes.frame.origin.y
                    currentLayoutAttributes.frame = frame ?? CGRect.zero
                } else {
                    // self.shiftCellsToCenter()
                    currentLayoutAttributes.frame.origin.x = leftEdgeInset
                    //To Avoid InConvience Emoji Cell
                    if (prevLayoutAttributes.frame.origin.x != 0) {
                        currentLayoutAttributes.frame.origin.y = prevLayoutAttributes.frame.origin.y + prevLayoutAttributes.frame.size.height + 08
                    }
                }
                // print(currentLayoutAttributes.frame)
            }
            //print("Main For Loop End")
        }
        self.shiftCellsToCenter()
        return cellAttributesArray
    }
    
    func shiftCellsToCenter() {
        if (tempCellAttributesArray.count == 0) {return}
        let lastCellLayoutAttributes = self.tempCellAttributesArray[self.tempCellAttributesArray.count-1]
        let lastCellMaxX: CGFloat = lastCellLayoutAttributes.frame.maxX
        let collectionViewSectionWidth = self.collectionViewContentSize.width - leftEdgeInset
        let xAxisDifference = collectionViewSectionWidth - lastCellMaxX
        if xAxisDifference > 0 {
            for each in self.tempCellAttributesArray{
                each.frame.origin.x += xAxisDifference/2
            }
        }
    }
}
