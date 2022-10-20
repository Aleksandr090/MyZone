//
//  ApplicationPreference.swift
//  Scarp App
//
//  Created by Admin on 28/10/20.
//  Copyright © 2020 Gaurav Kive. All rights reserved.
//

import Foundation
import UIKit

protocol ApplicationPreferenceHandler {
    func read(type:PreferenceType) -> Any
    func write(type:PreferenceType,value: Any)
    func clearData(type:PreferenceType)
}

enum PreferenceType:String {
    case appLaunchFirstTime
    case isGuestUser
    case logindata
    case authorization
    case appLangKey
    case deviceId
    case mobile_verify
    case email_verify
    case notification_unread_count
    case userLat
    case userLong
    case userRadius
    case fcmToken
    case showTutorial
    case isPlanPurchased
    case socialLogin
    case user_name
    case user_Id
    case userType
    case userAddress
    case user_photo
    case isPushNotification
    case appLanguageStr
    case isUserRemoved
    case userInterest
    case flagSCountry
    case flagSCity
    case flagUCountry
    case flagUCity
    case flagCCountry
    case flagCCity
    case filuserLat
    case filuserLong
    case dictSaveFilter
    case saveDiscover
    case saveFilter
    case isDark
    case isCommentNotify
    case isReplyNotify
    case isLikeNotify
    case isMessageNotify
    case isPublicNotify
    
    var description : String {
        switch self {
        case .appLaunchFirstTime: return "appLaunchFirstTime"
        case .isGuestUser : return "isGuestUser"
        case .logindata: return "logindata"
        case .authorization: return "authorization"
        case .appLangKey : return "AppLangKey"
        case .deviceId : return "device_id"
        case .mobile_verify : return "mobile_verify"
        case .email_verify : return "email_verify"
        case .notification_unread_count : return "notification_unread_count"
        case .userLat : return "userLat"
        case .userLong : return "userLong"
        case .userRadius: return "userRadius"
        case .userAddress : return "userAddress"
        case .fcmToken: return "fcmToken"
        case .showTutorial: return "showTutorial"
        case .isPlanPurchased: return "isPlanPurchased"
        case .socialLogin: return "socialLogin"
        case .user_name: return "user_name"
        case .user_photo: return "user_photo"
        case .user_Id: return "user_Id"
        case .userType: return "userType"
        case .isPushNotification: return "isPushNotification"
        case .appLanguageStr: return "appLanguageStr"
        case .isUserRemoved: return "isUserRemoved"
        case .userInterest: return "userInterest"
        case .flagSCountry: return "flagSCountry"
        case .flagSCity: return "flagSCity"
        case .flagUCountry: return "flagUCountry"
        case .flagUCity: return "flagUCity"
        case .flagCCountry: return "flagCCountry"
        case .flagCCity: return "flagCCity"
        case .filuserLat: return "filuserLat"
        case .filuserLong: return "filuserLong"
        case .dictSaveFilter: return "dictSaveFilter"
        case .saveDiscover: return "saveDiscover"
        case .saveFilter: return "saveFilter"
        case .isDark: return "isDark"
        case .isCommentNotify: return "isCommentNotify"
        case .isLikeNotify: return "isLikeNotify"
        case .isReplyNotify: return "isReplyNotify"
        case .isMessageNotify: return "isMessageNotify"
        case .isPublicNotify: return "isPublicNotify"
        }
    }
}

class ApplicationPreference{
    fileprivate static let userDefault = UserDefaults.standard
    
    static var sharedManager: ApplicationPreference {
        return ApplicationPreference()
    }
}

extension ApplicationPreference:ApplicationPreferenceHandler{
    
    func clearData(type: PreferenceType) {
        ApplicationPreference.userDefault.removeObject(forKey: type.description)
        ApplicationPreference.userDefault.synchronize()
    }
    
    func write(type: PreferenceType, value: Any) {
        ApplicationPreference.userDefault.set(value, forKey: type.description)
        ApplicationPreference.userDefault.synchronize()
    }
    
    func read(type: PreferenceType) -> Any {
        return ApplicationPreference.userDefault.object(forKey: type.description) ?? ""
    }
    
    func clearDataOnLogout () {
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.isGuestUser.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.logindata.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.authorization.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.mobile_verify.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.email_verify.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.socialLogin.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.user_name.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.user_Id.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.userType.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.user_photo.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.isPushNotification.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.isUserRemoved.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.appLanguageStr.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.userInterest.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.flagSCity.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.flagUCity.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.flagCCity.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.flagSCountry.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.flagUCountry.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.flagCCountry.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.filuserLat.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.filuserLong.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.dictSaveFilter.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.saveDiscover.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.saveFilter.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.isCommentNotify.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.isReplyNotify.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.isLikeNotify.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.isMessageNotify.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.isPublicNotify.description)

        ApplicationPreference.userDefault.synchronize()
        
        UserDefaults.standard.removeObject(forKey: "UserData")
        UserDefaults.standard.synchronize()
    }
    
    func clearAllData () {
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.appLaunchFirstTime.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.isGuestUser.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.logindata.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.authorization.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.mobile_verify.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.userType.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.email_verify.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.socialLogin.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.user_name.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.user_Id.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.user_photo.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.isPushNotification.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.isUserRemoved.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.appLanguageStr.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.userInterest.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.flagSCity.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.flagUCity.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.flagCCity.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.flagSCountry.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.flagUCountry.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.flagCCountry.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.filuserLat.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.filuserLong.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.dictSaveFilter.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.saveDiscover.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.saveFilter.description)
        
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.isCommentNotify.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.isReplyNotify.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.isLikeNotify.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.isMessageNotify.description)
        ApplicationPreference.userDefault.removeObject(forKey: PreferenceType.isPublicNotify.description)


        UserDefaults.standard.removeObject(forKey: "UserData")
        UserDefaults.standard.synchronize()
        
        ApplicationPreference.userDefault.synchronize()
    }
}
