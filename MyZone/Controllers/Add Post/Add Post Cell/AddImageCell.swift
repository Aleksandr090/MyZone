//
//  AddImageCell.swift
//  MyZone
//


import UIKit

class AddImageCell: UITableViewCell {

    @IBOutlet weak var imageCollectionView: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        self.imageCollectionView.register(UINib.init(nibName: "AddImageCollectionCell", bundle: nil), forCellWithReuseIdentifier: "AddImageCollectionCell")
    }
    
    func configureCell(_ images : PostData.Data , itemIndex : Int) {
    
    }
    
    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
        
        imageCollectionView.delegate = dataSourceDelegate
        imageCollectionView.dataSource = dataSourceDelegate
        imageCollectionView.tag = row
        imageCollectionView.setContentOffset(imageCollectionView.contentOffset, animated:false) // Stops collection view if it was scrolling.
        imageCollectionView.reloadData()
    }
    
    var collectionViewOffset: CGFloat {
        set { imageCollectionView.contentOffset.x = newValue }
        get { return imageCollectionView.contentOffset.x }
    }
    
}
