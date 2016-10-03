//
//  ViewController.swift
//  LineSDKDemo
//
//  Created by Kittisak Phetrungnapha on 10/2/2559 BE.
//  Copyright © 2559 Kittisak Phetrungnapha. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var resultOutputTextView: UITextView!
    var lineAdapter :LineAdapter!
    
    @IBAction func loginWithLineAppButtonTouch(_ sender: AnyObject) {
        if lineAdapter.isAuthorized {
            // If the authentication and authorization process has already been performed
            showAlertMsg(withViewController: self, message: "You have already been authorized. Nothing to do.")
        }
        else if lineAdapter.canAuthorizeUsingLineApp {
            // Authenticate with LINE application
            lineAdapter.authorize()
        }
        else {
            loginWithWebView()
        }
    }
    
    @IBAction func loginWithWebViewTouched(_ sender: AnyObject) {
        if lineAdapter.isAuthorized {
            // If the authentication and authorization process has already been performed
            showAlertMsg(withViewController: self, message: "You have already been authorized. Nothing to do.")
        }
        else {
            loginWithWebView()
        }
    }
    
    @IBAction func getUserProfileTouched(_ sender: AnyObject) {
        if lineAdapter.isAuthorized {
            lineAdapter.getLineApiClient().getMyProfile { (response: [AnyHashable : Any]?, error : Error?) in
                if let error = error {
                    self.showAlertMsg(withViewController: self, message: error.localizedDescription)
                    return
                }
                
                var output = ""
                
                if let apiClient = self.lineAdapter.getLineApiClient() {
                    output += "[access token] " + apiClient.accessToken + "\n\n" +
                                    "[refresh token] " + apiClient.refreshToken + "\n\n"
                }
                if let display_name = response?["displayName"] as? String {
                    output += "[display name] " + display_name + "\n\n"
                }
                if let mid = response?["mid"] as? String {
                    output += "[uid] " + mid + "\n\n"
                }
                if let pictureUrl = response?["pictureUrl"] as? String {
                    output += "[pictureUrl] " + pictureUrl + "\n\n"
                }
                if let statusMessage = response?["statusMessage"] as? String {
                    output += "[statusMessage] " + statusMessage
                }
                
                self.resultOutputTextView.text = output
            }
        }
        else {
            showAlertMsg(withViewController: self, message: "Please login first.")
        }
    }
    
    @IBAction func logoutButtonTounched(_ sender: AnyObject) {
        if lineAdapter.isAuthorized {
            resultOutputTextView.text = ""
            lineAdapter.unauthorize()
            showAlertMsg(withViewController: self, message: "Logout with Line successfully.")
        }
        else {
            showAlertMsg(withViewController: self, message: "You have already been unauthorized. Nothing to do.")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        lineAdapter = LineAdapter.withConfigFile()
        
        NotificationCenter.default.addObserver(self, selector: #selector(lineAdapterAuthorizationDidChange(with:)), name: NSNotification.Name.LineAdapterAuthorizationDidChange, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.LineAdapterAuthorizationDidChange, object: nil)
    }
    
    func loginWithWebView() {
        // Authenticate with LineAdapterWebViewController inside our apps
        let vc = LineAdapterWebViewController(adapter: lineAdapter, with: kOrientationAll) as LineAdapterWebViewController
        let leftBarButtonItem = LineAdapterNavigationController.barButtonItem(withTitle: "Cancel", target: self, action: #selector(cancel))
        vc.navigationItem.setLeftBarButton(leftBarButtonItem, animated: true)
        let nav = LineAdapterNavigationController(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
    }
    
    func lineAdapterAuthorizationDidChange(with notification: NSNotification) {
        if let adapter = notification.object as? LineAdapter {
            if adapter.isAuthorized {
                // Connection completed to LINE.
                self.dismiss(animated: true, completion: nil)
                showAlertMsg(withViewController: self, message: "Login with Line successfully. Please perform print user profile.")
            }
            else  {
                if let error = notification.userInfo?["error"] as? NSError {
                    showAlertMsg(withViewController: self, message: error.localizedDescription)
                }
            }
        }
        else {
            showAlertMsg(withViewController: self, message: "LineAdapter is null!")
        }
    }
    
    func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showAlertMsg(withViewController vc: UIViewController, message: String) {
        let alert = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        vc.present(alert, animated: true, completion: nil)
    }

}

