//
//  DropDownMenuCell.swift
//  MyZone
//
//  Created by Mac on 02.08.2022.
//

import UIKit
import DropDown

class DropDownMenuCell: DropDownCell {

    @IBOutlet weak var imvIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
