//
//  FeedViewController.swift
//  MyZone
//
//  Created by Apple on 28/02/22.
//

import UIKit

class FeedViewController: BaseViewController {
    
    @IBOutlet weak var btnLikeMinus: UIButton!
    @IBOutlet weak var btnLikePlus: UIButton!
    @IBOutlet weak var lblLikeCount: UILabel!
    
    @IBOutlet weak var btnCommentMinus: UIButton!
    @IBOutlet weak var btnCommentPlus: UIButton!
    @IBOutlet weak var lblCommentCount: UILabel!
    
    @IBOutlet weak var btnRecentCheckUncheck: UIButton!
    
    @IBOutlet weak var btnDone: UIButton!
    var recentCheck:Bool!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Feed"
        
        self.configureBackButton()
        
    }
    
    @IBAction func btnActionLikeMinus(_ sender: Any) {
        if lblLikeCount.text != "0"{
            lblLikeCount.text = String(Int(lblLikeCount.text!)! - 1)
        }
    }
    
    
    @IBAction func btnActionLikePlus(_ sender: Any) {
        lblLikeCount.text = String(Int(lblLikeCount.text!)! + 1)
        
    }
    
    @IBAction func btnActionCommentMinus(_ sender: Any) {
        if lblCommentCount.text != "0"{
            lblCommentCount.text = String(Int(lblCommentCount.text!)! - 1)
        }
    }
    
    @IBAction func btnActionCommentPlus(_ sender: Any) {
        lblCommentCount.text = String(Int(lblCommentCount.text!)! + 1)
    }
    
    
    @IBAction func btnActionRecentCheckUncheck(_ sender: Any) {
        if recentCheck == false{
            recentCheck = true
            btnRecentCheckUncheck.setImage(UIImage(named: "checkOff"), for: .normal)
        }else{
            recentCheck = false
            btnRecentCheckUncheck.setImage(UIImage(named: "checkOn"), for: .normal)
        }
    }
    
    @IBAction func btnActionDone(_ sender: Any) {
        print("Like Count ==> \(String(describing: lblLikeCount.text))")
        print("Commnet Count ==>\(String(describing: lblCommentCount.text))")
    }
    
}
