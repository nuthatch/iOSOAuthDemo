import UIKit

protocol SoundCloudLoginResultsDelegate: class {
    func didSucceed(loginViewController: SoundCloudLoginViewController, authResult: AuthenticationResult)
    func didFail(loginViewController: SoundCloudLoginViewController)
}

class SoundCloudLoginViewController: UIViewController, UIWebViewDelegate {

    var authenticator: SoundCloudAuthenticator?
    weak var delegate: SoundCloudLoginResultsDelegate?
    var webView: UIWebView? {
        get { return self.view as? UIWebView }
    }

    // MARK: - View Lifecycle

    override func loadView() {
        let webView = UIWebView(frame: CGRectZero)
        webView.delegate = self
        webView.scalesPageToFit = true
        self.view = webView
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        startAuthorization()
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    // MARK: - Private

    private func startAuthorization() {
        if let authenticator = self.authenticator, webView = self.webView {
            let url = authenticator.buildLoginURL()
            webView.loadRequest(NSURLRequest(URL: url))
        }
    }

    // MARK: - UIWebViewDelegate

    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let url = request.URL!
        if let authenticator = self.authenticator where authenticator.isOAuthResponse(url) {
            dismissViewControllerAnimated(true, completion: {
                if let authResult = authenticator.resultFromAuthenticationResponse(url), delegate = self.delegate {
                    delegate.didSucceed(self, authResult: authResult)
                } else if let delegate = self.delegate {
                    delegate.didFail(self)
                }
            })
        }
        return true
    }


}
