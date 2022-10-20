//
//  VideoFeedCollectionViewCell.swift
//  MyZone
//

import UIKit
import AVFoundation

class VideoFeedCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var videoPlayerView: AVPlayerView!
    
    @IBOutlet weak var btnSoundOnOff: UIButton!
    @IBOutlet weak var btnFullScreen: UIButton!
    
    var videoURL: String!
    var player = AVPlayer()
    var url: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureVideo(url:String){
        if let videoURL = URL(string: url) {
            player = AVPlayer(url: videoURL)
            let castLayer = videoPlayerView.layer as! AVPlayerLayer
            castLayer.player = player
            castLayer.videoGravity = .resizeAspect
        }
    }
    
    @IBAction func btnActionFullScreen(_ sender: Any) {
        player.pause()
        NotificationCenter.default.post(name: Notification.Name("fullVideoOpen"), object: nil, userInfo: ["url": url as Any])
    }
    
    @IBAction func btnActionSounfOnOff(_ sender: UIButton) {
        if sender.isSelected{
            btnSoundOnOff.setImage(UIImage(named: "soundOff"), for: .normal)
            sender.isSelected = false
            player.isMuted = true
        }else{
            btnSoundOnOff.setImage(UIImage(named: "soundOn"), for: .normal)
            sender.isSelected = true
            player.isMuted = false
        }
    }
}
