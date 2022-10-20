//
//  Services.swift
//

import Foundation
import Moya
import Alamofire
import SwiftUI
import MMPlayerView

private func JSONResponseDataFormatter(_ data: Data) -> String {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData = try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return String(data: prettyData, encoding: .utf8) ?? String(data: data, encoding: .utf8) ?? ""
    } catch {
        return String(data: data, encoding: .utf8) ?? ""
    }
}

private extension String {
    var urlEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}

let ServicesProvider = MoyaProvider<Services>(plugins: [NetworkLoggerPlugin(configuration: .init(formatter: .init(responseData: JSONResponseDataFormatter),
                                                                                                 logOptions: .verbose))])


enum Services {
    case login(param: JSONDictionary)
    case signup(param: JSONDictionary)
    case forgotPassword(email: String)
    case homePosts(param: JSONDictionary, limit: Int, page: Int)
    case searchPosts(param: JSONDictionary, limit: Int, page: Int, loginUserId: String)
    case bookmarkedPosts(param: JSONDictionary, limit: Int, page: Int, loginUserId: String)
    case likePost(param: JSONDictionary, loginUserId: String)
    case dislikePost(param: JSONDictionary, loginUserId: String)
    case reportPost(param: JSONDictionary, loginUserId: String)
    case bookmarkPost(param: JSONDictionary, loginUserId: String)
    case deletePost(postId: String, loginUserId: String)
    case postDeatil(param: JSONDictionary, postId: String)
    case notificationList(userId: String)
    case myCommentList(userId: String)
    case changePassword(param: JSONDictionary,userId:String)
    case editUserProfile(param:JSONDictionary, userId:String)
    case deleteUserAccount(userId: String)
    case enableViwingProfile(param:JSONDictionary, userId: String)
    case commentPost(param:JSONDictionary, userId: String)
    case recentPosts(param: JSONDictionary)
    case addPost(param: [String : Any], images: [Data], userId: String)
    case editPost(param: [String : Any], images: [Data], userId: String)
    case addPostVideo(media: [Data], userId: String, postId: String)
    case addPostAudio(media: [Data], userId: String, postId: String)
    case sendNotification(param:JSONDictionary, userId: String)
    
    case homeMainBanner
    case movieBanner
    case eventBanner
    case recommendedMovies
    case recommendedEvents
    case recommendedVideo
    case moviesGenreList
    case eventsGenreList
    case movieDetail(id: String, type: String)
    case eventDetail(id: String, type: String)
    case faqData
    case moviesList
    case avatarList
    case userProfile
    case updateProfile(param: JSONDictionary)
    case genreData(type: String)
    case selectedGenreData
    case addGenre(param: JSONDictionary)
    case addFavourites(type: String, itemId: String)
    case getFavourites(type: String)
    case searchMovieEvent(type: String, searchText: String)
    case addChoice(param: JSONDictionary)
    case socialLogin(name: String, email: String, deviceType : String, devicetToken : String , facebookId : String, googleId : String, imageUrl : String)
    case getUser(email : String)
    case coverPicture (param : [String : Any]  , coverImage : Data)
    case profilePicture (param : [String : Any]  , coverImage : Data)
    case getCategories
    case getPacDetail(pacId : Int  , categoryId : Int)
    case getSearchedPacs(searchText : String)
    case createWorkoutSchedule(pacId : Int  , scheduleDateTime : String)
    case getWorkoutScheduleList
    case deleteWorkoutSchedule(id: Int)
    case updateWorkoutSchedule(id: Int,pacId : Int  , scheduleDateTime : String)
    case getStaticVideo(videoTitle: String)
    case getEquipments(pacId: Int)
    case buildWorkout (trainingLevel : String, trainingTime : Int, hasWarmup : Bool, hasCooldown : Bool, hasBreathing: Bool,  isTimer : Bool,pacId: Int, equipments : [Int])
    case workoutHistory
    case weekSummary(startDate : String, endDate : String)
    case monthSummary( startDate : String, endDate : String)
    case finishWorkout(workoutId : Int , pointsEarned : Int , workoutTime : Int)
    case setNotification(notifications : Bool)
    case allSubTopicList(language: String, userId: String)
    case topicList(language: String)
    case subTopicList(language: String, userId: String, topicId: String)
    case saveInterest(param: JSONDictionary, userId: String)
    case commentNotify(param: JSONDictionary, userId: String)
    case replyNotify(param: JSONDictionary, userId: String)
    case likeNotify(param: JSONDictionary, userId: String)
    case messageNotify(param: JSONDictionary, userId: String)
    case publicNotify(param: JSONDictionary, userId: String)
    case logout
    
    
}
extension Services: TargetType {
    
