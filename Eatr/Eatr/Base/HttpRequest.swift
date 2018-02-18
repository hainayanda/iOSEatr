//
//  HttpRequest.swift
//  Eatr
//
//  Created by Nayanda Haberty on 16/02/18.
//  Copyright © 2018 Nayanda. All rights reserved.
//

import Foundation

open class HttpRequest {
    
    internal var method : HttpRequestMethod
    internal init(method : HttpRequestMethod) {
        self.method = method
    }
    
    internal var url : String?
    public func set(url : String) -> HttpRequest {
        self.url = url
        return self
    }
    
    internal var params : Dictionary<String, String>?
    public func set(params : Dictionary<String, String>) -> HttpRequest {
        self.params = params
        return self
    }
    
    internal var headers : Dictionary<String, String>?
    public func set(headers : Dictionary<String, String>) -> HttpRequest {
        self.headers = headers
        return self
    }
    
    internal var timeout = 10000
    public func set(timeout : Int) -> HttpRequest {
        self.timeout = timeout
        return self
    }
    
    public func addParam(withKey key : String, andValue value : String) -> HttpRequest {
        if(self.params == nil){
            self.params = Dictionary<String, String>.init()
        }
        params![key] = value
        return self
    }
    
    public func addHeader(withKey key : String, andValue value: String) -> HttpRequest {
        if(self.headers == nil){
            self.headers = Dictionary<String, String>.init()
        }
        headers![key] = value
        return self
    }
    
    public func addAuthorization(token : String) -> HttpRequest {
        if(self.headers == nil){
            self.headers = Dictionary<String, String>.init()
        }
        headers!["Authorization"] = "bearer " + token
        return self
    }
    
    internal var onBeforeSending : (URLSession) -> URLSession = { session in return session }
    public func set(onBeforeSending : @escaping (URLSession) -> URLSession) -> HttpRequest {
        self.onBeforeSending = onBeforeSending
        return self
    }
    
    internal var onTimeout : () -> Void = {}
    public func set(onTimeout : @escaping ()->Void) -> HttpRequest {
        self.onTimeout = onTimeout
        return self
    }
    
    internal var onError : (Error) -> Void = { _ in }
    public func set(onError : @escaping (Error) -> Void) -> HttpRequest {
        self.onError = onError
        return self
    }
    
    internal var onProgress : (Float) -> Void = { _ in }
    public func set(onProgress : @escaping (Float) -> Void) -> HttpRequest {
        self.onProgress = onProgress
        return self
    }
    
    internal var onResponded : (Response) -> Void = { _ in }
    public func set(onResponded : @escaping (Response) -> Void) -> HttpRequest {
        self.onResponded = onResponded
        return self
    }
    
    internal var onFinished : (Response?) -> Void = { _ in }
    public func asyncExecute(onFinished: @escaping (Response?) -> Void) {
        self.onFinished = onFinished
        asyncExecute()
    }
    
    internal var body : Data?
    public func asyncExecute() {
        onProgress(0)
        do {
            onProgress(0.1429)
            let sessions = try HttpRequest.requestBuilder(with: self, body: self.body, method: method).first
            if let sessions = sessions {
                let session = sessions.key
                let request = sessions.value
                HttpRequest.asyncExecutor(with: session, and: request, httpRequest: self)
            }
            else{
                self.onError(HttpRequestError.RequestError("Failed to create Http session"))
            }
        }
        catch{
            self.onError(error)
        }
    }
    
    public func awaitExecute() -> Response? {
        onProgress(0)
        do {
            onProgress(0.1429)
            let sessions = try HttpRequest.requestBuilder(with: self, body: self.body, method: method).first
            if let sessions = sessions {
                let session = sessions.key
                let request = sessions.value
                return HttpRequest.awaitExecutor(with: session, and: request, httpRequest: self)
            }
            else{
                let error = HttpRequestError.RequestError("Failed to create Http session")
                self.onError(error)
                return Response.init(nil, nil, nil, error)
            }
        }
        catch{
            self.onError(error)
            return Response.init(nil, nil, nil, error)
        }
    }
    
    static private func requestBuilder(with httpRequest : HttpRequest, body : Data?, method : HttpRequestMethod) throws -> [URLSession : NSMutableURLRequest] {
        guard let url : String = httpRequest.url else {
            throw HttpRequestError.URLError("URL is empty")
        }
        httpRequest.onProgress(0.2858)
        let request : NSMutableURLRequest = URL.init(using: url, withParams: httpRequest.params).request
        if let headers = httpRequest.headers {
            for header in headers {
                request.addValue(header.value, forHTTPHeaderField: header.key)
            }
        }
        if let body : Data = body {
            request.httpBody = body
        }
        request.httpMethod = method.rawValue
        httpRequest.onProgress(0.4287)
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = TimeInterval(httpRequest.timeout)
        config.timeoutIntervalForResource = TimeInterval(httpRequest.timeout)
        httpRequest.onProgress(0.5716)
        return [httpRequest.onBeforeSending(URLSession(configuration: config)) : request]
    }
    
    static private func asyncExecutor(with session : URLSession, and request : NSMutableURLRequest, httpRequest : HttpRequest){
        httpRequest.onProgress(0.7145)
        session.dataTask(with: request as URLRequest) {
            (data, response, error) -> Void in
            httpRequest.onProgress(0.8574)
            if let httpResponse : HTTPURLResponse = response as? HTTPURLResponse, let data : Data = data {
                let responseObj = Response.init(response, data, httpResponse.statusCode, error)
                httpRequest.onResponded(responseObj)
                httpRequest.onProgress(1.0)
                httpRequest.onFinished(responseObj)
            }
            else if response != nil {
                httpRequest.onProgress(1.0)
                httpRequest.onFinished(
                    Response.init(response, data, nil, error)
                )
            }
            else{
                if let error : Error = error{
                    httpRequest.onError(error)
                    httpRequest.onProgress(1.0)
                    httpRequest.onFinished(nil)
                }
                else{
                    httpRequest.onTimeout()
                    httpRequest.onProgress(1.0)
                    httpRequest.onFinished(nil)
                }
            }
        }.resume()
    }
    
    static private func awaitExecutor(with session : URLSession, and request : NSMutableURLRequest, httpRequest : HttpRequest) -> Response? {
        httpRequest.onProgress(0.7145)
        var responseObj : Response?
        let group = DispatchGroup.init()
        group.enter()
        session.dataTask(with: request as URLRequest) {
            (data, response, error) -> Void in
            httpRequest.onProgress(0.8574)
            if let httpResponse : HTTPURLResponse = response as? HTTPURLResponse, let data : Data = data {
                responseObj = Response.init(response, data, httpResponse.statusCode, error)
                httpRequest.onResponded(responseObj!)
            }
            else if response != nil {
                responseObj = Response.init(response, data, nil, error)
            }
            else{
                if let error : Error = error{
                    httpRequest.onError(error)
                }
                else{
                    httpRequest.onTimeout()
                }
            }
            group.leave()
        }.resume()
        group.wait()
        httpRequest.onProgress(1.0)
        return responseObj
    }
}
