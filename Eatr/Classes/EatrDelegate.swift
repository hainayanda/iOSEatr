//
//  EatrDelegate.swift
//  Eatr
//
//  Created by Nayanda Haberty on 02/08/18.
//

import Foundation

@objc public protocol EatrDelegate {
    @objc optional func eatrOnBeforeSending(_ sessionToSend : URLSession) -> URLSession
    @objc optional func eatrOnTimeout()
    @objc optional func eatrOnError(_ error: Error)
    @objc optional func eatrOnProgress(_ progress: Float)
    @objc optional func eatrOnResponded(_ response: EatrResponse)
    @objc optional func eatrOnFinished()
}
