//
//  TopicData.swift
//  MyZone
//
//  Created by Mac on 7/1/22.
//

import Foundation

struct SubTopicData: CreatableFromJSON {
    
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
    struct Data: CreatableFromJSON {
        let id: String
        let icon: String
        let subTopicNameEnglish: String
        let subTopicNameArabic: String
        var isSelected: Bool = false
        init(id: String, icon: String, subTopicNameEnglish: String, subTopicNameArabic: String) {
            self.id = id
            self.icon = icon
            self.subTopicNameEnglish = subTopicNameEnglish
            self.subTopicNameArabic = subTopicNameArabic
        }
        
        init?(json: [String: Any]) {
            let id = json["_id"] as? String ?? ""
            let icon = json["icon"] as? String ?? ""
            let subTopicNameEnglish = json["Sub_topic_name_english"] as? String ?? ""
            let subTopicNameArabic = json["Sub_topic_name_arabic"] as? String ?? ""
            self.init(id: id, icon: icon, subTopicNameEnglish: subTopicNameEnglish, subTopicNameArabic: subTopicNameArabic)
        }        
    }
}
