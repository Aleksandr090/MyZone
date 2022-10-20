//
//  MZUtilManager.swift
//  MyZone
//

import Foundation
import UIKit
import Photos
import PhotosUI

class MZUtilManager: NSObject {
    
    /// Data - Shared Instance
    static let shared = MZUtilManager()
    static let userData = SharedPreference.getUserData()
    
    func showErrorDialog(type: MZAlertViewType = .error, title: String, description: String, buttonTitle: String, secondBtnTitle: String = "", actionCallback: (() -> Void)? = nil, secondActionCallback: (() -> Void)? = nil) {
//        if let error = error, checkErrorTypeForPAMAlert(with: error) {
//            return
//        }
        if MZUtilManager.currentViewIsPAMAlertView() {
            return
        }
        let alertView = MZAlertView.createAlertView(type: type, title: title, message: description, shouldHideWhenTappingOutside: false, displayMode: .none)
        alertView.addAction(actionItem: MZAlertViewActionItem(title: buttonTitle, type: .primary, action: actionCallback))
        if !secondBtnTitle.isEmpty {
            alertView.addAction(actionItem: MZAlertViewActionItem(title: secondBtnTitle, type: .secondary, action: secondActionCallback))
        }
        alertView.show()
    }
    
    /// Return the Bool if current view is PAMAlertView
    static func currentViewIsPAMAlertView() -> Bool {
        if  let window = UIApplication.shared.windows.first {
            for subview in window.subviews {
                if subview is MZAlertView {
                    return true
                }
            }
        }
        return false
    }
    
    static func openLoginViewController() {
        if let window = UIApplication.shared.windows.first {
            let loginVC: LoginViewController = UIStoryboard(storyboard: .authentication).instantiateVC()
            let navVC = UINavigationController(rootViewController: loginVC)
            navVC.modalPresentationStyle = .overCurrentContext
            window.rootViewController?.present(navVC, animated: false, completion: nil)
            window.makeKeyAndVisible()
        }
    }
    
    static func openDeleteUserAccount() {
        print("Click Delete Account")
        MZProgressLoader.show()
        APIController.makeRequestReturnJSON(.deleteUserAccount(userId: userData!.id)) { (data, error,headerDict) in
            MZProgressLoader.hide()
            if error == nil {
                openLoginViewController()
                if let responseData = data, let userData = responseData["data"] as? JSONDictionary {
                    print("Edit UserProfile userData----->\(userData)")
                } else if let responseData = data, let statusCode = responseData["status"] as? Int, statusCode == 400 {
                    print("userData-----\(responseData)")
                }
            } else {
                MZUtilManager.showAlertWith(vc: nil, title: "", message: (error?.desc)!, actionTitle: "OK")
            }
        }
    }
    
    static func showDeleteAccountAlert() {
        if let window = UIApplication.shared.windows.first {
            let vc: MZAlertViewController = UIStoryboard(storyboard: .main).instantiateVC()
            vc.alertType = .deleteAccount
            vc.modalPresentationStyle = .overCurrentContext
            window.rootViewController?.present(vc, animated: false, completion: nil)
            window.makeKeyAndVisible()
        }
    }
    
    static func showLoginAlert() {
        if let window = UIApplication.shared.windows.first {
            let vc: MZAlertViewController = UIStoryboard(storyboard: .main).instantiateVC()
            vc.alertType = .login
            vc.modalPresentationStyle = .overCurrentContext
            window.rootViewController?.present(vc, animated: false, completion: nil)
            window.makeKeyAndVisible()
        }
    }
    
    static func showLogoutAlert() {
        if let window = UIApplication.shared.windows.first {
            let vc: MZAlertViewController = UIStoryboard(storyboard: .main).instantiateVC()
            vc.alertType = .logout
            vc.modalPresentationStyle = .overCurrentContext
            window.rootViewController?.present(vc, animated: false, completion: nil)
            window.makeKeyAndVisible()
        }
    }
    
