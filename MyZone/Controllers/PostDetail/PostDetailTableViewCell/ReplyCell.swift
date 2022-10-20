//
//  ReplyCell.swift
//  MyZone
//

import UIKit
import DropDown

class ReplyCell: UITableViewCell {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var OPLabel: UILabel!
    
    @IBOutlet weak var replyToReplyButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var moreOptionButton: UIButton!
    
    var likeDislikeClosure: ((Bool)->())?
    var moreOptionSelectionClosure: (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func configureCell(_ replyData : PostData.Data.Comment.Replies) {
        
        userImageView?.sd_setImage(with: URL(string: replyData.postedBy.profileImg), placeholderImage: nil, options: .continueInBackground)
        nameLabel.text = replyData.postedBy.displayName.isEmpty ? replyData.postedBy.userName : replyData.postedBy.displayName
        
        if let createdDate = replyData.createdAt.dateFromFormat("yyyy-MM-dd'T'HH:mm:ssZ") {
            timeLabel.text = "\u{2022} \(MZUtilManager.shared.timeAgoSinceDate(createdDate))"
        }
        commentLabel.text = replyData.text
        
        OPLabel.isHidden = replyData.postedBy.id != SharedPreference.getUserData()?.id
        
        likeCountLabel.text = "\(replyData.likedBy.count - replyData.dislikedBy.count)"
        
        if let isLiked = replyData.isLiked {
            if isLiked {
                likeButton.isSelected = true
            } else {
                dislikeButton.isSelected = true
            }
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
    
    @IBAction func reportAction (_ sender: UIButton) {
        moreOptionSelectionClosure!()
    }
}
