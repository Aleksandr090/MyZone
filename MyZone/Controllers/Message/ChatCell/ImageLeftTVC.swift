//
//  ImageLeftTVC.swift
//  MyZone
//
//  Created by Apple on 26/02/22.
//

import UIKit

class ImageLeftTVC: UITableViewCell {
    @IBOutlet weak var chatImageLeftMainView: UIView!
    @IBOutlet weak var imgChatLeft: UIImageView!
    @IBOutlet weak var btnImage: UIButton!
    @IBOutlet weak var lblChatImageLeftTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        chatImageLeftMainView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
