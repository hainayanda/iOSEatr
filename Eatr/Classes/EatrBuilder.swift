//
//  EatrBuilder.swift
//  Eatr
//
//  Created by Nayanda Haberty on 02/08/18.
//

import Foundation

public class EatrRequestBuilder {
    public static var httpGet : EatrRequest {
        return EatrRequest.init(method: .get)
    }
    
    public static var httpPost : EatrRequestWithBody {
        return EatrRequestWithBody.init(method: .post)
    }
    
    public static var httpPut : EatrRequestWithBody {
        return EatrRequestWithBody.init(method: .put)
    }
}
