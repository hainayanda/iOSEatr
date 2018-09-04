//
//  EatrRequest.swift
//  Eatr
//
//  Created by Nayanda Haberty on 02/08/18.
//

import Foundation

open class EatrRequest {
    
    internal var method : EatrRequestMethod
    internal init(method : EatrRequestMethod) {
        self.method = method
    }
    
    internal var url : String?
    public func set(url : String) -> EatrRequest {
        self.url = url
        return self
    }
    
    internal var params : Dictionary<String, String>?
    public func set(params : Dictionary<String, String>) -> EatrRequest {
        self.params = params
        return self
    }
    
    internal var headers : Dictionary<String, String>?
    public func set(headers : Dictionary<String, String>) -> EatrRequest {
        self.headers = headers
        return self
    }
    
    internal var timeout = 30
    public func set(timeout : Int) -> EatrRequest {
        self.timeout = timeout
        return self
    }
    
    public func addParam(withKey key : String, andValue value : String) -> EatrRequest {
        if(self.params == nil){
            self.params = Dictionary<String, String>.init()
        }
        params![key] = value
        return self
    }
    
    public func addHeader(withKey key : String, andValue value: String) -> EatrRequest {
        if(self.headers == nil){
            self.headers = Dictionary<String, String>.init()
        }
        headers![key] = value
        return self
    }
    
    public func addAuthorization(token : String) -> EatrRequest {
        if(self.headers == nil){
            self.headers = Dictionary<String, String>.init()
        }
        headers!["Authorization"] = "bearer " + token
        return self
    }
    
    internal var onBeforeSending : ((URLSession) -> URLSession)?
    public func set(onBeforeSending : @escaping (URLSession) -> URLSession) -> EatrRequest {
        self.onBeforeSending = onBeforeSending
        return self
    }
    
    internal var onTimeout : (() -> Void)?
    public func set(onTimeout : @escaping ()->Void) -> EatrRequest {
        self.onTimeout = onTimeout
        return self
    }
    
    internal var onError : ((Error) -> Void)?
    public func set(onError : @escaping (Error) -> Void) -> EatrRequest {
        self.onError = onError
        return self
    }
    
    internal var onProgress : ((Float) -> Void)?
    public func set(onProgress : @escaping (Float) -> Void) -> EatrRequest {
        self.onProgress = onProgress
        return self
    }
    
    internal var onResponded : ((EatrResponse) -> Void)?
    public func set(onResponded : @escaping (EatrResponse) -> Void) -> EatrRequest {
        self.onResponded = onResponded
        return self
    }
    
    internal var delegate : EatrDelegate?
    public func set(delegate : EatrDelegate) -> EatrRequest {
        self.delegate = delegate
        self.onBeforeSending = self.delegate!.eatrOnBeforeSending(_:)
        self.onTimeout = self.delegate!.eatrOnTimeout
        self.onError = self.delegate!.eatrOnError(_:)
        self.onProgress = self.delegate!.eatrOnProgress(_:)
        self.onResponded = self.delegate!.eatrOnResponded(_:)
        self.onFinished = { _ in self.delegate!.eatrOnFinished?() }
        return self
    }
    
    internal var onFinished : ((EatrResponse?) -> Void)?
    public func asyncExecute(onFinished: @escaping (EatrResponse?) -> Void) {
        self.onFinished = onFinished
        asyncExecute()
    }
    
    internal var body : Data?
    public func asyncExecute() {
        onProgress?(0)
        do {
            onProgress?(0.1429)
            let sessions = try EatrRequest.requestBuilder(with: self, body: self.body, method: method).first
            if let sessions = sessions {
                let session = sessions.key
                let request = sessions.value
                EatrRequest.asyncExecutor(with: session, and: request, httpRequest: self)
            }
            else{
                self.onError?(EatrError.RequestError("Failed to create Http session"))
            }
        }
        catch{
            self.onError?(error)
        }
    }
    
    public func awaitExecute() -> EatrResponse? {
        onProgress?(0)
        do {
            onProgress?(0.1429)
            let sessions = try EatrRequest.requestBuilder(with: self, body: self.body, method: method).first
            if let sessions = sessions {
                let session = sessions.key
                let request = sessions.value
                return EatrRequest.awaitExecutor(with: session, and: request, httpRequest: self)
            }
            else{
                let error = EatrError.RequestError("Failed to create Http session")
                self.onError?(error)
                return EatrResponse.init(nil, nil, nil, error)
            }
        }
        catch{
            self.onError?(error)
            return EatrResponse.init(nil, nil, nil, error)
        }
    }
    
    static private func requestBuilder(with httpRequest : EatrRequest, body : Data?, method : EatrRequestMethod) throws -> [URLSession : NSMutableURLRequest] {
        guard let url : String = httpRequest.url else {
            throw EatrError.URLError("URL is empty")
        }
        httpRequest.onProgress?(0.2858)
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
        httpRequest.onProgress?(0.4287)
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = TimeInterval(httpRequest.timeout)
        config.timeoutIntervalForResource = TimeInterval(httpRequest.timeout)
        httpRequest.onProgress?(0.5716)
        var session = URLSession(configuration: config)
        if let onBeforeSending : (URLSession) -> URLSession = httpRequest.onBeforeSending {
            session = onBeforeSending(session)
        }
        return [session : request]
    }
    
    static private func asyncExecutor(with session : URLSession, and request : NSMutableURLRequest, httpRequest : EatrRequest){
        httpRequest.onProgress?(0.7145)
        session.dataTask(with: request as URLRequest) {
            (data, response, error) -> Void in
            httpRequest.onProgress?(0.8574)
            if let httpResponse : HTTPURLResponse = response as? HTTPURLResponse, let data : Data = data {
                let responseObj = EatrResponse.init(response, data, httpResponse.statusCode, error)
                httpRequest.onResponded?(responseObj)
                httpRequest.onProgress?(1.0)
                httpRequest.onFinished?(responseObj)
            }
            else if response != nil {
                httpRequest.onProgress?(1.0)
                httpRequest.onFinished?(
                    EatrResponse.init(response, data, nil, error)
                )
            }
            else{
                if let error : Error = error{
                    httpRequest.onError?(error)
                    httpRequest.onProgress?(1.0)
                    httpRequest.onFinished?(nil)
                }
                else{
                    httpRequest.onTimeout?()
                    httpRequest.onProgress?(1.0)
                    httpRequest.onFinished?(nil)
                }
            }
            }.resume()
    }
    
    static private func awaitExecutor(with session : URLSession, and request : NSMutableURLRequest, httpRequest : EatrRequest) -> EatrResponse? {
        httpRequest.onProgress?(0.7145)
        var responseObj : EatrResponse?
        let group = DispatchGroup.init()
        group.enter()
        session.dataTask(with: request as URLRequest) {
            (data, response, error) -> Void in
            httpRequest.onProgress?(0.8574)
            if let httpResponse : HTTPURLResponse = response as? HTTPURLResponse, let data : Data = data {
                responseObj = EatrResponse.init(response, data, httpResponse.statusCode, error)
                httpRequest.onResponded?(responseObj!)
            }
            else if response != nil {
                responseObj = EatrResponse.init(response, data, nil, error)
            }
            else{
                if let error : Error = error{
                    httpRequest.onError?(error)
                }
                else{
                    httpRequest.onTimeout?()
                }
            }
            group.leave()
            }.resume()
        group.wait()
        httpRequest.onProgress?(1.0)
        return responseObj
    }
}
