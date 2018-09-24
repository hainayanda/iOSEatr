//
//  EatrRequest.swift
//  Eatr
//
//  Created by Nayanda Haberty on 02/08/18.
//

import Foundation

open class EatrRequest : NSObject, URLSessionDelegate {
    
    internal var opQueue : OperationQueue?
    public func set(operationQueue: OperationQueue?) -> EatrRequest{
        self.opQueue = operationQueue
        return self
    }
    
    internal var rMethod : String
    internal init(method : EatrRequestMethod) {
        self.rMethod = method.rawValue
    }
    
    internal init(method : String) {
        self.rMethod = method
    }
    
    internal var rUrl : String?
    public func set(url : String) -> EatrRequest {
        self.rUrl = url
        return self
    }
    
    internal var parameters : Dictionary<String, String>?
    public func set(params : Dictionary<String, String>) -> EatrRequest {
        self.parameters = params
        return self
    }
    
    internal var rHeaders : Dictionary<String, String>?
    public func set(headers : Dictionary<String, String>) -> EatrRequest {
        self.rHeaders = headers
        return self
    }
    
    internal var rTimeout = 30
    public func set(timeout : Int) -> EatrRequest {
        self.rTimeout = timeout
        return self
    }
    
    public func addParam(withKey key : String, andValue value : String) -> EatrRequest {
        if(self.parameters == nil){
            self.parameters = Dictionary<String, String>.init()
        }
        parameters![key] = value
        return self
    }
    
    public func addHeader(withKey key : String, andValue value: String) -> EatrRequest {
        if(self.rHeaders == nil){
            self.rHeaders = Dictionary<String, String>.init()
        }
        rHeaders![key] = value
        return self
    }
    
    public func addAuthorization(token : String) -> EatrRequest {
        if(self.rHeaders == nil){
            self.rHeaders = Dictionary<String, String>.init()
        }
        rHeaders!["Authorization"] = "bearer " + token
        return self
    }
    
    internal var rOnBeforeSending : ((URLSession) -> URLSession)?
    public func set(onBeforeSending : @escaping (URLSession) -> URLSession) -> EatrRequest {
        self.rOnBeforeSending = onBeforeSending
        return self
    }
    
    internal var rOnTimeout : (() -> Void)?
    public func set(onTimeout : @escaping ()->Void) -> EatrRequest {
        self.rOnTimeout = onTimeout
        return self
    }
    
    internal var rOnError : ((Error) -> Void)?
    public func set(onError : @escaping (Error) -> Void) -> EatrRequest {
        self.rOnError = onError
        return self
    }
    
    internal var rOnProgress : ((Float) -> Void)?
    public func set(onProgress : @escaping (Float) -> Void) -> EatrRequest {
        self.rOnProgress = onProgress
        return self
    }
    
    internal var rOnResponded : ((EatrResponse) -> Void)?
    public func set(onResponded : @escaping (EatrResponse) -> Void) -> EatrRequest {
        self.rOnResponded = onResponded
        return self
    }
    
    internal weak var rDelegate : EatrDelegate?
    public func set(delegate : EatrDelegate) -> EatrRequest {
        self.rDelegate = delegate
        self.rOnBeforeSending = self.rDelegate!.eatrOnBeforeSending(_:)
        self.rOnTimeout = self.rDelegate!.eatrOnTimeout
        self.rOnError = self.rDelegate!.eatrOnError(_:)
        self.rOnProgress = self.rDelegate!.eatrOnProgress(_:)
        self.rOnResponded = self.rDelegate!.eatrOnResponded(_:)
        self.onFinished = { _ in self.rDelegate!.eatrOnFinished?() }
        return self
    }
    
    internal var onFinished : ((EatrResponse?) -> Void)?
    public func asyncExecute(onFinished: @escaping (EatrResponse?) -> Void) {
        self.onFinished = onFinished
        asyncExecute()
    }
    
    internal var body : Data?
    public func asyncExecute() {
        rOnProgress?(0)
        do {
            rOnProgress?(0.1429)
            let sessions = try EatrRequest.requestBuilder(with: self, body: self.body, method: rMethod).first
            if let sessions = sessions {
                let session = sessions.key
                let request = sessions.value
                EatrRequest.asyncExecutor(with: session, and: request, httpRequest: self)
            }
            else{
                self.rOnError?(EatrError.RequestError("Failed to create Http session"))
            }
        }
        catch{
            self.rOnError?(error)
        }
    }
    
    public func awaitExecute() -> EatrResponse? {
        rOnProgress?(0)
        do {
            rOnProgress?(0.1429)
            let sessions = try EatrRequest.requestBuilder(with: self, body: self.body, method: rMethod).first
            if let sessions = sessions {
                let session = sessions.key
                let request = sessions.value
                return EatrRequest.awaitExecutor(with: session, and: request, httpRequest: self)
            }
            else{
                let error = EatrError.RequestError("Failed to create Http session")
                self.rOnError?(error)
                return EatrResponse.init(nil, nil, nil, error)
            }
        }
        catch{
            self.rOnError?(error)
            return EatrResponse.init(nil, nil, nil, error)
        }
    }
    
