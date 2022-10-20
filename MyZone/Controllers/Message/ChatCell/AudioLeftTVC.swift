//
//  AudioLeftTVC.swift
//  MyZone
//
//  Created by Apple on 26/02/22.
//

import UIKit

class AudioLeftTVC: UITableViewCell {
    @IBOutlet weak var chatAudioLeftMainView: UIView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var lblAudioLeftTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        chatAudioLeftMainView.layer.cornerRadius = 10
        
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
