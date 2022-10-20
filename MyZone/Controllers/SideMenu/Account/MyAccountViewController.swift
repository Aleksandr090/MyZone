//
//  MyAccountViewController.swift
//  MyZone
//

import UIKit
import Alamofire

class MyAccountViewController: BaseViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    
    @IBOutlet var topContainerView: UIView!
    
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var nameButton: UIButton!
    @IBOutlet var usernameLabel: UILabel!
    
    @IBOutlet weak var enableCommentingMyProfileSwitch: UISwitch!
    @IBOutlet weak var enableBookmarkingMyProfileSwitch: UISwitch!
    @IBOutlet weak var enableviwingMyProfileSwitch: UISwitch!
    @IBOutlet weak var enableNotificationMyProfileSwitch: UISwitch!
    @IBOutlet weak var enableSharingMyProfileSwitch: UISwitch!
    
    @IBOutlet var userBioTextView: UITextView!
    @IBOutlet weak var userEmailTextField: MZTextField!
    @IBOutlet weak var userMobileTextField: MZTextField!
    
    @IBOutlet var privacyView: UIView!
    @IBOutlet var changePasswordView: UIView!
    
    @IBOutlet var showPrivacyButton: UIButton!
    @IBOutlet var showPasswordButton: UIButton!
    
    @IBOutlet weak var oldPasswordTextField: MZTextField!
    @IBOutlet weak var newPasswordTextField: MZTextField!
    @IBOutlet weak var confirmPasswordTextField: MZTextField!
    
    @IBOutlet weak var btnSavePassword: MZButton!
    @IBOutlet weak var btnDeleteAccount: MZButton!
    @IBOutlet weak var btnSave: MZButton!
    
    var imagePicker = UIImagePickerController()
    let userData = SharedPreference.getUserData()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        if let userData = SharedPreference.getUserData() {
            profileImageView?.sd_setImage(with: URL(string: userData.profileImg), placeholderImage: nil, options: .continueInBackground)
            let name = userData.displayName.isEmpty ? userData.userName : userData.displayName
            nameButton.setTitle(name, for: .normal)
            usernameLabel.text = userData.userName
            userBioTextView.text = userData.userBio
            userEmailTextField.text = userData.email
            userMobileTextField.text = userData.contactNo
            
            enableCommentingMyProfileSwitch.isOn = MyDefaults().enableCommentingMyProfileValue
            enableBookmarkingMyProfileSwitch.isOn = MyDefaults().enableBookmarkingMyProfileValue
            enableviwingMyProfileSwitch.isOn = MyDefaults().enableviwingMyProfileValue
            enableNotificationMyProfileSwitch.isOn = MyDefaults().enableNotificationMyProfileValue
            enableSharingMyProfileSwitch.isOn = MyDefaults().enableSharingMyProfileValue
        }
        
        userBioTextView.placeholder = "Content"
        
        btnSavePassword.defaultTextColor = UIColor.white
        btnDeleteAccount.defaultTextColor = UIColor.white
        btnSave.defaultTextColor = UIColor.white
        
        confirmPasswordTextField.addTarget(self, action: #selector(MyAccountViewController.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeUsername(notification:)), name: Notification.Name("UsernameChange"), object: nil)
        }
    
    func setupUI() {
        configureBackButton()
        privacyView.isHidden = true
        changePasswordView.isHidden = true
        topContainerView.roundCorners([.bottomLeft, .bottomRight], radius: 15)
    }
    
    @IBAction func btnActionChageUserName(_ sender: Any) {
        performSegue(withIdentifier: "changeUsername", sender: nil)
    }
    
    @objc func changeUsername(notification: Notification) {
       let name = notification.userInfo!["name"]
        nameButton.setTitle((name as! String), for: .normal)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    //MARK: - Save Password Functinality
    @objc func textFieldDidChange(_ textField: UITextField) {
        btnSavePassword.isUserInteractionEnabled = true
        btnSavePassword.backgroundColor = UIColor.AppTheme.PinkColor
    }
    
    func checkChangePasswordFormValidation() -> (status: Bool, message: String){
        var message = ""
        var status = true
        if (oldPasswordTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty)!{
            status = false
            message = "Please enter old password."
        } else if (newPasswordTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty)!{
            status = false
            message = "Please enter new password."
        }else if (newPasswordTextField.text?.count)! < 6 {
            status = false
            message = "Password should contain 6 characters."
        }else if (newPasswordTextField.text != confirmPasswordTextField.text) {
            status = false
            message = "New password and new confirm passwords don't match."
        }
        return (status, message)
    }
    
    @IBAction func savePasswordAction(_ sender: Any) {
        let validation = self.checkChangePasswordFormValidation()
        if validation.status {
            MZProgressLoader.show()
            var param = JSONDictionary()
            param = ["password":oldPasswordTextField.text!,
                     "new_password": newPasswordTextField.text!
            ] as JSONDictionary
            callChangePasswordAPI(param: param)
        } else {
            MZUtilManager.showAlertWith(vc: self, title: "", message: validation.message, actionTitle: "OK")
        }
    }
    
    func callChangePasswordAPI(param: JSONDictionary){
        MZProgressLoader.show()
        APIController.makeRequestReturnJSON(.changePassword(param: param, userId:userData!.id)) { (data, error,headerDict) in
            MZProgressLoader.hide()
            if error == nil {
                if let responseData = data, let userData = responseData["data"] as? JSONDictionary {
                    self.oldPasswordTextField.text = ""
                    self.newPasswordTextField.text = ""
                    self.confirmPasswordTextField.text = ""
                    self.passwordSetting()
                    print("Change Password userData----->\(userData)")
                    
                } else if let responseData = data, let statusCode = responseData["status"] as? Int, statusCode == 400 {
                    print("userData-----\(responseData)")
                }
            } else {
                MZUtilManager.showAlertWith(vc: self, title: "", message: (error?.desc)!, actionTitle: "OK")
            }
        }
    }
    
    @IBAction func passwordSettingAction(_ sender: UIButton) {
        oldPasswordTextField.text = ""
        newPasswordTextField.text = ""
        confirmPasswordTextField.text = ""
        btnSavePassword.isUserInteractionEnabled = false
        btnSavePassword.backgroundColor = UIColor.darkGray
        passwordSetting()
    }
    
    func passwordSetting(){
        changePasswordView.isHidden = !changePasswordView.isHidden
        if L102Language.isRTL {
            showPasswordButton.imageView!.rotate(changePasswordView.isHidden ? 0.0 : -(.pi / 2))
        } else {
            showPasswordButton.imageView!.rotate(changePasswordView.isHidden ? 0.0 : .pi / 2)
        }
    }
    
    //MARK: - Save Profile Functinality
    func checkSaveUserDetailsFormValidation() -> (status: Bool, message: String){
        var message = ""
        var status = true
        if (userBioTextView.text?.trimmingCharacters(in: .whitespaces).isEmpty)!{
            status = false
            message = "Please enter Bio."
        } else if (userEmailTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty)!{
            status = false
            message = "Please enter email."
        }
        return (status, message)
    }
    
    @IBAction func saveProfileAction(_ sender: Any) {
        MZProgressLoader.show()
        var param = JSONDictionary()
        param = ["displayName":userData?.userName as Any,
                 "userBio": userBioTextView.text!,
                 "email": userEmailTextField.text!
        ] as JSONDictionary
        saveProfileAPI(param: param)
        /*let validation = self.checkSaveUserDetailsFormValidation()
         if validation.status {
         MZProgressLoader.show()
         var param = JSONDictionary()
         param = ["displayName":userData?.userName as Any,
         "userBio": userBioTextView.text!,
         "email": userEmailTextField.text!
         ] as JSONDictionary
         print(param)
         saveProfileAPI(param: param)
         } else {
         MZUtilManager.showAlertWith(title: "", message: validation.message, actionTitle: "OK")
         }*/
    }
    
    func saveProfileAPI(param:JSONDictionary){
        MZProgressLoader.show()
        APIController.makeRequestReturnJSON(.editUserProfile(param: param, userId: userData!.id)) { (data, error,headerDict) in
            MZProgressLoader.hide()
            if error == nil {
                if let responseData = data, let userData = responseData["data"] as? JSONDictionary {
                    self.userEmailTextField.text = ""
                    self.userBioTextView.text = ""
                    print("Edit UserProfile userData ----->\(userData)")
                } else if let responseData = data, let statusCode = responseData["status"] as? Int, statusCode == 400 {
                    print("userData ----->\(responseData)")
                }
            } else {
                MZUtilManager.showAlertWith(vc: self, title: "", message: (error?.desc)!, actionTitle: "OK")
            }
        }
    }
    
    //MARK: - Delete Profile Functinality
    @IBAction func deleteAccountAction(_ sender: Any) {
        MZUtilManager.showDeleteAccountAlert()
    }
    
    //MARK: - Privacy Policy Functinality
    @IBAction func privacySettingAction(_ sender: UIButton) {
        privacySetting()
    }
    
    func privacySetting(){
        privacyView.isHidden = !privacyView.isHidden
        if L102Language.isRTL {
            showPrivacyButton.imageView!.rotate(privacyView.isHidden ? 0.0 : -(.pi / 2))
        } else {
            showPrivacyButton.imageView!.rotate(privacyView.isHidden ? 0.0 : .pi / 2)
        }
    }
    
    //MARK: - Enable Commenting My Profile Functinality
    @IBAction func enableCommentingMyProfile(_ sender: Any) {
        if enableCommentingMyProfileSwitch.isOn{
            MyDefaults().enableCommentingMyProfileValue = true
            enableCommentingMyProfileAPICall(status:true)
        }else{
            MyDefaults().enableCommentingMyProfileValue = false
            enableCommentingMyProfileAPICall(status:false)
        }
    }
    
    func enableCommentingMyProfileAPICall(status:Bool){
        MZProgressLoader.show()
        let params:NSMutableDictionary? = [
            "status":status
        ]
        print(params as Any)
        var request = URLRequest(url: URL(string:Constant().UserAPIBaseUrl + Constant().enableMessageStatus + userData!.id)!)
        request.httpMethod = "PUT"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params as Any, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Constant().header, forHTTPHeaderField: "Authorization")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { [] data, response, error -> Void in
            do {
                let result = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                let json = result as NSDictionary
                print("Response ==>\(json)")
                let status = json.object(forKey: "status") as! NSNumber
                let message = json.object(forKey: "message") as! String
                if(status == 200){
                    DispatchQueue.main.async { [self] in
                        MZProgressLoader.hide()
                    }
                }else{
                    DispatchQueue.main.async {
                        MZProgressLoader.hide()
                        MZUtilManager.showAlertWith(vc: self, title: "", message:message, actionTitle: "OK")
                    }
                }
            } catch let error {
                DispatchQueue.main.async {
                    MZProgressLoader.hide()
                    debugPrint("user response error is:- \(error)")
                    MZUtilManager.showAlertWith(vc: self, title: "", message:"Sorry! Something went wrong please try again later.", actionTitle: "OK")
                }
            }
        })
        task.resume()
    }
    
    //MARK: - Enable Bookmarking My Profile Functinality
    @IBAction func enableBookmarkingMyProfile(_ sender: Any) {
        if enableBookmarkingMyProfileSwitch.isOn{
            MyDefaults().enableBookmarkingMyProfileValue = true
            enableBookmarkingMyProfileAPICall(status:true)
        }else{
            MyDefaults().enableBookmarkingMyProfileValue = false
            enableBookmarkingMyProfileAPICall(status:false)
        }
    }
    
    func enableBookmarkingMyProfileAPICall(status:Bool){
        MZProgressLoader.show()
        let params:NSMutableDictionary? = [
            "disable_bookmarking_profile":status
        ]
        print(params as Any)
        var request = URLRequest(url: URL(string:Constant().UserAPIBaseUrl + Constant().disableBookmarkingProfile + userData!.id)!)
        request.httpMethod = "PUT"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params as Any, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Constant().header, forHTTPHeaderField: "Authorization")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { [] data, response, error -> Void in
            do {
                let result = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                let json = result as NSDictionary
                print("Bookmarking My Profile ==>\(json)")
                let status = json.object(forKey: "status") as! NSNumber
                let message = json.object(forKey: "message") as! String
                if(status == 200){
                    DispatchQueue.main.async { [self] in
                        MZProgressLoader.hide()
                    }
                }else{
                    DispatchQueue.main.async {
                        MZProgressLoader.hide()
                        MZUtilManager.showAlertWith(vc: self, title: "", message:message, actionTitle: "OK")
                    }
                }
            } catch let error {
                DispatchQueue.main.async {
                    MZProgressLoader.hide()
                    debugPrint("user response error is:- \(error)")
                    MZUtilManager.showAlertWith(vc: self, title: "", message:"Sorry! Something went wrong please try again later.", actionTitle: "OK")
                }
            }
        })
        task.resume()
    }
    
    //MARK: - Enable Viewing My Profile Functinality
    @IBAction func enableViewingMyProfile(_ sender: Any) {
        if enableviwingMyProfileSwitch.isOn{
            MyDefaults().enableviwingMyProfileValue = true
            enableViwingMyProfileAPICall(status:true)
        }else{
            MyDefaults().enableviwingMyProfileValue = false
            enableViwingMyProfileAPICall(status:false)
        }
    }
    
    func enableViwingMyProfileAPICall(status:Bool){
        MZProgressLoader.show()
        let params:NSMutableDictionary? = [
            "viewProfile":status
        ]
        print(params as Any)
        var request = URLRequest(url: URL(string:Constant().UserAPIBaseUrl + Constant().enableViewProfile + userData!.id)!)
        request.httpMethod = "PUT"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params as Any, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Constant().header, forHTTPHeaderField: "Authorization")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { [] data, response, error -> Void in
            do {
                let result = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                let json = result as NSDictionary
                print("User Notification ==>\(json)")
                let status = json.object(forKey: "status") as! NSNumber
                let message = json.object(forKey: "message") as! String
                if(status == 200){
                    DispatchQueue.main.async { [self] in
                        MZProgressLoader.hide()
                    }
                }else{
                    DispatchQueue.main.async {
                        MZProgressLoader.hide()
                        MZUtilManager.showAlertWith(vc: self, title: "", message:message, actionTitle: "OK")
                    }
                }
            } catch let error {
                DispatchQueue.main.async {
                    MZProgressLoader.hide()
                    debugPrint("user response error is:- \(error)")
                    MZUtilManager.showAlertWith(vc: self, title: "", message:"Sorry! Something went wrong please try again later.", actionTitle: "OK")
                }
            }
        })
        task.resume()
    }
    
    //MARK: - Enable Notification My Profile Functinality
    @IBAction func enableNotificationMyProfile(_ sender: Any) {
        if enableNotificationMyProfileSwitch.isOn{
            MyDefaults().enableNotificationMyProfileValue = true
            enableNotificationMyProfileAPICall(status:true)
        }else{
            MyDefaults().enableNotificationMyProfileValue = false
            enableNotificationMyProfileAPICall(status:false)
        }
    }
    
    func enableNotificationMyProfileAPICall(status:Bool){
        MZProgressLoader.show()
        let params:NSMutableDictionary? = [
            "enableNotification_profile":status
        ]
        print(params as Any)
        var request = URLRequest(url: URL(string:Constant().UserAPIBaseUrl + Constant().enableProfileNotification + userData!.id)!)
        request.httpMethod = "PUT"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params as Any, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Constant().header, forHTTPHeaderField: "Authorization")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { [] data, response, error -> Void in
            do {
                let result = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                let json = result as NSDictionary
                print("User Notification ==>\(json)")
                let status = json.object(forKey: "status") as! NSNumber
                let message = json.object(forKey: "message") as! String
                if(status == 200){
                    DispatchQueue.main.async { [self] in
                        MZProgressLoader.hide()
                    }
                }else{
                    DispatchQueue.main.async {
                        MZProgressLoader.hide()
                        MZUtilManager.showAlertWith(vc: self, title: "", message:message, actionTitle: "OK")
                    }
                }
            } catch let error {
                DispatchQueue.main.async {
                    MZProgressLoader.hide()
                    debugPrint("user response error is:- \(error)")
                    MZUtilManager.showAlertWith(vc: self, title: "", message:"Sorry! Something went wrong please try again later.", actionTitle: "OK")
                }
            }
        })
        task.resume()
    }
    
    //MARK: - Enable Sharing My Profile Functinality
    @IBAction func enableShareMyProfile(_ sender: Any) {
        if enableSharingMyProfileSwitch.isOn{
            MyDefaults().enableSharingMyProfileValue = true
            enableSharingMyProfileAPICall(status:true)
        }else{
            MyDefaults().enableSharingMyProfileValue = false
            enableSharingMyProfileAPICall(status:false)
        }
    }
    
    func enableSharingMyProfileAPICall(status:Bool){
        MZProgressLoader.show()
        let params:NSMutableDictionary? = [
            "enableShare_profile":status
        ]
        print(params as Any)
        var request = URLRequest(url: URL(string:Constant().UserAPIBaseUrl + Constant().enableShareProfile + userData!.id)!)
        request.httpMethod = "PUT"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params as Any, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Constant().header, forHTTPHeaderField: "Authorization")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { [] data, response, error -> Void in
            do {
                let result = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                let json = result as NSDictionary
                print("User Share Profile ==>\(json)")
                let status = json.object(forKey: "status") as! NSNumber
                let message = json.object(forKey: "message") as! String
                if(status == 200){
                    DispatchQueue.main.async { [self] in
                        MZProgressLoader.hide()
                    }
                }else{
                    DispatchQueue.main.async {
                        MZProgressLoader.hide()
                        MZUtilManager.showAlertWith(vc: self, title: "", message:message, actionTitle: "OK")
                    }
                }
            } catch let error {
                DispatchQueue.main.async {
                    MZProgressLoader.hide()
                    debugPrint("user response error is:- \(error)")
                    MZUtilManager.showAlertWith(vc: self, title: "", message:"Sorry! Something went wrong please try again later.", actionTitle: "OK")
                }
            }
        })
        task.resume()
    }
    
    
    // MARK: - Set User Profile Functinality
    @IBAction func changeProfileImageAction(_ sender: UIButton) {
        selectSeekerProfileImage()
    }
    
    @objc func selectSeekerProfileImage() {
        let actionSheet = UIAlertController(title:"Upload Photo", message: "", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title:"Gallery", style: .default, handler: { (UIAlertAction) in
            self.openGallary()
        }))
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (UIAlertAction) in
            self.openCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
        else{
            //self.present(Constant().Alert(title: ValidationMassage().appName, msg:(ValidationMassage().cameraMsg)), animated: false, completion: nil)
        }
    }
    
    func openGallary(){
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        dismiss(animated: true, completion: nil)
        
        let controller = CropViewController()
        controller.delegate = self
        controller.image = selectedImage
        let navController = UINavigationController(rootViewController: controller)
        present(navController, animated: false, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion:nil)
    }
    
    func cropViewController(_ controller: CropViewController, didFinishCroppingImage image: UIImage) {
        print("didFinishCroppingImage")
    }
    
    func cropViewController(_ controller: CropViewController, didFinishCroppingImage image: UIImage, transform: CGAffineTransform, cropRect: CGRect) {
        controller.dismiss(animated: true, completion: nil)
        profileImageView.image = image
        uploadUserImageAPICall()
    }
    
    func cropViewControllerDidCancel(_ controller: CropViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func uploadUserImageAPICall(){
        MZProgressLoader.show()
        let url = SERVER_URL + "/api/setProfilePic/" + userData!.id
        let parameters =  [
            "profile_img":""
        ];
        let imgData = profileImageView.image!.jpegData(compressionQuality: 0.2)!
        let headers: HTTPHeaders
        
        headers = ["Content-type": "multipart/form-data",
                   "Content-Disposition" : "form-data",
                   "Authorization": Constant().header]
        AF.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(imgData, withName: "profile_img",fileName: "file.jpg", mimeType: "image/jpg")
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        },to: URL.init(string:url)!, usingThreshold: UInt64.init(),
                  method: .put,
                  headers: headers).response{ response in
            if((response.error == nil)){
                do{
                    if let jsonData = response.data{
                        let parsedData = try JSONSerialization.jsonObject(with: jsonData) as! Dictionary<String, AnyObject>
                        MZProgressLoader.hide()
                        if let userLogin = SharedPreference.getUserData() {
                            if let profileimage = parsedData["data"] as? String {
                                userLogin.profileImg = profileimage
                                SharedPreference.saveUserData(userLogin)
                                self.updateUser()
                            }
                        }
                        print(parsedData)
                        print("sucees message")
                    }
                }catch{
                    MZProgressLoader.hide()
                    print("error message")
                }
            }else{
                MZProgressLoader.hide()
                print("Error Response ==>\(response.error!.localizedDescription)")
            }
        }
    }
}
