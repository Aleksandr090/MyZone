//
//  UserDetailsCommentTVC.swift
//  MyZone
//
//  Created by Apple on 21/03/22.
//

import UIKit

class UserDetailsCommentTVC: UITableViewCell {
    
    @IBOutlet weak var imgCommentUser: UIImageView!
    @IBOutlet weak var lblCommentUserName: UILabel!
    @IBOutlet weak var lblCommentText: UILabel!
    @IBOutlet weak var lblCommentTime: UILabel!
    @IBOutlet weak var btnCommentMoreOption: UIButton!
    @IBOutlet weak var btnCommentReply: UIButton!
    @IBOutlet weak var btnCommentReplyShowHide: UIButton!
    
    @IBOutlet weak var btnCommentLike: UIButton!
    @IBOutlet weak var lblCommentLikeDisLikeCount: UILabel!
    @IBOutlet weak var btnCommentDisLike: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func configureCommentData(data:NSDictionary){
        let postedBy = data["postedBy"] as! NSDictionary
        let likeBy = data["likedBy"] as! NSArray
        let dislikedBy = data["dislikedBy"] as! NSArray
        let Replies = data["Replies"] as! NSArray
        
        imgCommentUser.sd_setImage(with: URL(string: postedBy["profile_img"] as! String), placeholderImage: nil, options: .continueInBackground)
        
        lblCommentUserName.text = (postedBy["displayName"] as! String).isEmpty ? (postedBy["user_name"] as! String) : (postedBy["displayName"] as! String)
        
        lblCommentText.text = (data["text"] as! String)
        
        let createdAt = data["createdAt"] as! String
        if let createdDate = createdAt.dateFromFormat("yyyy-MM-dd'T'HH:mm:ssZ") {
            lblCommentTime.text = MZUtilManager.shared.timeAgoSinceDate(createdDate)
        }
        
        lblCommentLikeDisLikeCount.text = "\(likeBy.count - dislikedBy.count)"
        
        let replyCount = Replies.count
        if replyCount > 1{
            btnCommentReplyShowHide.setTitle("\(replyCount) Replies", for: .normal)
        } else {
            btnCommentReplyShowHide.isHidden = true
            //btnCommentReplyShowHide.setTitle("\(replyCount) Reply", for: .normal)
        }
    }
    
}
