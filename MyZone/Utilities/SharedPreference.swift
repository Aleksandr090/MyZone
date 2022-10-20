//
//  SharedPreference.swift
//


import UIKit

class SharedPreference {
    
    static let sharedInstance = SharedPreference()

    let encoder = JSONEncoder()
    let defaults = UserDefaults.standard


    class func saveUserData(_ user: UserLogin) {
        sharedInstance.saveUserData(user)
    }

    fileprivate func saveUserData(_ user: UserLogin) {
        if let encoded = try? encoder.encode(user) {
            defaults.set(encoded, forKey: "SavedPerson")
        }
    }
    
    
    class func getUserData() -> UserLogin? {
        return sharedInstance.getUserData()
    }

    fileprivate func getUserData() -> UserLogin? {
        if let savedPerson = defaults.object(forKey: "SavedPerson") as? Data {
            let decoder = JSONDecoder()
            if let loadedPerson = try? decoder.decode(UserLogin.self, from: savedPerson) {
                print(loadedPerson)
                return loadedPerson
            }
        }
        return nil
    }
    
    class func clearUserData(){
        sharedInstance.clearUserData()
    }

    fileprivate func clearUserData(){
        defaults.removeObject(forKey: "SavedPerson")
    }
    
    class var isUserLogin: Bool {
        return SharedPreference.getUserData() != nil
    }
}

