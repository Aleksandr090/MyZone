//
//  SignupViewController.swift
//  MyZone
//

import UIKit
import CoreLocation

class SignupViewController: BaseViewController {
    
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var lblTerms:UILabel!
    @IBOutlet weak var txtFUserNm:MZTextField!
    @IBOutlet weak var txtFPass:MZTextField!
    @IBOutlet weak var txtConfirmPass:MZTextField!
    @IBOutlet weak var txtFEmail:MZTextField!
    @IBOutlet weak var txtFPhone:MZTextField!
    @IBOutlet weak var continueButton: MZButton!
    @IBOutlet weak var haveAnAccountButton: UIButton!
    @IBOutlet weak var loginButton: MZButton!

    let locationManager = CLLocationManager()

    var lat: Double = 24.7136
    var lng: Double = 46.6753
    var address = "Riyadh Saudi Arabia"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back-arrow"), style: .plain, target:  self, action: #selector(backButtonClicked))
        navigationItem.leftBarButtonItem = backButtonItem
        
        // Ask for Authorisation from the User.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        
        setupUI()
    }
    
    @objc func backButtonClicked() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupUI() {
        topContainerView.roundCorners([.bottomLeft, .bottomRight], radius: 15)
        
//        if BaseApp.sharedInstance.langStr == "ar" {
//            btnBack.setImage(#imageLiteral(resourceName: "side-arrow"), for: .normal)
//        } else {
//            btnBack.setImage(#imageLiteral(resourceName: "back-black"), for: .normal)
//        }
        
        
        // Setup term label
        let tncText = "By Continuing you agree to your Terms of Service and Privacy Policy"
        lblTerms.text = tncText
        self.lblTerms.textColor = UIColor.AppTheme.TextColor
        let underlineAttriString = NSMutableAttributedString(string: tncText)
        let range1 = (tncText as NSString).range(of: "Terms of Service")
        underlineAttriString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range1)
        underlineAttriString.addAttribute(NSAttributedString.Key.font, value: UIFont.init(name: "SFProDisplay-Regular", size: 14)!, range: range1)
        underlineAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemBlue, range: range1)
        let range2 = (tncText as NSString).range(of: "Privacy Policy")
        underlineAttriString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range2)
        underlineAttriString.addAttribute(NSAttributedString.Key.font, value: UIFont.init(name: "SFProDisplay-Regular", size: 14)!, range: range2)
        underlineAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemBlue, range: range2)
        lblTerms.attributedText = underlineAttriString
        lblTerms.isUserInteractionEnabled = true
        lblTerms.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(tapLabel(gesture:))))

        let button = txtFPass.setView(.right, image: UIImage(systemName: "eye.slash.fill"), selectedImage: UIImage(systemName: "eye.fill"), width: 60)
        button.tintColor = UIColor.AppTheme.PlaceholderColor
        button.tag = 100
        button.addTarget(self, action: #selector(self.textFieldActionClicked), for: .touchUpInside)

        let button2 = txtConfirmPass.setView(.right, image: UIImage(systemName: "eye.slash.fill"), selectedImage: UIImage(systemName: "eye.fill"), width: 60)
        button2.tintColor = UIColor.AppTheme.PlaceholderColor
        button2.tag = 101
        button2.addTarget(self, action: #selector(self.textFieldActionClicked), for: .touchUpInside)
    }
    
    @objc func textFieldActionClicked(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.tag == 100 {
            txtFPass.isSecureTextEntry = !txtFPass.isSecureTextEntry
        } else if sender.tag == 101 {
            txtConfirmPass.isSecureTextEntry = !txtConfirmPass.isSecureTextEntry
        }
    }
        
    @IBAction func loginBtn(_ sender:UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func continueBtn(_ sender:UIButton) {
        let validation = self.checkFormValidation()
        if validation.status {
            
            geocode(latitude: lat, longitude: lng) { placeMarker, error in
                guard let place = placeMarker?.first else {
                    print("No placemark from Apple: \(String(describing: error))")
                    return
                }
                self.address = place.locality ?? ""
                
                let param = ["user_name": self.txtFUserNm.text!,
                             "contact_no": self.txtFPhone.text!,
                             "email": self.txtFEmail.text!,
                             "password": self.txtFPass.text!,
                             "isSocial": false,
                             "socialToken": "",
                             "deviceToken": ApplicationPreference.sharedManager.read(type: .fcmToken),
                             "address": self.address,
                             "displayName": self.txtFUserNm.text ?? "",
                             "language": "",
                             "longitude": self.lng,
                             "latitude": self.lat,
                             "isOnline": true] as JSONDictionary
                
                self.registerAPICall(param: param)
            }
        } else {
            MZUtilManager.showAlertWith(vc: self, title: "", message: validation.message, actionTitle: "OK")
        }
    }
    
    @IBAction func googleLoginBtn(_ sender:UIButton) {
        SocialAuthenticationManager.shared.login(with: .google, in: self) { [weak self] (userData) in
            if let userData = userData, let id = userData["id"] as? String {
                
                let param = ["user_name": userData["name"] as? String ?? "",
                             "contact_no":"",
                             "email": userData["email"] as? String ?? "",
                             "password": "",
                             "isSocial": true,
                             "socialToken": id,
                             "deviceToken": ApplicationPreference.sharedManager.read(type: .fcmToken),
                             "address": "",
                             "displayName": "",
                             "language": "",
                             "longitude": self!.lng,
                             "latitude": self!.lat,
                             "isOnline": true] as JSONDictionary
                self!.registerAPICall(param: param)
            }
        }
    }
    
    @IBAction func appleLoginBtn(_ sender:UIButton) {
        SocialAuthenticationManager.shared.login(with: .apple, in: self) { [weak self] (userData) in
            if let userData = userData, let id = userData["id"] as? String {
                let param = ["user_name": userData["name"] as? String ?? "",
                             "contact_no":"",
                             "email": userData["email"] as? String ?? "",
                             "password": "",
                             "isSocial": true,
                             "socialToken": id,
                             "deviceToken": ApplicationPreference.sharedManager.read(type: .fcmToken),
                             "address": "",
                             "displayName": "",
                             "language": "",
                             "longitude": self!.lng,
                             "latitude": self!.lat,
                             "isOnline": true] as JSONDictionary
                self!.registerAPICall(param: param)
            }
        }
    }
    
    @IBAction func tapLabel(gesture: UITapGestureRecognizer) {
        let tncText = "By Continuing you agree to your Terms of Service and Privacy Policy"
        let termsRange = (tncText as NSString).range(of: "Terms of Service")
        let privacyRange = (tncText as NSString).range(of: "Privacy Policy")
//        if gesture.didTapAttributedTextInLabel(label: lblTerms, inRange: termsRange) {
//            print("Tapped terms")
//        } else if gesture.didTapAttributedTextInLabel(label: lblTerms, inRange: privacyRange) {
//            print("Tapped privacy")
//        } else {
//            print("Tapped none")
//        }
    }
    
    func checkFormValidation() -> (status: Bool, message: String){
        var message = ""
        var status = true
        
        if (txtFUserNm.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            status = false
            message = "User Name should not be empty."
        } else if (txtFEmail.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            status = false
            message = "Email should not be empty."
        } else if (txtFPass.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            status = false
            message = "Password should not be empty."
        } else if (txtFPass.text?.count)! < 6 {
            status = false
            message = "Password should contain 6 characters."
        } else if (txtConfirmPass.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            status = false
            message = "Confirm Password should not be empty."
        } else if (txtConfirmPass.text?.count)! < 6 {
            status = false
            message = "Confirm Password should contain 6 characters."
        } else if txtFPass.text != txtConfirmPass.text {
            status = false
            message = "Password and Confirm Password should be same."
        }
        return (status, message)
    }
    
    func registerAPICall(param: JSONDictionary) {
        MZProgressLoader.show()
        
        // print("SignUp Request Param -----\(param)")

        APIController.makeRequestReturnJSON(.signup(param: param)) { (data, error,headerDict) in
        MZProgressLoader.hide()
            if error == nil {
                if let responseData = data, let userData = responseData["data"] as? JSONDictionary {

                    let user = UserLogin.updatedData(withDictionary: userData)
                    SharedPreference.saveUserData(user)
                    if let userData = SharedPreference.getUserData() {
                        // print("SignUp response userData-----\(userData)")
                    }
                    self.addUser()
                    let vc: SelectLocationViewController = UIStoryboard(storyboard: .authentication).instantiateVC()
                    self.navigationController?.pushViewController(vc, animated: true)
                } else if let responseData = data, let statusCode = responseData["status"] as? Int, statusCode == 400 {
                    
                    if let responseData = data, let response_msg = responseData["message"] as? String {
                        MZUtilManager.showAlertWith(vc: self, title: "", message: response_msg, actionTitle: "OK")
                    }
                }
            }else{
                MZUtilManager.showAlertWith(vc: self, title: "", message: (error?.desc)!, actionTitle: "OK")
            }
        }
    }
    
    func loginSocialUserAPICall(username: String, email: String, socialToken: String) {
        MZProgressLoader.show()
        let param = ["user_name": username,
                     "email": email,
                     "password": "",
                     "isSocial": true,
                     "socialToken": socialToken,
                     "deviceToken": ApplicationPreference.sharedManager.read(type: .fcmToken),
                     "longitude": self.lng,
                     "latitude": self.lat,
                     "isOnline": true] as JSONDictionary
        
        print("Social Login Request Param -----\(param)")

        APIController.makeRequestReturnJSON(.login(param: param)) { (data, error,headerDict) in
            MZProgressLoader.hide()
            if error == nil {
                if let responseData = data, let userData = responseData["data"] as? JSONDictionary {
                    
                    let user = UserLogin.updatedData(withDictionary: userData)
                    SharedPreference.saveUserData(user)
                    if let userData = SharedPreference.getUserData() {
                        print("Social Login userData-----\(userData)")
                    }
                    self.addUser()
                    let vc: SelectLocationViewController = UIStoryboard(storyboard: .authentication).instantiateVC()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                MZUtilManager.showAlertWith(vc: self, title: "", message: (error?.desc)!, actionTitle: "OK")
            }
        }
    }
    
    func geocode(latitude: Double, longitude: Double, completion: @escaping (_ placemark: [CLPlacemark]?, _ error: Error?) -> Void)  {
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude)) { placemark, error in
            guard let placemark = placemark, error == nil else {
                completion(nil, error)
                return
            }
            completion(placemark, nil)
        }
    }


}

extension SignupViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        lat = locValue.latitude
        lng = locValue.longitude
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
}
