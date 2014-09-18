//
//  HTTPController.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 9/17/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import Foundation
import Alamofire

protocol HTTPControllerProtocol {
    func didReceiveAPIResults(err: NSError?, results: NSDictionary?)
}

class HTTPController {
    
    
    class func getInstance() -> HTTPController {
        return HTTPController() //for now just create a new instance, class variables not supported yet
    }
    
    private init() {
        /*
        let path = NSBundle.mainBundle().pathForResource("Config", ofType: "plist")
        let config:NSDictionary = NSDictionary(contentsOfFile:path)
        host = config.objectForKey("host") as String
        */
    }

   
    
    private func doRequest(urlPath: String, method: Alamofire.Method, parameters: [String: AnyObject]? = nil, delegate: HTTPControllerProtocol) {
        Alamofire.request(method, urlPath, parameters: parameters)
            .responseJSON { (request, response, json, error) in
                println("doGET: url=\(urlPath) params=\(parameters)")
                println("doGET: req=\(request) res=\(response) json=\(json) err=\(error)")
                var jsonDic: Dictionary<String, AnyObject>?
                if (error == nil) {
                    jsonDic = json as Dictionary<String, AnyObject>!
                }
                delegate.didReceiveAPIResults(error, results: jsonDic)
        }
    }
    
    func doGET(urlPath: String, parameters: [String: AnyObject]? = nil, delegate: HTTPControllerProtocol) {
        doRequest(urlPath, method:.GET, parameters: parameters, delegate: delegate)
    }
    
    func doPOST(urlPath: String, parameters: [String: AnyObject]? = nil, delegate: HTTPControllerProtocol) {
        doRequest(urlPath, method:.POST, parameters: parameters, delegate: delegate)
    }
    
    func doLogin(delegate: HTTPControllerProtocol) {
        let userDefaults = NSUserDefaults.standardUserDefaults();
        let username: NSString? = userDefaults.objectForKey("username") as NSString?
        let authToken: NSString? = userDefaults.objectForKey("authToken") as NSString?
        
        if username != nil && authToken != nil {
            var url = "http://lit-woodland-6706.herokuapp.com/api/auth/login"
            var formData: [String: AnyObject] = [
                "username": username!,
                "password": authToken!
            ]
            doPOST(url, parameters: formData, delegate: delegate)
        } else {
            // no login data yet (first time use)
            let error: NSError = NSError()
            delegate.didReceiveAPIResults(error, results: nil)
        }
    }
    
    func saveLogin(username: String, authToken: String) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(username as NSString, forKey: "username")
        userDefaults.setObject(authToken as NSString, forKey: "authToken")
        userDefaults.synchronize()
        print("Saved key: ") ; println(userDefaults.objectForKey("username") as? NSString)
    }
    

}


    /*
    func old_doGET(urlPath: String, delegate: HTTPControllerProtocol) {
        println("calling doGET on "+urlPath)
        let url: NSURL = NSURL(string: urlPath)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
            println("Task completed")
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println("Error in doGET: "+error.localizedDescription)
                return delegate.didReceiveAPIResults(error, results: nil)
            }
            
            var err: NSError?
            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
            if(err != nil) {
                // If there is an error parsing JSON, print it to the console
                println("JSON Error \(err!.localizedDescription)")
                return delegate.didReceiveAPIResults(err, results: nil)
            }
            println("doGET result \(jsonResult)")
            delegate.didReceiveAPIResults(nil, results: jsonResult)
        })
        
        task.resume()
    }
    
    func old_doPOST(urlPath: String, formData: Dictionary<String, String>, delegate: HTTPControllerProtocol) {
        var formDataString = ""
        for (key, value) in formData {
            if (countElements(formDataString) > 0) {
                formDataString += "&"
            }
            formDataString += key + "=" + value
        }
        var url = urlPath + "?" + formDataString;
        println("Warning: faking doPOST into doGET with params = "+formDataString)
        
    }*/
        
    /*
let url: NSURL = NSURL(string: urlPath)
let urlRequest: NSURLRequest = NSURLRequest(URL: url)
let escapedFormDataString: String = formDataString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
let formDataObj: NSData = (formData as NSString).dataUsingEncoding(NSUTF8StringEncoding)!
let session = NSURLSession.sharedSession()
let task = session.uploadTaskWithRequest(urlRequest, fromData: formDataObj, completionHandler: {data, response, error -> Void in
println("Task completed")
if(error != nil) {
If there is an error in the web request, print it to the console
println(error.localizedDescription)
return
}

var err: NSError?
var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary

if(err != nil) {
If there is an error parsing JSON, print it to the console
println("JSON Error \(err!.localizedDescription)")
}
delegate.didReceiveAPIResults(jsonResult)
})
task.resume()*/


    /*
    func request(method:Int, url:String, params:Dictionary<String, AnyObject>, requestSuccessHandler: (Dictionary<String, NSObject>) -> (), requestFailureHandler: (Int) -> Bool) {

    func localFailureHandler(statusCode:Int) {
    let consumed = requestFailureHandler(statusCode)
    if !consumed {
    self.onRequestError(statusCode)
    }
    }
    
    let manager:AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
    manager.requestSerializer = AFJSONRequestSerializer()
    
    
    println("Request method: " + method.description + ", url: " + url + ", params: " + params.description)
    
    //TODO handle possible error response with html e.g. not found page
    
    //FIXME getting weird error messages when use NSDictionary or Dictionary<String, NSObject> as type of response
    let successHandler = {(operation: AFHTTPRequestOperation!, response: AnyObject!) -> () in
    
    println("Request response: " + response.description)
    
    let responseDict = response as Dictionary<String, NSObject>
    
    let statusCode:Int =  (responseDict["status"] as NSNumber).integerValue
    
    if statusCode == 1 {
    requestSuccessHandler(responseDict)
    
    } else {
    localFailureHandler(statusCode)
    }
    }
    
    let failureHandler = {(operation: AFHTTPRequestOperation!, error: NSError!) -> () in
    
    println("Request error: " + error.description)
    
    let statusCode:Int =  9
    localFailureHandler(statusCode)
    }
    
    if (method == 1) {
    manager.GET(url, parameters: params, success: successHandler, failure: failureHandler)
    } else if (method == 2) {
    manager.POST(url, parameters: params, success: successHandler, failure: failureHandler)
    } else {
    
    }
    }
    
    func onRequestError(statusCode:Int) {
    var errorMsg = ""
    
    switch(statusCode) {
    case 0, 2, 9 /* 9 is a local error -> wrong json format (TODO?) */:
    errorMsg = "An unknown error ocurred. Please try again later."
    case 4:
    errorMsg = "Not found."
    case 5:
    errorMsg = "Validation error."
    case 3:
    errorMsg = "User already exists."
    case 6:
    errorMsg = "Login failed, check your data is correct."
    case 7:
    errorMsg = "Not authenticated, please register/login and try again."
    case 8:
    errorMsg = "Connection error."
    default:
    break;
    }
    DialogUtils.showAlert("Error", msg: errorMsg)
    }
    */