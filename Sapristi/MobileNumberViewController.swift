import UIKit

class MobileNumberViewController: UIViewController {
    
    @IBOutlet weak var countryCodeField: UITextField!
    
    @IBOutlet weak var mobileNumberField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Loaded MobileNumberController")
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func submitButtonPressed(sender: UIButton) {
        print("Button pressed")
        mobileNumberField.text = "Please wait"
        var fullNumber = countryCodeField.text + " " + mobileNumberField.text
        
        
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: "http://itunes.apple.com/search?term=test")//"http://10.0.1.32:3000/api/register")
        let urlRequest: NSURLRequest = NSURLRequest(URL: url)
        let formDataString: String = "username=123&password=abc&mobileNumber=456"
        let escapedFormDataString: String = formDataString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let formData: NSData = (formDataString as NSString).dataUsingEncoding(NSUTF8StringEncoding)!
        let httpTask = session.uploadTaskWithRequest(urlRequest, fromData: formData, completionHandler: {data, response, error -> Void in
            
            println("Task completed")
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
                return
            }
            var err: NSError?
            
            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
            
            if(err != nil) {
                // If there is an error parsing JSON, print it to the console
                println("JSON Error \(err!.localizedDescription)")
            }
            let results: NSArray = jsonResult["results"] as NSArray
            dispatch_async(dispatch_get_main_queue(), {
                println(results)
                //                self.tableData = results
                //                self.appsTableView!.reloadData()
            })
        })
        httpTask.resume()
            
        /* GET REQUEST
        var escapedSearchTerm = "madonna"
        var url = NSURL(string: "http://itunes.apple.com/search?term=\(escapedSearchTerm)&media=software")
        let task = session.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
            println("Task completed")
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
            }
            var err: NSError?
            
            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary

            if(err != nil) {
                // If there is an error parsing JSON, print it to the console
                println("JSON Error \(err!.localizedDescription)")
            }
            let results: NSArray = jsonResult["results"] as NSArray
            dispatch_async(dispatch_get_main_queue(), {
                println(results)
//                self.tableData = results
//                self.appsTableView!.reloadData()
            })
        })
        
        task.resume()
*/
        
        //segueForUnwindingToViewController(<#toViewController: UIViewController!#>, fromViewController: <#UIViewController!#>, identifier: <#String!#>)
    }
    
    
}

