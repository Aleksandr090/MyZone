//
//  NotificationTableViewCell.swift
//  MyZone
//

import UIKit
import DropDown

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var notifTitleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var moreOptionButton: UIButton!

    var offNotificationBlock: (()->())?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        containerView.addShadow()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func optionAction(_ sender:UIButton) {
        moreOptionSelection()
    }
    
    func moreOptionSelection() {
        let moreOptionDropDown = DropDown()
        moreOptionDropDown.anchorView = moreOptionButton
        moreOptionDropDown.bottomOffset = CGPoint(x: 0, y: moreOptionButton.bounds.height)
        // You can also use localizationKeysDataSource instead. Check the docs.
        moreOptionDropDown.dataSource = ["Turn off notification"]
        
        // Action triggered on selection
        moreOptionDropDown.selectionAction = { [weak self] (index, item) in
            self!.offNotificationBlock!()
        }
        moreOptionDropDown.show()
    }
}
