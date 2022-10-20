//
//  UserDetailsReplyTVC.swift
//  MyZone
//
//  Created by Apple on 21/03/22.
//

import UIKit

class UserDetailsReplyTVC: UITableViewCell {
    @IBOutlet weak var imgReplyUser: UIImageView!
    @IBOutlet weak var lblReplyUserName: UILabel!
    @IBOutlet weak var lblReplyText: UILabel!
    @IBOutlet weak var lblReplyTime: UILabel!
    @IBOutlet weak var btnReplyMoreOption: UIButton!
    
    @IBOutlet weak var btnReplyReply: UIButton!
    @IBOutlet weak var btnReplyLike: UIButton!
    @IBOutlet weak var lblReplyLikeDisLikeCount: UILabel!
    @IBOutlet weak var btnReplyDisLike: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
