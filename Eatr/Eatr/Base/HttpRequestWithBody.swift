//
//  HttpRequestWithBody.swift
//  Eatr
//
//  Created by Nayanda Haberty on 16/02/18.
//  Copyright © 2018 Nayanda. All rights reserved.
//

import Foundation

public class HttpRequestWithBody {
    
    private var httpRequest : HttpRequest
    internal init(method: HttpRequestMethod) {
        httpRequest = HttpRequest.init(method: method)
    }
    
    public func add(rawBody : Data) -> HttpRequestWithBody {
        httpRequest.body = rawBody
        return self
    }
    
    public func add(body : String) -> HttpRequestWithBody {
        httpRequest.body = body.data(using: .utf8)
        return self
    }
    
    public func add(jsonBody : Dictionary<String, Any?>) throws -> HttpRequestWithBody {
        httpRequest.body = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
        httpRequest = httpRequest.addHeader(withKey: "Content-Type", andValue: "application/json")
        return self
    }
    
    public func add(arrayJsonBody : Array<Any?>) throws -> HttpRequestWithBody {
        httpRequest.body = try JSONSerialization.data(withJSONObject: arrayJsonBody, options: [])
        httpRequest = httpRequest.addHeader(withKey: "Content-Type", andValue: "application/json")
        return self
    }
    
    public func add(formUrlEncoded : Dictionary<String, String>) -> HttpRequestWithBody {
        var body = ""
        for biConsumer in formUrlEncoded {
            body += biConsumer.key.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            body += "=" + biConsumer.value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            body += "&"
        }
        if body.count > 0 {
            body.remove(at: body.endIndex)
        }
        httpRequest = httpRequest.addHeader(withKey: "Content-Type", andValue: "application/x-www-form-urlencoded")
        return self.add(body: body)
    }
    
    public func set(url : String) -> HttpRequestWithBody {
        httpRequest.url = url
        return self
    }
    
    public func set(params : Dictionary<String, String>) -> HttpRequestWithBody {
        httpRequest.params = params
        return self
    }
    
    public func set(headers : Dictionary<String, String>) -> HttpRequestWithBody {
        httpRequest.headers = headers
        return self
    }
    
    public func set(timeout : Int) -> HttpRequestWithBody {
        httpRequest.timeout = timeout
        return self
    }
    
    public func addParam(withKey key : String, andValue value : String) -> HttpRequestWithBody {
        httpRequest = httpRequest.addParam(withKey: key, andValue: value)
        return self
    }
    
    public func addHeader(withKey key : String, andValue value: String) -> HttpRequestWithBody {
        httpRequest = httpRequest.addHeader(withKey: key, andValue: value)
        return self
    }
    
    public func addAuthorization(token : String) -> HttpRequestWithBody {
        httpRequest = httpRequest.addAuthorization(token: token)
        return self
    }
    
    public func set(onBeforeSending : @escaping (URLSession) -> URLSession) -> HttpRequestWithBody {
        httpRequest = httpRequest.set(onBeforeSending : onBeforeSending)
        return self
    }
    
    public func set(onTimeout : @escaping ()->Void) -> HttpRequestWithBody {
        httpRequest = httpRequest.set(onTimeout: onTimeout)
        return self
    }
    
    public func set(onError : @escaping (Error) -> Void) -> HttpRequestWithBody {
        httpRequest = httpRequest.set(onError: onError)
        return self
    }
    
    public func set(onProgress : @escaping (Float) -> Void) -> HttpRequestWithBody {
        httpRequest = httpRequest.set(onProgress: onProgress)
        return self
    }
    
    public func set(onResponded : @escaping (Response) -> Void) -> HttpRequestWithBody {
        httpRequest = httpRequest.set(onResponded: onResponded)
        return self
    }
    
    public func asyncExecute(onFinished: @escaping (Response?) -> Void) {
        httpRequest.asyncExecute(onFinished: onFinished)
    }
    
    public func asyncExecute() {
        httpRequest.asyncExecute()
    }
    
    public func awaitExecute() -> Response? {
        return httpRequest.awaitExecute()
    }
}