    static private func requestBuilder(with httpRequest : EatrRequest, body : Data?, method : String) throws -> [URLSession : NSMutableURLRequest] {
        guard let url : String = httpRequest.rUrl else {
            throw EatrError.URLError("URL is empty")
        }
        httpRequest.rOnProgress?(0.2858)
        let request : NSMutableURLRequest = URL.init(using: url, withParams: httpRequest.parameters).request
        if let headers = httpRequest.rHeaders {
            for header in headers {
                request.addValue(header.value, forHTTPHeaderField: header.key)
            }
        }
        if let body : Data = body {
            request.httpBody = body
        }
        request.httpMethod = method
        httpRequest.rOnProgress?(0.4287)
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = TimeInterval(httpRequest.rTimeout)
        config.timeoutIntervalForResource = TimeInterval(httpRequest.rTimeout)
        httpRequest.rOnProgress?(0.5716)
        var session = URLSession.init(configuration: config, delegate: httpRequest, delegateQueue: httpRequest.opQueue)
        if let onBeforeSending : (URLSession) -> URLSession = httpRequest.rOnBeforeSending {
            session = onBeforeSending(session)
        }
        return [session : request]
    }
    
    static private func asyncExecutor(with session : URLSession, and request : NSMutableURLRequest, httpRequest : EatrRequest){
        httpRequest.rOnProgress?(0.7145)
        session.dataTask(with: request as URLRequest) {
            (data, response, error) -> Void in
            httpRequest.rOnProgress?(0.8574)
            if let httpResponse : HTTPURLResponse = response as? HTTPURLResponse, let data : Data = data {
                let responseObj = EatrResponse.init(response, data, httpResponse.statusCode, error)
                httpRequest.rOnResponded?(responseObj)
                httpRequest.rOnProgress?(1.0)
                httpRequest.onFinished?(responseObj)
            }
            else if response != nil {
                httpRequest.rOnProgress?(1.0)
                httpRequest.onFinished?(
                    EatrResponse.init(response, data, nil, error)
                )
            }
            else{
                if let error : Error = error{
                    httpRequest.rOnError?(error)
                }
                else{
                    httpRequest.rOnTimeout?()
                }
                httpRequest.rOnProgress?(1.0)
                httpRequest.onFinished?(nil)
            }
            }.resume()
    }
    
    fileprivate static var groups : [URLSession : DispatchGroup] = [:]
    fileprivate static var awaitResults : [URLSession : EatrResponse?] = [:]
    static private func awaitExecutor(with session : URLSession, and request : NSMutableURLRequest, httpRequest : EatrRequest) -> EatrResponse? {
        httpRequest.rOnProgress?(0.7145)
        var responseObj : EatrResponse?
        let group = DispatchGroup.init()
        groups[session] = group
        group.enter()
        session.dataTask(with: request as URLRequest) {
            (data, response, error) -> Void in
            httpRequest.rOnProgress?(0.8574)
            if let httpResponse : HTTPURLResponse = response as? HTTPURLResponse, let data : Data = data {
                responseObj = EatrResponse.init(response, data, httpResponse.statusCode, error)
                httpRequest.rOnResponded?(responseObj!)
            }
            else if let response : URLResponse = response {
                responseObj = EatrResponse.init(response, data, nil, error)
            }
            else{
                if let error : Error = error{
                    httpRequest.rOnError?(error)
                    responseObj = EatrResponse.init(nil, data, nil, error)
                }
                else{
                    httpRequest.rOnTimeout?()
                    responseObj = EatrResponse.init(nil, data, nil, nil)
                }
            }
            group.leave()
            }.resume()
        let _ = group.wait(timeout: DispatchTime.now() + request.timeoutInterval)
        httpRequest.rOnProgress?(1.0)
        let resultExist = awaitResults.contains(where: { (pair) -> Bool in
            return pair.key == session
        })
        let awaitResult: EatrResponse? = resultExist ? (awaitResults[session] ?? nil) : nil
        if resultExist {
            awaitResults.removeValue(forKey: session)
        }
        responseObj = responseObj ?? awaitResult
        return responseObj
    }
    
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        if let error : Error = error {
            rOnError?(error)
        }
        EatrRequest.awaitResults[session] = EatrResponse.init(nil, nil, nil, error)
        let groupExist = EatrRequest.groups.contains(where: { (pair) -> Bool in
            return pair.key == session
        })
        if groupExist {
            EatrRequest.groups[session]?.leave()
            EatrRequest.groups.removeValue(forKey: session)
        }
    }
}
