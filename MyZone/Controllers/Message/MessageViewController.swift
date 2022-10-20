//
//  MessageViewController.swift
//  MyZone
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics
import SDWebImage

class MessageViewController: BaseViewController {
    @IBOutlet weak var messageListTableView: UITableView!
    var arrUserChatFinalList: Array<Any> = []
    var refArtists: DatabaseReference!
    let selfUserData = SharedPreference.getUserData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Message"
        setupSideMenu()
        navigationController?.isNavigationBarHidden = false
        
//        let filterButtonItem = UIBarButtonItem(image: UIImage(named:"filterWithText"), style: .plain, target: self, action: #selector(didTouchFilterButton))
//        navigationItem.rightBarButtonItem = filterButtonItem
     
                                               
//        NotificationCenter.default.addObserver(self, selector: #selector(fetchDB), name: Notification.Name("ChatBadge"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // self.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        
        currentViewController = self
        if !SharedPreference.isUserLogin {
            MZUtilManager.showLoginAlert()
            return
        }
        
//        if let tabItems = self.tabBarController?.tabBar.items {
//            let tabItem = tabItems[4]
//            tabItem.badgeValue = nil
//        }
        if ((currentViewController?.isKind(of: MessageViewController.self)) != nil) {
            self.fetchDB()
        }
    }
    
    @objc func didTouchFilterButton() {
        let actionSheet = UIAlertController(title:"Filter", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title:"Accept message only from bookmaked people", style: .default, handler: { (UIAlertAction) in
            // Code here
        }))
        actionSheet.addAction(UIAlertAction(title: "Only from my location", style: .default, handler: { (UIAlertAction) in
            // Code here
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func fetchDB(){
        arrUserChatFinalList.removeAll()
        MZProgressLoader.show()
        let ref = Database.database().reference()
        
        ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists(){
                if let userData = snapshot.value as? Dictionary<String,AnyObject>{
                    for(key, value) in userData{
                        let selfUserId = self.selfUserData?.id ?? ""
                        let otherUserId = key
                        
                        let nodeOne =  selfUserId + "-" + otherUserId
                        let nodeTwo = otherUserId + "-" + selfUserId
                        
                        //-------------------- Message Table DataLoad Start -------------

                        ref.child("messages").observeSingleEvent(of: .value, with: { (snapshot) in
                            if let messagesData = snapshot.value as? Dictionary<String,AnyObject>{                                
                                for(key, msg) in messagesData{
                                    if(nodeOne == key){
                                        let lastMessage = self.getLastMessage(msg as! [String : AnyObject])
                                        if value is Dictionary<String,AnyObject>{
                                            let id = value.object(forKey: "id")
                                            let name = value.object(forKey: "name")
                                            let lastSeen = value.object(forKey: "userLastSeen")
                                            let photo = value.object(forKey: "photo")
                                            
                                            var arrUserChatList:NSDictionary = [:]
                                            arrUserChatList = [
                                                "name":name as Any,
                                                "id":id as Any,
                                                "userLastSeen": lastSeen as Any,
                                                "photo": photo as Any,
                                                "lastMessage": lastMessage.1,
                                                "lastTime": lastMessage.0,
                                                "nodeId": key,
                                                "badge": lastMessage.2
                                            ]
                                            self.arrUserChatFinalList.append(arrUserChatList)
                                        }
                                    } else if (nodeTwo == key) {
                                        let lastMessage = self.getLastMessage(msg as! [String : AnyObject])
                                        if value is Dictionary<String,AnyObject>{
                                            let id = value.object(forKey: "id")
                                            let name = value.object(forKey: "name")
                                            let lastSeen = value.object(forKey: "userLastSeen")
                                            let photo = value.object(forKey: "photo")
                                            
                                            var arrUserChatList:NSDictionary = [:]
                                            arrUserChatList = [
                                                "name":name as Any,
                                                "id":id as Any,
                                                "userLastSeen": lastSeen as Any,
                                                "photo": photo as Any,
                                                "lastMessage": lastMessage.1,
                                                "lastTime": lastMessage.0,
                                                "nodeId": key,
                                                "badge": lastMessage.2
                                            ]
                                            self.arrUserChatFinalList.append(arrUserChatList)
                                        }
                                    }else{
                                        // print("** come else **")
                                    }
                                    
                                }
                            }
                            self.messageListTableView.reloadData()
                            MZProgressLoader.hide()
                        })
                        //-------------------- Message Table DataLoad End -------------
                    }
                }
            }
        })
    }
    
    func getMessages() {
        
        arrUserChatFinalList.removeAll()
        
        let ref = Database.database().reference()
        
        ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists(){
                if let userData = snapshot.value as? Dictionary<String,AnyObject>{
                    for(key, value) in userData{
                        let selfUserId = self.selfUserData?.id ?? ""
                        let otherUserId = key
                        
                        let nodeOne =  selfUserId + "-" + otherUserId
                        let nodeTwo = otherUserId + "-" + selfUserId
                        
                        //-------------------- Message Table DataLoad Start -------------

                        ref.child("messages").observeSingleEvent(of: .value, with: { (snapshot) in
                            if let messagesData = snapshot.value as? Dictionary<String,AnyObject>{
                                for(key, msg) in messagesData{
                                    if(nodeOne == key){
                                        let lastMessage = self.getLastMessage(msg as! [String : AnyObject])
                                        if value is Dictionary<String,AnyObject>{
                                            let id = value.object(forKey: "id")
                                            let name = value.object(forKey: "name")
                                            let lastSeen = value.object(forKey: "userLastSeen")
                                            let photo = value.object(forKey: "photo")
                                            
                                            var arrUserChatList:NSDictionary = [:]
                                            arrUserChatList = [
                                                "name":name as Any,
                                                "id":id as Any,
                                                "userLastSeen": lastSeen as Any,
                                                "photo": photo as Any,
                                                "lastMessage": lastMessage.1,
                                                "lastTime": lastMessage.0,
                                                "nodeId": key,
                                                "badge": lastMessage.2
                                            ]
                                            self.arrUserChatFinalList.append(arrUserChatList)
                                        }
                                    } else if (nodeTwo == key) {
                                        let lastMessage = self.getLastMessage(msg as! [String : AnyObject])
                                        if value is Dictionary<String,AnyObject>{
                                            let id = value.object(forKey: "id")
                                            let name = value.object(forKey: "name")
                                            let lastSeen = value.object(forKey: "userLastSeen")
                                            let photo = value.object(forKey: "photo")
                                            
                                            var arrUserChatList:NSDictionary = [:]
                                            arrUserChatList = [
                                                "name":name as Any,
                                                "id":id as Any,
                                                "userLastSeen": lastSeen as Any,
                                                "photo": photo as Any,
                                                "lastMessage": lastMessage.1,
                                                "lastTime": lastMessage.0,
                                                "nodeId": key,
                                                "badge": lastMessage.2
                                            ]
                                            self.arrUserChatFinalList.append(arrUserChatList)
                                        }
                                    }else{
                                    }
                                }
                            }
                        })                        
                    }
                }
            }
        })
        
    }
    
    func getLastMessage(_ msgObj: [String: AnyObject]) -> (String, String, Int) {
        var lastTime: Double = 0
        var lastMessage = ""
        var badgeCount = 0
        for message in msgObj.values {
            if let obj = message as? [String: AnyObject] {
                let lasttime = obj["timestamp"] as! String
                if Double(lasttime)! > lastTime {
                    lastTime = Double(lasttime)!
                    if (obj["msgType"] as! String) == "audio" {
                        lastMessage = "[Audio]"
                    } else if (obj["msgType"] as! String) == "image" {
                        lastMessage = "[Image]"
                    } else {
                        lastMessage = obj["text"] as! String
                    }
                }
                if (obj["receiverId"] as! String) == selfUserData!.id {
                    if !(obj["isread"] as! Bool) {
                        badgeCount += 1
                    }
                }
                NotificationCenter.default.post(name: Notification.Name("ChatBadge"), object: nil, userInfo: ["badgeCount": badgeCount])
                
            }
        }
        
        let epochTime = TimeInterval(lastTime) / 1000
        let date = Date(timeIntervalSince1970: epochTime)
        let dateFormatter = DateFormatter()
        if Int(Date().timeIntervalSince1970) - Int(lastTime) > 24 * 60 * 60 {
            
            dateFormatter.dateFormat = "MM dd YYYY"
        } else {
            dateFormatter.dateFormat = "hh:mm a"
        }
        let lastDate = dateFormatter.string(from: date)        
        return (lastDate, lastMessage, badgeCount)
    }
}


