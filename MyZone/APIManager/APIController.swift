
import Moya
//import Result
import Foundation
import GoogleSignIn


typealias JSONDictionary = [String: Any]

// EBabuAPI == Services

enum ResponseCode : Int {
    case Success = 200
    case Nocontent = 204
    case Created = 201
    case AlreadyExist = 400
    case Failed = 422
    case Unauthorised = 401
    case Block_by_admin = 403
    case Unverify_by_admin = 410
    case Invalid = 404
    case Unverify_user = 409
}

class APIController {
    public typealias CompletionHandler = (_ result: Result<Moya.Response, ServicesError>) -> Void
    private class func callService(request: Services, completionHandler: @escaping CompletionHandler) {
      
        ServicesProvider.request(request) { (result) in
            switch result {
            case let .success(response):
//                if response.statusCode == 401
//                {
//                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
//                    MZProgressLoader.hide()
//
//                    return
//                }
                if !Helpers.validateResponse(response.statusCode) {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    guard let json = try? response.mapJSON(), let dict = json as? JSONDictionary else {
                        completionHandler(Result.failure(ServicesError.failure(0,Constants.Texts.errorParsingResponse)))
                        return
                    }
                    let error = ServicesError.init(dict)
                    
                    completionHandler(Result.failure(error))
                    return
                }
                completionHandler(Result.success(response))
            case .failure(_):
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                completionHandler(Result.failure(ServicesError.noConnectivity()))
            }
        }
    }
    
    // not in use
    public class func makeRequest(_ request: Services, completion:@escaping ((Data?, ServicesError?) -> Void)) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let reachability = Reachability()!
        if  reachability.connection != .none {
     
            APIController.callService(request: request) { (result) in
                switch result {
                    
                case .success(let response):
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    completion(response.data, nil)
                case .failure(let error):
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    completion(nil, error)
                }
            }
        }else{
//            MZProgressLoader.hide()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
//            appDelegate.showAlert(strMessage: "Internet Connection not Available!")
        }
    }
    
    public class func makeRequestReturnJSON(_ request: Services, completion:@escaping ((JSONDictionary?, ServicesError?, JSONDictionary?) -> Void)) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let reachability = Reachability()!
        if  reachability.connection != .none {
            APIController.callService(request: request) { (result) in
                DispatchQueue.main.async {
                    print(result)
                    switch result {
                        
                    case .success(let response):
//                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        if response.data.count == 0 {
                            completion(nil, nil, nil)
                            return
                        }
                        guard let json = try? response.mapJSON() as? JSONDictionary else {
                            completion(nil, ServicesError.unknownError(), nil)
                            return
                        }
                        
                        if let validationCode = json["code"] as? Int {
                            validateJason(validationCode, completion: { (bool) in
                                if bool {
                                    if json["success"] as! Bool {
                                        let headerDict = response.response?.allHeaderFields as! JSONDictionary
                                        completion(json,nil,headerDict)
                                    } else {
                                        //                                    completion(nil, ServicesError.failure( json!["code"] as! Int, json!["message"] as! String), nil)
                                        
                                        if let msg = json["message"] as? String {
//                                            appDelegate.showAlert(strMessage: msg, closer: {
//                                                
//                                            })
                                        }
                                    }
                                } else {
                                    if let msg = json["message"] as? String {
                                        
//                                        appDelegate.showAlert(strMessage: msg, closer: {
//
//                                        })
                                    }
                                    completion(nil, ServicesError.failure( validationCode, json["message"] as! String), nil)
                                }
                            })
                        } else {
                            completion(json,nil,nil)
                        }
                        
                    case .failure(let error):
//                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        completion(nil, error, nil)
                    }
                }
            }
        } else {
//            MZProgressLoader.hide()
//            UIApplication.shared.isNetworkActivityIndicatorVisible = false
//            appDelegate.showAlert(strMessage: "Internet Connection not Available!")
        }
    }
    
    
    public class func makeRequestReturnJSONArray(_ request: Services, completion:@escaping (([JSONDictionary]?, ServicesError?, JSONDictionary?) -> Void)) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let reachability = Reachability()!
        if  reachability.connection != .none {
            APIController.callService(request: request) { (result) in
                DispatchQueue.main.async {
                    switch result {
                        
                    case .success(let response):
//                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        if response.data.count == 0 {
                            completion(nil, nil, nil)
                            return
                        }
                        guard let json = try? response.mapJSON() as? [JSONDictionary] else {
                            completion(nil, ServicesError.unknownError(), nil)
                            return
                        }
                        
//                        if let validationCode = json["code"] as? Int {
//                            validateJason(validationCode, completion: { (bool) in
//                                if bool {
//                                    if json["success"] as! Bool {
//                                        let headerDict = response.response?.allHeaderFields as! JSONDictionary
//                                        completion(json,nil,headerDict)
//                                    } else {
//                                        //                                    completion(nil, ServicesError.failure( json!["code"] as! Int, json!["message"] as! String), nil)
//
//                                        if let msg = json["message"] as? String {
//                                            appDelegate.showAlert(strMessage: msg, closer: {
//
//                                            })
//                                        }
//                                    }
//                                } else {
//                                    if let msg = json["message"] as? String {
//
//                                        appDelegate.showAlert(strMessage: msg, closer: {
//
//                                        })
//                                    }
//                                    completion(nil, ServicesError.failure( validationCode, json["message"] as! String), nil)
//                                }
//                            })
//                        } else {
                            completion(json,nil,nil)
//                        }
                        
                    case .failure(let error):
//                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        completion(nil, error, nil)
                    }
                }
            }
        } else {
//            MZProgressLoader.hide()
//            UIApplication.shared.isNetworkActivityIndicatorVisible = false
//            appDelegate.showAlert(strMessage: "Internet Connection not Available!")
        }
    }
    
    
    public class func makeRequestReturnStringArray(_ request: Services, completion:@escaping (([String]?, ServicesError?, JSONDictionary?) -> Void)) {
        let reachability = Reachability()!
        if  reachability.connection != .none {
            APIController.callService(request: request) { (result) in
                DispatchQueue.main.async {
                    switch result {
                    
                    case .success(let response):
                        if response.data.count == 0 {
                            completion(nil, nil, nil)
                            return
                        }
                        guard let json = try? response.mapJSON() as? [String] else {
                            completion(nil, ServicesError.unknownError(), nil)
                            return
                        }
                        
                        completion(json,nil,nil)
                        
                    case .failure(let error):
                        completion(nil, error, nil)
                    }
                }
            }
        } else {
            
        }
    }
    
    public class func validateJason(_ code: Int , completion:@escaping ((Bool) -> Void)) {
        switch code
        {
        case ResponseCode.Success.rawValue :
            completion(true)
            break
        case ResponseCode.Nocontent.rawValue :
            completion(true)
            break
        case ResponseCode.Failed.rawValue :
            completion(false)
            break
        case ResponseCode.Unauthorised.rawValue :
            completion(false)
            break
        case ResponseCode.Unverify_by_admin.rawValue :
            completion(false)
            break
        case ResponseCode.Block_by_admin.rawValue :
            completion(false)
            break
        case ResponseCode.Created.rawValue:
            completion(true)
            break
        case ResponseCode.AlreadyExist.rawValue:
            completion(false)
        case ResponseCode.Unverify_user.rawValue:
            completion(false)
            break
        default:
            completion(false)
            break
        }
    }
}
