//
//  PostData.swift
//  Jeeran
//

import Foundation
import CoreLocation

struct PostData: CreatableFromJSON { // TODO: Rename this struct
    
    enum PostType: String {
        case Advertisement = "Advertisement"
        case Announcement = "Announcement"
        case Conversation = "Conversation"
        case Invitation = "Invitation"
        case LostAndFound = "Lost and Found"
        case News = "News"
        case Offers = "Offers"
        case Request = "Request"
        case Warning = "Warning"
    }
    
    let data: [Data]
    let message: String
    let status: Int
    let total: Int
    init(data: [Data], message: String, status: Int, total: Int) {
        self.data = data
        self.message = message
        self.status = status
        self.total = total
    }
    init?(json: [String: Any]) {
        let data = Data.createRequiredInstances(from: json, arrayKey: "data")  ?? [Data.init(json: [:])!]
        let message = json["message"] as? String ?? ""
        let status = json["status"] as? Int ?? 0
        let total = json["total"] as? Int ?? 0
        self.init(data: data, message: message, status: status, total: total)
    }
    struct Data: CreatableFromJSON { // TODO: Rename this struct
        let audio: [Audio]
        let bookmarkStatus: Bool
        var bookmarkedBy: [String]?
        let city: String
        var comment: [Comment]
        let contactNo: String
        let country: String
        let createdAt: String
        let date: String
        var dislikedBy: [String]
        let flagCount: [String]
        let id: String
        let image: [Image]
        let inappropriateFlagStatus: Bool
        var likedBy: [String]
        let location: Location
        let neighborehood: String
        let placeName: String
        let postDescription: String
        let postTitle: String
        let postType: [String]
        let postedBy: PostedBy
        let radius: String
        let subSubject: String
        let postDate: String
        let postTime: String
        let time: String
        let updatedAt: String
        let v: Int
        let topicId: TopicData.Data
        let video: [Video]
        init(audio: [Audio], bookmarkStatus: Bool, bookmarkedBy: [String]?, city: String, comment: [Comment], contactNo: String, country: String, createdAt: String, date: String, dislikedBy: [String], flagCount: [String], id: String, image: [Image], inappropriateFlagStatus: Bool, likedBy: [String], location: Location, neighborehood: String, placeName: String, postDescription: String, postTitle: String, postType: [String], postedBy: PostedBy, radius: String, subSubject: String, time: String, postDate:String, postTime: String, updatedAt: String, v: Int, video: [Video], topic: TopicData.Data) {
            self.audio = audio
            self.bookmarkStatus = bookmarkStatus
            self.bookmarkedBy = bookmarkedBy
            self.city = city
            self.comment = comment
            self.contactNo = contactNo
            self.country = country
            self.createdAt = createdAt
            self.date = date
            self.dislikedBy = dislikedBy
            self.flagCount = flagCount
            self.id = id
            self.image = image
            self.inappropriateFlagStatus = inappropriateFlagStatus
            self.likedBy = likedBy
            self.location = location
            self.neighborehood = neighborehood
            self.placeName = placeName
            self.postDescription = postDescription
            self.postTitle = postTitle
            self.postType = postType
            self.postedBy = postedBy
            self.radius = radius
            self.subSubject = subSubject
            self.time = time
            self.postDate = postDate
            self.postTime = postTime
            self.updatedAt = updatedAt
            self.v = v
            self.video = video
            self.topicId = topic
        }
        init?(json: [String: Any]) {
            let bookmarkStatus = json["bookmark_status"] as? Bool ?? false
            let city = json["city"] as? String ?? ""
            let comment = Comment.createRequiredInstances(from: json, arrayKey: "comment") ?? [Comment.init(json: [:])!]
            let contactNo = json["contact_no"] as? String ?? ""
            let country = json["country"] as? String ?? ""
            let createdAt = json["createdAt"] as? String ?? ""
            let date = json["date"] as? String ?? ""
            let dislikedBy = json["dislikedBy"] as? [String] ?? []
            let flagCount = json["flag_count"] as? [String] ?? []
            let id = json["_id"] as? String ?? ""
            let image = Image.createRequiredInstances(from: json, arrayKey: "image") ?? [Image.init(json: [:])!]
            let inappropriateFlagStatus = json["inappropriate_flag_status"] as? Bool ?? false
            let likedBy = json["likedBy"] as? [String] ?? []
            let location = Location(json: json, key: "location") ?? Location.init(json: [:])!
            let neighborehood = json["neighborehood"] as? String ?? ""
            let placeName = json["place_name"] as? String ?? ""
            let postDescription = json["post_description"] as? String ?? ""
            let postTitle = json["post_title"] as? String ?? ""
            let postType = json["post_type"] as? [String] ?? []
            let postedBy = PostedBy(json: json, key: "postedBy") ?? PostedBy.init(json: [:])!
            let radius = json["radius"] as? String ?? ""
            let subSubject = json["sub_subject"] as? String ?? ""
            let time = json["time"] as? String ?? ""
            let postDate = json["postDate"] as? String ?? ""
            let postTime = json["postTime"] as? String ?? ""
            let updatedAt = json["updatedAt"] as? String ?? ""
            let v = json["__v"] as? Int ?? 0
            let audio = Audio.createRequiredInstances(from: json, arrayKey: "audio") ?? [Audio.init(json: [:])!]
            let bookmarkedBy = json["bookmarkedBy"] as? [String] ?? []
            let video = Video.createRequiredInstances(from: json, arrayKey: "video") ?? [Video.init(json: [:])!]
            let topicId = TopicData.Data(json: json["topicId"] as? [String : Any] ?? [:]) ?? TopicData.Data.init(json: [:])!
            self.init(audio: audio, bookmarkStatus: bookmarkStatus, bookmarkedBy: bookmarkedBy, city: city, comment: comment, contactNo: contactNo, country: country, createdAt: createdAt, date: date, dislikedBy: dislikedBy, flagCount: flagCount, id: id, image: image, inappropriateFlagStatus: inappropriateFlagStatus, likedBy: likedBy, location: location, neighborehood: neighborehood, placeName: placeName, postDescription: postDescription, postTitle: postTitle, postType: postType, postedBy: postedBy, radius: radius, subSubject: subSubject, time: time, postDate: postDate, postTime: postTime, updatedAt: updatedAt, v: v, video: video, topic: topicId)
        }
        struct Comment: CreatableFromJSON { // TODO: Rename this struct
            let createdAt: String
            let dislikedBy: [String]
            let id: String
            let likedBy: [String]
            let postId: String
            let postedBy: PostedBy
            let replies: [Replies]
            let text: String
            let time: String
            let updatedAt: String
            let v: Int
            var collapsed: Bool
            var isDeleted: Bool
            init(createdAt: String, dislikedBy: [String], id: String, likedBy: [String], postId: String, postedBy: PostedBy, replies: [Replies], text: String, time: String, updatedAt: String, v: Int, collapsed: Bool = true, isDeleted: Bool) {
                self.createdAt = createdAt
                self.dislikedBy = dislikedBy
                self.id = id
                self.likedBy = likedBy
                self.postId = postId
                self.postedBy = postedBy
                self.replies = replies
                self.text = text
                self.time = time
                self.updatedAt = updatedAt
                self.v = v
                self.collapsed = collapsed
                self.isDeleted = isDeleted
            }
            init?(json: [String: Any]) {
                let createdAt = json["createdAt"] as? String ?? ""
                let dislikedBy = json["dislikedBy"] as? [String] ?? []
                let id = json["_id"] as? String ?? ""
                let likedBy = json["likedBy"] as? [String] ?? []
                let postId = json["postId"] as? String ?? ""
                let postedBy = PostedBy(json: json, key: "postedBy") ?? PostedBy.init(json: [:])!
                let replies = Replies.createRequiredInstances(from: json, arrayKey: "Replies") ?? [Replies.init(json: [:])!]
                let text = json["text"] as? String ?? ""
                let time = json["time"] as? String ?? ""
                let updatedAt = json["updatedAt"] as? String ?? ""
                let v = json["__v"] as? Int ?? 0
                let isDeleted = json["isDeleted"] as? Bool ?? false
                self.init(createdAt: createdAt, dislikedBy: dislikedBy, id: id, likedBy: likedBy, postId: postId, postedBy: postedBy, replies: replies, text: text, time: time, updatedAt: updatedAt, v: v, isDeleted: isDeleted)
            }
            struct PostedBy: CreatableFromJSON { // TODO: Rename this struct
                let displayName: String
                let id: String
                let profileImg: String
                let userName: String
                init(displayName: String, id: String, profileImg: String, userName: String) {
                    self.displayName = displayName
                    self.id = id
                    self.profileImg = profileImg
                    self.userName = userName
                }
                init?(json: [String: Any]) {
                    let displayName = json["displayName"] as? String ?? ""
                    let id = json["_id"] as? String ?? ""
                    let profileImg = json["profile_img"] as? String ?? ""
                    let userName = json["user_name"] as? String ?? ""
                    self.init(displayName: displayName, id: id, profileImg: profileImg, userName: userName)
                }
            }
            
