import UIKit

class MeViewController: UIViewController, SoundCloudLoginResultsDelegate {

    let oauthState = OAuthState(
        clientId: "Put your client ID here",
        clientSecret: "Put your client secret here",
        redirectUri: "Put your redirect URI here",
        responseType: OAuthResponseType.Token)

    var authResult: AuthenticationResult?
    @IBOutlet weak var usernameLabel: UILabel?
    @IBOutlet weak var uriLabel: UILabel?

    // MARK: - View Lifecycle

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? SoundCloudLoginViewController,
               segueID = segue.identifier where segueID == "LoginSegue" {
            controller.authenticator = SoundCloudAuthenticator(oauthState: oauthState)
            controller.delegate = self
        }
    }

    // MARK: - SoundCloudLoginResultsDelegate

    func didSucceed(loginViewController: SoundCloudLoginViewController, authResult: AuthenticationResult) {
        requestMe(authResult.value)
        showAlert("Authenticated!", message: "Received token \(authResult.value)")
    }

    func didFail(loginViewController: SoundCloudLoginViewController) {
        showAlert("Error", message: "Failed to authenticate")
    }

    // MARK: - Private

    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }

    private func requestMe(token: String) {
        let url = NSURL(string: "https://api.soundcloud.com/me.json?oauth_token=\(token)")!
        //let request = NSURLRequest(URL: url)
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
                                   delegate: nil, delegateQueue: NSOperationQueue.mainQueue())

        let dataTask = session.dataTaskWithURL(url) { (data, response, error) -> Void in
            if let jsonOutput = (try? NSJSONSerialization.JSONObjectWithData(data!, options: [])) as? [String:AnyObject] {
                self.displayMe(jsonOutput)
            }
        }
        dataTask.resume()
    }

    private func displayMe(jsonDict: [String:AnyObject]) {
        usernameLabel?.text = jsonDict["username"] as? String
        uriLabel?.text = jsonDict["uri"] as? String
    }
}
