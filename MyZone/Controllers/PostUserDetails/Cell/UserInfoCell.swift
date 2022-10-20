//
//  UserInfoCell.swift
//  MyZone
//
//  Created by Mac on 11.08.2022.
//

import UIKit

class UserInfoCell: UITableViewCell {
    
    @IBOutlet weak var mainViewHeight: NSLayoutConstraint!
    
    
    
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblUserPostTime: UILabel!
    @IBOutlet weak var lblUserDescription: UILabel!
    @IBOutlet weak var btnUserReward: UIButton!
    
    @IBOutlet weak var btnChat: UIButton!
    @IBOutlet weak var btnBookmark: UIButton!
    @IBOutlet weak var btnNotification: UIButton!
    
    @IBOutlet weak var msgView: CardView!
    @IBOutlet weak var msgViewHeight: NSLayoutConstraint!
    @IBOutlet weak var msgViewTop: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
