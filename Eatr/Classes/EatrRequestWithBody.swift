//
//  EatrRequestWithBody.swift
//  Eatr
//
//  Created by Nayanda Haberty on 02/08/18.
//

import Foundation
import HandyJSON

public class EatrRequestWithBody {
    
    private var httpRequest : EatrRequest
    internal init(method: EatrRequestMethod) {
        httpRequest = EatrRequest.init(method: method)
    }
    
    public func set(rawBody : Data) -> EatrRequestWithBody {
        httpRequest.body = rawBody
        return self
    }
    
    public func set(formDataBody datas: [EatrFormBody]) -> EatrRequestWithBody{
        let body = NSMutableData()
        let boundary = "\(self.randomString(length: 20))"
        
        for data in datas {
            body.append("--\(boundary)\r\n" .data(using: String.Encoding.utf8, allowLossyConversion: false)!)
            
            body.append("Content-Disposition: form-data; name=\"\(data.name)\"" .data(using: String.Encoding.utf8, allowLossyConversion: false)!)
            if let fileName = data.fileName {
                body.append("; filename=\"\(fileName)\"" .data(using: String.Encoding.utf8, allowLossyConversion: false)!)
            }
            body.append("\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false)!)
            
            body.append("Content-Type: \(data.type)\r\n\r\n" .data(using: String.Encoding.utf8, allowLossyConversion: false)!)
            
            body.append(data.content)
            body.append("\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false)!)
        }
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false)!)
        httpRequest.body = body.copy() as? Data
        httpRequest = httpRequest.addHeader(withKey: "Content-Length", andValue: "\(body.length)")
        httpRequest = httpRequest.addHeader(withKey: "Content-Type", andValue: "multipart/form-data; boundary=\(boundary)")
        return self
    }
    
    public func set(body : String) -> EatrRequestWithBody {
        httpRequest.body = body.data(using: .utf8)
        return self
    }
    
    public func set(jsonBody : Dictionary<String, Any>) throws -> EatrRequestWithBody {
        httpRequest.body = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
        httpRequest = httpRequest.addHeader(withKey: "Content-Type", andValue: "application/json")
        return self
    }
    
    public func set(arrayJsonBody : Array<Any?>) throws -> EatrRequestWithBody {
        httpRequest.body = try JSONSerialization.data(withJSONObject: arrayJsonBody, options: [])
        httpRequest = httpRequest.addHeader(withKey: "Content-Type", andValue: "application/json")
        return self
    }
    
    public func set(json : HandyJSON) throws -> EatrRequestWithBody {
        return try set(jsonBody: json.toJSON()!)
    }
    
    public func set(arrayJson : [HandyJSON?]) throws -> EatrRequestWithBody {
        return try set(arrayJsonBody: arrayJson.toJSON())
    }
    
    public func set(formUrlEncoded : Dictionary<String, String>) -> EatrRequestWithBody {
        var body = ""
        for biConsumer in formUrlEncoded {
            body += biConsumer.key.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            body += "=" + biConsumer.value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            body += "&"
        }
        if body.count > 0 {
            body.removeLast()
        }
        httpRequest = httpRequest.addHeader(withKey: "Content-Type", andValue: "application/x-www-form-urlencoded")
        return self.set(body: body)
    }
    
    public func set(url : String) -> EatrRequestWithBody {
        httpRequest.url = url
        return self
    }
    
    public func set(params : Dictionary<String, String>) -> EatrRequestWithBody {
        httpRequest.params = params
        return self
    }
    
    public func set(headers : Dictionary<String, String>) -> EatrRequestWithBody {
        httpRequest.headers = headers
        return self
    }
    
    public func set(timeout : Int) -> EatrRequestWithBody {
        httpRequest.timeout = timeout
        return self
    }
    
    public func addParam(withKey key : String, andValue value : String) -> EatrRequestWithBody {
        httpRequest = httpRequest.addParam(withKey: key, andValue: value)
        return self
    }
    
    public func addHeader(withKey key : String, andValue value: String) -> EatrRequestWithBody {
        httpRequest = httpRequest.addHeader(withKey: key, andValue: value)
        return self
    }
    
    public func addAuthorization(token : String) -> EatrRequestWithBody {
        httpRequest = httpRequest.addAuthorization(token: token)
        return self
    }
    
    public func set(onBeforeSending : @escaping (URLSession) -> URLSession) -> EatrRequestWithBody {
        httpRequest = httpRequest.set(onBeforeSending : onBeforeSending)
        return self
    }
    
    public func set(onTimeout : @escaping ()->Void) -> EatrRequestWithBody {
        httpRequest = httpRequest.set(onTimeout: onTimeout)
        return self
    }
    
    public func set(onError : @escaping (Error) -> Void) -> EatrRequestWithBody {
        httpRequest = httpRequest.set(onError: onError)
        return self
    }
    
    public func set(onProgress : @escaping (Float) -> Void) -> EatrRequestWithBody {
        httpRequest = httpRequest.set(onProgress: onProgress)
        return self
    }
    
    public func set(onResponded : @escaping (EatrResponse) -> Void) -> EatrRequestWithBody {
        httpRequest = httpRequest.set(onResponded: onResponded)
        return self
    }
    
    public func set(delegate : EatrDelegate) -> EatrRequestWithBody {
        httpRequest = httpRequest.set(delegate: delegate)
        return self
    }
    
    public func asyncExecute(onFinished: @escaping (EatrResponse?) -> Void) {
        httpRequest.asyncExecute(onFinished: onFinished)
    }
    
    public func asyncExecute() {
        httpRequest.asyncExecute()
    }
    
    public func awaitExecute() -> EatrResponse? {
        return httpRequest.awaitExecute()
    }
    
    private func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
}
