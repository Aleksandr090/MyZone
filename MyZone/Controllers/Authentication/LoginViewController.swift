//
//  LoginViewController.swift
//  MyZone
//

import UIKit
import CoreLocation

class LoginViewController: BaseViewController {
    
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var usernameTextField: MZTextField!
    @IBOutlet weak var passwordTextField: MZTextField!
    @IBOutlet weak var loginButton: MZButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var registerButton: MZButton!
    
    let locationManager = CLLocationManager()
    
 
    var lat: Double = 24.7136
    var lng: Double = 46.6753
    var address = "Riyadh Saudi Arabia"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back-arrow"), style: .plain, target:  self, action: #selector(backButtonClicked))
        navigationItem.leftBarButtonItem = backButtonItem
        
        // self.navigationController?.isNavigationBarHidden = true
        // Do any additional setup after loading the view.
        
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
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func setupUI() {
        //        appNameLabel.text = "MyZone".localizedstr
        //        loginLabel.text = "Let's Login.".localizedstr
        //        txtFUserNm.placeholder = "User Name Or Email".localizedstr
        //        txtFPass.placeholder = "Password".localizedstr
        //        loginButton.setTitle("Login".localizedstr, for: .normal)
        //        forgotPasswordButton.setTitle("Forgot your password?".localizedstr, for: .normal)
        //        registerButton.setTitle("Register".localizedstr, for: .normal)
        
        topContainerView.roundCorners([.bottomLeft, .bottomRight], radius: 15)
        
        //        usernameTextField.text = "jeran01@yopmail.com"
        //        passwordTextField.text = "12345678"
        
        let button = passwordTextField.setView(.right, image: UIImage(systemName: "eye.slash.fill"), selectedImage: UIImage(systemName: "eye.fill"), width: 60)
        button.tintColor = UIColor.AppTheme.PlaceholderColor
        button.addTarget(self, action: #selector(self.textFieldActionClicked), for: .touchUpInside)
    }
    
    @objc func textFieldActionClicked(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        passwordTextField.isSecureTextEntry = !passwordTextField.isSecureTextEntry
    }
    
    @IBAction func loginBtn(_ sender:UIButton) {
        let validation = self.checkFormValidation()
        if validation.status {
            var param = JSONDictionary()
            param = ["user_name":usernameTextField.text!,
                     "email": usernameTextField.text!,
                     "password": passwordTextField.text!,
                     "isSocial": false,
                     "socialToken": "",
                     "deviceToken": ApplicationPreference.sharedManager.read(type: .fcmToken),
                     "longitude": lng,
                     "latitude": lat,
//                     "longitude": "83.8322",
//                     "latitude": "24.6005",
                     "isOnline": true] as JSONDictionary
            //            if usernameTextField.text!.isEmail() {
            //                param["email"] = usernameTextField.text!
            //            } else {
            //                param["user_name"] = usernameTextField.text!
            //            }
            loginAPICall(param: param)
        } else {
            MZUtilManager.showAlertWith(vc: self, title: "", message: validation.message, actionTitle: "OK")
        }
    }
    
    @IBAction func googleLoginBtn(_ sender:UIButton) {
        SocialAuthenticationManager.shared.login(with: .google, in: self) { [weak self] (userData) in
            if let userData = userData, let id = userData["id"] as? String {
                
                let param = ["user_name": userData["name"] as? String ?? "",
                             "email": userData["email"] as? String ?? "",
                             "password": "",
                             "isSocial": true,
                             "socialToken": id,
                             "deviceToken": ApplicationPreference.sharedManager.read(type: .fcmToken),
                             "longitude": self!.lng,
                             "latitude": self!.lat,
                             "isOnline": true] as JSONDictionary
                self!.loginAPICall(param: param, isSocial: true)
            }
        }
    }
    
    @IBAction func appleLoginBtn(_ sender:UIButton) {
        SocialAuthenticationManager.shared.login(with: .apple, in: self) { [weak self] (userData) in
            if let userData = userData, let id = userData["id"] as? String {
                print(userData)
                let param = ["user_name": userData["name"] as? String ?? "",
//                             "email": userData["email"] as? String ?? "",
                             "email": "\(id)@apple.com",
                             "password": "",
                             "isSocial": true,
                             "socialToken": id,
                             "deviceToken": ApplicationPreference.sharedManager.read(type: .fcmToken),
                             "longitude": self!.lng,
                             "latitude": self!.lat,
                             "isOnline": true] as JSONDictionary
                
                self!.loginAPICall(param: param, isSocial: true)
            }
        }
    }
    
    func checkFormValidation() -> (status: Bool, message: String){
        var message = ""
        var status = true
        if (usernameTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty)!{
            status = false
            message = "User Name Or Email should not be empty."
        } else if (passwordTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty)!{
            status = false
            message = "Password should not be empty."
        }else if (passwordTextField.text?.count)! < 6 {
            status = false
            message = "Password should contain 6 characters."
        }
        return (status, message)
    }
    
    
    func loginAPICall(param: JSONDictionary, isSocial: Bool = false) {
        
        MZProgressLoader.show()
        
        APIController.makeRequestReturnJSON(.login(param: param)) { (data, error,headerDict) in
            MZProgressLoader.hide()
            if error == nil {
                if let responseData = data, let userData = responseData["data"] as? JSONDictionary {
                    
                    let user = UserLogin.updatedData(withDictionary: userData)
                    
                    SharedPreference.saveUserData(user)                    
                    
                    self.addUser()
                    let vc: SelectLocationViewController = UIStoryboard(storyboard: .authentication).instantiateVC()
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                } else if let responseData = data, let statusCode = responseData["status"] as? Int, statusCode == 400 {
                    
                    if isSocial {
                        self.registerSocialUserAPICall(username: param["user_name"] as! String,
                                                       email:  param["email"] as! String,
                                                       socialToken: param["socialToken"] as! String)
                    } else {
                        MZUtilManager.showAlertWith(vc: self, title: "", message: responseData["message"] as? String ?? "", actionTitle: "OK")
                    }
                }
            } else {
                MZUtilManager.showAlertWith(vc: self, title: "", message: (error?.desc)!, actionTitle: "OK")
            }
        }
    }
    
    
    func registerSocialUserAPICall(username: String, email: String, socialToken: String) {
        MZProgressLoader.show()
        var param = JSONDictionary()
        param = ["user_name": username,
                 "contact_no":"",
                 "email": email,
                 "password": "",
                 "isSocial": true,
                 "socialToken": socialToken,
                 "deviceToken": ApplicationPreference.sharedManager.read(type: .fcmToken),
                 "address": "",
                 "displayName": "",
                 "language": "",
                 "longitude": lng,
                 "latitude": lat,
                 "isOnline": true] as JSONDictionary
        
        APIController.makeRequestReturnJSON(.signup(param: param)) { (data, error,headerDict) in
            MZProgressLoader.hide()
            if error == nil {
                if let responseData = data, let userData = responseData["data"] as? JSONDictionary {
                    
                    let user = UserLogin.updatedData(withDictionary: userData)
                    SharedPreference.saveUserData(user)
                    
                    self.addUser()
                    let vc: SelectLocationViewController = UIStoryboard(storyboard: .authentication).instantiateVC()
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    MZUtilManager.showAlertWith(vc: self, title: "", message: data!["message"] as? String ?? "", actionTitle: "OK")
                }
            } else {
                MZUtilManager.showAlertWith(vc: self, title: "", message: (error?.desc)!, actionTitle: "OK")
            }
        }
    }
    
}

extension LoginViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        lat = locValue.latitude
        lng = locValue.longitude
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
}
