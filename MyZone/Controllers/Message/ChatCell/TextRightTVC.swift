//
//  TextRightTVC.swift
//  MyZone
//
//  Created by Apple on 25/02/22.
//

import UIKit

class TextRightTVC: UITableViewCell {
    @IBOutlet weak var chatRightMainView: UIView!
    @IBOutlet weak var lblRightText: UILabel!
    @IBOutlet weak var lblRightTime: UILabel!
    
    @IBOutlet weak var rightViewWidth: NSLayoutConstraint!
    @IBOutlet weak var lblWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        chatRightMainView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
