#
# Be sure to run `pod lib lint Eatr.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Eatr'
  s.version          = '0.1.2'
  s.summary          = 'RESTful web service consumer for iOS (Swift) with builder.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  Features
  - Builder pattern
  - Auto encode param and form url encoded body
  - Support synchronous or asynchronous operation
  - Support progress observer
  - Support HandyJSON object
  
  Requirements
  
  - Swift 3.2 or higher
  
  Usage Example
  
  - Synchronous
  Build the object using HttpRequestBuilder and then execute
  
  Code :
  //HttpGet
  let getResponse : Response? = EatrRequestBuilder.httpGet.set(url : "http://your.url.here")
  .addHeader(withKey : "SOME-HEADER", andValue : "header_value")
  .addParam(withKey : "param_key", andValue : "param_value")
  .awaitExecute()
  
  if let response : EatrResponse = getResponse {
      let rawResponse : URLResponse? = response.rawResponse
      let isSuccess : Bool = response.isSuccess
      let isError : Bool = response.isError
      let statusCode : Int? = response.statusCode
      let body : Data? = response.rawBody
      let strBody : String? = response.bodyAsString
      let jsonBody : [String : Any?] = response.bodyAsJson
      let arrJsonBody : [Any?] = response.bodyAsJsonArray
      let parsedBody : YourHandyJSONObj = response.parsedBody()
      let parsedArray : [YourHandyJSONObj?] = response.parsedArrayBody
  }
  
  //HttpPost with Json body
  let postJsonResponse : Response? = EatrRequestBuilder.httpPost.set(url : "http://your.url.here")
  .addHeader(withKey : "SOME-HEADER", andValue : "header_value")
  .addParam(withKey : "param_key", andValue : "param_value")
  .set(jsonBody : jsonDictionary).awaitExecute()
  
  
  
  You can use raw body, form data, string, HandyJSON Object or any JSON Object for request body
  
  - Simple Asynchronous
  Everything is same like synchronous, but you need to pass consumer function into the execute method
  Remember, response inside closure will be null if reaching timeout
  
  Code:
  //Basic
  EatrRequestBuilder.httpGet.set(url : "http://your.url.here")
     .addHeader(withKey : "SOME-HEADER", andValue : "header_value")
     .addParam(withKey : "param_key", andValue : "param_value")
     .asyncExecute(onFinished : { response : Response? in
        //YOUR CODE HERE
        // WILL BE EXECUTE AFTER REQUEST IS FINISHED
    })
  
  
  - Advanced Asynchronous/Synchronous
    Same like any async http request, but you can set your consumer separately. you can set 5 closure consumer:
    - onProgress which will run for every progress, it will give the progress in float start from 0.0f to 1.0f
      Because this method will called periodically, its better if you're not put object creation inside this method
    - onBeforeSending which will run before sending
    - onResponded which will **ONLY** run when you get response
    - onTimeout which will **ONLY** run when you get no response after timeout
    - onException which will **ONLY** run when you get unhandled exception
    - onFinished which will run after all request is complete
                
    You don't need to set all of the consumer. just the one you need.
                
    Remember, response inside closure will be null if reaching timeout
                
    Code:
    //with onFinished closure
    EatrRequestBuilder.httpGet.set(url : "http://your.url.here")
        .addHeader(withKey : "SOME-HEADER", andValue : "header_value")
        .addParam(withKey : "param_key", andValue : "param_value")
        .set(onTimeout : {
            //YOUR CODE HERE
        })
        .set(onBeforeSending : { (session : URLSession) -> URLSession in
            //YOUR CODE HERE
        })
        .set(onError : { error : Error in
            //YOUR CODE HERE
        })
        .set(onProgress : { progress : Float in
            //YOUR CODE HERE
        })
        .set(onResponded : { response : Response in
            //YOUR CODE HERE
        })
        .asyncExecute()
                                         
    //you can even do it synchronously and all your closure will be executed synchronously
    let response : Response? = EatrRequestBuilder.httpGet.set(url : "http://your.url.here")
        .addHeader(withKey : "SOME-HEADER", andValue : "header_value")
        .addParam(withKey : "param_key", andValue : "param_value")
        .set(onTimeout : {
            //YOUR CODE HERE
        })
        .set(onBeforeSending : { (session : URLSession) -> URLSession in
            //YOUR CODE HERE
        })
        .set(onError : { error : Error in
            //YOUR CODE HERE
        })
        .set(onProgress : { progress : Float in
            //YOUR CODE HERE
        })
        .set(onResponded : { response : Response in
            //YOUR CODE HERE
        })
        .awaitExecute()
                                                                      
  - Using Delegate
    If you prefer using delegate, there is delegate protocol for you to use which is EatrDelegate with available method :
    - eatrOnBeforeSending(_ sessionToSend : URLSession) -> URLSession
    - eatrOnTimeout()
    - eatrOnError(_ error: Error)
    - eatrOnProgress(_ progress: Float)
    - eatrOnResponded(_ response: EatrResponse)
    - eatrOnFinished()
                                                                      
    All method are optional, use the one you need
                                                                      
    Code:
    EatrRequestBuilder.httpGet.set(url : "http://your.url.here")
        .addHeader(withKey : "SOME-HEADER", andValue : "header_value")
        .addParam(withKey : "param_key", andValue : "param_value")
        .set(delegate : self)
        .asyncExecute()
                       DESC

  s.homepage         = 'https://github.com/nayanda1/iOSEatr'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'Apache', :file => 'LICENSE' }
  s.author           = { 'nayanda1' => 'nayanda1@outlook.com' }
  s.source           = { :git => 'https://github.com/nayanda1/iOSEatr.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'Eatr/Classes/**/*'
  s.swift_version = '3.2'
  # s.resource_bundles = {
  #   'Eatr' => ['Eatr/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'HandyJSON', '~> 4.1.1'
end
