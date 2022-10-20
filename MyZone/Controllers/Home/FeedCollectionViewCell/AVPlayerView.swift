//
//  AVPlayerView.swift
//  MyZone
//
//  Created by Apple on 17/03/22.
//

import UIKit
import AVFoundation

class AVPlayerView: UIView {
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}