    var headers: [String : String]? {
        switch self {
        default:
//            print(SharedPreference.authToken())
            return ["Authorization": "Bearer \(SharedPreference.getUserData()?.token ?? "")"]
//            return nil"
        }
    }
    
    var baseURL : URL {
        switch self {
        //        case .getUserProfileImage, .uploadImage( _, _, _):
        //         return URL(string: Constants.API.imageBaseURL)!
        default:
            return URL(string: Constants.API.baseURL)!
        }
    }
    
    var path: String {
        switch self {
        case .login:
            return "user/login"
        case .signup:
            return "user/register"
        case .forgotPassword:
            return "user/forget_password"
        case .homePosts(_, _, _):
            return "user/recent_post"
        case .recentPosts:
            return "user/recent_post"
        case .searchPosts(_, _, _, let loginUserId):
            return "user/search_post_topic/\(loginUserId)"
        case .bookmarkedPosts(_, _, _, let loginUserId):
            return "user/bookmarked_postlist/\(loginUserId)"
        case .likePost(_ ,let loginUserId):
            return "user/like/\(loginUserId)"
        case .dislikePost(_ ,let loginUserId):
            return "user/dislike/\(loginUserId)"
        case .reportPost(_ ,let loginUserId):
            return "user/post_inappropriate_flag_status/\(loginUserId)"
        case .bookmarkPost(_ ,let loginUserId):
            return "user/add_bookmark/\(loginUserId)"
        case .postDeatil(_ ,let postId):
            return "user/post_detail/\(postId)"
        case .notificationList(let userId):
            return "user/notification_list/\(userId)"
        case .myCommentList(let userId):
            return "user/my_comment/\(userId)"
        case .changePassword(_, let userId):
            return "user/change_password/\(userId)"
        case .editUserProfile(_, let userId):
            return "user/edit_user/\(userId)"
        case .deleteUserAccount(let userId):
            return "user/remove_user/\(userId)"
        case .deletePost(let postId, let userId):
            return "user/remove_post/\(userId)/\(postId)"
        case .enableViwingProfile(_, let userId):
            return "user/enable_view_profile/\(userId)"
            
        case .commentPost(_, let userId):
            return "user/do_reply/\(userId)"
        case .topicList( _):
            return "user/post_topic_list"
        case .allSubTopicList(_, let userId):
            return "user/All_SubTopic_list/\(userId)"
        case .subTopicList(_, let userId, let topicId):
            return "user/post_subTopic_list/\(userId)/\(topicId)"
        case .addPost(_,_, let userId):
            return "user/add_post/\(userId)"
        case .editPost(_,_, let userId):
            return "user/edit_post/\(userId)"
        case .addPostVideo(_, let userId, let postId) :
            return "user/add_post_video/\(userId)/\(postId)"
        case .addPostAudio(_, let userId, let postId):
            return "user/add_post_audio/\(userId)/\(postId)"
        case .saveInterest(_, let userId):
            return "user/myIntrests/\(userId)"
        //----------------------------------------
            
        case .homeMainBanner:
            return "api/sort/featuredBanner"
        case .movieBanner:
            return "api/sort/mainBanner/movie"
        case .eventBanner:
            return "api/sort/mainBanner/event"
        case .recommendedMovies:
            return "api/sort/recommendedList/movie"
        case .recommendedEvents:
            return "api/sort/recommendedList/event"
        case .recommendedVideo:
            return "api/sort/list/movie"
        case .moviesGenreList:
            return "api/sort/genreList/movie"
        case .eventsGenreList:
            return "api/sort/genreList/event"
        case .movieDetail(let id, let type):
            return "api/sort/details/\(type)/\(id)"
        case .eventDetail(let id, let type):
            return "api/sort/details/\(type)/\(id)"
        case .faqData:
            return "static/faq"
        case .moviesList:
            return "api/sort/list/movie"
        case .avatarList:
            return "static/profileAvatar"
        case .userProfile:
            return "api/sort/getProfileByEmail"
        case .updateProfile:
            return "api/sort/updateProfile"
        case .genreData(let type):
            return "api/sort/fetchGenreData/\(type)"
        case .selectedGenreData:
            return "api/sort/getPreferences"
        case .addGenre:
            return "api/sort/addPreferences"
        case .addFavourites(let type, let itemId):
            return "api/sort/addFavourites/\(type)/\(itemId)"
        case .getFavourites(let type):
            return "api/sort/getFavourites/\(type)"
        case .searchMovieEvent(let type, let searchText):
            return "api/sort/search/\(type)/\(searchText)"
        case .addChoice:
            return "api/sort/addChoice"
            
        case .socialLogin:
            return "social-login"
            
        case .getUser(let email):
            return "user?email=\(email)"
        case .coverPicture:
            return "users/cover-picture"
        case .profilePicture:
            return "users/profile-picture"
        case .getCategories:
            return "categories"
        case .getPacDetail(let pacId,let categoryId):
            return "pacs/details?pacId=\(pacId)&categoryId=\(categoryId)"
        case .getSearchedPacs(let searchText):
            return "pacs/search?filter=\(searchText)"
        case .createWorkoutSchedule(_, _), .getWorkoutScheduleList, .updateWorkoutSchedule:
            return "schedule-workouts"
        case .deleteWorkoutSchedule(let id):
            return "schedule-workouts?scheduleId=\(id)"
        case.getStaticVideo(let videoTitle):
            return "get-static-video?videoTitle=\(videoTitle)"
        case .getEquipments(let pacId):
            return "pacs/equipments?pacId=\(pacId)"
        case .buildWorkout :
            return "build-workout"
        case .workoutHistory:
            return "workout-history"
        case .weekSummary(let startDate, let endDate):
            return "week-summary?start_date=\(startDate)&end_date=\(endDate)"
        case .monthSummary(let startDate, let endDate):
            return "month-summary?start_date=\(startDate)&end_date=\(endDate)"
        case .finishWorkout(let workoutId, _ , _):
            return "finish-workout?workoutId=\(workoutId)"
        case .setNotification:
            return "user/notification"
        case .sendNotification(_, let userId):
            return "user/messageNotification/\(userId)"
        case .commentNotify(_, let userId):
            return "user/commentNotify/\(userId)"
        case .replyNotify(_, let userId):
            return "user/replyNotify/\(userId)"
        case .likeNotify(_, let userId):
            return "user/likeNotify/\(userId)"
        case .messageNotify(_, let userId):
            return "user/messaageNotify/\(userId)"
        case .publicNotify(_, let userId):
            return "user/publicNotification/\(userId)"
        case .logout:
            return "logout"
        }
    }
    public var method: Moya.Method {
        switch self {
        case .login, .signup,.updateProfile, .socialLogin, .forgotPassword, .coverPicture, .profilePicture, .changePassword, .createWorkoutSchedule, .buildWorkout, .finishWorkout, .setNotification, .addGenre, .addChoice, .homePosts, .recentPosts, .searchPosts, .bookmarkedPosts, .postDeatil, .addPost, .sendNotification:
            return .post
        case .homeMainBanner, .movieBanner, .eventBanner, .recommendedMovies, .recommendedEvents, .addFavourites, .moviesGenreList,  .eventsGenreList, .recommendedVideo, .movieDetail, .eventDetail, .moviesList, .avatarList, .userProfile, .genreData, .selectedGenreData, .getFavourites, .searchMovieEvent, .notificationList, .myCommentList,
             
                .getUser, .getCategories, .getPacDetail, .getSearchedPacs, .getWorkoutScheduleList, .getStaticVideo, .getEquipments, .workoutHistory , .weekSummary, .monthSummary, .logout , .faqData, .topicList, .subTopicList, .allSubTopicList:
            return .get
        case .reportPost, .commentPost, .enableViwingProfile, .likePost, .dislikePost, .editUserProfile, .bookmarkPost, .updateWorkoutSchedule, .addPostVideo, .addPostAudio, .saveInterest, .commentNotify, .replyNotify, .likeNotify, .messageNotify, .publicNotify, .editPost:
            return .put
        case .deleteWorkoutSchedule,.deleteUserAccount, .deletePost:
            return .delete
            
        }
    }
    var sampleData: Data {
        return "".data(using: .utf8)!
    }
    
