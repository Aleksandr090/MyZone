//
//  HomeFeedTableViewCell.swift
//  MyZone
//

import UIKit
import SDWebImage
import DropDown

class HomeFeedTableViewCell: UITableViewCell {
    @IBOutlet weak var conatinerView: UIView!
    @IBOutlet weak var collectionConatinerView: UIView!
    @IBOutlet weak var feedCollectionView: UICollectionView!
    @IBOutlet weak var collectionPageControl: UIPageControl!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userImageButtonTap: UIButton!
    @IBOutlet weak var postTypeImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var rewardImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postDescriptionLabel: UILabel!
    
    
    @IBOutlet weak var viewBottomOption: UIView!
    @IBOutlet weak var stalViewLeft: UIStackView!
    @IBOutlet weak var stalViewRight: UIStackView!
    @IBOutlet weak var stakViewLeftInner: UIStackView!
    @IBOutlet weak var viewLikeCount: UIView!
    @IBOutlet weak var distanceButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var moreOptionButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    
    var sharePostClosure: (()->())?
    var likeDislikeClosure: ((Bool)->())?
    var addFavouriteClosure: ((Bool)->())?
    var moreOptionSelectionClosure: (()->())?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewBottomOption.semanticContentAttribute = .forceLeftToRight
        stalViewLeft.semanticContentAttribute = .forceLeftToRight
        stalViewRight.semanticContentAttribute = .forceLeftToRight
        stakViewLeftInner.semanticContentAttribute = .forceLeftToRight
        viewLikeCount.semanticContentAttribute = .forceLeftToRight
        distanceButton.semanticContentAttribute = .forceLeftToRight
        likeButton.semanticContentAttribute = .forceLeftToRight
        dislikeButton.semanticContentAttribute = .forceLeftToRight
        likeCountLabel.semanticContentAttribute = .forceLeftToRight
        favouriteButton.semanticContentAttribute = .forceLeftToRight
        moreOptionButton.semanticContentAttribute = .forceLeftToRight
        shareButton.semanticContentAttribute = .forceLeftToRight
        commentButton.semanticContentAttribute = .forceLeftToRight
    
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
        userImageView?.sd_setImage(with: URL(string: postData.postedBy.profileImg), placeholderImage: UIImage(named: "dummy"), options: .continueInBackground)
        nameLabel.text = postData.postedBy.displayName.isEmpty ? postData.postedBy.userName : postData.postedBy.displayName
        usernameLabel.text = "@\(postData.postedBy.userName)"
        if let rewardId = postData.postedBy.rewardId {
            rewardImageView.sd_setImage(with: URL(string: rewardId.rewardImage))
        } else {
            rewardImageView.sd_setImage(with: URL(string: ""))
        }
        
        if let createdDate = postData.createdAt.dateFromFormat("yyyy-MM-dd'T'HH:mm:ssZ") {
            timeLabel.text = "\u{2022} \(MZUtilManager.shared.timeAgoSinceDate(createdDate))"
        }
                
        postTitleLabel.text = postData.postTitle
        // If there is no multimedia post
        postDescriptionLabel.text = postData.getAllPagerItems().isEmpty ? postData.postDescription : ""
        
        likeCountLabel.text = "\(postData.likedBy.count - postData.dislikedBy.count)"
        
        if let isLiked = postData.isLiked {
            likeButton.isSelected = isLiked
            dislikeButton.isSelected = !isLiked
        } else {
            likeButton.isSelected = false
            dislikeButton.isSelected = false
        }
        
        distanceButton.setTitle( postData.postDistance, for: .normal)
        distanceButton.imageEdgeInsets = L102Language.isRTL ? UIEdgeInsets(top: 5, left: 0, bottom: 5, right: -5) : UIEdgeInsets(top: 5, left: -5, bottom: 5, right: 0)
        
        favouriteButton.isSelected = postData.isBookmarked

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
        
//        switch sender {
//        case likeButton:
//
//        case dislikeButton:
//        default
//        break
//        }
        if sender.isSelected {
            return
        }
        
        var islike = false
        if sender == likeButton {
            islike = true
//            dislikeButton.isSelected = sender.isSelected
        } else if sender == dislikeButton {
            islike = false
//            likeButton.isSelected = sender.isSelected
        }
//        sender.isSelected = !sender.isSelected
        self.likeDislikeClosure!(islike)
    }
    
    @IBAction func shareAction (_ sender: UIButton) {
        self.sharePostClosure!()
    }
   
    @IBAction func reportAction (_ sender: UIButton) {
        self.moreOptionSelectionClosure!()
    }
    
    @IBAction func favouriteAction (_ sender: UIButton) {
        self.addFavouriteClosure!(!favouriteButton.isSelected)
    }
    
}
