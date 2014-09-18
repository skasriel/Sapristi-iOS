import UIKit

class MobileNumberViewController: UIViewController, HTTPControllerProtocol {
    
    @IBOutlet weak var countryCodeField: UITextField!
    @IBOutlet weak var mobileNumberField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mobileNumberField.becomeFirstResponder()
        print("Loaded MobileNumberController")
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showError(error: String) {
        nextButton.enabled = true
        errorMessageLabel.text = error
        errorMessageLabel.hidden = false
        println("showError: \(error)")
    }
    
    func didReceiveAPIResults(err: NSError?, results: NSDictionary?) {
        println("In didReceiveAPIResults")
        if (err != nil) {
            showError("Server error: \(err!.localizedDescription)")
            return
        }
        let usernameObj: AnyObject? = results!["username"]
        let authTokenObj: AnyObject? = results!["authToken"]
        if (usernameObj == nil || authTokenObj == nil) {
            showError("Error: no return values")
            return
        }
        let username = usernameObj as String
        let authToken = authTokenObj as String

        dispatch_async(dispatch_get_main_queue(), {
            println("Results = \(username) \(authToken)")

            HTTPController.getInstance().saveLogin(username, authToken: authToken)
            
            self.performSegueWithIdentifier("fromNumberToConfirmation", sender: self)
            //self.tableData = resultsArr
            //self.appsTableView!.reloadData()
        })
    }

    @IBAction func submitButtonPressed(sender: UIButton) {
        errorMessageLabel.hidden = true
        nextButton.enabled = false
        let mobileNumber = countryCodeField.text + " " + mobileNumberField.text
        let username = mobileNumber
        let password = Int(arc4random_uniform(99999999))
        var url = "http://lit-woodland-6706.herokuapp.com/api/auth/register"
        var formData: [String: AnyObject] = [
            "username":  username,
            "password": password,
            "mobileNumber": mobileNumber
        ]

        HTTPController.getInstance().doPOST(url, parameters: formData, delegate: self)
    }
    
    
}

