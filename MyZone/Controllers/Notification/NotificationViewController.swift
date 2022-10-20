//
//  NotificationViewController.swift
//  MyZone
//

import UIKit

class NotificationViewController: BaseViewController {
    
    @IBOutlet weak var notifTableView: UITableView!
    
    var notifList = [NotificationData.Data]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Notifications"
        
        notifTableView?.register(UINib(nibName: "NotificationTableViewCell", bundle: nil), forCellReuseIdentifier: "notificationTableViewCell")
        
        // Do any additional setup after loading the view.
        setupSideMenu()
        
        let filterButtonItem = UIBarButtonItem(image:UIImage(named:"filterWithText"), style: .plain, target: self, action: #selector(didTouchFilterButton))
        navigationItem.rightBarButtonItem = filterButtonItem
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !SharedPreference.isUserLogin {
            MZUtilManager.showLoginAlert()
            return
        }
        getNotificationList()
    }
    
    @objc func didTouchFilterButton() {
        let actionSheet = UIAlertController(title:"Filter", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title:"New comments", style: .default, handler: { (UIAlertAction) in
            // Code here
        }))
        actionSheet.addAction(UIAlertAction(title: "Posts made nearby", style: .default, handler: { (UIAlertAction) in
            // Code here
        }))
        actionSheet.addAction(UIAlertAction(title: "My post notifications", style: .default, handler: { (UIAlertAction) in
            // Code here
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func getNotificationList() {
        MZProgressLoader.show()
        guard let userData = SharedPreference.getUserData() else { return }
        APIController.makeRequestReturnJSON(.notificationList(userId: userData.id)) { (data, error,headerDict) in
            MZProgressLoader.hide()
            if error == nil {
                guard let responseData = data, let jsonArray = responseData["data"] as? [JSONDictionary] else {
                    return
                }
                print(responseData)
                self.notifList = jsonArray.compactMap{ NotificationData.Data.init(json: $0) }
                
                self.notifTableView.reloadData()
            } else {
                MZUtilManager.showAlertWith(vc: self, title: "", message: (error?.desc)!, actionTitle: "OK")
            }
        }
    }
    
    
    func getNotificationData(notifData: NotificationData.Data)-> (title: String, subTitle: String) {
        
        var title = String()
        var subTitle = String()
        
        switch notifData.type {
        case .comment:
            title = "\(notifData.postedBy.userName) comment on your post"
            subTitle = notifData.text!
        case .like:
            title = "\(notifData.postedBy.userName) liked your post"
            
        case .disLike:
            title = "\(notifData.postedBy.userName) disliked your post"
            
        case .commentLike:
            title = "\(notifData.postedBy.userName) liked your post"
            
        case .commentDislike:
            title = "\(notifData.postedBy.userName) disliked your comment"
            
        case .replyDislike:
            title = "\(notifData.postedBy.userName) liked your post"
            
        case .replyLike:
            title = "\(notifData.postedBy.userName) disliked your comment"
            
        case .profileComment:
            title = "\(notifData.postedBy.userName) comment on your profile"
            subTitle = notifData.text!
        case .newPost:
            title = "\(notifData.postedBy.userName) added new post"
            subTitle = notifData.text!
        }
        
        return (title, subTitle)
    }
    
}

extension NotificationViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationTableViewCell", for: indexPath) as! NotificationTableViewCell
        
        cell.notifTitleLabel.text = self.getNotificationData(notifData: notifList[indexPath.row]).title
        cell.descriptionLabel.text = self.getNotificationData(notifData: notifList[indexPath.row]).subTitle
        
        
        cell.offNotificationBlock = { [weak self] in
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellData = notifList[indexPath.row]
        if cellData.clickAction == .post {
            let vc: PostDetailViewController = UIStoryboard(storyboard: .home).instantiateVC()
            vc.postId = cellData.postId
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
