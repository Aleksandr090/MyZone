//
//  PostUserDetailsViewController.swift
//  MyZone
//
//  Created by Apple on 26/02/22.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics
import DropDown
import SDWebImage
import SwiftUI

class PostUserDetailsViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var tblUserDetails: UITableView!
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnInfo: UIButton!
    
    @IBOutlet weak var btnInfoWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var viewCommentReply: UIView!
    @IBOutlet weak var lblCmmentReplyUsername: UILabel!
    @IBOutlet weak var btnCancelCommentReply: UIButton!
    
    @IBOutlet weak var txtViewAddPublicComment: UITextView!
    @IBOutlet weak var btnPublicCommentCancle: UIButton!
    @IBOutlet weak var btnPublicCommentSend: UIButton!
    
    let selfUserData = SharedPreference.getUserData()
    var commentReply:Bool = false
    var commentReplyTag:Int!
    var userId:String!
    var userName:String!
    var userType:String!
    var userImage:String = ""
    var userImageData: UIImage?
    
    var notificationStatus:NSNumber = 0
    var bookmarkStatus:NSNumber = 0
    var reportProfileStatus:NSNumber = 0
    
    var refArtists: DatabaseReference!
    
    var arrCommentList:NSMutableArray = []
    
    var userData: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        getPostUserDetails()
        viewCommentReply.isHidden = true
        self.tblUserDetails.register(UINib(nibName: "UserInfoCell", bundle: nil), forCellReuseIdentifier: "UserInfoCell")
        self.tblUserDetails?.register(UINib(nibName: "UserDetailsCommentTVC", bundle: nil), forCellReuseIdentifier: "UserDetailsCommentTVC")
        self.tblUserDetails?.register(UINib(nibName: "UserDetailsReplyTVC", bundle: nil), forCellReuseIdentifier: "UserDetailsReplyTVC")
        
        txtViewAddPublicComment.delegate = self
        txtViewAddPublicComment.text = "Add public comment"
        txtViewAddPublicComment.textColor = UIColor.lightGray
        btnPublicCommentCancle.isHidden = true
        
        if let user = SharedPreference.getUserData() {
            if user.id != userId {
                btnInfo.isHidden = true
                btnInfoWidthConstraint.constant = 0
            }
        }
        
    }
    
    @IBAction func btnActionBack(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnActionShare(_ sender: Any) {
        let profileImage = userData?["profile_img"] as! String
        // set up activity view controller
        let imageToShare = [ profileImage ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    //MARK: - Notification Code And Functinality
    @IBAction func btnActionInfo(_ sender: Any) {
        let moreOptionDropDown = DropDown()
        moreOptionDropDown.anchorView = btnInfo
        moreOptionDropDown.bottomOffset = CGPoint(x: -100, y: btnInfo.bounds.height)
        // You can also use localizationKeysDataSource instead. Check the docs.
        moreOptionDropDown.dataSource = ["  Setting","  Report"]
        
        // Action triggered on selection
        moreOptionDropDown.selectionAction = { [weak self] (index, item) in
            if(index == 1){
                if(self!.reportProfileStatus == 0){
                    self!.reportProfileStatus = 1
                    self!.reportUser(status:true)
                }else{
                    self!.reportProfileStatus = 0
                    self!.reportUser(status:false)
                }
            }
        }
        
        moreOptionDropDown.show()
    }
    
    func reportUser(status: Bool){
        if !SharedPreference.isUserLogin {
            MZUtilManager.showLoginAlert()
            return
        }
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
    
    //MARK: - User Chat
    @IBAction func btnActionChat(_ sender: Any) {
        if !SharedPreference.isUserLogin {
            MZUtilManager.showLoginAlert()
            return
        }
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
    
    //MARK: - Bookmark Code And Functinality
    @IBAction func btnActionBookmark(_ sender: Any) {
        if !SharedPreference.isUserLogin {
            MZUtilManager.showLoginAlert()
            return
        }
        if(self.bookmarkStatus == 0){
            self.bookmarkStatus = 1
            bookmarkAPICall(status:true)
        }else{
            self.bookmarkStatus = 0
            bookmarkAPICall(status:false)
        }
    }
    
    func bookmarkAPICall(status:Bool){
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
                        self.tblUserDetails.reloadData()
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
    
    //MARK: - Notification Code And Functinality
    @IBAction func btnActionNotification(_ sender: Any) {
        if !SharedPreference.isUserLogin {
            MZUtilManager.showLoginAlert()
            return
        }
        if(self.notificationStatus == 0){
            self.notificationStatus = 1
            notificationAPICall(status:true)
        }else{
            self.notificationStatus = 0
            notificationAPICall(status:false)
        }
    }
    
    func notificationAPICall(status:Bool){
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
                        self.tblUserDetails.reloadData()
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
    
    func getPostUserDetails(){
        MZProgressLoader.show()
        let params:NSMutableDictionary? = [
            "user_id":userId as Any
        ]
        
        var request = URLRequest(url: URL(string:Constant().UserAPIBaseUrl + Constant().profileDetail + userId)!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params as Any, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Constant().header, forHTTPHeaderField: "Authorization")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { [] data, response, error -> Void in
            do {
                let result = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                let json = result as NSDictionary
                
                let status = json.object(forKey: "status") as! NSNumber
                let message = json.object(forKey: "message") as! String
                if(status == 200){
                    self.userData = (json.object(forKey: "data") as! NSDictionary)
                    
                    
                    self.arrCommentList = (self.userData["comment"] as! NSArray).mutableCopy() as? NSMutableArray ?? NSMutableArray()
                    
                    self.notificationStatus = (self.userData["notificationStatus"] as! NSNumber)
                    self.bookmarkStatus = (self.userData["bookmark_status"] as! NSNumber)
                    self.reportProfileStatus = (self.userData["reportProfile_Status"] as! NSNumber)
                    
                    DispatchQueue.main.async { [self] in
                        
                        MZProgressLoader.hide()
                        tblUserDetails.reloadData()
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
    
    //MARK: - Add Public Comment Code
    func textViewDidBeginEditing(_ textView: UITextView) {
        if txtViewAddPublicComment.textColor == UIColor.lightGray {
            txtViewAddPublicComment.text = nil
            txtViewAddPublicComment.textColor = UIColor.AppTheme.TextColor
            btnPublicCommentCancle.isHidden = false
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if txtViewAddPublicComment.text.isEmpty {
            txtViewAddPublicComment.text = "Add public comment"
            txtViewAddPublicComment.textColor = UIColor.lightGray
            btnPublicCommentCancle.isHidden = true
        }
    }
    
    @IBAction func btnActionCanclePublicComment(_ sender: Any) {
        // txtViewAddPublicComment.text = "Add public comment"
        // txtViewAddPublicComment.textColor = UIColor.lightGray
        
        txtViewAddPublicComment.text = nil
        txtViewAddPublicComment.textColor = UIColor.AppTheme.TextColor
    }
    
    @IBAction func btnActionSendPublicComment(_ sender: Any) {
        if !SharedPreference.isUserLogin {
            MZUtilManager.showLoginAlert()
            return
        }
        if(commentReply == true){
            commentReplyAPICall()
        }else{
            commentPublicAPICall()
        }
    }
    
    func commentPublicAPICall(){
        if txtViewAddPublicComment.textColor == UIColor.lightGray { return }
        MZProgressLoader.show()
        let params:NSMutableDictionary? = [
            "user_id":userId!,
            "text":txtViewAddPublicComment.text!,
            "time":String(Date().timeIntervalSince1970 * 1000)
        ]
        print(params as Any)
        var request = URLRequest(url: URL(string:Constant().ProfileAPIBaseUrl + Constant().comment + selfUserData!.id)!)
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
                        txtViewAddPublicComment.text = "Add public comment"
                        txtViewAddPublicComment.textColor = UIColor.lightGray
                        getPostUserDetails()
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
    
    
    //MARK: - Comment Like/DisLike
    @IBAction func commentLike(button: UIButton){
        if !SharedPreference.isUserLogin {
            MZUtilManager.showLoginAlert()
            return
        }
        let url = Constant().UserAPIBaseUrl + Constant().profileCommentLike + selfUserData!.id
        commentLikeDisLikeAPICall(tag: button.tag, url: url)
    }
    
    @IBAction func commentDisLike(button: UIButton){
        if !SharedPreference.isUserLogin {
            MZUtilManager.showLoginAlert()
            return
        }
        let url = Constant().UserAPIBaseUrl + Constant().profileCommentDisLike + selfUserData!.id
        commentLikeDisLikeAPICall(tag: button.tag, url:url)
    }
    
    func commentLikeDisLikeAPICall(tag:Int, url:String){
        let data = arrCommentList[tag] as! NSDictionary
        let commentId = data["_id"] as! String
        MZProgressLoader.show()
        let params:NSMutableDictionary? = [
            "user_id":userId!,
            "comment_id":commentId,
        ]
        print(params as Any)
        var request = URLRequest(url: URL(string:url)!)
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
                        getPostUserDetails()
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
    
    //MARK: - Comment Reply Show Hide
    @IBAction func commentReplyShowHide(button: UIButton){
        
    }
    
    //MARK: - Comment Reply
    @IBAction func btnActionCommentReplyCancel(_ sender: Any) {
        viewCommentReply.isHidden = true
        commentReply = false
    }
    
    @IBAction func commentReply(button: UIButton){
        if !SharedPreference.isUserLogin {
            MZUtilManager.showLoginAlert()
            return
        }
        let data = arrCommentList[button.tag] as! NSDictionary
        let postedBy = data["postedBy"] as! NSDictionary
        commentReply = true
        commentReplyTag = button.tag
        viewCommentReply.isHidden = false
        lblCmmentReplyUsername.text = "Replying to @" + (postedBy["user_name"] as! String)
    }
    
    func commentReplyAPICall(){
        if txtViewAddPublicComment.textColor == UIColor.lightGray { return }
        let data = arrCommentList[commentReplyTag] as! NSDictionary
        let postedBy = data["postedBy"] as! NSDictionary
        let commentUserId = postedBy["_id"] as! String
        let commentId = data["_id"] as! String
        MZProgressLoader.show()
        let params:NSMutableDictionary? = [
            "user_id":userId!,
            "comment_user":commentUserId,
            "commentId":commentId,
            "text":txtViewAddPublicComment.text!,
            "time":String(Int(Date().timeIntervalSince1970 * 1000))
        ]
        print(params as Any)
        var request = URLRequest(url: URL(string:Constant().UserAPIBaseUrl + Constant().profileCommentReply + selfUserData!.id)!)
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
                        commentReply = false
                        viewCommentReply.isHidden = true
                        txtViewAddPublicComment.text = "Add public comment"
                        txtViewAddPublicComment.textColor = UIColor.lightGray
                        getPostUserDetails()
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
    
    @IBAction func commentMoreOption(button: UIButton){
        if !SharedPreference.isUserLogin {
            MZUtilManager.showLoginAlert()
            return
        }
        //let temp = arrCommentList[button.tag] as! NSDictionary
        // let id = temp["_id"] as! String
        // let reportProfileStatus = temp["reportProfile_Status"] as! NSNumber
        
        let moreOptionDropDown = DropDown()
        moreOptionDropDown.anchorView = button
        moreOptionDropDown.bottomOffset = CGPoint(x: -100, y: button.bounds.height)
        // You can also use localizationKeysDataSource instead. Check the docs.
        moreOptionDropDown.dataSource = ["  Report"]
        
        //Action triggered on selection
        moreOptionDropDown.selectionAction = { [weak self] (index, item) in
            
        }
        
        moreOptionDropDown.show()
    }
}

extension PostUserDetailsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCommentList.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 300
        } else {
            return 101
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            let cell = tblUserDetails.dequeueReusableCell(withIdentifier: "UserInfoCell", for: indexPath) as! UserInfoCell
            
            cell.userProfileImage.layer.cornerRadius = 10
            
            if(userId == selfUserData?.id){
                cell.msgView.isHidden = true
                cell.msgViewHeight.constant = 0.0
                cell.msgViewTop.constant = 0.0
                cell.mainViewHeight.constant = 350
            }else{
                cell.msgView.isHidden = false
                cell.msgViewHeight.constant = 64.0
                cell.msgViewTop.constant = 20
                cell.mainViewHeight.constant = 435
            }
            
            if userData != nil {
                let displayName = userData?["displayName"] as! String
                let userName = userData?["user_name"] as! String
                let userBio = userData?["userBio"] as! String
                let userProfileImage = userData?["profile_img"] as! String
                let createdAt = userData?["createdAt"] as! String
                var rewardImage: String = ""
                if let reward = userData?["rewardId"] as? NSDictionary {
                    rewardImage = reward["rewardImage"] as? String ?? ""
                }
                
                cell.userProfileImage.sd_setImage(with: URL(string: userProfileImage), placeholderImage: UIImage(named: "dummy"))
                
                cell.lblName.text = displayName
                cell.lblUserName.text = userName
                cell.lblUserDescription.text = userBio
                self.userName = userName
                cell.btnUserReward.sd_setImage(with: URL(string: rewardImage), for: .normal)
                if let createdDate = createdAt.dateFromFormat("yyyy-MM-dd'T'HH:mm:ssZ") {
                    cell.lblUserPostTime.text = MZUtilManager.shared.timeAgoSinceDate(createdDate)
                }
                
                cell.btnChat.addTarget(self, action: #selector(btnActionChat(_:)), for: .touchUpInside)
                cell.btnBookmark.addTarget(self, action: #selector(btnActionBookmark(_:)), for: .touchUpInside)
                cell.btnNotification.addTarget(self, action: #selector(btnActionNotification(_:)), for: .touchUpInside)
            }
            
            if(self.bookmarkStatus == 0){
                cell.btnBookmark.setImage(UIImage(named: "yellowBookmark"), for: .normal)
            }else{
                cell.btnBookmark.setImage(UIImage(named: "yellowFillBookmark"), for: .normal)
            }
            
            if(self.notificationStatus == 0){
                cell.btnNotification.setImage(UIImage(named: "redNotification"), for: .normal)
            }else{
                cell.btnNotification.setImage(UIImage(named: "redFillNotification"), for: .normal)
            }
          
            return cell
            
        } else {
            
            let cell = tblUserDetails.dequeueReusableCell(withIdentifier: "UserDetailsCommentTVC", for: indexPath) as! UserDetailsCommentTVC
            
            let data = arrCommentList[indexPath.row-1] as! NSDictionary
            cell.configureCommentData(data:data)
            
            cell.btnCommentLike.tag = indexPath.row-1
            cell.btnCommentLike.addTarget(self, action: #selector(commentLike(button:)), for: .touchUpInside)
            
            cell.btnCommentDisLike.tag = indexPath.row-1
            cell.btnCommentDisLike.addTarget(self, action: #selector(commentDisLike(button:)), for: .touchUpInside)
            
            cell.btnCommentReplyShowHide.tag = indexPath.row-1
            cell.btnCommentReplyShowHide.addTarget(self, action: #selector(commentReplyShowHide(button:)), for: .touchUpInside)
            
            cell.btnCommentReply.tag = indexPath.row-1
            cell.btnCommentReply.addTarget(self, action: #selector(commentReply(button:)), for: .touchUpInside)
            
            cell.btnCommentMoreOption.tag = indexPath.row-1
            cell.btnCommentMoreOption.addTarget(self, action: #selector(commentMoreOption(button:)), for: .touchUpInside)
            
            return cell
            
        }
        
    }
}
