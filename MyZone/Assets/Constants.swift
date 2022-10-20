//
//  Constants.swift
//  

import Foundation
import UIKit

//#if targetEnvironment(simulator)
var SERVER_URL = "http://3.13.183.235:8080"
//#else
//var SERVER_URL = "http://192.168.0.30:8080"
//#endif


struct Constants {
    
    static let isDebugOn = false
    
    
    struct API {
        static let baseURL = SERVER_URL +  "/api/"
        static let imageBaseURL = SERVER_URL +  "/image/user/"
        
    }
    struct Texts {
        static let errorParsingResponse = "Unknown Error"
    }
    
    struct APPKey {
        static let googleAPIKey = "853028846700-5tam62jfobc7r21hd4c92ddtk54418ip.apps.googleusercontent.com"
        static let googlePlacePickerKey = "AIzaSyDz1zXY2dFI3cI93y_cOwHrRszEi6c1igo"
    }
    
    struct AppURL {
        static let terms = "http://sortapp-env.eba-sppmbzda.us-east-2.elasticbeanstalk.com/static/termsCondition"
        static let privacy = "http://sortapp-env.eba-sppmbzda.us-east-2.elasticbeanstalk.com/static/privacyPolicy"
        static let faq = "http://sortapp-env.eba-sppmbzda.us-east-2.elasticbeanstalk.com/static/termsCondition"
    }
    
    
    struct AppPrefrencesConstants{
        static var LanguageChangeNotificationKey: String {
            return "__app_language_change"
        }
        static var CurrentLanguageKey: String {
            return "__k__current_language"
        }
        
        struct Color {
            static var ThemeColorHexCode: String {
                return "000000"
            }
            static var ThemePlaceholderColorHexCode: String {
                return "9FA8AF"
            }
            static var ThemeColorBackGroundHexCode: String {
                return "FAFAFA"
            }
            static var ThemeSegmentButtonSelectedColorHexCode: String {
                return "8704C4"
            }
        }
        
        struct AppLanguage {
            struct Code {
                static var English: String {
                    return "en"
                }
                static var Arabic: String {
                    return "ar"
                }
            }
            struct Title {
                static var English: String {
                    return "English"
                }
                static var Arabic: String {
                    return "Arabic"
                }
            }
        }
        
        struct User {
            static var UserTypeKey: String {
                return "__app_prefrence_user_type"
            }
        }
    }
    
    struct NotificationMessageKey{
        static let kDate = "date"
        static let kTime = "time"
    }
    
    struct Localized{
        static let ContorllerKey = "controller"
        static let LocalizedFileKey = "Localizable"
        
        struct Module {
            static let Login = "login"
            static let SignUp = "signup"
            static let Error = "error"
        }
        
        struct Component {
            static let Email = "email"
            static let Password = "password"
            static let Login = "login"
            static let Network = "network"
        }
        
        struct  Element {
            static let Button = "button"
            static let Label = "label"
            static let TextField = "textfield"
            static let TextView = "textview"
            static let Parser = "parser"
            static let Encoding = "encoding"
        }
    }
    
}

struct IconSize{
    struct Navigation{
        static var Menu:CGSize {
            return CGSize(width: 20, height: 20)
        }
        static var Back:CGSize {
            return CGSize(width: 20, height: 20)
        }
    }
}

struct FontSizes {
    static let large: Float = 22.0
    static let medium: Float = 18.0
    static let small: Float = 12.0
}

struct ValidationLength {
    static let nameMin: Int = 3
    static let nameMax: Int = 20
    
    //--------------------------------
    static let mobileNumber: Int = 11
    static let passwordMin: Int = 6
    static let passwordMax: Int = 50
    static let buisenameMax: Int = 100
    static let chooseServiceMin: Int = 1
    static let attachId: Int = 1
    static let otpLength: Int = 4
    
}

public enum ToastColor: Int {
    case warning = 0
    case error
    case success
    case information
}

struct Fontname {
    static let SFProDisplayRegular: String = "SFProDisplay-Regular"
    static let SFProDisplayMedium: String = "SFProDisplay-Medium"
    static let SFProDisplayBold: String = "SFProDisplay-Bold"
    static let PlayfairDisplayBold: String = "PlayfairDisplay-Bold"
    
}

extension UIColor {
  enum AppTheme {
    static let MainBackground = UIColor(named: "main_bg_color")!
    static let CardBackground = UIColor(named: "card_bg_color")!
    static let PlaceholderColor = UIColor(named: "placeholder_color")!
    static let TextColor = UIColor(named: "text_color")!
    static let TextReverseColor = UIColor(named: "text_color_reverse")!
    static let TextGrayColor = UIColor(named: "text_gray_color")!
    static let PinkColor = UIColor(named: "pink_color")!
    static let LightPinkColor = UIColor(named: "light_pink_color")!
    static let LightBlueColor = UIColor(named: "light_blue_color")!
    static let LightGreenColor = UIColor(named: "light_green_color")!
    static let ShadowColor = UIColor(named: "shadow_color")!
    static let SideMenuLineViewColor = UIColor(named: "side_menu_lineView")!
    static let PostNextButtonBgColor = UIColor(named: "post_next_button_bg_color")!
    static let PostNextButtonTitleColor = UIColor(named: "post_next_button_title_color")!
    static let PostNextButtonSelectTitleColor = UIColor(named: "post_next_button_select_title_color")!
        
  }
}
