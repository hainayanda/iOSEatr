//
//  EatrFormBody.swift
//  Eatr
//
//  Created by Nayanda Haberty on 02/08/18.
//

import Foundation

public class EatrFormBody {
    public var content : Data
    public var type : String
    public var name : String
    public var fileName: String?
    
    public init(content: Data, name: String, type: String) {
        self.content = content
        self.name = name
        self.type = type
    }
    
    public init(content: Data, fileName: String, name: String, type: String) {
        self.content = content
        self.name = name
        self.type = type
        self.fileName = fileName
    }
}