            struct Replies: CreatableFromJSON { // TODO: Rename this struct
                let commentId: String
                let createdAt: String
                let dislikedBy: [String]
                let id: String
                let likedBy: [String]
                let postId: String
                let postedBy: PostedBy
                let replyInappropriateFlagStatus: Bool
                let text: String
                let time: String
                let updatedAt: String
                let v: Int
                init(commentId: String, createdAt: String, dislikedBy: [String], id: String, likedBy: [String], postId: String, postedBy: PostedBy, replyInappropriateFlagStatus: Bool, text: String, time: String, updatedAt: String, v: Int) {
                    self.commentId = commentId
                    self.createdAt = createdAt
                    self.dislikedBy = dislikedBy
                    self.id = id
                    self.likedBy = likedBy
                    self.postId = postId
                    self.postedBy = postedBy
                    self.replyInappropriateFlagStatus = replyInappropriateFlagStatus
                    self.text = text
                    self.time = time
                    self.updatedAt = updatedAt
                    self.v = v
                }
                init?(json: [String: Any]) {
                    let commentId = json["commentId"] as? String ?? ""
                    let createdAt = json["createdAt"] as? String ?? ""
                    let dislikedBy = json["dislikedBy"] as? [String] ?? []
                    let id = json["_id"] as? String ?? ""
                    let likedBy = json["likedBy"] as? [String] ?? []
                    let postId = json["postId"] as? String ?? ""
                    let postedBy = PostedBy(json: json, key: "postedBy") ?? PostedBy.init(json: [:])!
                    let replyInappropriateFlagStatus = json["reply_inappropriate_flag_status"] as? Bool ?? false
                    let text = json["text"] as? String ?? ""
                    let time = json["time"] as? String ?? ""
                    let updatedAt = json["updatedAt"] as? String ?? ""
                    let v = json["__v"] as? Int ?? 0
                    self.init(commentId: commentId, createdAt: createdAt, dislikedBy: dislikedBy, id: id, likedBy: likedBy, postId: postId, postedBy: postedBy, replyInappropriateFlagStatus: replyInappropriateFlagStatus, text: text, time: time, updatedAt: updatedAt, v: v)
                }
                var isLiked: Bool? {
                    if let userData = SharedPreference.getUserData() {
                        if self.likedBy.contains(userData.id) {
                            return true
                        } else if self.dislikedBy.contains(userData.id) {
                            return false
                        }
                        return nil
                    }
                    return nil
                }
            }
            
