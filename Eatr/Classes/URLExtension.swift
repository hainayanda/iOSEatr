//
//  URLExtension.swift
//  Eatr
//
//  Created by Nayanda Haberty on 02/08/18.
//

import Foundation

extension URL {
    public init(using url: String, withParams params: Dictionary<String, String>?) {
        var parameter = ""
        if let params : Dictionary<String, String> = params {
            for param in params {
                parameter += param.key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                parameter += "=" + param.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                parameter += "&"
            }
            if parameter.count > 0 {
                parameter = "?" + parameter
                parameter = String.init(parameter.dropLast())
            }
        }
        let fullUrl = url + parameter
        self.init(string: fullUrl)!
    }
    
    public var request : NSMutableURLRequest {
        get {
            return NSMutableURLRequest(url: self)
        }
    }
}