//class SharedPreference: NSObject {
//    fileprivate let kUserID = "__u_id"
//    fileprivate let kPhone = "__phone"
//    fileprivate let kemail = "__email"
//    fileprivate let kusername = "__username"
//
//    fileprivate let kUserEmail = "__u_email"
//    fileprivate let kUserPassword = "__u_password"
//    fileprivate let kProfileImage = "__u_profile_img"
//    fileprivate let kTokenType = "__token_type"
//    fileprivate let kdob = "__u_dob"
//    fileprivate let kIsVerified = "__u_is_verifide"
//    fileprivate let kFacebookId = "__u_facebook_id"
//    fileprivate let kGoogleId = "__u_google_id"
//    fileprivate let kImageUrl = "__u_image_url"
//    fileprivate let kLocation = "__u_location"
//    fileprivate let kProvider = "__provider"
//    fileprivate let kName = "__u_name"
//    fileprivate let kGender = "__u_gender"
//
//    fileprivate let kAuthKey = "__u_auth_key"
//    fileprivate let kUserMobile = "__u_mobile"
//    fileprivate let kDeviceToken = "__k_device_token_name";
//    fileprivate let kBadgeNumber = "__k_badge_number";
//    fileprivate let kUDID = "__k_device_UDID";
//    fileprivate let kAPP_OPENED_COUNT = "__k_APP_OPENED_COUNT";
//    fileprivate let kCurrentLocationLat = "__u_k_current_lat"
//    fileprivate let kCurrentLocationLong = "__u_k_current_long"
//    fileprivate let kNotificationStatus = "__u_k_notification_status"
//    fileprivate let defaults = UserDefaults.standard
//    static let sharedInstance = SharedPreference()
//
//    class func saveUserData(_ user: UserLogin)
//    {
//        sharedInstance.saveUserData(user)
//    }
//
//    fileprivate func saveUserData(_ user: UserLogin)
//    {
//        defaults.setValue(user.id , forKey: kUserID)
//        defaults.setValue(user.email, forKey: kemail)
//        defaults.setValue(user.displayName, forKey: kusername)
//        defaults.setValue(user.profileImg, forKey: kProfileImage)
//        defaults.setValue(user.contactNo, forKey: kPhone)
//        defaults.setValue(user.location, forKey: kLocation)
//    }
//
//    class func clearUserData(){
//        sharedInstance.clearUserData()
//    }
//
//    fileprivate func clearUserData(){
//        self.saveUserData(UserLogin())
//
//    }
//
//    class func getUserData() -> UserLogin{
//        return sharedInstance.getUserData()
//    }
//
//    fileprivate  func getUserData() -> UserLogin {
//        let user: UserLogin =  UserLogin()
//        user.id =  (defaults.value(forKey: kUserID)  as? String) ?? ""
//        user.email =  (defaults.value(forKey: kemail) as? String) ?? ""
//        user.displayName = (defaults.value(forKey: kusername) as? String) ?? ""
//        user.avatarImage = (defaults.value(forKey: kProfileImage) as? String) ?? ""
//        user.gender = (defaults.value(forKey: kGender) as? String) ?? ""
//        user.phone = (defaults.value(forKey: kPhone) as? String) ?? ""
//        user.fullName = (defaults.value(forKey: kName) as? String) ?? ""
//        user.tokenType = (defaults.value(forKey: kTokenType) as? String) ?? ""
//        user.provider = (defaults.value(forKey: kProvider) as? String) ?? ""
//        user.dateOfBirth = (defaults.value(forKey: kdob) as? String) ?? ""
//
//
//        user.name              =  (defaults.value(forKey: kName) as? String) ?? ""
//        user.profileImageUrl     =  (defaults.value(forKey: kProfileImage) as? String) ?? ""
////        user.deviceToken              =  (defaults.value(forKey: kDeviceToken) as? String) ?? ""
//        user.isVerified      =  (defaults.value(forKey: kIsVerified) as? Bool) ?? false
//        user.facebookId      =  (defaults.value(forKey: kFacebookId) as? String) ?? ""
//        user.googleId       =  (defaults.value(forKey: kGoogleId) as? String) ?? ""
//        user.imageUrl     =  (defaults.value(forKey: kImageUrl) as? String) ?? ""
//        user.location     =  (defaults.value(forKey: kLocation) as? String) ?? ""
//        user.gender     =  (defaults.value(forKey: kGender) as? String) ?? ""
//        user.totalWorkouts     =  (defaults.value(forKey: kTotalWorkouts) as? String) ?? ""
//        user.todaysWorkouts     =  (defaults.value(forKey: kTodaysWorkout) as? String) ?? ""
//        user.totalPoints     =  (defaults.value(forKey: kTotalPoints) as? String) ?? ""
//        user.todaysPoints     =  (defaults.value(forKey: kTodaysPoints) as? String) ?? ""
//        user.notifications      =  (defaults.value(forKey: kNotifications) as? Bool) ?? false
//
//        return user
//    }
//
//
//    func setCurrentLocation(_ lat: String, long: String){
//        defaults.set(lat, forKey: kCurrentLocationLat)
//        defaults.set(long, forKey: kCurrentLocationLong)
//        defaults.synchronize()
//    }
//
//    func currentLocation() -> (lat: String, long: String) {
//        return (defaults.string(forKey: kCurrentLocationLat)!,defaults.string(forKey: kCurrentLocationLong)!)
//
//    }
//
//
//    // device token
//
//    class func storeDeviceToken(_ token: String) {
//        sharedInstance.setDeviceToken(token)
//    }
//    class func deviceToken() -> String {
//        return sharedInstance.getDeviceToken() ?? "123456"
//    }
//    fileprivate func setDeviceToken(_ token: String){
//        defaults.set(token, forKey: kDeviceToken);
//    }
//
//    fileprivate func getDeviceToken() -> String?{
//        return defaults.value(forKey: kDeviceToken) as? String;
//    }
//
//
//
//
//    // notification Enable Disable
//
//    class func setNotificationState(_ isEnable: Bool) {
//        sharedInstance.setNotificationState(isEnable)
//    }
//    class func notificationState() -> Bool {
//        return sharedInstance.getNotificationState() ?? false
//    }
//    fileprivate func setNotificationState(_ isEnable: Bool){
//        defaults.set(isEnable, forKey: kNotifications);
//    }
//
//    fileprivate func getNotificationState() -> Bool?{
//        return defaults.value(forKey: kNotifications) as? Bool;
//    }
//
//
//
//    // Remeber Email and password
//
//    class func storeEmailAndPassword(_ email: String , password : String) {
//        sharedInstance.setEmailAndPassword(email, password: password)
//    }
//    class func EmailAndPassword() -> ( email: String , password : String) {
//        return sharedInstance.getEmailAndPassword()
//    }
//    fileprivate func setEmailAndPassword(_ email: String , password : String){
//        defaults.set(email, forKey: kUserEmail);
//        defaults.set(password, forKey: kUserPassword);
//    }
//
//    fileprivate func getEmailAndPassword() -> ( email: String , password : String){
//        return ( defaults.value(forKey: kUserEmail) as? String ?? "" ,defaults.value(forKey: kUserPassword) as? String ?? "")
//    }
//
//
//
//
//    // badge number
//
//    class func storeBadgeNumber(_ number: Int) {
//        sharedInstance.setBadgeNumber(number)
//    }
//    class func BadgeNumber() -> Int {
//        return sharedInstance.getBadgeNumber() ?? 0
//    }
//    fileprivate func setBadgeNumber(_ number: Int){
//        defaults.set(number, forKey: kBadgeNumber);
//    }
//
//    fileprivate func getBadgeNumber() -> Int?{
//        return defaults.value(forKey: kBadgeNumber) as? Int;
//    }
//
//
//
//    // IsSocialLogin
//
//    class func storeAuthToken(_ authToken: String) {
//        sharedInstance.setAuthToken(authToken)
//    }
//    class func authToken() -> String {
//        return sharedInstance.getAuthToken() ?? ""
//    }
//    fileprivate func setAuthToken(_ authToken: String){
//        defaults.set(authToken, forKey: kAuthKey);
//    }
//
//    fileprivate func getAuthToken() -> String?{
//        return defaults.value(forKey: kAuthKey) as? String;
//    }
//
//
//
//    // udid
//
//
//    class func storeUDID(_ token: String) {
//        sharedInstance.setUDID(token)
//    }
//    class func UDID() -> String {
//        return sharedInstance.getUDID() ?? "123456789"
//    }
//    fileprivate func setUDID(_ token: String){
//        defaults.set(token, forKey: kUDID);
//    }
//
//    fileprivate func getUDID() -> String?{
//        return defaults.value(forKey: kUDID) as? String;
//    }
//
//
//    // notification status
//
//    class func storeNotificationStatus(_ status: Bool) {
//        sharedInstance.setNotificationStatus(status)
//    }
//    class func notificationStatus() -> Bool? {
//        guard let bool = sharedInstance.getNotificationStatus() else { return nil }
//        return bool
//    }
//    fileprivate func setNotificationStatus(_ status: Bool){
//        defaults.set(status, forKey: kNotificationStatus)
//    }
//
//    fileprivate func getNotificationStatus() -> Bool?{
//        return defaults.value(forKey: kNotificationStatus) as? Bool
//    }
//
//    class func clearNotificationStatus(){
//        sharedInstance.clearUserData()
//    }
//
//    fileprivate func clearNotificationStatus(){
//        UserDefaults.standard.removeObject(forKey: kNotificationStatus)
//
//    }
//
//
//
//    // udid
//    class func storeappOpenCount(_ count: Int) {
//        sharedInstance.setappOpenCount(count)
//    }
//    class func appOpenCount() -> Int {
//        return sharedInstance.getappOpenCount() ?? 0
//    }
//    fileprivate func setappOpenCount(_ count: Int){
//        defaults.set(count, forKey: kAPP_OPENED_COUNT);
//    }
//
//    fileprivate func getappOpenCount() -> Int?{
//        return defaults.value(forKey: kAPP_OPENED_COUNT) as? Int;
//    }
//
//
//}
