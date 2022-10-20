//
//  ContactViewController.swift
//  MyZone
//
//  Created by Mac on 7/5/22.
//

import UIKit

class ContactViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Contact"
        self.configureBackButton()
        navigationController?.isNavigationBarHidden = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
}
