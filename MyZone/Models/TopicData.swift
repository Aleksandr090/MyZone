//
//  TopicData.swift
//  MyZone
//
//  Created by Mac on 7/1/22.
//

import Foundation

struct TopicData: CreatableFromJSON {
    
    let data: [Data]
    let message: String
    let status: Int
    
    init(data: [Data], message: String, status: Int) {
        self.data = data
        self.message = message
        self.status = status
    }
    init?(json: [String: Any]) {
        let data = Data.createRequiredInstances(from: json, arrayKey: "data") ?? [Data.init(json: [:])!]
        let message = json["message"] as? String ?? ""
        let status = json["status"] as? Int ?? 0
        self.init(data: data, message: message, status: status)
    }
    struct Data: CreatableFromJSON { // TODO: Rename this struct
        let id: String
        let icon: String
        let topicNameEnglish: String
        let topicNameArabic: String
        init(id: String, icon: String, topicNameEnglish: String, topicNameArabic: String) {
            self.id = id
            self.icon = icon
            self.topicNameEnglish = topicNameEnglish
            self.topicNameArabic = topicNameArabic
        }
        
        init?(json: [String: Any]) {
            let id = json["_id"] as? String ?? ""
            let icon = json["icon"] as? String ?? ""
            let topicNameEnglish = json["topic_name_english"] as? String ?? ""
            let topicNameArabic = json["topic_name_arabic"] as? String ?? ""
            self.init(id: id, icon: icon, topicNameEnglish: topicNameEnglish, topicNameArabic: topicNameArabic)
        }        
    }
}
