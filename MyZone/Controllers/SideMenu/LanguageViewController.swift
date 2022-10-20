//
//  LanguageViewController.swift
//  MyZone
//

import UIKit

class LanguageViewController: BaseViewController {
    @IBOutlet weak var btnEnglish: UIButton!
    @IBOutlet weak var btnArabic: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Language"
        self.configureBackButton()
        
        if(L102Language.currentAppleLanguage() == "en"){
            btnEnglish.setImage(UIImage(named: "languageRight"), for: .normal)
            btnArabic.setImage(UIImage(named: ""), for: .normal)
        }else{
            btnEnglish.setImage(UIImage(named: ""), for: .normal)
            btnArabic.setImage(UIImage(named: "languageRight"), for: .normal)
        }
    }
    
    @IBAction func btnActionEnglish(_ sender: Any) {
        L102Language.setAppleLAnguageTo(lang: "en")
        btnEnglish.setImage(UIImage(named: "languageRight"), for: .normal)
        btnArabic.setImage(UIImage(named: ""), for: .normal)
    }
    
    @IBAction func btnActionArabic(_ sender: Any) {
        L102Language.setAppleLAnguageTo(lang: "ar")
        btnEnglish.setImage(UIImage(named: ""), for: .normal)
        btnArabic.setImage(UIImage(named: "languageRight"), for: .normal)
    }
    
    @IBAction func btnActionDone(_ sender: Any) {
        if L102Language.currentAppleLanguage() == "en" {
            L102Language.setAppleLAnguageTo(lang: "en")
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        } else {
            L102Language.setAppleLAnguageTo(lang: "ar")
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            
        }
        reloadUI()
    }
    
    func reloadUI() {
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController")
            window.makeKeyAndVisible()
            UIView.transition(with: window, duration: 0.5, options: .autoreverse, animations: { () -> Void in
            }) { (finished) -> Void in
                
            }
        }
    }
}