extension MessageViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrUserChatFinalList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messageListTableView.dequeueReusableCell(withIdentifier: "messageListCell", for: indexPath) as! messageListCell
        
        let temp = arrUserChatFinalList[indexPath.row] as! NSDictionary
        
        if(((temp.object(forKey:"photo") as! String)) != ""){
            cell.imgUser.sd_setImage(with: URL(string:(temp.object(forKey:"photo") as! String)), placeholderImage: UIImage(named: "dummy.png"))
        } else {
            cell.imgUser.image = UIImage(named: "dummy.png")
        }
        cell.lblLastMsg.text = (temp.object(forKey: "lastMessage") as! String)
        cell.lblTime.text = (temp.object(forKey: "lastTime") as! String)
        cell.lblUser.text = (temp.object(forKey: "name") as! String)
        cell.lblBadge.isHidden = (temp.object(forKey: "badge") as! Int) == 0
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let temp = arrUserChatFinalList[indexPath.row] as! NSDictionary
        let id = (temp.object(forKey: "id") as! String)
        let name = (temp.object(forKey: "name") as! String)
        
        let messagesNode = (temp.object(forKey: "nodeId") as! String)
        
        refArtists = Database.database().reference().child("messages");
        
        let vc: MessageChatViewController = UIStoryboard(storyboard: .message).instantiateVC()
        vc.databaseChats = refArtists
        vc.messagesNode = messagesNode
        vc.msgSenderId = selfUserData!.id
        vc.msgReceiverId = id
        vc.msgSenderName = selfUserData!.userName
        vc.msgReceiverName = name
        
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        
        /* let objChatView = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController
         objChatView?.titleName = name
         objChatView?.databaseChats = refArtists
         objChatView?.messagesNode = messagesNode
         objChatView?.msgSenderId = selfUserData!.id
         objChatView?.msgReceiverId = id
         objChatView?.msgSenderName = selfUserData!.userName
         objChatView?.msgReceiverName = name
         objChatView?.hidesBottomBarWhenPushed = true
         self.navigationController?.pushViewController(objChatView!, animated: true)*/
    }
}

class messageListCell : UITableViewCell{
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblUser: UILabel!
    @IBOutlet weak var lblLastMsg: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblBadge: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}
