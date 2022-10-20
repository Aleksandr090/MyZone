//
//  HomeViewController.swift
//  MyZone
//

import UIKit
import AVFoundation
import MMPlayerView
import AVKit
import DropDown


class SearchResultViewController: BaseViewController {
    
    @IBOutlet var homeTableView: UITableView!
    
    var offsetObservation: NSKeyValueObservation?
    
    lazy var mmPlayerLayer: MMPlayerLayer = {
        let l = MMPlayerLayer()
        l.cacheType = .memory(count: 0)
        l.coverFitType = .fitToPlayerView
        l.videoGravity = AVLayerVideoGravity.resizeAspect
        l.replace(cover: CoverA.instantiateFromNib())
        l.repeatWhenEnd = false
        return l
    }()
    
    var audioPlayer: AVPlayer?
    
    var viewModel: HomeViewModal!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
                                    #selector(HomeViewController.handleRefresh(_:)),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.AppTheme.PinkColor
        
        return refreshControl
    }()
    
    var storedOffsets = [Int: CGFloat]()
    
    let navOptionImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    let navTitleLabel = UILabel()
    let zoneValueLabel = UILabel()
    
    var postListType = ""
    var index:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel = HomeViewModal()
        
        playerSetup()
        
        self.homeTableView.tableFooterView = UIView(frame: .zero)
        
        self.homeTableView.addSubview(self.refreshControl)
        
        self.homeTableView?.register(UINib(nibName: "HomeFeedTableViewCell", bundle: nil), forCellReuseIdentifier: "HomeFeedTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        setupNavigationBar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.openFullVideoScreen(notification:)), name: Notification.Name("fullVideoOpen"), object: nil)
        
        navigationController?.isNavigationBarHidden = false
        
        let radius = String(format: "%.0f", ApplicationPreference.sharedManager.read(type: .userRadius) as? Double ?? 0.0)
        zoneValueLabel.text = "\(radius) KM"
        viewModel.radius = radius
        viewModel.lat = "\(ApplicationPreference.sharedManager.read(type: .userLat))"
        viewModel.lng = "\(ApplicationPreference.sharedManager.read(type: .userLong))"
        viewModel.postType = postListType == "All" ? "recent" : postListType
        getPostData()
    }
    
    @objc func openFullVideoScreen(notification: Notification) {
        let url = notification.userInfo!["url"]
        openVideoFullScreen(videoUrl: url as! String)
    }
    
    func openVideoFullScreen(videoUrl:String){
        let vc: PlayerViewController = UIStoryboard(storyboard: .home).instantiateVC()
        vc.modalPresentationStyle = .overCurrentContext
        vc.videoUrl = videoUrl
        self.tabBarController!.present(vc, animated: true, completion: nil)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        mmPlayerLayer.player?.pause()
        audioPlayer?.pause()
    }
    
    func setupNavigationBar() {
        setupNavBarWith(title: postListType)
    }
    
    func setupNavBarWith(title: String) {
        self.navigationItem.title = title
        configureBackButton()
    }
    
    func setupHomeNavigationBar() {
        // side menu
        setupSideMenu()
        
        // Setup Title view
        let arrowImageView = UIImageView()
        arrowImageView.image = #imageLiteral(resourceName: "down-arrow")
        arrowImageView.tintColor = UIColor.AppTheme.PinkColor
        navOptionImageView.image = #imageLiteral(resourceName: "recent_icon")
        navTitleLabel.text = "All"
        navTitleLabel.font = UIFont(name: Fontname.SFProDisplayMedium, size: 18)
        navTitleLabel.textColor = UIColor.AppTheme.TextColor
        
        let stackView = UIStackView(arrangedSubviews: [arrowImageView, navTitleLabel, navOptionImageView])
        stackView.alignment = .center
        stackView.spacing = 5
        stackView.axis = .horizontal
        stackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(stackViewTapped)))
        self.navigationItem.titleView = stackView
        
        // Left Bar button
        let zoneLabel = UILabel()
        zoneLabel.text = "Zone"
        zoneLabel.font = UIFont(name: Fontname.SFProDisplayMedium, size: 9)
        zoneLabel.textColor = UIColor.white
        zoneValueLabel.text = "10 KM"
        zoneValueLabel.font = UIFont(name: Fontname.SFProDisplayBold, size: 10)
        zoneValueLabel.textColor = UIColor.white
        let rightStackView = UIStackView(arrangedSubviews: [zoneLabel, zoneValueLabel])
        rightStackView.frame = CGRect(x: 0, y: 7, width: 44, height: 30)
        rightStackView.alignment = .center
        rightStackView.distribution = .fillEqually
        rightStackView.spacing = 0
        rightStackView.axis = .vertical
        let rigthNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        rigthNavView.backgroundColor = UIColor.AppTheme.PinkColor
        rigthNavView.addSubview(rightStackView)
        rigthNavView.cornerRadiusValue = 22
        rigthNavView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rightNavItemTapped)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rigthNavView)
    }
    
    func playerSetup() {
        self.navigationController?.mmPlayerTransition.push.pass(setting: { (_) in
            
        })
        offsetObservation = homeTableView.observe(\.contentOffset, options: [.new]) { [weak self] (_, value) in
            guard let self = self, self.presentedViewController == nil else {return}
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            self.perform(#selector(self.startLoading), with: nil, afterDelay: 0.2)
        }
        homeTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 200, right:0)
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
        //            self?.updateByContentOffset()
        //            self?.startLoading()
        //        }
        
        mmPlayerLayer.getStatusBlock { [weak self] (status) in
            switch status {
            case .failed(let err):
                let alert = UIAlertController(title: "err", message: err.description, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            case .ready:
                print("Ready to Play")
            case .playing:
                print("Playing")
            case .pause:
                print("Pause")
            case .end:
                print("End")
            default: break
            }
        }
        
        mmPlayerLayer.getOrientationChange { (status) in
            print("Player OrientationChange \(status)")
        }
    }
    
    @objc func stackViewTapped() {
        postSortByDropDown()
    }
    
    @objc func rightNavItemTapped() {
        let vc: SelectLocationViewController = UIStoryboard(storyboard: .authentication).instantiateVC()
        vc.vcType = .fromHome
        vc.modalPresentationStyle = .overCurrentContext
        self.tabBarController!.present(vc, animated: true, completion: nil)
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        refreshControl.endRefreshing()
        postListType == "All" ? viewModel.getPostBy(pageCount: 1, lastCreatedAt: "") : viewModel.getSearchPostBy(pageCount: 1, lastCreatedAt: "")
    }
    
    func getPostData() {
        MZProgressLoader.show()
        postListType == "All" ? viewModel.getPostBy(pageCount: 1, lastCreatedAt: "") : viewModel.getSearchPostBy(pageCount: 1, lastCreatedAt: "")
        viewModel.completion = { json , error in
            DispatchQueue.main.async {
                MZProgressLoader.hide()
                
                if error == nil {
                    UIView.animate(withDuration: 0.1, animations: {
                        self.homeTableView.delegate = self
                        self.homeTableView.dataSource = self
                        self.homeTableView.reloadData()
                    })
                } else {
                    if self.viewModel.totalRow == 0 {
                        MZUtilManager.showAlertWith(vc: self, title: "", message: "No post found", actionTitle: "OK")
                        
//                            self.showErrorView(errorCode: (error?.code)!, errorTitle: (error?.desc)!, errorMsg: "", completion: {
//                                self.viewModel.getEvents(offset: "0", lastCreatedAt: "")
//                            })
                    }
                }
            }
        }
    }
    
    func sharePostAction (_ post: PostData.Data) {        
       
        let text = post.image.count > 0 ? post.image[0].img : post.video.count > 0  ? post.video[0].videos : ""
        if text == "" { return }
        // set up activity view controller
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = self.view
        //        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
    func postSortByDropDown() {
        let filters = ["Recent", "Trending", "Popular"]
        let filtersImage = ["recent_icon", "trending_icon", "popular_icon"]
        
        let chooseDropDown = DropDown()
        chooseDropDown.anchorView = self.navigationItem.titleView
        chooseDropDown.bottomOffset = CGPoint(x: 0, y: self.navigationItem.titleView!.bounds.height)
        chooseDropDown.dataSource = filters
        
        /*** FOR CUSTOM CELLS ***/
        chooseDropDown.cellNib = UINib(nibName: "TitleDropDownCell", bundle: nil)
        chooseDropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
            guard let cell = cell as? TitleDropDownCell else { return }
            cell.titleLogoImageView.image = UIImage(named: filtersImage[index])
        }
        chooseDropDown.show()
        
        // Action triggered on selection
        chooseDropDown.selectionAction = { [weak self] (index, item) in
            self?.navTitleLabel.text = filters[index]
            self?.navOptionImageView.image = UIImage(named: filtersImage[index])
            self?.viewModel.postType = filters[index].lowercased()
            self?.getPostData()
        }
    }
    
    func likeDislikePost(by indexPath: IndexPath, isLike: Bool) {
        MZProgressLoader.show()
        self.viewModel.likeDislikePost(isLike: isLike, postIndex: indexPath.row) { responseData, error in
            MZProgressLoader.hide()
            if error == nil {
                if let userData = SharedPreference.getUserData() {
                    if isLike {
                        if self.viewModel.posts[indexPath.row].dislikedBy.contains(userData.id) {
                            self.viewModel.posts[indexPath.row].dislikedBy.remove(at: self.viewModel.posts[indexPath.row].dislikedBy.firstIndex(of: userData.id)!)
                        }
                        self.viewModel.posts[indexPath.row].likedBy.append(userData.id)
                    } else {
                        if self.viewModel.posts[indexPath.row].likedBy.contains(userData.id) {
                            self.viewModel.posts[indexPath.row].likedBy.remove(at: self.viewModel.posts[indexPath.row].likedBy.firstIndex(of: userData.id)!)
                        }
                        self.viewModel.posts[indexPath.row].dislikedBy.append(userData.id)
                    }
                    self.homeTableView.beginUpdates()
                    self.homeTableView.reloadRows(at: [indexPath], with: .automatic)
                    self.homeTableView.endUpdates()
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
    
    func addFavouritePost(by indexPath: IndexPath, isFavourite: Bool) {
        MZProgressLoader.show()
        self.viewModel.addFavouritePost(isFavourite: isFavourite, postIndex: indexPath.row) { responseData, error in
            MZProgressLoader.hide()
            if error == nil {
                if let userData = SharedPreference.getUserData() {
                    if self.viewModel.posts[indexPath.row].bookmarkedBy!.contains(userData.id) {
                        self.viewModel.posts[indexPath.row].bookmarkedBy!.remove(at: self.viewModel.posts[indexPath.row].bookmarkedBy!.firstIndex(of: userData.id)!)
                    } else {
                        self.viewModel.posts[indexPath.row].bookmarkedBy!.append(userData.id)
                    }
                }
                self.homeTableView.beginUpdates()
                self.homeTableView.reloadRows(at: [indexPath], with: .automatic)
                self.homeTableView.endUpdates()
            } else {
                MZUtilManager.showAlertWith(vc: self, title: "", message: (error?.desc)!, actionTitle: "OK")
            }
        }
    }
}


//MARK:- UITableViewDataSource, UITableViewDelegate
extension SearchResultViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.totalRow
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeFeedTableViewCell") as! HomeFeedTableViewCell
        
        cell.configureCell(viewModel.posts[indexPath.row], itemIndex: indexPath.row)
        
        if viewModel.posts[indexPath.row].getAllPagerItems().count > 0 {
            cell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
            cell.collectionConatinerView.isHidden = false
        } else {
            cell.collectionConatinerView.isHidden = true
        }
        
        cell.sharePostClosure = {
            self.sharePostAction(self.viewModel.posts[indexPath.row])
        }
        
        cell.addFavouriteClosure = { [weak self] isFavourite in
            if SharedPreference.isUserLogin {
                self?.addFavouritePost(by: indexPath, isFavourite: isFavourite)
            } else {
                MZUtilManager.showLoginAlert()
            }
        }
        
        cell.likeDislikeClosure = { [weak self] isLike in
            if SharedPreference.isUserLogin {
                self?.likeDislikePost(by: indexPath, isLike: isLike)
            } else {
                MZUtilManager.showLoginAlert()
            }
        }
        
        cell.moreOptionSelectionClosure = {
            if SharedPreference.isUserLogin {
                let vc: MZAlertViewController = UIStoryboard(storyboard: .main).instantiateVC()
                vc.alertType = .report
                vc.itemIndex = indexPath.row
                vc.delegate = self
                vc.modalPresentationStyle = .overCurrentContext
                self.present(vc, animated: false, completion: nil)
            } else {
                MZUtilManager.showLoginAlert()
            }
        }
        
        cell.userImageButtonTap.tag = indexPath.row
        cell.userImageButtonTap.addTarget(self, action: #selector(openUserProfileDetail(button:)), for: .touchUpInside)
        
        
        return cell
    }
    
    @objc func openUserProfileDetail(button: UIButton){
        let vc: PostUserDetailsViewController = UIStoryboard(storyboard: .home).instantiateVC()
        vc.userId = viewModel.posts[button.tag].postedBy.id
        vc.userName = viewModel.posts[button.tag].postedBy.userName
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.totalRow - 1 && !viewModel.isLastContent {
            if !viewModel.isLastContent {
                viewModel.pageCount += 1
                viewModel.getPostBy(pageCount: viewModel.pageCount, lastCreatedAt: viewModel.posts[indexPath.row].id)
            }
        }
        guard let cell = cell as? HomeFeedTableViewCell else { return }
        //        cell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
        cell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? HomeFeedTableViewCell else { return }
        storedOffsets[indexPath.row] = cell.collectionViewOffset
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc: PostDetailViewController = UIStoryboard(storyboard: .home).instantiateVC()
        vc.viewModel = self.viewModel
        vc.postId = viewModel.posts[indexPath.row].id
        vc.selectedFeedIndex = indexPath.row
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension SearchResultViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.posts[collectionView.tag].getAllPagerItems().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let pagerData = viewModel.posts[collectionView.tag].getAllPagerItems()[indexPath.item]
        
        if let image = pagerData as? PostData.Data.Image {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageFeedCollectionViewCell", for: indexPath) as! ImageFeedCollectionViewCell
            
            cell.feedImageView?.sd_setImage(with: URL(string: image.img), placeholderImage: nil, options: .continueInBackground)
            
            cell.feedImageView.contentMode = .scaleAspectFill
            return cell
            
        } else if let video = pagerData as? PostData.Data.Video {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoFeedCollectionViewCell", for: indexPath) as! VideoFeedCollectionViewCell
            
            //test video url => "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4"
            cell.url = video.videos
            cell.configureVideo(url: video.videos)
            //cell.player.play()
            
            return cell
            
        } else if let audio = pagerData as? PostData.Data.Audio {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AudioFeedCollectionViewCell", for: indexPath) as! AudioFeedCollectionViewCell
            
            cell.playPauseClosure = { [weak self] isPlay in
                if isPlay{
                    print(audio)
                    //self!.playAudio(audio.audios)
                } else {
                    //self!.pauseAudio()
                }
            }
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width , height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if let mainCell = homeTableView.cellForRow(at: IndexPath(row: collectionView.tag, section: 0)) as? HomeFeedTableViewCell {
            mainCell.collectionPageControl.currentPage = indexPath.item
        }
        
        if let cell = cell as? VideoFeedCollectionViewCell{
            cell.player.play()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? VideoFeedCollectionViewCell{
            cell.player.pause()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pagerData = viewModel.posts[collectionView.tag].getAllPagerItems()[indexPath.item]
        let cell = collectionView.cellForItem(at: indexPath)
        if cell is ImageFeedCollectionViewCell {
            let vc: PostDetailViewController = UIStoryboard(storyboard: .home).instantiateVC()
            vc.viewModel = self.viewModel
            vc.postId = viewModel.posts[collectionView.tag].id
            vc.selectedFeedIndex = collectionView.tag
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        } else if ((cell?.isKind(of: VideoFeedCollectionViewCell.self)) != nil) {
            if let video = pagerData as? PostData.Data.Video {
                //openVideoFullScreen(videoUrl: video.videos)
            }
        }
    }
    
}


// MARK:- Setup player
extension SearchResultViewController {
    
    fileprivate func updateByContentOffset() {
        if mmPlayerLayer.isShrink {
            return
        }
        
        if let path = findCurrentPath(), self.presentedViewController == nil {
            print("currnet index -\(path)")
            let cell = self.findCurrentCell(path: path) as! HomeFeedTableViewCell
            
            //            self.updateCell(at: path)
            self.updateCell(at: path, pagerCollection: cell.feedCollectionView)
            //Demo SubTitle
            //            if path.row == 0, self.mmPlayerLayer.subtitleSetting.subtitleType == nil {
            //                let subtitleStr = Bundle.main.path(forResource: "srtDemo", ofType: "srt")!
            //                if let str = try? String.init(contentsOfFile: subtitleStr) {
            //                    self.mmPlayerLayer.subtitleSetting.subtitleType = .srt(info: str)
            //                    self.mmPlayerLayer.subtitleSetting.defaultTextColor = .red
            //                    self.mmPlayerLayer.subtitleSetting.defaultFont = UIFont.boldSystemFont(ofSize: 20)
            //                }
            //            }
        }
    }
    
    fileprivate func updateDetail(at row : Int,  indexPath: IndexPath) {
        //        let value = DemoSource.shared.demoData[indexPath.row]
        //        if let detail = self.presentedViewController as? DetailViewController {
        //            detail.data = value
        //        }
        
        self.mmPlayerLayer.thumbImageView.image = nil //value.image
        //        self.mmPlayerLayer.set(url: URL(string: (viewModel.posts[row].getAllPagerItems()[0] as? PostData.Data.Video)!.videos))
        self.mmPlayerLayer.set(url: URL(string: viewModel.posts[row].video[0].videos))
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
            //// this thumb use when transition start and your video dosent start
            //mmPlayerLayer.thumbImageView.image = cell.placeholderImageView.image
            // set video where to play
            //mmPlayerLayer.playView = cell.placeholderImageView
            mmPlayerLayer.set(url: URL(string: playURL))
            mmPlayerLayer.resume()
        } else {
            //            destroyMMPlayerInstance()
        }
    }
    
    //    func destroyMMPlayerInstance() {
    //        self.mmPlayerLayer.player?.pause()
    //        self.mmPlayerLayer.playView = nil
    //   }
    
    @objc fileprivate func startLoading() {
        self.updateByContentOffset()
        if self.presentedViewController != nil {
            return
        }
        // start loading video
        //        mmPlayerLayer.resume()
    }
    
    private func findCurrentPath() -> IndexPath? {
        let p = CGPoint(x: homeTableView.frame.width/2, y: homeTableView.contentOffset.y + homeTableView.frame.width/2)
        return homeTableView.indexPathForRow(at: p)
    }
    
    private func findCurrentCell(path: IndexPath) -> UITableViewCell {
        return homeTableView.cellForRow(at: path)!
    }
}

extension SearchResultViewController: MZAlertViewDelegate {
    func didReport(itemIndex: Int, type: String) {
        if !type.isEmpty {
            self.reportPost(by: itemIndex, type: type)
        }
    }
}

// Mark:- Audio Player
//extension HomeViewController {
//    func playAudio (_ urlString : String) {
//
//        guard let url = URL(string: urlString ) else { return }
//
//        do {
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
//            try AVAudioSession.sharedInstance().setActive(true)
//
//            let item = AVPlayerItem(url: url)
//            NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying) , name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
//
//            audioPlayer = AVPlayer(playerItem: item)
//            guard let player = audioPlayer else { return }
//            player.play()
//
//        } catch let error {
//
//        }
//    }
//
//    func pauseAudio() {
//        audioPlayer?.pause()
//    }
//
//    @objc func playerDidFinishPlaying(note: NSNotification) {
//        audioPlayer?.pause()
//
//        let visibaleIndexPath = self.homeTableView.indexPathsForVisibleRows
//        let oldIndexPath = IndexPath(row: (self.rowIndex)! , section: 0)
//
//        if (visibaleIndexPath?.contains(oldIndexPath))! {
//            let rowCollection = self.tableView.cellForRow(at: oldIndexPath) as! RecommendedTableViewCell
//            rowCollection.playIndex = 0
//            rowCollection.collectionView.reloadData()
//        } else {
//            self.homeTableView.reloadRows(at: [IndexPath(row: (self.rowIndex)! , section: 0)], with: UITableViewRowAnimation.none)
//        }
//        self.cardIndex = nil
//    }
//}

