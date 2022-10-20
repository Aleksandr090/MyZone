//
//  AudioRightTVC.swift
//  MyZone
//
//  Created by Apple on 26/02/22.
//

import UIKit

class AudioRightTVC: UITableViewCell {
    @IBOutlet weak var chatAudioRightMainView: UIView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var lblAudioRightTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        chatAudioRightMainView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            btnPlay.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        } else {
            btnPlay.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    

}
