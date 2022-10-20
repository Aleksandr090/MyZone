//
//  ImageRightTVC.swift
//  MyZone
//
//  Created by Apple on 26/02/22.
//

import UIKit

class ImageRightTVC: UITableViewCell {
    @IBOutlet weak var chatImageRightMainView: UIView!
    @IBOutlet weak var imgChatRight: UIImageView!
    @IBOutlet weak var btnImage: UIButton!
    @IBOutlet weak var lblChatImageRightTime: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        chatImageRightMainView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
