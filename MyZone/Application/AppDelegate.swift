//
//  AppDelegate.swift
//  MyZone
//

import UIKit
import GoogleMaps
import GooglePlaces
import GoogleSignIn
import IQKeyboardManagerSwift
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        
        L102Localizer.DoTheMagic()
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.layoutIfNeededOnUpdate = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        
        GMSPlacesClient.provideAPIKey("AIzaSyCnUnEqXBesxl6IMU93erFZCUV_SBfXFjo")
        GMSServices.provideAPIKey("AIzaSyCnUnEqXBesxl6IMU93erFZCUV_SBfXFjo")
        GIDSignIn.sharedInstance().clientID = "1007050056647-60i97sj396jgtuu62c4fjgfje3v705qd.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self as? GIDSignInDelegate
        
        // Override point for customization after application launch.
        // Sets background to a blank/empty image
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        // Sets shadow (line below the bar) to a blank image
        UINavigationBar.appearance().shadowImage = UIImage()
        // Sets the translucent background color
        UINavigationBar.appearance().backgroundColor = .clear
        // Set translucent. (Default value is already true, so this can be removed if desired.)
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().tintColor = UIColor.AppTheme.TextColor
        
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.AppTheme.PinkColor]
        UINavigationBar.appearance().titleTextAttributes = textAttributes
        
        
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        
        
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        if let token: String = Messaging.messaging().fcmToken {
//            print("FCM Token===", token)
//            ApplicationPreference.sharedManager.write(type: .fcmToken, value: token)
//        }
//    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let token = fcmToken {
            print("FCM Token===", token)
            ApplicationPreference.sharedManager.write(type: .fcmToken, value: token)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let body = notification.request.content.body
        let userInfo = notification.request.content.userInfo
        print("notification received==\(body)", userInfo)
        
        if let type = userInfo["type"] as? String, type == "message" {
            NotificationCenter.default.post(name: Notification.Name("ChatBadge"), object: nil, userInfo: ["badgeCount": 1])
        } else {
            NotificationCenter.default.post(name: Notification.Name("NotiBadge"), object: nil, userInfo: ["badgeCount": 1])
        }
       
        completionHandler([])
    }
}

