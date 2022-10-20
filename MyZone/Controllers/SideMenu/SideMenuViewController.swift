//
//  SideMenuViewController.swift
//  MyZone
//

import UIKit
import SDWebImage

class SideMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK:- IBOutlets
    @IBOutlet private var menuTableView : UITableView!
    @IBOutlet private var profileImageView : UIImageView!
    @IBOutlet private var nameLabel : UILabel!
    @IBOutlet weak var btnReward: UIButton!
    @IBOutlet private var usernameLabel : UILabel!
    
    var sections = [Section]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sections = [
            Section(name: "", imageName: "", items: [Section.Item(name: "My Comment", imageName: "comment"),
                                                     Section.Item(name: "My Post", imageName: "post"),
                                                     Section.Item(name: "My Interests", imageName: "interest"),
                                                     Section.Item(name: "Saved People", imageName: "people"),
                                                     Section.Item(name: "Saved Topics", imageName: "topic"),
                                                     Section.Item(name: "Dark Mode", imageName: ""),
                                                     Section.Item(name: "Language", imageName: "language")], collapsed: false),
            Section(name: "Settings", imageName: "settings", items: [/*Section.Item(name: "Feed", imageName: ""),*/
                                                                     Section.Item(name: "Messages", imageName: ""),
                                                                     Section.Item(name: "Notifications", imageName: ""),
                                                                     Section.Item(name: "Account", imageName: ""), 
                                                                     Section.Item(name: SharedPreference.isUserLogin ? "Logout" : "Login", imageName: "")]),
            Section(name: "Help", imageName: "help", items: [Section.Item(name: "Contact", imageName: ""),
                                                             Section.Item(name: "Terms of Use", imageName: "")]),
            Section(name: "", imageName: "", items: [Section.Item(name: "", imageName: "")], collapsed: false)]
        
        self.menuTableView.register(UINib(nibName: "SideMenuCell", bundle: .main), forCellReuseIdentifier: "SideMenuCell")
        self.menuTableView.register(UINib(nibName: "SideMenuHeaderCell", bundle: .main), forCellReuseIdentifier: "SideMenuHeaderCell")
        self.menuTableView.tableFooterView = UIView(frame: .zero)
        
        
        if let userData = SharedPreference.getUserData() {
            profileImageView?.sd_setImage(with: URL(string: userData.profileImg), placeholderImage: UIImage(named: "dummy"), options: .continueInBackground)
            nameLabel.text = userData.displayName.isEmpty ? userData.userName : userData.displayName
            usernameLabel.text = userData.userName
            if let rewardImage = userData.rewardImage {
                btnReward.sd_setImage(with: URL(string: rewardImage), for: .normal)
            }
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @IBAction func sideMenuUserImageClick(_ sender: Any) {
        showUserProfileDetails()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // refresh cell blur effect in case it changed
        menuTableView.reloadData()
        
        // Set up a cool background image for demo purposes
        
        //        let topView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 60))
        //        topView.backgroundColor = UIColor.AppTheme.PinkColor
        //        let imageView = UIImageView(image: #imageLiteral(resourceName: "splash_bg"))
        //        imageView.contentMode = .scaleToFill
        //        imageView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        //        tableView.backgroundView = topView
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sections[section].collapsed ? 0 : sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 3 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SocialLinksCell", for: indexPath) as? SocialLinksCell else { return  UITableViewCell() }
            
            return cell
            
        } else if let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuCell", for: indexPath) as? SideMenuCell {
            
            cell.itemData = sections[indexPath.section].items[indexPath.row]
            if indexPath.section == 0 {
                cell.isSubCell = false
            } else {
                cell.isSubCell = true
            }
            cell.setupItemData()
            
            cell.setDarkLightMode = { isDarkMode in
                if let window = UIApplication.shared.windows.first {
                    if isDarkMode {
                        // change UI into dark mode
                        window.overrideUserInterfaceStyle = .dark
                    } else {
                        // change UI into light mode
                        window.overrideUserInterfaceStyle = .light
                    }
                }
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionItem = sections[section]
        if sectionItem.name.isEmpty {
            return UIView()
        } else {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? SideMenuTableViewHeader ?? SideMenuTableViewHeader(reuseIdentifier: "header")
            header.titleLabel.text = sections[section].name
            header.primaryImageView.image = UIImage(named: sectionItem.imageName)
            header.setCollapsed(sections[section].collapsed)
            
            header.section = section
            header.delegate = self
            return header
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 ||  section == 3 {
            return 0.0
        }
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true, completion: nil)
        switch (indexPath.section, indexPath.row) {
        case (0,0): // My comment
            showMyCmment()
            break
        case (0,1): // My Post
            showPosts(postType: .myPost)
        case (0,2): // My Intersts
            showMyInterest()
        case (0,3): // Saved People
            showSavedPeople()
            break
        case (0,4): // Saved Topics
            showPosts(postType: .savedTopic)
        case (0,5): // Dark mode
            break
        case (0,6): // Language
            changeLanguage()
        /*case (1,0): // Feed
            showFeed()
            break*/
        case (1,0): // Message
            showMessageList()
            self.tabBarController?.selectedIndex = 4
        case (1,1): // Notification
            showNotificationList()
            self.tabBarController?.selectedIndex = 3
        case (1,2): // Account
            showMyAccount()
        case (1,3): // LogOut
            if SharedPreference.isUserLogin {
                MZUtilManager.showLogoutAlert()
            } else {
                MZUtilManager.openLoginViewController()
            }
        case (2,0): // Contact
            showContact()
            break
        case (2,1): // Terms of use
            break
        default:
            break
        }
    }
    
    func checkUserLogin() {
        
    }
    
    func showUserProfileDetails(){
        if SharedPreference.isUserLogin {
            let vc: PostUserDetailsViewController = UIStoryboard(storyboard: .home).instantiateVC()
            vc.userId = Constant().userId
            vc.userType = "Self"
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            MZUtilManager.showLoginAlert()
        }
    }
    
    func showMyCmment(){
        if SharedPreference.isUserLogin {
            let vc: MyCommentViewController = UIStoryboard(storyboard: .home).instantiateVC()
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            MZUtilManager.showLoginAlert()
        }
    }
    
    func showSavedPeople(){
        if SharedPreference.isUserLogin {
            let vc: SavedPeopleViewController = UIStoryboard(storyboard: .home).instantiateVC()
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            MZUtilManager.showLoginAlert()
        }
    }
    
    func showMyAccount() {
        if SharedPreference.isUserLogin {
            let vc: MyAccountViewController = UIStoryboard(storyboard: .main).instantiateVC()
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            MZUtilManager.showLoginAlert()
        }
    }
    
    func showFeed() {
        if SharedPreference.isUserLogin {
            let vc: FeedViewController = UIStoryboard(storyboard: .feed).instantiateVC()
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            MZUtilManager.showLoginAlert()
        }
    }
    
    func showMessageList(){
        if SharedPreference.isUserLogin {
            let vc: MessageViewController = UIStoryboard(storyboard: .message).instantiateVC()
            vc.hidesBottomBarWhenPushed = false
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            MZUtilManager.showLoginAlert()
        }
    }
    
    func showNotificationList(){
        if SharedPreference.isUserLogin {
            let vc: NotificationSettingViewController = UIStoryboard(storyboard: .main).instantiateVC()
            vc.hidesBottomBarWhenPushed = false
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            MZUtilManager.showLoginAlert()
        }
    }
    
    func showPosts(postType: PostListType) {
        if SharedPreference.isUserLogin {
            let vc: HomeViewController = UIStoryboard(storyboard: .home).instantiateVC()
            vc.postListType = postType
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            MZUtilManager.showLoginAlert()
        }
    }
    
    func showMyInterest() {
        if SharedPreference.isUserLogin {
            let vc: MyInterestViewController = UIStoryboard(storyboard: .home).instantiateVC()
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            MZUtilManager.showLoginAlert()
        }
    }
    
    
    func changeLanguage() {
        let vc: LanguageViewController = UIStoryboard(storyboard: .main).instantiateVC()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        /*if L102Language.currentAppleLanguage() == "en" {
         L102Language.setAppleLAnguageTo(lang: "ar")
         UIView.appearance().semanticContentAttribute = .forceRightToLeft
         } else {
         L102Language.setAppleLAnguageTo(lang: "en")
         UIView.appearance().semanticContentAttribute = .forceLeftToRight
         }*/
        
        //reloadUI()
    }
    
    func showContact() {
        if SharedPreference.isUserLogin {
            let vc: ContactViewController = UIStoryboard(storyboard: .home).instantiateVC()
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            MZUtilManager.showLoginAlert()
        }
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

//
// MARK: - Section Header Delegate
//
extension SideMenuViewController: SideMenuTableViewHeaderDelegate {
    func toggleSection(_ header: SideMenuTableViewHeader, section: Int) {
        let collapsed = !sections[section].collapsed
        
        // Toggle collapse
        sections[section].collapsed = collapsed
        header.setCollapsed(collapsed)
        
        menuTableView.beginUpdates()
        menuTableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .none)
        menuTableView.endUpdates()
    }
}

struct Section {
    var name: String
    var imageName: String
    var items: [Item]
    var collapsed: Bool
    
    init(name: String, imageName: String, items: [Item], collapsed: Bool = true) {
        self.name = name
        self.imageName = imageName
        self.items = items
        self.collapsed = collapsed
    }
    
    struct Item {
        var name: String
        var imageName: String
        init(name: String, imageName: String) {
            self.name = name
            self.imageName = imageName
        }
    }
}

