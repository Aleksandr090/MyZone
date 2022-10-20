//
//  SplashViewController.swift
//  MyZone
//

import UIKit

class SplashViewController: UIViewController {
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.versionLabel.text = "\(NSLocalizedString("version", comment: "version")) \(Bundle.versionNumber)"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.gotoSelectLocation()
        }
    }
    
    func gotoSelectLocation() {
        let vc: SelectLocationViewController = UIStoryboard(storyboard: .authentication).instantiateVC()
        //      let vc: TabBarController = UIStoryboard(storyboard: .main).instantiateVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
