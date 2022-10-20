//
//  PostDetailTableViewCell.swift
//  MyZone
//

import UIKit
import SDWebImage

protocol cellButtonDelegate {
    func onCall(_ postData: PostData.Data)
    func onDate(_ postData: PostData.Data)
    func onAddress(_ postData: PostData.Data)
}

class PostDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var conatinerView: UIView!
    @IBOutlet weak var collectionConatinerView: UIView!
    @IBOutlet weak var feedCollectionView: UICollectionView!
    @IBOutlet weak var collectionPageControl: UIPageControl!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var postTypeImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var rewardImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postDescriptionLabel: UILabel!

    @IBOutlet weak var distanceButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!

    @IBOutlet weak var calenderView: UIView!
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var callView: UIView!
    @IBOutlet weak var callLabel: UILabel!
    @IBOutlet weak var calenderLabel: UILabel!
    @IBOutlet weak var adddressLabel: UILabel!
    @IBOutlet weak var calendarViewHeight: NSLayoutConstraint!
    @IBOutlet weak var callViewHeight: NSLayoutConstraint!
    @IBOutlet weak var addressViewHeight: NSLayoutConstraint!
    
    var likeDislikeClosure: ((Bool)->())?
    
    var delegate: cellButtonDelegate?
    
    var postData : PostData.Data!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        self.feedCollectionView.register(UINib.init(nibName: "ImageFeedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageFeedCollectionViewCell")

        self.feedCollectionView.register(UINib.init(nibName: "VideoFeedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "VideoFeedCollectionViewCell")

        self.feedCollectionView.register(UINib.init(nibName: "AudioFeedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AudioFeedCollectionViewCell")

        // Configure the view for the selected state
    }

    func configureCell(_ postData : PostData.Data , itemIndex : Int) {
        conatinerView.addShadow()
        self.postData = postData
        userImageView?.sd_setImage(with: URL(string: postData.postedBy.profileImg), placeholderImage: nil, options: .continueInBackground)
        nameLabel.text = postData.postedBy.displayName.isEmpty ? postData.postedBy.userName : postData.postedBy.displayName
        usernameLabel.text = "@\(postData.postedBy.userName)"
        if let rewardId = postData.postedBy.rewardId {
            rewardImageView.sd_setImage(with: URL(string: rewardId.rewardImage))
        }
        if let createdDate = postData.createdAt.dateFromFormat("yyyy-MM-dd'T'HH:mm:ssZ") {
            timeLabel.text = "\u{2022} \(MZUtilManager.shared.timeAgoSinceDate(createdDate))"
        }
                
        postTitleLabel.text = postData.postTitle
        postDescriptionLabel.text = postData.postDescription
        
        likeCountLabel.text = "\(postData.likedBy.count - postData.dislikedBy.count)"
        
        if let isLiked = postData.isLiked {
            if isLiked {
                likeButton.isSelected = true
                dislikeButton.isSelected = false
            } else {
                likeButton.isSelected = false
                dislikeButton.isSelected = true
            }
        }
        
        calenderLabel.text = "Make reminder for: " + postData.time
        calenderView.isHidden = postData.time.isEmpty
        calendarViewHeight.constant = postData.time.isEmpty ? 0 : 50
        
        callView.isHidden = postData.contactNo.isEmpty
        callViewHeight.constant = postData.contactNo.isEmpty ? 0 : 50
        callLabel.text = postData.contactNo
        
        if(postData.placeName != ""){
            adddressLabel.text = String(postData.placeName)
            addressViewHeight.constant = 50
        }else{
            addressView.isHidden = true
            addressViewHeight.constant = 0
        }
        
        distanceButton.setTitle( postData.postDistance, for: .normal)
        distanceButton.imageEdgeInsets = L102Language.isRTL ? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -5) : UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)

        commentButton.imageEdgeInsets = L102Language.isRTL ? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -5) : UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        commentButton.setTitle( "\(postData.comment.count)", for: .normal)
        commentButton.isUserInteractionEnabled = false
        
        let pagerCount = postData.getAllPagerItems().count
        if pagerCount > 1 {
            collectionPageControl.isHidden = false
            collectionPageControl.numberOfPages =  pagerCount
        } else {
            collectionPageControl.isHidden = true
        }
        postTypeImageView.sd_setImage(with: URL(string: postData.topicId.icon))
    }
    
    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
        
        feedCollectionView.delegate = dataSourceDelegate
        feedCollectionView.dataSource = dataSourceDelegate
        feedCollectionView.tag = row
        feedCollectionView.setContentOffset(feedCollectionView.contentOffset, animated:false) // Stops collection view if it was scrolling.
        feedCollectionView.reloadData()
    }
    
    var collectionViewOffset: CGFloat {
        set { feedCollectionView.contentOffset.x = newValue }
        get { return feedCollectionView.contentOffset.x }
    }
        
    @IBAction func likeDislikeAction (_ sender: UIButton) {
        if sender.isSelected {
            return
        }
        
        var islike = false
        
        if sender == likeButton {
            islike = true
        } else if sender == dislikeButton {
            islike = false
        }
        
        self.likeDislikeClosure!(islike)
    }

    @IBAction func dateAction(_ sender: Any) {
        delegate?.onDate(postData)
    }
    
    @IBAction func callAction (_ sender: UIButton) {
        delegate?.onCall(postData)
    }
    
    @IBAction func addressAction (_ sender: UIButton) {
        delegate?.onAddress(postData)
    }
}
