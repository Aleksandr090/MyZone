//
//  SideMenuCell.swift
//  MyZone
//

import UIKit

class SideMenuCell: UITableViewCell {
    
    @IBOutlet var itemNameLabel: UILabel!
    @IBOutlet var itemNameLabelLeading: NSLayoutConstraint!
//    @IBOutlet var itemImageView: UIImageView!
    @IBOutlet var itemImageButton: UIButton!

    @IBOutlet var darkLightStackView: UIStackView!
    @IBOutlet var darkButton: UIButton!
    @IBOutlet var lightButton: UIButton!

    var isSubCell = false
    var itemData: Section.Item?
    
    var setDarkLightMode: ((Bool)->())?
    var isDarkMode = false

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
    }
    
    func setupItemData() {
        darkLightStackView.isHidden = true

        if isSubCell {
            itemImageButton.isHidden = true
            itemNameLabelLeading.constant = 50
        } else {
            itemImageButton.isHidden = false
            itemNameLabelLeading.constant = 20
        }
        
        if itemData == nil {
            return
        }
        
        if SharedPreference.isUserLogin {
            itemNameLabel.text = itemData?.name
        } else {
            itemNameLabel.text = itemData?.name
        }
        
//        itemImageView.image = UIImage(named: itemData!.imageName)
        itemImageButton.setImage(UIImage(named: itemData!.imageName), for: .normal)
        
        if itemData?.name == "Dark Mode" {
            itemImageButton.isHidden = true
            darkLightStackView.isHidden = false
        }
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func setDarkLightModeAction (_ sender: UIButton) {
        if sender == darkButton {
            isDarkMode = true
        } else if sender == lightButton {
            isDarkMode = false
        }
        setDarkLightMode!(isDarkMode)
    }
}
