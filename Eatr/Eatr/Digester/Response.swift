//
//  Response.swift
//  Eatr
//
//  Created by Nayanda Haberty on 16/02/18.
//  Copyright © 2018 Nayanda. All rights reserved.
//

import Foundation

public class Response {
    
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
    
    var bodyAsJson: Dictionary<String, Any?>?{
        guard let data : Data = rawBody else { return nil }
        do {
            if let json : Dictionary<String, Any?> = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Dictionary<String, Any?>
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
