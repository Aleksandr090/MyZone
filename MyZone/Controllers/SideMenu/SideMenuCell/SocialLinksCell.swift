//
//  SocialLinksCell.swift
//  MyZone
//

import UIKit

class SocialLinksCell: UITableViewCell {

    @IBOutlet var instaButton: UIButton!
    @IBOutlet var fbButton: UIButton!
    @IBOutlet var twitterButton: UIButton!
    @IBOutlet var shareButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func linksAction (_ sender: UIButton) {
    
    
    }

}
