<p align="center">
  <img width="128" height="192" src="ios.eatr.png"/>
</p>

# iOSEatr
RESTful web service consumer for iOS (Swift) with builder


---
## Changelog
for changelog check [here](CHANGELOG.md)

---
## Features

- [x] Builder pattern
- [x] Auto encode param and form url encoded body
- [x] Support synchronous or asynchronous operation
- [x] Support progress observer
- [x] Support HandyJSON object
---
## Requirements

- Swift 3.0 or higher

---
## Installation
### CocoaPods
*COMING SOON*

### Manually
1. Clone this repository.
2. Added to your project.
3. Congratulation!

## Usage Example
### Synchronous
Build the object using HttpRequestBuilder and then execute

```swift
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
```
You can use raw body, form data, string, HandyJSON Object or any JSON Object for request body

### Simple Asynchronous
Everything is same like synchronous, but you need to pass consumer function into the execute method  
Remember, response inside closure will be null if reaching timeout
```swift
//Basic
EatrRequestBuilder.httpGet.set(url : "http://your.url.here")
    .addHeader(withKey : "SOME-HEADER", andValue : "header_value")
    .addParam(withKey : "param_key", andValue : "param_value")
    .asyncExecute(onFinished : { response : Response? in
        //YOUR CODE HERE
        // WILL BE EXECUTE AFTER REQUEST IS FINISHED
    })
```

### Advanced Asynchronous/Synchronous
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

```swift
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
```

### Using Delegate
If you prefer using delegate, there is delegate protocol for you to use which is EatrDelegate with available method :
- eatrOnBeforeSending(_ sessionToSend : URLSession) -> URLSession
- eatrOnTimeout()
- eatrOnError(_ error: Error)
- eatrOnProgress(_ progress: Float)
- eatrOnResponded(_ response: EatrResponse)
- eatrOnFinished()

All method are optional, use the one you need

```swift
EatrRequestBuilder.httpGet.set(url : "http://your.url.here")
    .addHeader(withKey : "SOME-HEADER", andValue : "header_value")
    .addParam(withKey : "param_key", andValue : "param_value")
    .set(delegate : self)
    .asyncExecute()
```

---
## Contribute
We would love you for the contribution to **iOSEatr**, just contact me to nayanda1@outlook.com or just pull request
