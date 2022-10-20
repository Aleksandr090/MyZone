//
//  MyCommentViewController.swift
//  MyZone
//

import UIKit
import SDWebImage

class MyCommentViewController: BaseViewController {
    @IBOutlet weak var MyCommentListTableView: UITableView!
    var arrMyCommentList:NSMutableArray = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Comment"
        self.configureBackButton()
        
        getMyCommentList()
    }
   
    func getMyCommentList(){
        MZProgressLoader.show()
        
        var request = URLRequest(url: URL(string:Constant().UserAPIBaseUrl + Constant().myCommentUrl + Constant().userId)!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Constant().header, forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { [] data, response, error -> Void in
            do {
                let result = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                let json = result as NSDictionary
                print("Comment List ==> \(json)")
                let status = json.object(forKey: "status") as! NSNumber
                let message = json.object(forKey: "message") as! String
                if(status == 200){
                    self.arrMyCommentList = []
                    self.arrMyCommentList = (json.object(forKey: "data") as! NSArray).mutableCopy() as? NSMutableArray ?? NSMutableArray()
                    
                    DispatchQueue.main.async {
                        self.MyCommentListTableView.reloadData()
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

extension MyCommentViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMyCommentList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MyCommentListTableView.dequeueReusableCell(withIdentifier: "MyCommentListCell", for: indexPath) as! MyCommentListCell
        
        let temp = arrMyCommentList[indexPath.row] as! NSDictionary
        let userName = temp["postedBy"] as! NSDictionary
        
        cell.userImage.sd_setImage(with: URL(string: userName["profile_img"] as? String ?? ""), placeholderImage: UIImage(named: "dummy"))
        
        cell.lblCommentTitle.text = userName["user_name"] as? String ?? ""
        cell.lblCommentDescription.text = temp["text"] as? String ?? ""
        
        let createdAt = temp["createdAt"] as? String ?? ""
        
        if let createdDate = createdAt.dateFromFormat("yyyy-MM-dd'T'HH:mm:ssZ") {
            cell.lblCommentTime.text = MZUtilManager.shared.timeAgoSinceDate(createdDate)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let temp = arrMyCommentList[indexPath.row] as! NSDictionary
        let postId = temp["postId"] as! NSDictionary
        let vc: PostDetailViewController = UIStoryboard(storyboard: .home).instantiateVC()
        vc.postId = postId["_id"] as! String
        vc.selectedFeedIndex = indexPath.row
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

class MyCommentListCell: UITableViewCell{
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var lblCommentTitle: UILabel!
    @IBOutlet weak var lblCommentDescription: UILabel!
    @IBOutlet weak var lblCommentTime: UILabel!
    
}
