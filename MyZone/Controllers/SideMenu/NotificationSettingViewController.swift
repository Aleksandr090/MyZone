//
//  NotificationSettingViewController.swift
//  MyZone
//
//  Created by Mac on 26.07.2022.
//

import UIKit

class NotificationSettingViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    var settingItems: [(String, Bool)] = []
        
    @IBOutlet weak var tblnotiSettings: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Notifications"
        configureBackButton()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        settingItems = [("Notify me on new comments on my posts", (ApplicationPreference.sharedManager.read(type: .isCommentNotify) as? Bool) ?? true),
                        ("Notify me on replies on my comments", (ApplicationPreference.sharedManager.read(type: .isReplyNotify) as? Bool) ?? true),
                        ("Notify me on new likes",( ApplicationPreference.sharedManager.read(type: .isLikeNotify) as? Bool) ?? true),
                        ("Notify me on new direct messages", (ApplicationPreference.sharedManager.read(type: .isMessageNotify) as? Bool) ?? true),
                        ("App public notifications", (ApplicationPreference.sharedManager.read(type: .isPublicNotify) as? Bool) ?? true)
                        ]
        
        tblnotiSettings.reloadData()
    }
    

    @objc func onSwitchTapped(_ sender: UISwitch) {
        print(sender.tag)
        let userId = SharedPreference.getUserData()!.id
        switch sender.tag {
        case 0:
            MZProgressLoader.show()
            let params = ["isCommentNotify": sender.isOn ? true : false]
            APIController.makeRequestReturnJSON(.commentNotify(param: params, userId: userId)) { data, error, headerDic in
                MZProgressLoader.hide()
                if error == nil {
                    guard let responseData = data, let status = responseData["status"] as? Int else {
                        return
                    }
                    
                    print(status)
                    ApplicationPreference.sharedManager.write(type: .isCommentNotify, value: sender.isOn)
                    
                }else{
                    MZUtilManager.showAlertWith(vc: self, title: "", message: (error?.desc)!, actionTitle: "OK")
                }
            }
        case 1:
            MZProgressLoader.show()
            let params = ["isReplyNotify": sender.isOn ? true : false]
            APIController.makeRequestReturnJSON(.replyNotify(param: params, userId: userId)) { data, error, headerDic in
                MZProgressLoader.hide()
                if error == nil {
                    guard let responseData = data, let status = responseData["status"] as? Int else {
                        return
                    }
                    print(status)
                    ApplicationPreference.sharedManager.write(type: .isReplyNotify, value: sender.isOn)
                    
                }else{
                    MZUtilManager.showAlertWith(vc: self, title: "", message: (error?.desc)!, actionTitle: "OK")
                }
            }
        case 2:
            MZProgressLoader.show()
            let params = ["isLikeNotify": sender.isOn ? true : false]
            APIController.makeRequestReturnJSON(.likeNotify(param: params, userId: userId)) { data, error, headerDic in
                MZProgressLoader.hide()
                if error == nil {
                    guard let responseData = data, let status = responseData["status"] as? Int else {
                        return
                    }
                    print(status)
                    ApplicationPreference.sharedManager.write(type: .isLikeNotify, value: sender.isOn)
                    
                }else{
                    MZUtilManager.showAlertWith(vc: self, title: "", message: (error?.desc)!, actionTitle: "OK")
                }
            }
        case 3:
            MZProgressLoader.show()
            let params = ["isDirectMessage": sender.isOn ? true : false]
            APIController.makeRequestReturnJSON(.messageNotify(param: params, userId: userId)) { data, error, headerDic in
                MZProgressLoader.hide()
                if error == nil {
                    guard let responseData = data, let status = responseData["status"] as? Int else {
                        return
                    }
                    print(status)
                    ApplicationPreference.sharedManager.write(type: .isMessageNotify, value: sender.isOn)
                    
                }else{
                    MZUtilManager.showAlertWith(vc: self, title: "", message: (error?.desc)!, actionTitle: "OK")
                }
            }
            
        default:
            MZProgressLoader.show()
            let params = ["isPublicNotification": sender.isOn ? true : false]
            APIController.makeRequestReturnJSON(.publicNotify(param: params, userId: userId)) { data, error, headerDic in
                MZProgressLoader.hide()
                if error == nil {
                    guard let responseData = data, let status = responseData["status"] as? Int else {
                        return
                    }
                    
                    print(status)
                    ApplicationPreference.sharedManager.write(type: .isPublicNotify, value: sender.isOn)
                    
                }else{
                    MZUtilManager.showAlertWith(vc: self, title: "", message: (error?.desc)!, actionTitle: "OK")
                }
            }
        }
    }
    
    //MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationSettingCell") as! NotificationSettingCell
        cell.lblName.text = settingItems[indexPath.row].0
        cell.onSwitch.tag = indexPath.row
        cell.onSwitch.setOn(settingItems[indexPath.row].1, animated: false)
        cell.onSwitch.addTarget(self, action: #selector(onSwitchTapped(_:)), for: .valueChanged)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

}

class NotificationSettingCell: UITableViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var onSwitch: UISwitch!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
}