    var task: Task {
        switch self {
        case .login(let param), .recentPosts(let param), .signup(let param),  .likePost(let param, _), .dislikePost(let param, _), .reportPost(let param, _), .bookmarkPost(let param, _), .postDeatil(let param, _), .commentPost(let param, _), .saveInterest(let param, _), .sendNotification(let param, _), .commentNotify(let param, _), .replyNotify(let param, _), .likeNotify(let param, _), .messageNotify(let param, _), .publicNotify(let param, _):
            return .requestParameters(parameters: param, encoding: JSONEncoding.default)
            
        case .homePosts(let param, _, _), .searchPosts(let param, _, _, _), .bookmarkedPosts(let param, _, _, _):
            return .requestCompositeParameters(bodyParameters: param, bodyEncoding: JSONEncoding.default, urlParameters: parameters!)
            
        case .topicList(let language), .subTopicList(let language, _, _), .allSubTopicList(let language, _):
            return .requestParameters(parameters: ["language": language], encoding: URLEncoding.queryString)
            
        case .forgotPassword(let email):
            return .requestParameters(parameters: ["email": email], encoding: JSONEncoding.default)

        case .socialLogin(let name, let email,  let deviceType, let devicetToken, let facebookId, let googleId, let imageUrl):
            return .requestParameters(parameters: ["name" : name, "email":email, "deviceType": deviceType, "devicetToken": devicetToken ,"facebookId" : facebookId , "googleId" : googleId, "imageUrl" : imageUrl ], encoding: JSONEncoding.default)
            
        case .coverPicture(let param ,let coverPicture), .profilePicture(let param ,let coverPicture):
            var multipartFormData = [Moya.MultipartFormData]()
            multipartFormData.append(MultipartFormData(provider: .data(coverPicture), name: "file", fileName: "file.jpeg", mimeType: "image/jpeg"))
            for (key, value) in param {
                multipartFormData.append(Moya.MultipartFormData(provider: .data((value as AnyObject).data(using: String.Encoding.utf8.rawValue) ?? Data()) , name : key))
            }
            return .uploadMultipart(multipartFormData)
        
        case .addPost(let param, let images, _), .editPost(let param, let images, _):
            var multipartFormData = [Moya.MultipartFormData]()
            for i in 0..<images.count {
                multipartFormData.append(MultipartFormData(provider: .data(images[i]), name: "image", fileName: "postImage_\(i).jpg", mimeType: "image/jpg"))
            }
            for (key, value) in param {
                multipartFormData.append(MultipartFormData(provider: .data("\(value)".data(using: .utf8)!), name: key))
            }
            return .uploadMultipart(multipartFormData)
            
        case .addPostVideo(let media, _,_):
            var multipartFormData = [Moya.MultipartFormData]()
            for i in 0..<media.count {
                multipartFormData.append(MultipartFormData(provider: .data(media[i]), name: "video", fileName: "video.mp4", mimeType: "video/mp4"))
            }
            
            return .uploadMultipart(multipartFormData)
            
        case .addPostAudio(let media, _,_):
            var multipartFormData = [Moya.MultipartFormData]()
            for i in 0..<media.count {
                multipartFormData.append(MultipartFormData(provider: .data(media[i]), name: "audio", fileName: "audio.m4a", mimeType: "audio/m4a"))
            }
            
            return .uploadMultipart(multipartFormData)
            
        case .addGenre(let param), .addChoice(let param):
            return .requestParameters(parameters: param, encoding: JSONEncoding.default)
            
        case  .enableViwingProfile, .deleteUserAccount,.homeMainBanner, .movieBanner , .eventBanner, .recommendedMovies, .recommendedEvents, .recommendedVideo, .moviesGenreList, .eventsGenreList, .movieDetail, .eventDetail, .moviesList, .avatarList, .userProfile, .genreData, .selectedGenreData, .addFavourites, .getFavourites, .searchMovieEvent, .notificationList,.myCommentList, .getUser, .getCategories, .getPacDetail, .getSearchedPacs, .getWorkoutScheduleList, .deleteWorkoutSchedule, .getStaticVideo, .getEquipments, .workoutHistory, .weekSummary, .monthSummary, .logout, .faqData, .deletePost:
            return .requestPlain
            
        case .updateProfile(let param):
            return .requestParameters(parameters: param, encoding: JSONEncoding.default)
            
        case .changePassword(let param, _):
            return .requestParameters(parameters: param, encoding: JSONEncoding.default)
            
        case .editUserProfile(let param, _):
            return .requestParameters(parameters: param, encoding: JSONEncoding.default)

        case .createWorkoutSchedule(let pacId,let scheduleDateTime):
            return .requestParameters(parameters: ["pacId" : pacId, "scheduleDateTime":scheduleDateTime], encoding: JSONEncoding.default)
            
        case .updateWorkoutSchedule(let id,let pacId,let scheduleDateTime):
            return .requestParameters(parameters: ["id" : id,"pacId": pacId, "scheduleDateTime":scheduleDateTime], encoding: JSONEncoding.default)
        case .buildWorkout(let trainingLevel, let trainingTime, let hasWarmup, let hasCooldown, let hasBreathing, let isTimer, let pacId, let equipments):
            return .requestParameters(parameters: ["trainingLevel" : trainingLevel, "trainingTime":trainingTime, "hasWarmup":hasWarmup, "hasCooldown":hasCooldown, "hasBreathing":hasBreathing, "isTimer":isTimer, "pacId": pacId, "equipments" : equipments], encoding: JSONEncoding.default)
        case .finishWorkout(_ ,let pointsEarned, let workoutTime):
            return .requestParameters(parameters: ["pointsEarned" : pointsEarned, "workoutTime" : workoutTime], encoding: JSONEncoding.default)
        case .setNotification(let notifications):
            return .requestParameters(parameters: ["notifications":notifications], encoding: JSONEncoding.default)
        }
    }
    
    func dicToStrig(data : AnyObject) -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            let jsonString = String(data: jsonData, encoding: String.Encoding.ascii)!
            return  jsonString
            
        } catch {
            //handle error
            print(error)
        }
        return ""
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
        
        default:
            return JSONEncoding.default
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .homePosts(_, let limit, let pageCount), .searchPosts(_, let limit, let pageCount, _), .bookmarkedPosts(_, let limit, let pageCount, _):
            return ["limit": limit, "page": pageCount]
        default : break
        }
        return nil
    }
}

struct JsonArrayEncoding: Moya.ParameterEncoding {
    
    public static var `default`: JsonArrayEncoding { return JsonArrayEncoding() }
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var req = try urlRequest.asURLRequest()
        let json = try JSONSerialization.data(withJSONObject: parameters!["jsonArray"]!, options: JSONSerialization.WritingOptions.prettyPrinted)
        req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        req.httpBody = json
        return req
    }
    
}


