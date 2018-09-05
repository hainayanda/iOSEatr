//
//  HandyJSONExtension.swift
//  Eatr
//
//  Created by Nayanda Haberty on 02/08/18.
//

import Foundation
import HandyJSON

extension Array where Element == HandyJSON?  {
    
    public func toJSONString() -> String {
        var arrJson = "["
        for member in self {
            if let member : HandyJSON = member, let json : String = member.toJSONString() {
                arrJson = "\(arrJson)\(json),"
            }
            else {
                arrJson = "\(arrJson)null,"
            }
        }
        if arrJson.last == "," {
            arrJson.removeLast()
        }
        arrJson = "\(arrJson)]"
        return arrJson
    }
    
    public func toJSON() -> [[String : Any]?] {
        var arrJson : [[String: Any]?] = []
        for member in self {
            if let member : HandyJSON = member, let json : [String: Any] = member.toJSON() {
                arrJson.append(json)
            }
            else {
                arrJson.append(nil)
            }
        }
        return arrJson
    }
    
}

extension Dictionary where Key == String, Value == HandyJSON? {
    
    public func toJSONString() -> String {
        var dictJson = "["
        for pair in self {
            let key = pair.key
            if let value : HandyJSON = pair.value, let json : String = value.toJSONString() {
                dictJson = "\(dictJson)\"\(key)\":\(json),"
            }
            else {
                dictJson = "\(dictJson)\"\(key)\":null,"
            }
        }
        if dictJson.last == "," {
            dictJson.removeLast()
        }
        dictJson = "\(dictJson)]"
        return dictJson
    }
    
    public func toJSON() -> [String : [String : Any]?] {
        var dictJson : [String : [String: Any]?] = [:]
        for pair in self {
            let key = pair.key
            if let value : HandyJSON = pair.value, let json : [String: Any] = value.toJSON() {
                dictJson[key] = json
            }
            else {
                dictJson[key] = nil
            }
        }
        return dictJson
    }
    
}