    static func performUserLogout() {
        SharedPreference.clearUserData()
        if let window = UIApplication.shared.windows.first {
            let tabVC: TabBarController = UIStoryboard(storyboard: .main).instantiateVC()
            window.rootViewController = tabVC
            window.makeKeyAndVisible()
        }
    }
    
    class func showAlertWith(vc: UIViewController?, title: String, message: String, actionTitle: String, closer:(()-> Void)? = nil ){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: actionTitle, style: UIAlertAction.Style.default) {
            (result : UIAlertAction) -> Void in
            print(actionTitle)
            closer?()
        }
        alert.addAction(okAction)
        
        if let window = UIApplication.shared.windows.first {
//            if let vc = vc { window.rootViewController = vc }
            window.rootViewController?.present(alert, animated: false, completion: nil)
            window.makeKeyAndVisible()
        }
    }
    
    func timeAgoSinceDate(_ date: Date, numericDates: Bool = false) -> String {
        let calendar = NSCalendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = Date()
        let earliest = now < date ? now : date
        let latest = (earliest == now) ? date : now
        let components = calendar.dateComponents(unitFlags, from: earliest, to: latest)
        
        if (components.year! >= 2) {
            return "\(components.year!) years ago" //PAMLocaleManager.localizedString(key: "common_x_years_ago", comment: "years ago").replacingOccurrences(of: "[X]", with: "\(components.year!)")
        } else if (components.year! >= 1) {
            return "Last year" //PAMLocaleManager.localizedString(key: "common_last_year", comment: "Last year")
        } else if (components.month! >= 2) {
            return "\(components.month!) months ago" //PAMLocaleManager.localizedString(key: "common_x_months_ago", comment: "months ago").replacingOccurrences(of: "[X]", with: "\(components.month!)")
        } else if (components.month! >= 1) {
            return "Last month" //PAMLocaleManager.localizedString(key: "common_last_month", comment: "Last month") //
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) weeks ago" // PAMLocaleManager.localizedString(key: "common_x_weeks_ago", comment: "weeks ago").replacingOccurrences(of: "[X]", with: "\(components.weekOfYear!)")
        } else if (components.weekOfYear! >= 1) {
            return "Last week" // PAMLocaleManager.localizedString(key: "common_last_week", comment: "Last week") //
        } else if (components.day! >= 2) {
            return "\(components.day!) days ago" //PAMLocaleManager.localizedString(key: "common_x_days_ago", comment: "days ago").replacingOccurrences(of: "[X]", with: "\(components.day!)")
        } else if (components.day! >= 1) {
            return "Yesterday" // PAMLocaleManager.localizedString(key: "common_yesterday", comment: "Yesterday") //
        } else if (components.hour! >= 2) {
            return "\(components.hour!) Hours Ago" //PAMLocaleManager.localizedString(key: "common_x_hours_ago", comment: "Hours Ago").replacingOccurrences(of: "[X]", with: "\(components.hour!)")
        } else if (components.hour! >= 1) {
            return "\(components.hour!) Hour Ago" // PAMLocaleManager.localizedString(key: "common_x_hour_ago", comment: "Hour Ago").replacingOccurrences(of: "[X]", with: "\(components.hour!)") //
        } else if (components.minute! >= 2) {
            return "\(components.minute!) Minutes Ago" // PAMLocaleManager.localizedString(key: "common_x_minutes_ago", comment: "Minutes Ago").replacingOccurrences(of: "[X]", with: "\(components.minute!)")
        } else if (components.minute! >= 1) {
            return "\(components.minute!) Minute Ago" // PAMLocaleManager.localizedString(key: "common_x_minute_ago", comment: "Minute Ago").replacingOccurrences(of: "[X]", with: "\(components.minute!)") //
        } else if (components.second! >= 30) {
            return "\(components.second!) Seconds Ago" // PAMLocaleManager.localizedString(key: "common_x_seconds_ago", comment: "Seconds Ago").replacingOccurrences(of: "[X]", with: "\(components.second!)")
        } else {
            return "Just now" //PAMLocaleManager.localizedString(key: "common_just_now", comment: "Just now")
        }
    }
}
