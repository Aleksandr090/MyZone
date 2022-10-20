//
//  StoryboardName.swift
//  MyZone
//

import Foundation

import UIKit

enum StoryboardName: String {
    case main = "Main"
    case authentication = "Authentication"
    case notification = "Notification"
    case message = "Message"
    case explore = "Explore"
    case home = "Home"
    case feed = "Feed"

    static func `for`(_ storyboard: StoryboardName) -> String {
        return storyboard.rawValue
    }
}

// MARK: - UIStoryboard name & ViewController Instantiation function
extension UIStoryboard {
    convenience init(storyboard: StoryboardName, bundle: Bundle? = nil) {
        self.init(name: storyboard.rawValue, bundle: bundle)
    }
    
    func instantiateVC<VC: UIViewController>() -> VC {
        guard let viewController = instantiateViewController(withIdentifier: VC.identifier) as? VC else {
            fatalError("Couldn't instantiate viewController with identifier \(VC.identifier)")
        }
        return viewController
    }
}

// MARK: - UIViewController Identifier
extension UIViewController {
    static var identifier: String {
        return String(describing: self)
    }
}
