//
//  TabBarController.swift
//  MyZone
//

import UIKit
import SideMenu

enum BaseTabBarIndex: Int {
  
    case home, explore, add, notification, message
    
    var image: UIImage {
        switch self {
        case .home:
            return UIImage(named:"home")!
        case .explore:
            return UIImage(named:"explore")!
        case .add:
            return UIImage(named:"add-sel")!
        case .notification:
            return UIImage(named:"notification")!
        case .message:
            return UIImage(named:"message")!
        }
    }
    
    var sel_image: UIImage {
        switch self {
        case .home:
            return UIImage(named:"home-sel")!
        case .explore:
            return UIImage(named:"explore-sel")!
        case .add:
            return UIImage(named:"add-sel")!
        case .notification:
            return UIImage(named:"notification-sel")!
        case .message:
            return UIImage(named:"message-sel")!
        }
    }
}

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    //MARK:-
    let menuButton = UIButton()
    var menu: SideMenuNavigationController?
    var previousIndex: Int = 0

    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSideMenu()
        
        self.setupTabBarUI()
        self.setTabbarItems()
        self.delegate = self

        menuButton.frame = CGRect(x: (UIScreen.main.bounds.width/2) - 20, y: 5, width: 40, height: 40)
        menuButton.setBackgroundImage(BaseTabBarIndex.add.image, for: .normal)
        menuButton.addTarget(self, action: #selector(plusTabAction(_:)), for: .touchUpInside)
        self.tabBar.addSubview(menuButton)

        
        NotificationCenter.default.addObserver(self, selector: #selector(plusTabAction(_:)), name: NSNotification.Name("plusTabAction"), object: nil)
        
    }
    
//    static func fromStoryBoard() -> TabBarController {
//        return UIStoryboard.home.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.setBadge(notification:)), name: Notification.Name("ChatBadge"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.setNotiBadge(notification:)), name: Notification.Name("NotiBadge"), object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
//        self.view.bringSubviewToFront(menuButton)
//        menuButton.frame = CGRect.init(x:  (UIScreen.main.bounds.width/2) - 40, y: self.tabBar.frame.minY - 50, width: 80, height: 80)
//
//        if let navVC = self.selectedViewController as? UINavigationController, navVC.viewControllers.last!.hidesBottomBarWhenPushed {
//            menuButton.isHidden = true
//        } else {
//            menuButton.isHidden = false
//        }
        
    }
    
    private func setupTabBarUI() {
        // Setup your colors and corner radius
        self.tabBar.layer.cornerRadius = 25
        self.tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.tabBar.layer.borderWidth = 0.5
        self.tabBar.layer.borderColor = UIColor.AppTheme.ShadowColor.cgColor
        self.tabBar.layer.backgroundColor = UIColor.AppTheme.CardBackground.cgColor
        self.tabBar.tintColor = UIColor.AppTheme.PinkColor
        self.tabBar.clipsToBounds = true
        self.tabBar.backgroundColor = UIColor.AppTheme.CardBackground
        

        // Remove the line
        if #available(iOS 13.0, *) {
            let appearance = self.tabBar.standardAppearance
            appearance.shadowImage = nil
            appearance.shadowColor = nil
            self.tabBar.standardAppearance = appearance
        } else {
            self.tabBar.shadowImage = UIImage()
            self.tabBar.backgroundImage = UIImage()
        }
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .selected)
//        UITabBar.appearance().tintColor = UIColor.AppTheme.MainBackground
    }

    //MARK: -
    private func setTabbarItems() {
        let tabOneVC: HomeViewController = UIStoryboard(storyboard: .home).instantiateVC()
        let tabOneNavVC = UINavigationController(rootViewController: tabOneVC)
        tabOneNavVC.tabBarItem = UITabBarItem.init(title: "Home", image: BaseTabBarIndex.home.image, selectedImage: BaseTabBarIndex.home.sel_image)

        let tabTwoVC: ExploreViewController = UIStoryboard(storyboard: .explore).instantiateVC()
        let tabTwoNavVC = UINavigationController(rootViewController: tabTwoVC)
        tabTwoNavVC.tabBarItem = UITabBarItem.init(title: "Explore", image: BaseTabBarIndex.explore.image, selectedImage: BaseTabBarIndex.explore.sel_image)

        let tabThreeVC: ExploreViewController = UIStoryboard(storyboard: .explore).instantiateVC()
        let tabThreeNavVC = UINavigationController(rootViewController: tabThreeVC)
        tabThreeNavVC.tabBarItem = UITabBarItem.init(title: "", image: nil, selectedImage: nil)

        let tabFourVC: NotificationViewController = UIStoryboard(storyboard: .notification).instantiateVC()
        let tabFourNavVC = UINavigationController(rootViewController: tabFourVC)
        tabFourNavVC.tabBarItem = UITabBarItem.init(title: "Notifications", image: BaseTabBarIndex.notification.image, selectedImage: BaseTabBarIndex.notification.sel_image)
        
        let tabFiveVC: MessageViewController = UIStoryboard(storyboard: .message).instantiateVC()
        let tabFiveNavVC = UINavigationController(rootViewController: tabFiveVC)
        tabFiveNavVC.tabBarItem = UITabBarItem.init(title: "Message", image: BaseTabBarIndex.message.image, selectedImage: BaseTabBarIndex.message.sel_image)

        viewControllers = [tabOneNavVC, tabTwoNavVC, tabThreeNavVC, tabFourNavVC, tabFiveNavVC]
    }
    
    //MARK: -
    @objc func plusTabAction(_ sender: UIButton) {
        previousIndex = selectedIndex
        addActionPerformed()
//        self.selectedIndex = 2
//        MZUtilManager.shared.showErrorDialog(title: "", description: "Lgoin", buttonTitle: "Done")
    }
    
    @objc func setBadge(notification: Notification) {        
        let badgeCount = notification.userInfo!["badgeCount"] as! Int
        if let tabItems = self.tabBar.items {
            let tabItem = tabItems[4]
            tabItem.badgeValue = badgeCount > 0 ? "" : nil
        }
    }
    
    @objc func setNotiBadge(notification: Notification) {
        let badgeCount = notification.userInfo!["badgeCount"] as! Int
        if let tabItems = self.tabBar.items {
            let tabItem = tabItems[3]
            tabItem.badgeValue = badgeCount > 0 ? "" : nil
        }
    }
        
    // UITabBarControllerDelegate method
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
      
        previousIndex = selectedIndex
        
        if selectedIndex == 2 {
            selectedIndex = previousIndex
            plusTabAction(UIButton())
        }
    }
    
    func addActionPerformed() {
        if SharedPreference.isUserLogin {
            let vc: PostTypeViewController = UIStoryboard(storyboard: .home).instantiateVC()
//            let vc: AddPostViewController = UIStoryboard(storyboard: .home).instantiateVC()
            let navVC = UINavigationController(rootViewController: vc)
            navVC.modalPresentationStyle = .overCurrentContext
            self.present(navVC, animated: true, completion: nil)
        } else {
            selectedIndex = previousIndex
            MZUtilManager.showLoginAlert()
        }
    }
    
    private func setupSideMenu() {
        let sideMenu: SideMenuViewController = UIStoryboard(storyboard: .main).instantiateVC()
        menu = SideMenuNavigationController(rootViewController: sideMenu)
        if L102Language.isRTL {
            menu?.leftSide = false
        } else {
            menu?.leftSide = true
        }
        
//        // Define the menus
//        SideMenuManager.default.leftMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController
////        SideMenuManager.default.rightMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: "RightMenuNavigationController") as? SideMenuNavigationController
//
//        // Enable gestures. The left and/or right menus must be set up above for these to work.
//        // Note that these continue to work on the Navigation Controller independent of the View Controller it displays!
//        SideMenuManager.default.addPanGestureToPresent(toView: navigationController!.navigationBar)
//        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: view)
    }
}

