//
//  ViewController.swift
//  MyZone
//
//  Created by Apple on 25/03/22.
//

import UIKit
import AVFoundation
import AVKit

class ViewController: AVPlayerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string:
                        "http://www.ebookfrenzy.com/ios_book/movie/movie.mov")
//        let player = AVPlayer(url:url!)
//        let playerController = AVPlayerViewController()
//        playerController.player = player
//        self.addChild(playerController)
//        self.view.addSubview(playerController.view)
//        playerController.view.frame = self.view.frame
//        player.play()
        
        let player = AVPlayer(url: url!)
        let playerController = AVPlayerViewController()
        playerController.showsPlaybackControls = true
        view.backgroundColor = UIColor.red
        playerController.player = player
        playerController.videoGravity = .resizeAspect
        self.addChild(playerController)
        self.view.addSubview(playerController.view)
        playerController.view.frame = self.view.frame
        
        player.play()
    }
}
