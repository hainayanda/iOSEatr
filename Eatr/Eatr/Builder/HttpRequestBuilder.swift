//
//  HttpRequestBuilder.swift
//  Eatr
//
//  Created by Nayanda Haberty on 16/02/18.
//  Copyright © 2018 Nayanda. All rights reserved.
//

import Foundation

public class HttpRequestBuilder {
    public static var httpGet : HttpRequest {
        return HttpRequest.init(method: .get)
    }
    
    public static var httpPost : HttpRequestWithBody {
        return HttpRequestWithBody.init(method: .post)
    }
    
    public static var httpPut : HttpRequestWithBody {
        return HttpRequestWithBody.init(method: .put)
    }
}
