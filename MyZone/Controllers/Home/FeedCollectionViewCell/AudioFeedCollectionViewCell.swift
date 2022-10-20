//
//  AudioFeedCollectionViewCell.swift
//  MyZone
//

import UIKit

class AudioFeedCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!

    var playPauseClosure: ((Bool)->())?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    func configureCell(_ audioData : PostData.Data.Audio) {
    
    }

    @IBAction func playPauseAction (_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected

        self.playPauseClosure!(sender.isSelected)

    }

}
