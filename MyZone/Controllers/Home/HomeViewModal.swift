//
//  HomeViewModal.swift
//  MyZone
//

import Foundation

class HomeViewModal {
    
    let pageLimit = 10
    var pageCount = 1
    var radius = "0"
    var lat = "0"
    var lng = "0"
    var postType = "recents"

    var completion:((JSONDictionary?, ServicesError?) ->())?

    var posts = [PostData.Data]()

    var totalRow: Int {
        return posts.count
    }
    
    var isLastContent = false
        
    func getPostBy(pageCount: Int, lastCreatedAt: String, completion:(() -> ())? = nil) {
        
        let param: JSONDictionary = [ "longitude": lng,
                                      "latitude": lat,
                                      "radius": radius,
//                                      "radius": "20000",
                                      "post": postType ]
        APIController.makeRequestReturnJSON(.homePosts(param: param, limit: pageLimit, page: pageCount)) { (data, error,headerDict) in

            if error == nil {
                guard let responseData = data, let jsonArray = responseData["data"] as? [JSONDictionary] else {
                    self.isLastContent = true
                    self.completion?(nil, error)
                    return
                }

                self.isLastContent = jsonArray.isEmpty
                
                if lastCreatedAt.isEmpty  {
                    self.posts = jsonArray.compactMap{ PostData.Data.init(json: $0) }
                } else {
                    self.posts.append(contentsOf: jsonArray.compactMap{ PostData.Data.init(json: $0)})
                }
                self.completion?(responseData, nil)
            } else {
                self.completion?(nil, error)
            }
        }
    }
    
    func getSearchPostBy(pageCount: Int, lastCreatedAt: String, completion:(() -> ())? = nil) {
        
        let userId = SharedPreference.isUserLogin ? SharedPreference.getUserData()!.id : "me"
        let param: JSONDictionary = [ "longitude": lng,
                                      "latitude": lat,
                                      "radius": radius,
//                                      "radius": "20000",
                                      "post_type": postType ]
        APIController.makeRequestReturnJSON(.searchPosts(param: param, limit: pageLimit, page: pageCount, loginUserId: userId)) { (data, error,headerDict) in

            if error == nil {
                guard let responseData = data, let jsonArray = responseData["data"] as? [JSONDictionary] else {
                    self.isLastContent = true
                    self.completion?(nil, error)
                    return
                }

                self.isLastContent = jsonArray.isEmpty
                
                if lastCreatedAt.isEmpty  {
                    self.posts = jsonArray.compactMap{ PostData.Data.init(json: $0) }
                } else {
                    self.posts.append(contentsOf: jsonArray.compactMap{ PostData.Data.init(json: $0)})
                }
                self.completion?(responseData, nil)
            } else {
                self.completion?(nil, error)
            }
        }
    }
    
    func getBookmarkedPostBy(pageCount: Int, lastCreatedAt: String, completion:(() -> ())? = nil) {
        
        let param: JSONDictionary = [:]
        let userId = SharedPreference.isUserLogin ? SharedPreference.getUserData()!.id : "me"
        APIController.makeRequestReturnJSON(.bookmarkedPosts(param: param, limit: pageLimit, page: pageCount, loginUserId: userId)) { (data, error,headerDict) in

            if error == nil {
                guard let responseData = data, let jsonArray = responseData["data"] as? [JSONDictionary] else {
                    self.isLastContent = true
                    self.completion?(nil, error)
                    return
                }

                self.isLastContent = jsonArray.isEmpty
                
                if lastCreatedAt.isEmpty  {
                    self.posts = jsonArray.compactMap{ PostData.Data.init(json: $0) }
                } else {
                    self.posts.append(contentsOf: jsonArray.compactMap{ PostData.Data.init(json: $0)})
                }
                self.completion?(responseData, nil)
            } else {
                self.completion?(nil, error)
            }
        }
    }
    
    func likeDislikePost(isLike: Bool, postIndex: Int , completion:((JSONDictionary?, ServicesError?) ->())?) {
        
        var likeDislikeService : Services
        let param = [ "post_id": posts[postIndex].id,
                      "user_id": posts[postIndex].postedBy.id ]
        let userData = SharedPreference.getUserData()
        if isLike {
            likeDislikeService = .likePost(param: param, loginUserId: userData!.id)
        } else {
            likeDislikeService = .dislikePost(param: param, loginUserId: userData!.id)
        }
        
        APIController.makeRequestReturnJSON(likeDislikeService) { (data, error,headerDict) in
            if error == nil {
                completion!(data, nil)
            } else {
                completion!(nil, error)
            }
        }
    }
    
    func reportPost( status: Bool, postIndex: Int, type: String , completion:((JSONDictionary?, ServicesError?) ->())? ) {
        
        let userData = SharedPreference.getUserData()
        
        let param = ["post_id": posts[postIndex].id,
                     "inappropriate_flag_status": status,
                     "report_content": type] as [String : Any]
        APIController.makeRequestReturnJSON(.reportPost(param: param, loginUserId: userData!.id)) { (data, error,headerDict) in
            if error == nil {
                completion!(data, nil)
            } else {
                completion!(nil, error)
            }
        }
    }
    
    func addFavouritePost( isFavourite: Bool, postIndex: Int , completion:((JSONDictionary?, ServicesError?) ->())? ) {
        
        let userData = SharedPreference.getUserData()
        
        let param = ["post_id": posts[postIndex].id,
                     "bookmark_status": isFavourite] as [String : Any]
        APIController.makeRequestReturnJSON(.bookmarkPost(param: param, loginUserId: userData!.id)) { (data, error,headerDict) in
            if error == nil {
                completion!(data, nil)
            } else {
                completion!(nil, error)
            }
        }
    }
    
    func deletePost(postId: String, completion:((JSONDictionary?, ServicesError?) ->())?) {
        let userData = SharedPreference.getUserData()        
        APIController.makeRequestReturnJSON(.deletePost(postId: postId, loginUserId: userData!.id)) { (data, error, headerDict) in
            if error == nil {
                completion!(data, nil)
            } else {
                completion!(nil, error)
            }
        }
    }
}
