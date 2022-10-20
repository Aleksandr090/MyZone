//
//  CommentCell.swift
//  MyZone
//


import UIKit
import DropDown

class CommentCell: UIView {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var btnUserImage: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var OPLabel: UILabel!
    
    @IBOutlet weak var btnCommentReply: UIButton!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var moreOptionButton: UIButton!

    var likeDislikeClosure: ((Bool)->())?
    var showHideReplyClosure: (()->())?
    var moreOptionSelectionClosure: (()->())?
    
    var commentById:String!
    var postId:String!
    var commentId:String!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    let selfUserData = SharedPreference.getUserData()

    func configureCell(_ commentData : PostData.Data.Comment) {
        commentById = commentData.postedBy.id
        postId = commentData.postId
        commentId = commentData.id
        
        userImageView?.sd_setImage(with: URL(string: commentData.postedBy.profileImg), placeholderImage: nil, options: .continueInBackground)
        nameLabel.text = commentData.postedBy.displayName.isEmpty ? commentData.postedBy.userName : commentData.postedBy.displayName
        
        if let createdDate = commentData.createdAt.dateFromFormat("yyyy-MM-dd'T'HH:mm:ssZ") {
            timeLabel.text = "\u{2022} \(MZUtilManager.shared.timeAgoSinceDate(createdDate))"
        }        
        
        //commentLabel.preferredMaxLayoutWidth = commentLabel.frame.size.width
        commentLabel.text = !commentData.isDeleted ? commentData.text : "\nDeleted Comment"
        commentLabel.font = !commentData.isDeleted ? .systemFont(ofSize: 14) : .italicSystemFont(ofSize: 14)
        likeCountLabel.isHidden = commentData.isDeleted
        likeButton.isHidden = commentData.isDeleted
        dislikeButton.isHidden = commentData.isDeleted
        timeLabel.isHidden = commentData.isDeleted
        moreOptionButton.isHidden = commentData.isDeleted
        btnCommentReply.isHidden = commentData.isDeleted
        
        //setNeedsLayout()
        //layoutIfNeeded()
        
        likeCountLabel.text = "\(commentData.likedBy.count - commentData.dislikedBy.count)"
        
        if let isLiked = commentData.isLiked {
            if isLiked {
                likeButton.isSelected = true
            } else {
                dislikeButton.isSelected = true
            }
        }
        
        let replyCount = commentData.replies.count
        if replyCount > 0 && !commentData.isDeleted {
            replyButton.isHidden = false
            replyButton.setTitle("\(replyCount) Replies", for: .normal)
        } else {
            replyButton.isHidden = true
            //replyButton.setTitle("\(replyCount) Reply", for: .normal)
        }
        
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

    @IBAction func showReplyAction (_ sender: UIButton) {
        self.showHideReplyClosure!()
    }
    
    @IBAction func reportAction (_ sender: UIButton) {        
       
        if(selfUserData?.id == commentById){
            let moreOptionDropDown = DropDown()
            moreOptionDropDown.anchorView = moreOptionButton
            moreOptionDropDown.bottomOffset = CGPoint(x: 0, y: moreOptionButton.bounds.height)
            moreOptionDropDown.dataSource = ["Delete"]
            
            moreOptionDropDown.selectionAction = { [weak self] (index, item) in
                NotificationCenter.default.post(name: Notification.Name("deleteSelfComment"), object: nil, userInfo: ["commentId":self!.commentId, "postId":self!.postId])
            }
            
            moreOptionDropDown.show()
        }else{
            self.moreOptionSelectionClosure!()
        }
    }
}
