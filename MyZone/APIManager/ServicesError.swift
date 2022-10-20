//
//  ServicesError.swift
//

import Foundation

struct ServicesError: Swift.Error {
    let code: Int
    let desc: String
    
    static func failure(_ code: Int , _ text: String) -> ServicesError {
        return ServicesError.init(code: code, desc: text)
    }
    static func noConnectivity() -> ServicesError {
        return ServicesError.init(code: 0, desc: "Server not responding")
    }
    static func unknownError() -> ServicesError {
        return ServicesError.init(code: 0, desc: "Unknown Error")
    }
}
extension ServicesError {
    init(_ json: JSONDictionary) {
        self.code = json["code"] as? Int ?? 0
        self.desc = json["error"] as? String ?? json["message"] as? String ?? ""
    }
}
