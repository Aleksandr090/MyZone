//
//  AddOtherContantCell.swift
//  MyZone
//

import UIKit

enum OtherContantType {
    case phone
    case address
    case date
}

class AddOtherContantCell: UITableViewCell {
    
    @IBOutlet weak var optionBGView: UIView!
    @IBOutlet weak var optionImageView: UIImageView!
    @IBOutlet weak var optionTextLabel: UILabel!

    var otherContantType:  OtherContantType = .phone
    var removeContantClosure: (()->())?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
       
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell() {
        switch otherContantType {
        case .phone:
            optionBGView.backgroundColor = UIColor.AppTheme.LightPinkColor
//            optionTextLabel.text = "9999999999"
            optionImageView.image = UIImage(named: "add_phone")
        case .address:
            optionBGView.backgroundColor = UIColor.AppTheme.LightGreenColor
//            optionTextLabel.text = "Akshya Nagar 1st Block 1st Cross, Rammurthy nagar, Bangalore-560016"
            optionImageView.image = UIImage(named: "add_location")
        case .date:
            optionBGView.backgroundColor = UIColor.AppTheme.LightBlueColor
//            optionTextLabel.text = "20-11-2021 08:30:00 PM"
            optionImageView.image = UIImage(named: "add_date")
        }
    }

    @IBAction func removeContantAction (_ sender: UIButton) {
        removeContantClosure!()
    }
    
}
