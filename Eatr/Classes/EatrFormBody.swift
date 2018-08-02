//
//  EatrFormBody.swift
//  Eatr
//
//  Created by Nayanda Haberty on 02/08/18.
//

import Foundation

public class EatrFormBody {
    var content : Data
    var type : String
    var name : String
    var fileName: String?
    
    init(content: Data, name: String, type: String) {
        self.content = content
        self.name = name
        self.type = type
    }
    
    init(content: Data, fileName: String, name: String, type: String) {
        self.content = content
        self.name = name
        self.type = type
        self.fileName = fileName
    }
}
