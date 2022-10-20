//
//  SavedPeopleViewController.swift
//  MyZone
//

import UIKit
import DropDown
import SDWebImage
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

class SavedPeopleViewController: BaseViewController {
    @IBOutlet weak var SavedPeopleListTableView: UITableView!
    
    var arrSavedPeopleList:NSMutableArray = []
    
    let selfUserData = SharedPreference.getUserData()
    var refArtists: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Saved People"
        self.configureBackButton()
        navigationController?.isNavigationBarHidden = false
        getSavedPeopleList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    
    func getSavedPeopleList(){
        MZProgressLoader.show()
        let params:NSMutableDictionary? = [:]
        var request = URLRequest(url: URL(string:Constant().UserAPIBaseUrl + Constant().bookmarkedUserlist + Constant().userId)!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params as Any, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Constant().header, forHTTPHeaderField: "Authorization")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { [] data, response, error -> Void in
            do {
                let result = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                let json = result as NSDictionary
                print("Saved People Response ==>\(json)")
                let status = json.object(forKey: "status") as! NSNumber
                let message = json.object(forKey: "message") as! String
                if(status == 200){
                    self.arrSavedPeopleList = []
                    self.arrSavedPeopleList = (json.object(forKey: "data") as! NSArray).mutableCopy() as? NSMutableArray ?? NSMutableArray()
                    
                    DispatchQueue.main.async { [self] in
                        SavedPeopleListTableView.reloadData()
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
    
    @IBAction func openMoreInfo(button: UIButton){
        let temp = arrSavedPeopleList[button.tag] as! NSDictionary
        let id = temp["_id"] as! String
        let reportProfileStatus = temp["reportProfile_Status"] as! NSNumber
        
        let moreOptionDropDown = DropDown()
        moreOptionDropDown.anchorView = button
        moreOptionDropDown.bottomOffset = CGPoint(x: -100, y: button.bounds.height)
        // You can also use localizationKeysDataSource instead. Check the docs.
        moreOptionDropDown.dataSource = ["  Report","  Remove"]
        
        //Action triggered on selection
        moreOptionDropDown.selectionAction = { [weak self] (index, item) in
            if(index == 0){
                if(reportProfileStatus == 0){
                    self!.reportUser(status:true, userId:id)
                }else{
                    self!.reportUser(status:false, userId:id)
                }
            }else{
                self!.bookmarkAPICall(status:false, userId:id)
            }
        }
        
        moreOptionDropDown.show()
    }
    
    func reportUser(status: Bool, userId:String){
        MZProgressLoader.show()
        let params:NSMutableDictionary? = [
            "user_id":userId as Any,
            "reportProfile_Status":status
        ]
        print(params as Any)
        var request = URLRequest(url: URL(string:Constant().UserAPIBaseUrl + Constant().profileReport + selfUserData!.id)!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params as Any, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Constant().header, forHTTPHeaderField: "Authorization")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { [] data, response, error -> Void in
            do {
                let result = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                let json = result as NSDictionary
                print("User Profile Report ==>\(json)")
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
    
    func bookmarkAPICall(status:Bool, userId:String){
        MZProgressLoader.show()
        let params:NSMutableDictionary? = [
            "user_id":userId as Any,
            "bookmark_status":status
        ]
        print(params as Any)
        var request = URLRequest(url: URL(string:Constant().UserAPIBaseUrl + Constant().profileBookmark + selfUserData!.id)!)
        request.httpMethod = "PUT"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params as Any, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Constant().header, forHTTPHeaderField: "Authorization")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { [] data, response, error -> Void in
            do {
                let result = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                let json = result as NSDictionary
                print("User Bookmark ==>\(json)")
                let status = json.object(forKey: "status") as! NSNumber
                let message = json.object(forKey: "message") as! String
                if(status == 200){
                    DispatchQueue.main.async { [self] in
                        getSavedPeopleList()
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
    
    @IBAction func openNotification(button: UIButton){
        let temp = arrSavedPeopleList[button.tag] as! NSDictionary
        let notificationStatus = temp["notificationStatus"] as! NSNumber
        let id = temp["_id"] as! String
        
        if(notificationStatus == 0){
            notificationAPICall(status:true, userId:id)
        }else{
            notificationAPICall(status:false,userId:id)
        }
    }
    
    func notificationAPICall(status:Bool, userId:String){
        MZProgressLoader.show()
        let params:NSMutableDictionary? = [
            "user_id":userId as Any,
            "notificationStatus": status
        ]
        print(params as Any)
        var request = URLRequest(url: URL(string:Constant().UserAPIBaseUrl + Constant().notifyPostToUser + selfUserData!.id)!)
        request.httpMethod = "POST"
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
                        getSavedPeopleList()
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
    
    @IBAction func openMessage(button: UIButton){
        let temp = arrSavedPeopleList[button.tag] as! NSDictionary
        let userId = temp["_id"] as! String
        let userName = temp["displayName"] as! String
        
        let messagesNode = String(selfUserData!.id) + "-" + userId
        
        refArtists = Database.database().reference().child("messages");
        let vc: MessageChatViewController = UIStoryboard(storyboard: .message).instantiateVC()
        vc.databaseChats = refArtists
        vc.messagesNode = messagesNode
        
        vc.msgSenderId = selfUserData!.id
        vc.msgSenderName = selfUserData!.userName
        
        vc.msgReceiverId = userId
        vc.msgReceiverName = userName
        
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension SavedPeopleViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSavedPeopleList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SavedPeopleListTableView.dequeueReusableCell(withIdentifier: "SavedPeopleListCell", for: indexPath) as! SavedPeopleListCell
        
        let temp = arrSavedPeopleList[indexPath.row] as! NSDictionary
        
        cell.userImage.sd_setImage(with: URL(string: temp["profile_img"] as? String ?? ""), placeholderImage: UIImage(named: "dummy"))
        
        cell.lblName.text = temp["displayName"] as? String ?? ""
        cell.lblUsername.text = temp["user_name"] as? String ?? ""
        
        let notificationStatus = temp["notificationStatus"] as! NSNumber
        
        if(notificationStatus == 0){
            cell.btnNotification.setImage(UIImage(named: "redNotification"), for: .normal)
        }else{
            cell.btnNotification.setImage(UIImage(named: "redFillNotification"), for: .normal)
        }
        
        cell.btnMoreInfo.tag = indexPath.row
        cell.btnMoreInfo .addTarget(self, action: #selector(openMoreInfo(button:)), for: .touchUpInside)
        
        cell.btnNotification.tag = indexPath.row
        cell.btnNotification .addTarget(self, action: #selector(openNotification(button:)), for: .touchUpInside)
        
        cell.btnMessage.tag = indexPath.row
        cell.btnMessage .addTarget(self, action: #selector(openMessage(button:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let temp = arrSavedPeopleList[indexPath.row] as! NSDictionary
        let userId = temp["_id"] as! String
        
        let vc: PostUserDetailsViewController = UIStoryboard(storyboard: .home).instantiateVC()
        vc.userId = userId
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

class SavedPeopleListCell: UITableViewCell{
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var btnNotification: UIButton!
    @IBOutlet weak var btnMessage: UIButton!
    @IBOutlet weak var btnMoreInfo: UIButton!
}
