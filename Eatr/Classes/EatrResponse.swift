//
//  Response.swift
//  Eatr
//
//  Created by Nayanda Haberty on 02/08/18.
//

import Foundation
import HandyJSON

public class EatrResponse : NSObject {
    
    private var _rawResponse : URLResponse?
    var rawResponse : URLResponse?{
        return _rawResponse
    }
    
    private var _rawBody : Data?
    var rawBody: Data? {
        return _rawBody
    }
    
    var bodyAsString: String? {
        guard let data : Data = rawBody else {
            return nil
        }
        if let str : String = String(data: data, encoding: .utf8) {
            return str
        }
        else{
            return nil
        }
    }
    
    var bodyAsJson: Dictionary<String, Any>?{
        guard let data : Data = rawBody else { return nil }
        do {
            if let json : Dictionary<String, Any> = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Dictionary<String, Any>
            {
                return json
            } else {
                return nil
            }
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    func parsedBody<T: HandyJSON>() -> T? {
        if let json : [String : Any] = bodyAsJson {
            return T.deserialize(from: json)
        }
        return nil
    }
    
    func parsedArrayBody<T: HandyJSON>() -> [T?]? {
        if let json : [Any?] = bodyAsJsonArray {
            var results : [T?] = []
            for member in json {
                if let member : [String : Any] = member as? [String : Any] {
                    if let obj : T = T.deserialize(from: member) {
                        results.append(obj)
                    }
                    else {
                        results.append(nil)
                    }
                }
                else {
                    results.append(nil)
                }
            }
            return results
        }
        return nil
    }
    
    var bodyAsJsonArray : Array<Any?>?{
        guard let data : Data = rawBody else { return nil }
        do {
            if let array : Array<Any?> = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Array<Any?>
            {
                return array
            } else {
                return nil
            }
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    private var _statusCode : Int?
    var statusCode : Int? {
        return _statusCode
    }
    
    var isSuccess : Bool {
        if let statusCode : Int = statusCode {
            return statusCode >= 200 && statusCode <= 299
        }
        else {
            return false
        }
    }
    
    private var _error : Error?
    var error : Error? {
        return _error
    }
    
    var isError : Bool {
        return error == nil
    }
    
    
    init(_ rawResponse : URLResponse?, _ rawBody: Data?, _ statusCode : Int?, _ error : Error?) {
        self._rawResponse = rawResponse
        self._rawBody = rawBody
        self._statusCode = statusCode
        self._error = error
    }
    
}
