//
//  AddImageCollectionCell.swift
//  MyZone
//

import UIKit

class AddImageCollectionCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!

    var removeImageClosure: (()->())?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func removeImageAction (_ sender: UIButton) {
        removeImageClosure!()
    }
}
