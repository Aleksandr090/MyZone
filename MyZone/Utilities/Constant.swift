//
//  Constant.swift
//  MyZone
//
//  Created by Apple on 05/03/22.
//

import UIKit

class Constant: NSObject {
    var header = "Bearer \(SharedPreference.getUserData()?.token ?? "")"
    var userId = SharedPreference.getUserData()?.id ?? ""
    
    var UserAPIBaseUrl = SERVER_URL + "/api/user/"
    var ProfileAPIBaseUrl = SERVER_URL + "/api/profile/"
    
    var myCommentUrl = "my_comment/"
    var profileBookmark = "profile_bookmark/"
    var addBookmark = "add_bookmark/"
    var profileDetail = "profile_detail/"
    var bookmarkedUserlist = "bookmarked_userlist/"
    var notifyPostToUser = "notifyPost_to_User/"
    var profileReport = "profile_report/"
    
    var enableViewProfile = "enable_view_profile/"
    var disableBookmarkingProfile = "disable_bookmarking_profile/"
    var enableShareProfile = "enable_share_profile/"
    var enableProfileNotification = "enable_Profile_notification/"
    var enableMessageStatus = "enable_message_status/"
    var editUser = "edit_user/"
    
    
    var comment = "comment/"
    var profileCommentReply = "profile_comment_reply/"
    var profileCommentLike = "profile_comment_like/"
    var profileCommentDisLike = "profile_comment_dislike/"
    
    var postLike = "like/"
    var postDislike = "dislike/"
    var postCommentRemove = "post_comment_remove/"
    var postCommentReply = "do_reply/"
    var postCommentLike = "post_comment_like/"
    var postCommentDislike = "post_comment_dislike/"
    
    var postCommentReplyLike = "post_comment_reply_like/"
    var postCommentReplyDislike = "post_comment_reply_dislike/"
    
    
    
}
