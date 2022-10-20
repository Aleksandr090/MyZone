//
//  MZProgressLoader.swift
//  MyZone
//

import UIKit
import NVActivityIndicatorView

class MZProgressLoader: UIViewController, NVActivityIndicatorViewable {
    
    fileprivate class var sharedInstance: MZProgressLoader {
        struct singleton {
            static let instance = MZProgressLoader()
        }
        return singleton.instance
    }
    
    var presentingIndicatorTypes = {
        return NVActivityIndicatorType.allCases.filter { $0 != .blank }
    }()
    
    class func showCirculer(){
        let size = CGSize(width: 50, height: 45)
        let indicatorType = sharedInstance.presentingIndicatorTypes[23]
        sharedInstance.startAnimating(size, message: "", type: indicatorType, color: UIColor.white, fadeInAnimation: nil) //"00AAB5"
    }
    
    class func show() {
        let size = CGSize(width: 50, height: 45)
        let indicatorType = sharedInstance.presentingIndicatorTypes[0]
        sharedInstance.startAnimating(size, message: "", type: indicatorType, color: UIColor.white, fadeInAnimation: nil) //"00AAB5"
    }
    
    class func hide() {
        sharedInstance.stopAnimating(nil)
    }
}
