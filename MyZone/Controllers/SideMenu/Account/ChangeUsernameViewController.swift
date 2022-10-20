//
//  ChangeUsernameViewController.swift
//  MyZone
//
//  Created by Apple on 09/04/22.
//

import UIKit

class ChangeUsernameViewController: UIViewController {
    
    @IBOutlet weak var txtFieldUsername: UITextField!
    let userData = SharedPreference.getUserData()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.closePopup (_:)))
        self.view.addGestureRecognizer(gesture)
        
    }
    
    @objc func closePopup(_ sender:UITapGestureRecognizer){
        dismiss(animated: true)
    }
    
    @IBAction func btnActionCncel(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func btnActionOk(_ sender: Any) {
        if(txtFieldUsername.text == ""){
            self.dismiss(animated: true)
        }else{
            saveProfileAPI()
        }
    }
    
    func saveProfileAPI(){
        MZProgressLoader.show()
        let params:NSMutableDictionary? = [
            "displayName":txtFieldUsername.text as Any,
            "userBio": userData!.userBio,
            "email": userData!.email
        ]
        print(params as Any)
        var request = URLRequest(url: URL(string:Constant().UserAPIBaseUrl + Constant().editUser + userData!.id)!)
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
                        NotificationCenter.default.post(name: Notification.Name("UsernameChange"), object: nil, userInfo:["name":txtFieldUsername.text as Any])
                        if let user = SharedPreference.getUserData() {
                            user.displayName = txtFieldUsername.text!
                            user.userName = txtFieldUsername.text!
                            SharedPreference.saveUserData(user)
                        }
                        self.dismiss(animated: true)
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
}
