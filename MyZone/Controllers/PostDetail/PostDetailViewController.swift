//
//  PostDetailViewController.swift
//  MyZone
//

import UIKit
import MMPlayerView
import AVKit
import DropDown
import MaterialComponents.MaterialTextControls_FilledTextAreas
import MapKit

class PostDetailViewController: BaseViewController, UITextViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet weak var viewMainComment: UIView!
    @IBOutlet weak var txtViewdAddPublicComment: UITextView!
    @IBOutlet weak var btnPublicCommentCancle: UIButton!
    @IBOutlet weak var btnPublicCommentSend: UIButton!
    
    @IBOutlet weak var viewCommentReply: UIView!
    @IBOutlet weak var lblCmmentReplyUsername: UILabel!
    @IBOutlet weak var btnCancelCommentReply: UIButton!
    
    var postDetail: PostData.Data!
    var storedOffsets = [Int: CGFloat]()
    
    lazy var mmPlayerLayer: MMPlayerLayer = {
        let l = MMPlayerLayer()
        l.cacheType = .memory(count: 5)
        l.coverFitType = .fitToPlayerView
        l.videoGravity = AVLayerVideoGravity.resizeAspect
        l.replace(cover: CoverA.instantiateFromNib())
        l.repeatWhenEnd = false
        return l
    }()
    
    var moreButtonItem = UIBarButtonItem()
    let wishlistButton = UIButton()
    
    var viewModel: HomeViewModal!
    var postId = String()
    var postById = String()
    var selectedFeedIndex: Int!
    
    var commentReply:Bool = false
    var commentReplyTag:Int!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
                                    #selector(PostDetailViewController.handleRefresh(_:)),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.AppTheme.PinkColor
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //  self.viewModel = HomeViewModal()
        self.setupNavigationBar()
        self.tableView.tableFooterView = UIView(frame: .zero)
        //self.tableView.addSubview(self.refreshControl)
        
        self.tableView?.register(UINib(nibName: "PostDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "PostDetailTableViewCell")
        self.tableView?.register(UINib(nibName: "ReplyCell", bundle: nil), forCellReuseIdentifier: "ReplyCell")
        
        if viewModel != nil {
            postDetail = viewModel.posts[selectedFeedIndex]
            self.setupFeedData()
            if postDetail != nil {
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
            }
        } else {
            getPostDetail()
        }
        
        viewCommentReply.isHidden = true
        txtViewdAddPublicComment.delegate = self
        txtViewdAddPublicComment.text = "Add public comment"
        txtViewdAddPublicComment.textColor = UIColor.lightGray
        btnPublicCommentCancle.isHidden = true
        
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.tableView.addSubview(self.refreshControl)
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        refreshControl.endRefreshing()
        getPostDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.deleteSelfComment(notification:)), name: Notification.Name("deleteSelfComment"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.openFullVideoScreen(notification:)), name: Notification.Name("fullVideoOpen"), object: nil)
        
    }
    
    @objc func openFullVideoScreen(notification: Notification) {
        let vc: PlayerViewController = UIStoryboard(storyboard: .home).instantiateVC()
        vc.modalPresentationStyle = .overCurrentContext
        vc.videoUrl = String(postDetail.video[0].videos)
        self.tabBarController!.present(vc, animated: true, completion: nil)
    }
    
    @objc func deleteSelfComment(notification: Notification) {
        let commentId = notification.userInfo!["commentId"]
        let postId = notification.userInfo!["postId"]
        guard let userData = SharedPreference.getUserData() else { return }
        MZProgressLoader.show()
        let params:NSMutableDictionary? = [
            "post_id":postId as Any,
            "commentId":commentId as Any
        ]
        print(params as Any)
        var request = URLRequest(url: URL(string:Constant().UserAPIBaseUrl + Constant().postCommentRemove + userData.id)!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params as Any, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Constant().header, forHTTPHeaderField: "Authorization")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { [] data, response, error -> Void in
            do {
                let result = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                let json = result as NSDictionary
                print("Delete Self COmment ==>\(json)")
                let status = json.object(forKey: "status") as! NSNumber
                let message = json.object(forKey: "message") as! String
                if(status == 200){
                    DispatchQueue.main.async { [self] in
                        getPostDetail()
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
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func getPostDetail() {
        
        MZProgressLoader.show()
        guard let userData = SharedPreference.getUserData() else { return }
        APIController.makeRequestReturnJSON(.postDeatil(param: ["user_id": userData.id], postId: postId)) { (data, error,headerDict) in
            MZProgressLoader.hide()
            if error == nil {
                guard let responseData = data, let jsonData = responseData["data"] as? JSONDictionary else {
                    return
                }
                
                self.postDetail = PostData.Data.init(json: jsonData)
                self.setupFeedData()
                if self.postDetail != nil {
                    self.tableView.delegate = self
                    self.tableView.dataSource = self
                    self.tableView.reloadData()
                }
            }else{
                MZUtilManager.showAlertWith(vc: self, title: "", message: (error?.desc)!, actionTitle: "OK")
            }
        }
    }
    
    //MARK: - Add Public Comment Code
    func textViewDidBeginEditing(_ textView: UITextView) {
        if txtViewdAddPublicComment.textColor == UIColor.lightGray {
            txtViewdAddPublicComment.text = nil
            txtViewdAddPublicComment.textColor = UIColor.AppTheme.TextColor
            btnPublicCommentCancle.isHidden = false
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if txtViewdAddPublicComment.text.isEmpty {
            txtViewdAddPublicComment.text = "Add public comment"
            txtViewdAddPublicComment.textColor = UIColor.lightGray
            btnPublicCommentCancle.isHidden = true
        }
    }
    
    @IBAction func btnActionCanclePublicComment(_ sender: Any) {
        //txtViewdAddPublicComment.text = "Add public comment"
        //txtViewdAddPublicComment.textColor = UIColor.lightGray
        
        txtViewdAddPublicComment.text = nil
        txtViewdAddPublicComment.textColor = UIColor.AppTheme.TextColor
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
        guard let userData = SharedPreference.getUserData() else { return }
        if txtViewdAddPublicComment.textColor == UIColor.lightGray { return }
        MZProgressLoader.show()
        let params:NSMutableDictionary? = [
            "post_id":postDetail.id,
            "user_id":postDetail.postedBy.id,
            "text":txtViewdAddPublicComment.text!,
            "time":String(Int(Date().timeIntervalSince1970 * 1000))
        ]
        print(params as Any)
        var request = URLRequest(url: URL(string:Constant().UserAPIBaseUrl + Constant().comment + userData.id)!)
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
                        txtViewdAddPublicComment.text = "Add public comment"
                        txtViewdAddPublicComment.textColor = UIColor.lightGray
                        getPostDetail()
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
    
    //MARK: - Comment Reply Code
    @IBAction func btnActionCommentReplyCancel(_ sender: Any) {
        viewCommentReply.isHidden = true
        commentReply = false
    }
    
    @objc func sendCommentReply(button: UIButton){
        let postedByName = postDetail.comment[button.tag].postedBy.userName
        commentReply = true
        commentReplyTag = button.tag
        viewCommentReply.isHidden = false
        lblCmmentReplyUsername.text = "Replying to @" + postedByName
    }
    
    func commentReplyAPICall(){
        guard let userData = SharedPreference.getUserData() else { return }
        if txtViewdAddPublicComment.textColor == UIColor.lightGray { return }
        let commentUserId =  postDetail.comment[commentReplyTag].postedBy.id
        let commentId =  postDetail.comment[commentReplyTag].id
        MZProgressLoader.show()
        let params:NSMutableDictionary? = [
            "post_id":postDetail.id,
            "user_id":postDetail.postedBy.id,
            "comment_user":commentUserId,
            "commentId":commentId,
            "text":txtViewdAddPublicComment.text!,
            "time":String(Int(Date().timeIntervalSince1970 * 1000))
        ]
        print(params as Any)
        var request = URLRequest(url: URL(string:Constant().UserAPIBaseUrl + Constant().postCommentReply + userData.id)!)
        request.httpMethod = "PUT"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params as Any, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Constant().header, forHTTPHeaderField: "Authorization")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { [] data, response, error -> Void in
            do {
                let result = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                let json = result as NSDictionary
                print("Post Comment Reply ==>\(json)")
                let status = json.object(forKey: "status") as! NSNumber
                let message = json.object(forKey: "message") as! String
                if(status == 200){
                    DispatchQueue.main.async { [self] in
                        MZProgressLoader.hide()
                        commentReply = false
                        viewCommentReply.isHidden = true
                        txtViewdAddPublicComment.text = "Add public comment"
                        txtViewdAddPublicComment.textColor = UIColor.lightGray
                        getPostDetail()
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
    func likeDislikePostComment(sectionTag:Int, isLike: Bool){
        guard let userData = SharedPreference.getUserData() else { return }
        let commentId =  postDetail.comment[sectionTag].id
        
        let url:String!
        if(isLike == true){
            url = Constant().UserAPIBaseUrl + Constant().postCommentLike + userData.id
        }else{
            url = Constant().UserAPIBaseUrl + Constant().postCommentDislike + userData.id
        }
        
        MZProgressLoader.show()
        let params:NSMutableDictionary? = [
            "post_id":postDetail.id,
            "user_id":postDetail.postedBy.id,
            "comment_id":commentId
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
                print("Post Comment Like DislIke ==>\(json)")
                let status = json.object(forKey: "status") as! NSNumber
                let message = json.object(forKey: "message") as! String
                if(status == 200){
                    DispatchQueue.main.async { [self] in
                        MZProgressLoader.hide()
                        getPostDetail()
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
    
    func setupNavigationBar() {
        self.configureBackButton()
        
        let shareButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "feed_share"), style: .plain, target:  self, action: #selector(didTouchShareButton))
        wishlistButton.setImage( #imageLiteral(resourceName: "bookmark"), for: .normal)
        wishlistButton.setImage( #imageLiteral(resourceName: "bookmark_black"), for: .selected)
        wishlistButton.addTarget(self, action:  #selector(didTouchWishlistButton), for: .touchDown)
        let wishlistButtonItem = UIBarButtonItem(customView: wishlistButton)
        
        moreButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "info"), style: .plain, target:  self, action: #selector(didTouchMoreOptionButton))
        
        navigationItem.rightBarButtonItems = [moreButtonItem, wishlistButtonItem,shareButtonItem]
    }
    
    func setupFeedData() {
        wishlistButton.isSelected = postDetail.isBookmarked        
    }
    
    @objc func didTouchShareButton() {
        let text = postDetail.image.count > 0 ? postDetail.image[0].img : postDetail.video.count > 0  ? postDetail.video[0].videos : ""
        if text == "" { return }
        // set up activity view controller
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = self.view
        //  activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @objc func didTouchWishlistButton() {
        if !SharedPreference.isUserLogin {
            MZUtilManager.showLoginAlert()
            return
        }
        self.addFavouritePost(by: selectedFeedIndex, isFavourite: !wishlistButton.isSelected)
    }
    
    @objc func didTouchMoreOptionButton() {
        if !SharedPreference.isUserLogin {
            MZUtilManager.showLoginAlert()
            return
        }
        
        let moreOptionDropDown = DropDown()
        moreOptionDropDown.anchorView = moreButtonItem
        moreOptionDropDown.bottomOffset = CGPoint(x: -100, y: 60)
        // You can also use localizationKeysDataSource instead. Check the docs.
        if(SharedPreference.getUserData()?.id == postDetail.postedBy.id){
            moreOptionDropDown.dataSource = ["Edit", "Refresh", "Hide", "Delete"]
            let iconNames = ["edit_icon", "refresh_icon", "eye_icon", "delete_icon"]
            moreOptionDropDown.cellNib = UINib(nibName: "DropDownMenuCell", bundle: nil)
            moreOptionDropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
               guard let cell = cell as? DropDownMenuCell else { return }

                cell.imvIcon.image = UIImage(named: iconNames[index])
            }
            moreOptionDropDown.selectionAction = { (index, item) in
                switch index {
                case 0:
                    print("edit")
                    self.gotoEditPost()
                    break
                case 1:
                    print("refresh")
                    self.getPostDetail()
                    break
                case 2:
                    print("hide")
                    break
                default:
                    print("delete")
                    let vc: MZAlertViewController = UIStoryboard(storyboard: .main).instantiateVC()
                    vc.alertType = .deletePost
                    vc.delegate = self
                    vc.modalPresentationStyle = .overCurrentContext
                    self.present(vc, animated: false, completion: nil)
                    break
                }
            }
            
        } else {
            moreOptionDropDown.dataSource = ["Report"]
     
            moreOptionDropDown.cellNib = UINib(nibName: "DropDownMenuCell", bundle: nil)
            
            moreOptionDropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
               guard let cell = cell as? DropDownMenuCell else { return }

                cell.imvIcon.image = UIImage(named: "flag_icon")
            }
            
            moreOptionDropDown.selectionAction = { [weak self] (index, item) in
                let vc: MZAlertViewController = UIStoryboard(storyboard: .main).instantiateVC()
                vc.alertType = .report
                vc.itemIndex = self!.selectedFeedIndex
                vc.delegate = self
                vc.modalPresentationStyle = .overCurrentContext
                self!.present(vc, animated: false, completion: nil)
            }
        }
        
        moreOptionDropDown.show()
    }
    
    func gotoEditPost() {        
        let vc: AddPostViewController = UIStoryboard(storyboard: .home).instantiateVC()
        vc.postId = postDetail.id
        vc.from = 1
        vc.postDetail = postDetail
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .overCurrentContext
        self.present(navVC, animated: true, completion: nil)
    }
    
    // Comment Reply Like DisLike
    func commentReplyLikeDislike(data:PostData.Data.Comment.Replies, isLike: Bool){
        guard let userData = SharedPreference.getUserData() else { return }
        let url:String!
        let params:NSMutableDictionary!
        if(isLike == true){
            params =  [
                "post_id":data.postId,
                "comment_id":data.commentId,
                "reply_id":data.id,
                "reply_user":userData.id
            ]
            url = Constant().UserAPIBaseUrl + Constant().postCommentReplyLike + userData.id
        }else{
            params =  [
                "reply_id":data.id
            ]
            url = Constant().UserAPIBaseUrl + Constant().postCommentReplyDislike + userData.id
        }
        MZProgressLoader.show()
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
                print("Post Comment Reply Like DislIke ==>\(json)")
                let status = json.object(forKey: "status") as! NSNumber
                let message = json.object(forKey: "message") as! String
                if(status == 200){
                    DispatchQueue.main.async { [self] in
                        MZProgressLoader.hide()
                        getPostDetail()
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
    
    func likeDislikePost(isLike: Bool) {
        guard let userData = SharedPreference.getUserData() else { return }
        let url:String!
        if(isLike == true){
            url = Constant().UserAPIBaseUrl + Constant().postLike + userData.id
        }else{
            url = Constant().UserAPIBaseUrl + Constant().postDislike + userData.id
        }
        
        MZProgressLoader.show()
        let params:NSMutableDictionary? = [
            "post_id":postDetail.id,
            "user_id":userData.id,
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
                print("Post Like DislIke ==>\(json)")
                let status = json.object(forKey: "status") as! NSNumber
                let message = json.object(forKey: "message") as! String
                if(status == 200){
                    DispatchQueue.main.async { [self] in
                        MZProgressLoader.hide()
                        getPostDetail()
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
    
    func addFavouritePost(by index: Int, isFavourite: Bool) {
        MZProgressLoader.show()
        self.viewModel.addFavouritePost(isFavourite: isFavourite, postIndex: index) { responseData, error in
            MZProgressLoader.hide()
            if error == nil {
                if let userData = SharedPreference.getUserData() {
                    if self.viewModel.posts[index].bookmarkedBy!.contains(userData.id) {
                        self.viewModel.posts[index].bookmarkedBy!.remove(at: self.viewModel.posts[index].bookmarkedBy!.firstIndex(of: userData.id)!)
                        self.wishlistButton.isSelected = false
                    } else {
                        self.viewModel.posts[index].bookmarkedBy!.append(userData.id)
                        self.wishlistButton.isSelected = true
                    }
                }
            } else {
                MZUtilManager.showAlertWith(vc: self, title: "", message: (error?.desc)!, actionTitle: "OK")
            }
        }
    }
    
    func reportPost(by index: Int, type: String) {
        MZProgressLoader.show()
        self.viewModel.reportPost(status: true, postIndex: index, type: type) { responseData, error in
            MZProgressLoader.hide()
            if error == nil {
                
            } else {
                MZUtilManager.showAlertWith(vc: self, title: "", message: (error?.desc)!, actionTitle: "OK")
            }
        }
    }
    
    func deletePostAPI() {
        MZProgressLoader.show()
        self.viewModel.deletePost(postId: postDetail.id) { responseData, error in
            MZProgressLoader.hide()
            if error == nil {
                self.navigationController?.popViewController(animated: true)
            } else {
                MZUtilManager.showAlertWith(vc: self, title: "", message: (error?.desc)!, actionTitle: "OK")
            }
        }
    }
    
    // method to run when imageview is tapped
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        let imgView = tapGestureRecognizer.view as! UIImageView
        if (imgView.tag == 0){
            let vc: PostUserDetailsViewController = UIStoryboard(storyboard: .home).instantiateVC()
            vc.userId = postDetail.postedBy.id
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func openUserProfileDetail(button: UIButton){
        let vc: PostUserDetailsViewController = UIStoryboard(storyboard: .home).instantiateVC()
        vc.userId = postDetail.comment[button.tag-1].postedBy.id
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

//MARK:- UITableViewDataSource, UITableViewDelegate
extension PostDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return (postDetail.comment.count + 1)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        return postDetail.comment[section-1].collapsed ? 0 : postDetail.comment[section-1].replies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostDetailTableViewCell") as! PostDetailTableViewCell
            
            cell.configureCell(postDetail, itemIndex: indexPath.row)
            cell.delegate = self
            
            if postDetail.getAllPagerItems().count > 0 {
                cell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
                cell.collectionConatinerView.isHidden = false
            } else {
                cell.collectionConatinerView.isHidden = true
            }
            
            cell.likeDislikeClosure = { [weak self] isLike in
                if SharedPreference.isUserLogin {
                    self?.likeDislikePost(isLike: isLike)
                } else {
                    MZUtilManager.showLoginAlert()
                }
            }
            
            cell.userImageView?.tag = indexPath.row
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            tapGestureRecognizer.numberOfTapsRequired = 1
            cell.userImageView?.isUserInteractionEnabled = true
            cell.userImageView?.addGestureRecognizer(tapGestureRecognizer)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReplyCell") as! ReplyCell
            cell.configureCell(postDetail.comment[indexPath.section-1].replies[indexPath.row])
            cell.OPLabel.isHidden = postDetail.postedBy.id != postDetail.comment[indexPath.section-1].replies[indexPath.row].postedBy.id
            let data = postDetail.comment[indexPath.section-1].replies[indexPath.row]
            cell.likeDislikeClosure = { [weak self] isLike in
                if SharedPreference.isUserLogin {
                    //self?.likeDislikePost(by: indexPath, isLike: isLike)
                    self?.commentReplyLikeDislike(data:data, isLike: isLike)
                } else {
                    MZUtilManager.showLoginAlert()
                }
            }
            
            cell.replyToReplyButton.tag = indexPath.section - 1
            cell.replyToReplyButton.addTarget(self, action: #selector(sendCommentReply(button:)), for: .touchUpInside)
            cell.moreOptionSelectionClosure = {
                if SharedPreference.isUserLogin {
                    let vc: MZAlertViewController = UIStoryboard(storyboard: .main).instantiateVC()
                    vc.alertType = .report
                    vc.itemIndex = indexPath.section - 1
                    vc.delegate = self
                    vc.modalPresentationStyle = .overCurrentContext
                    self.present(vc, animated: false, completion: nil)
                } else {
                    MZUtilManager.showLoginAlert()
                }
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //        if indexPath.row == viewModel.totalRow - 1 && !viewModel.isLastContent {
        //            if !viewModel.isLastContent {
        //                viewModel.pageCount += 1
        //                viewModel.getPostBy(pageCount: viewModel.pageCount, lastCreatedAt: viewModel.posts[indexPath.row].id)
        //            }
        //        }
        guard let cell = cell as? PostDetailTableViewCell else { return }
        cell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
        
        cell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? PostDetailTableViewCell else { return }
        storedOffsets[indexPath.row] = cell.collectionViewOffset
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.0
        }else{
            let cell = CommentCell.instantiateFromNib()
            let txt = postDetail.comment[section-1].text
            cell.commentLabel.numberOfLines = 0
            cell.commentLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.commentLabel.text = txt
            cell.commentLabel.font = UIFont(name: "SFProDisplay-Regular", size: 14.0)
            cell.commentLabel.sizeToFit()
            return 80.0 + CGFloat(cell.commentLabel.frame.height)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return UIView()
        }
        
        let commentCell = CommentCell.instantiateFromNib()
        
        commentCell.btnUserImage.tag = section
        commentCell.btnUserImage.addTarget(self, action: #selector(openUserProfileDetail(button:)), for: .touchUpInside)
        
        commentCell.btnCommentReply.tag = section - 1
        commentCell.btnCommentReply.addTarget(self, action: #selector(sendCommentReply(button:)), for: .touchUpInside)
        
        commentCell.configureCell(postDetail.comment[section-1])
        commentCell.OPLabel.isHidden = postDetail.postedBy.id != postDetail.comment[section-1].postedBy.id
        
        commentCell.likeDislikeClosure = { [weak self] isLike in
            if SharedPreference.isUserLogin {
                self?.likeDislikePostComment(sectionTag: section-1, isLike: isLike)
            } else {
                MZUtilManager.showLoginAlert()
            }
        }
        
        commentCell.moreOptionSelectionClosure = {
            if SharedPreference.isUserLogin {
                let vc: MZAlertViewController = UIStoryboard(storyboard: .main).instantiateVC()
                vc.alertType = .report
                vc.itemIndex = section - 1
                vc.delegate = self
                vc.modalPresentationStyle = .overCurrentContext
                self.present(vc, animated: false, completion: nil)
            } else {
                MZUtilManager.showLoginAlert()
            }
        }
        
        commentCell.showHideReplyClosure = {
            self.postDetail.comment[section-1].collapsed = !self.postDetail.comment[section-1].collapsed
            tableView.beginUpdates()
            tableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .none)
            tableView.endUpdates()
        }
        
        return commentCell
    }
}

extension PostDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postDetail.getAllPagerItems().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let pagerData = postDetail.getAllPagerItems()[indexPath.item]
        
        if let image = pagerData as? PostData.Data.Image {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageFeedCollectionViewCell", for: indexPath) as! ImageFeedCollectionViewCell
            
            cell.feedImageView?.sd_setImage(with: URL(string: image.img), placeholderImage: nil, options: .continueInBackground)
            
            cell.feedImageView.contentMode = .scaleAspectFill
            return cell
            
        } else if let video = pagerData as? PostData.Data.Video {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoFeedCollectionViewCell", for: indexPath) as! VideoFeedCollectionViewCell
            
            cell.configureVideo(url: video.videos)
            cell.player.play()
            
            return cell
            
        } else if let audio = pagerData as? PostData.Data.Audio {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AudioFeedCollectionViewCell", for: indexPath) as! AudioFeedCollectionViewCell
            print(audio)
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width , height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if let mainCell = tableView.cellForRow(at: IndexPath(row: collectionView.tag, section: 0)) as?  PostDetailTableViewCell{
            mainCell.collectionPageControl.currentPage = indexPath.item
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        
        //if ((cell?.isKind(of: ImageFeedCollectionViewCell.self)) != nil) {
        if let imageCell = cell as? ImageFeedCollectionViewCell {
            let vc: ImageZoomViewController = UIStoryboard(storyboard: .home).instantiateVC()
            vc.feedImage = imageCell.feedImageView.image!
            vc.modalPresentationStyle = .overCurrentContext
            self.tabBarController!.present(vc, animated: true, completion: nil)
            
            //} else if let imageCell = cell as? VideoFeedCollectionViewCell {
        } else if ((cell?.isKind(of: VideoFeedCollectionViewCell.self)) != nil) {
            DispatchQueue.main.async { [unowned self] in
                if self.presentedViewController != nil || self.mmPlayerLayer.isShrink == true {
                    collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                    self.updateDetail(at: collectionView.tag, indexPath: indexPath)
                } else {
                    self.presentDetail(at: collectionView.tag, indexPath: indexPath, pagerCollection: collectionView)
                }
            }
        }
    }
}

extension PostDetailViewController {
    fileprivate func updateDetail(at row : Int,  indexPath: IndexPath) {
        //        let value = DemoSource.shared.demoData[indexPath.row]
        //        if let detail = self.presentedViewController as? DetailViewController {
        //            detail.data = value
        //        }
        
        self.mmPlayerLayer.thumbImageView.image = nil //value.image
        //        self.mmPlayerLayer.set(url: URL(string: (viewModel.posts[row].getAllPagerItems()[0] as? PostData.Data.Video)!.videos))
        self.mmPlayerLayer.set(url: URL(string: postDetail.video[0].videos))
        self.mmPlayerLayer.resume()
    }
    
    fileprivate func presentDetail(at row : Int,  indexPath: IndexPath, pagerCollection: UICollectionView) {
        self.updateCell(at: indexPath, pagerCollection: pagerCollection)
        mmPlayerLayer.resume()
        
        //        if let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
        //            vc.data = DemoSource.shared.demoData[indexPath.row]
        //            self.present(vc, animated: true, completion: nil)
        //            self.navigationController?.pushViewController(vc, animated: true)
        //        }
    }
    
    fileprivate func updateCell(at indexPath: IndexPath, pagerCollection: UICollectionView) {
        if let cell = pagerCollection.cellForItem(at: indexPath) as? VideoFeedCollectionViewCell, let playURL = cell.videoURL {
            // this thumb use when transition start and your video dosent start
            mmPlayerLayer.set(url: URL(string: playURL))
            mmPlayerLayer.resume()
        }
    }
}

extension PostDetailViewController: cellButtonDelegate {
    func onDate(_ postData: PostData.Data) {
        
        let interval = postData.date
        if let url = URL(string: "calshow:\(interval)") {
            UIApplication.shared.open(url)
        }
    }
    
    func onAddress(_ postData: PostData.Data) {
            
        let latitude:CLLocationDegrees =  postData.location.coordinates[0]
        let longitude:CLLocationDegrees =  postData.location.coordinates[1]
            
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(postData.placeName)"
        mapItem.openInMaps(launchOptions: options)
    }
    
    
    func onCall(_ postData: PostData.Data) {
        if let url = URL(string: "tel://\(postData.contactNo)") {
            UIApplication.shared.open(url)
        }
    }
}

extension PostDetailViewController: MZAlertViewDelegate {
    func didReport(itemIndex: Int, type: String) {
        if !type.isEmpty {
            self.reportPost(by: itemIndex, type: type)
        }
    }
    func deleteMyPost() {
        self.deletePostAPI()
    }
}

 
