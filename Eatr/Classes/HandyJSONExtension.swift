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
