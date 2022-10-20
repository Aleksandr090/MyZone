//
//  AddAudioCell.swift
//  MyZone
//

import UIKit

class AddAudioCell: UITableViewCell {

    @IBOutlet weak var audioTitleLabel: UILabel!

    var removeAudioClosure: (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        audioTitleLabel.text = "Audio Preview"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func removeAudioAction (_ sender: UIButton) {
        removeAudioClosure!()
    }
}
