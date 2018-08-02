//
//  EatrEnumeration.swift
//  Eatr
//
//  Created by Nayanda Haberty on 02/08/18.
//

import Foundation

public enum EatrError : Error {
    case URLError(String)
    case RequestError(String)
}

internal enum EatrRequestMethod : String {
    case put = "PUT"
    case get = "GET"
    case post = "POST"
}
