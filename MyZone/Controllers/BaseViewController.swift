//
//  BaseViewController.swift
//  MyZone
//

import UIKit
import SideMenu
import SDWebImage
import FirebaseDatabase
import StoreKit

var currentViewController: UIViewController?

class BaseViewController: UIViewController {
    
    var sideMenu: SideMenuNavigationController?
    let minimumReviewWorthyActionCount = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func configureBackButton(title: String = "") {
        // custom back button
        
        let backButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back-arrow"), style: .plain, target:  self, action: #selector(didTouchBackButton))
        
        var leftBarbuttonItems = [backButtonItem]
        
        if !title.isEmpty {
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = UIFont(name: Fontname.SFProDisplayMedium, size: 20)
            titleLabel.sizeToFit()
            let titleItem = UIBarButtonItem(customView: titleLabel)
            
            leftBarbuttonItems.append(titleItem)
        }
        navigationItem.leftBarButtonItems = leftBarbuttonItems
        
    }
    
    func setupLeftNavigationBar() {
        
        let profileImage = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        //        profileImage.setImage(UIImage(named: "add-sel"), for: .normal)
        
        profileImage.layer.cornerRadius = 4
        profileImage.layer.masksToBounds = true
        //        let lockButton = UIButton(type: .system)
        //        lockButton.setImage(UIImage(named: "add-sel"), for: .normal)        
        
        if let userData = SharedPreference.getUserData() {
            profileImage.backgroundColor = .gray
            profileImage.sd_setImage(with: URL(string: userData.profileImg), for: .normal, placeholderImage: UIImage(named: "dummy"), options: .continueInBackground)
            profileImage.sd_setBackgroundImage(with: URL(string: userData.profileImg), for: .normal, completed: nil)
            profileImage.addTarget(self, action: #selector(sideMenuAction(_:)), for: .touchUpInside)
        } else {
            profileImage.setImage(UIImage(named: "login"), for: .normal)
            profileImage.addTarget(self, action: #selector(loginAction(_:)), for: .touchUpInside)
        }
        
        let profileImageItem = UIBarButtonItem(customView: profileImage)
        profileImageItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        profileImageItem.customView?.heightAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageItem.customView?.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        navigationItem.leftBarButtonItem = profileImageItem
        
        //        let imageVW = UIImageView()
        //        if let userData = SharedPreference.getUserData() {
        //            imageVW.sd_setImage(with: URL(string: userData.profileImg)) { (image, error, type, url) in
        //                if let img = image {
        //                    profileImageItem = UIBarButtonItem(image: img, style: .plain, target: self, action: #selector(self.sideMenuAction(_:)))
        //                    self.navigationItem.leftBarButtonItem = profileImageItem
        //                }
        //            }
        //        }
    }
    
    func setupSideMenu() {
        let menuVC: SideMenuViewController = UIStoryboard(storyboard: .main).instantiateVC()
        sideMenu = SideMenuNavigationController(rootViewController: menuVC)
        
        if L102Language.isRTL {
            SideMenuManager.default.rightMenuNavigationController = sideMenu
            sideMenu?.leftSide = false
        } else {
            sideMenu?.leftSide = true
            SideMenuManager.default.leftMenuNavigationController = sideMenu
        }
        if SharedPreference.isUserLogin {
            SideMenuManager.default.addPanGestureToPresent(toView: view)
        }
        sideMenu?.setNavigationBarHidden(true, animated: true)
        sideMenu?.menuWidth = view.frame.size.width * 0.7
        sideMenu?.presentDuration = 0.5
        sideMenu?.presentationStyle = .menuSlideIn
        sideMenu?.presentationStyle.onTopShadowOpacity = 1
        
        setupLeftNavigationBar()
    }
    
    @objc func sideMenuAction(_ sender: UIButton) {
        if sideMenu != nil {
            present(sideMenu!, animated: true, completion: nil)
        }
    }
    
    @objc func loginAction(_ sender: UIButton) {
        MZUtilManager.openLoginViewController()
    }
    
    // MARK: - Actions
    /// back button action handler
    @objc func didTouchBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Add User to firebase
    func addUser() {
        
        let user = SharedPreference.getUserData()!
        let params = [
            "name": user.userName,
            "email": user.email,
            "phone": user.contactNo,
            "displayName": user.displayName,
            "id": user.id,
            "photo": user.profileImg,
            "isOnline": true,
            "userLastSeen": "\(Int(NSDate().timeIntervalSince1970 * 10000 / 10))"] as [String : Any]
        let ref = Database.database().reference()
        
        ref.child("users").child(user.id).setValue(params) { error, ref in
            if error == nil {
                print("user is added to firebase")
            }
        }
    }
    //MARK: - Update User to firebase
    func updateUser() {
        if let user = SharedPreference.getUserData() {
            let params = [
                "displayName": user.displayName,
                "photo": user.profileImg,
                "isOnline": true] as [String : Any]
                
            let ref = Database.database().reference().child("users").child(user.id)
            ref.updateChildValues(params)
        }
    }
}

extension BaseViewController: SideMenuNavigationControllerDelegate {
    
    func sideMenuWillAppear(menu: SideMenuNavigationController, animated: Bool) {
        //        print("SideMenu Appearing! (animated: \(animated))")
    }
    
    func sideMenuDidAppear(menu: SideMenuNavigationController, animated: Bool) {
        //        print("SideMenu Appeared! (animated: \(animated))")
    }
    
    func sideMenuWillDisappear(menu: SideMenuNavigationController, animated: Bool) {
        //        print("SideMenu Disappearing! (animated: \(animated))")
    }
    
    func sideMenuDidDisappear(menu: SideMenuNavigationController, animated: Bool) {
        //        print("SideMenu Disappeared! (animated: \(animated))")
    }
}
extension BaseViewController {
    
    func requestReviewIfAppropriate() {
      //let defaults = UserDefaults.standard
      //let bundle = Bundle.main
      SKStoreReviewController.requestReview()

    }
}
