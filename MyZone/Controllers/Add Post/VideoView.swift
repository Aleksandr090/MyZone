//
//  VideoView.swift
//  MyZone
//
//  Created by Mac on 7/4/22.
//

import Foundation
import UIKit
import AVKit
import AVFoundation

class VideoView: UIView {
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    var isLoop: Bool = true
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func configure(url: String) {
        if let videoURL = URL(string: url) {
            player = AVPlayer(url: videoURL)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = bounds
            //playerLayer?.videoGravity = AVLayerVideoGravity.resize
            playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            if let playerLayer = self.playerLayer {
                layer.addSublayer(playerLayer)
            }
            NotificationCenter.default.addObserver(self, selector: #selector(reachTheEndOfTheVideo(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
        }
    }
    
    func configure(url: URL?) {
        if let videoURL = url {
            player = AVPlayer(url: videoURL)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = bounds
//            playerLayer?.videoGravity = AVLayerVideoGravity.resize
            playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            if let playerLayer = self.playerLayer {
                layer.addSublayer(playerLayer)
            }
            NotificationCenter.default.addObserver(self, selector: #selector(reachTheEndOfTheVideo(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
        }
    }
    
    func configureWithControl(url: String) {
        if let videoURL = URL(string: url) {
            player = AVPlayer(url: videoURL)
            
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            playerViewController.view.frame = frame
            playerViewController.player?.pause()
            playerViewController.showsPlaybackControls = true
            
            
            player = AVPlayer(url: videoURL)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = bounds
            //playerLayer?.videoGravity = AVLayerVideoGravity.resize
            playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            if let playerLayer = self.playerLayer {
                layer.addSublayer(playerLayer)
                //addSubview(playerViewController.view)
            }
            NotificationCenter.default.addObserver(self, selector: #selector(reachTheEndOfTheVideo(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
        }
    }
    
    func configureWithControl(url: URL?) {
        if let videoURL = url {
            player = AVPlayer(url: videoURL)
            
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            playerViewController.view.frame = frame
            playerViewController.player?.pause()
            playerViewController.showsPlaybackControls = true
            
            
            player = AVPlayer(url: videoURL)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = bounds
//            playerLayer?.videoGravity = AVLayerVideoGravity.resize
            playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            if let playerLayer = self.playerLayer {
                layer.addSublayer(playerLayer)
//                addSubview(playerViewController.view)
            }
            NotificationCenter.default.addObserver(self, selector: #selector(reachTheEndOfTheVideo(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
        }
    }
    
    func play() {
        if player?.timeControlStatus != AVPlayer.TimeControlStatus.playing {
            player?.play()
        }
    }
    
    func pause() {
        player?.pause()
    }
    
    func stop() {
        player?.pause()
        player?.seek(to: CMTime.zero)
    }
    
    @objc func reachTheEndOfTheVideo(_ notification: Notification) {
        if isLoop {
            player?.pause()
            player?.seek(to: CMTime.zero)
            player?.play()
        }
    }
}
