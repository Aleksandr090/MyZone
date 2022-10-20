//
//  AddVideoCell.swift
//  MyZone
//

import UIKit
import AVFoundation

class AddVideoCell: UITableViewCell {

    var player : AVPlayer!
    var avPlayerLayer : AVPlayerLayer!
 
    @IBOutlet weak var videoView: VideoView!
    @IBOutlet weak var playButton: UIButton!
    var isPlaying: Bool = false
    
    var removeVideoClosure: (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        videoView.isLoop = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func removeVideoAction (_ sender: UIButton) {
        removeVideoClosure!()
    }
    
    @IBAction func playVideo(_ sender: UIButton) {
        if isPlaying {            
            videoView.pause()
            playButton.setImage(UIImage(named: "PlayButton"), for: .normal)
            isPlaying = false
        } else {
            videoView.play()
            playButton.setImage(UIImage(named: "PauseButton"), for: .normal)
            isPlaying = true
        }
    }
}