            var isLiked: Bool? {
                if let userData = SharedPreference.getUserData() {
                    if self.likedBy.contains(userData.id) {
                        return true
                    } else if self.dislikedBy.contains(userData.id) {
                        return false
                    }
                    return nil
                }
                return nil
            }
        }
        struct Image: CreatableFromJSON { // TODO: Rename this struct
            let id: String
            let img: String
            init(id: String, img: String) {
                self.id = id
                self.img = img
            }
            init?(json: [String: Any]) {
                let id = json["_id"] as? String ?? ""
                let img = json["img"] as? String ?? ""
                self.init(id: id, img: img)
            }
        }
        struct Location: CreatableFromJSON { // TODO: Rename this struct
            let coordinates: [Double]
            let type: String
            init(coordinates: [Double], type: String) {
                self.coordinates = coordinates
                self.type = type
            }
            init?(json: [String: Any]) {
                let coordinates = (json["coordinates"] as? [NSNumber]).map({ $0.toDoubleArray() }) ?? []
                let type = json["type"] as? String ?? ""
                self.init(coordinates: coordinates, type: type)
            }
        }
        struct PostedBy: CreatableFromJSON { // TODO: Rename this struct
            let displayName: String
            let id: String
            let profileImg: String
            let userName: String
            let rewardId: Reward?
            init(displayName: String, id: String, profileImg: String, userName: String, rewardId: Reward?) {
                self.displayName = displayName
                self.id = id
                self.profileImg = profileImg
                self.userName = userName
                self.rewardId = rewardId
            }
            init?(json: [String: Any]) {
                let displayName = json["displayName"] as? String ?? ""
                let id = json["_id"] as? String ?? ""
                let profileImg = json["profile_img"] as? String ?? ""
                let userName = json["user_name"] as? String ?? ""
                let rewardId = Reward(json: json, key: "rewardId") ?? nil
                self.init(displayName: displayName, id: id, profileImg: profileImg, userName: userName, rewardId: rewardId)
            }
            
