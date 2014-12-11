import UIKit

class MobileNumberViewController: SetupScreenViewController, HTTPControllerProtocol {
    
    @IBOutlet weak var countryCodeField: UITextField!
    @IBOutlet weak var mobileNumberField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mobileNumberField.becomeFirstResponder()
        print("Loaded MobileNumberController")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        nextButton.enabled = true
        nextButton.backgroundColor = colorWithHexString("#00E85F") // green = enabled
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
    
    func didReceiveAPIResults(err: NSError?, queryID: String?, results: AnyObject?) {
        if (err != nil) {
            showError("Server error: \(err!.localizedDescription)")
            return
        }
        var jsonDic: Dictionary<String, AnyObject> = results as Dictionary<String, AnyObject>!
        let usernameObj: AnyObject? = jsonDic["username"]
        let authTokenObj: AnyObject? = jsonDic["authToken"]
        if (usernameObj == nil || authTokenObj == nil) {
            showError("Error: no return values")
            return
        }
            
        let username = usernameObj as String
        let authToken = authTokenObj as String

        dispatch_async(dispatch_get_main_queue(), {
            HTTPController.getInstance().saveLogin(username, authToken: authToken)
            self.performSegueWithIdentifier("fromNumberToConfirmation", sender: self)
        })
    }

    @IBAction func submitButtonPressed(sender: UIButton) {
        errorMessageLabel.hidden = true
        nextButton.enabled = false
        nextButton.backgroundColor = colorWithHexString("#8E8D93") // dark gray = disabled
        //Country Code doesn't seem to link to anything...
        //STEPH:NOT SURE WHAT TO DO WITH THAT????
        //let mobileNumber = countryCodeField.text + " " + mobileNumberField.text
        let mobileNumber = mobileNumberField.text
        let username = mobileNumber
        let password = Int(arc4random_uniform(99999999))
        var url = "/api/auth/register"
        var formData: [String: AnyObject] = [
            "username":  username,
            "password": password,
            "mobileNumber": mobileNumber
        ]

        HTTPController.getInstance().doPOST(url, parameters: formData, delegate: self, queryID: "SEND_MOBILE_NUMBER")
    }
    
    
}

