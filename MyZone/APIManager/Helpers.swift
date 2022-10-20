//
//  Helpers.swift

import Foundation
import Alamofire


struct Helpers {
    fileprivate let defaults = UserDefaults.standard
    static let helperInstance = Helpers()
 
    
    static func validateResponse(_ statusCode: Int) -> Bool {
        if case 200...300 = statusCode {
            return true
        }
        
        
        return false
    }
}