            struct Reward: CreatableFromJSON {
                
                let id: String
                let arabicName: String
                let englishName: String
                let rewardImage: String
                init(id: String, englishName: String, arabicName: String, rewardImage: String) {
                    self.id = id
                    self.englishName = englishName
                    self.arabicName = arabicName
                    self.rewardImage = rewardImage
                }
                init?(json: [String : Any]) {
                    let id = json["_id"] as? String ?? ""
                    let englishName = json["rewardEnglishName"] as? String ?? ""
                    let arabicName = json["rewardArabicName"] as? String ?? ""
                    let rewardImage = json["rewardImage"] as? String ?? ""
                    self.init(id: id, englishName: englishName, arabicName: arabicName, rewardImage: rewardImage)
                }
            }
        }
        
        struct Video: CreatableFromJSON { // TODO: Rename this struct
            let id: String
            let videos: String
            init(id: String, videos: String) {
                self.id = id
                self.videos = videos
            }
            init?(json: [String: Any]) {
                let id = json["_id"] as? String ?? ""
                let videos = json["videos"] as? String ?? ""
                self.init(id: id, videos: videos)
            }
        }
        
        struct Audio: CreatableFromJSON { // TODO: Rename this struct
            let id: String
            let audios: String
            init(id: String, audios: String) {
                self.id = id
                self.audios = audios
            }
            init?(json: [String: Any]) {
                let id = json["_id"] as? String ?? ""
                let audios = json["audios"] as? String ?? ""
                self.init(id: id, audios: audios)
            }
        }
        
        func getAllPagerItems() -> [Any] {
            var pagerList = [Any]()
            pagerList = image + video + audio
            return pagerList
        }
        
        var postDistance: String! {
            if let currentLat = ApplicationPreference.sharedManager.read(type: .userLat) as? Double, let currentLng = ApplicationPreference.sharedManager.read(type: .userLong) as? Double {
                
                let currentCoordinate = CLLocation(latitude: currentLat, longitude: currentLng)
                let postCoordinate = CLLocation(latitude: location.coordinates[1], longitude: location.coordinates[0])
                let distanceInMeters = currentCoordinate.distance(from: postCoordinate) // result is in meters
                let distanceInKM = round(distanceInMeters/1000)
                if distanceInKM < 1 {
                    return "Close enough"
                } else {
                    return "\(distanceInKM) KM"
                }
            }
            return ""
        }
        var isLiked: Bool? {
            if let userData = SharedPreference.getUserData() {
                if self.likedBy.contains(userData.id) {
                    return true
                } else if self.dislikedBy.contains(userData.id) {
                    return false
                }
                return nil
            }
            return nil
        }
        
        var isBookmarked: Bool {
            if let userData = SharedPreference.getUserData() {
                if let bookmarkedData = self.bookmarkedBy {
                    return bookmarkedData.contains(userData.id)
                }
                return false
            }
            return false
        }
    }
}
