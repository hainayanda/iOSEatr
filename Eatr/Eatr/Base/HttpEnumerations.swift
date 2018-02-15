//
//  HttpEnumerations.swift
//  Eatr
//
//  Created by Nayanda Haberty on 16/02/18.
//  Copyright © 2018 Nayanda. All rights reserved.
//

import Foundation

public enum HttpRequestError : Error {
    case URLError(String)
    case RequestError(String)
}

internal enum HttpRequestMethod : String {
    case put = "PUT"
    case get = "GET"
    case post = "POST"
}
