//
//  NotificationData.swift
//  MyZone
//

import Foundation


struct NotificationData: CreatableFromJSON { // TODO: Rename this struct
    
    enum NotificationType: String {
        case comment = "Comment"
        case like = "like"
        case disLike = "dislike"
        case commentLike = "commentlike"
        case commentDislike = "commentDislike"
        case replyDislike = "replydislike"
        case replyLike = "replylike"
        case profileComment = "profileComment";
        case newPost = "newPost"
    }
    
    enum ActionType: String {
        case post = "Post"
        case profile = "Profile"
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
        let data = Data.createRequiredInstances(from: json, arrayKey: "data") ?? [Data.init(json: [:])!]
        let message = json["message"] as? String ?? ""
        let status = json["status"] as? Int ?? 0
        let total = json["total"] as? Int ?? 0
        self.init(data: data, message: message, status: status, total: total)
    }
    struct Data: CreatableFromJSON { // TODO: Rename this struct
        let clickAction: ActionType
        let commentId: String?
        let createdAt: String
        let id: String
        let postId: String
        let postedBy: PostedBy
        let text: String?
        let time: String?
        let type: NotificationType
        let updatedAt: String
        let userId: String
        let v: Int
        init(clickAction: ActionType, commentId: String?, createdAt: String, id: String, postId: String, postedBy: PostedBy, text: String?, time: String?, type: NotificationType, updatedAt: String, userId: String, v: Int) {
            self.clickAction = clickAction
            self.commentId = commentId
            self.createdAt = createdAt
            self.id = id
            self.postId = postId
            self.postedBy = postedBy
            self.text = text
            self.time = time
            self.type = type
            self.updatedAt = updatedAt
            self.userId = userId
            self.v = v
        }
        init?(json: [String: Any]) {
            let clickAction =  ActionType(rawValue: json["clickAction"] as? String ?? "") ?? ActionType(rawValue: "post")
            let createdAt = json["createdAt"] as? String ?? ""
            let id = json["_id"] as? String ?? ""
            let postId = json["postId"] as? String ?? ""
            let postedBy = PostedBy(json: json, key: "postedBy") ?? PostedBy.init(json: [:])!
            let type = NotificationType(rawValue: json["type"] as? String ?? "") ?? NotificationType(rawValue: "like")
            let updatedAt = json["updatedAt"] as? String ?? ""
            let userId = json["userId"] as? String ?? ""
            let v = json["__v"] as? Int ?? 0
            let commentId = json["commentId"] as? String
            let text = json["text"] as? String
            let time = json["time"] as? String
            self.init(clickAction: clickAction!, commentId: commentId, createdAt: createdAt, id: id, postId: postId, postedBy: postedBy, text: text, time: time, type: type!, updatedAt: updatedAt, userId: userId, v: v)
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
    }
}
