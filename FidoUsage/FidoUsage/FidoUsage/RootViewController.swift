//
//  RootViewController.swift
//  FidoUsage
//
//  Created by Honghao Zhang on 2015-09-18.
//  Copyright © 2015 Honghao Zhang. All rights reserved.
//

import UIKit
import ChouTi
import WebKit

// Ref: WebKit: http://blog.csdn.net/reylen/article/details/46437517

class RootViewController: UIViewController {
	
	let loginWebView = WKWebView()
    var loginTask: Task?
    
	override func viewDidLoad() {
		super.viewDidLoad()
		addUsageContainerViewController()
		
		let url = NSURL(string: "https://www.fido.ca/pages/#/login?m=login")
		let urlRequest = NSURLRequest(URL: url!)
		
		loginWebView.loadRequest(urlRequest)
		loginWebView.navigationDelegate = self
		
		view.addSubview(loginWebView)
		loginWebView.fullSizeMarginInSuperview()
        
        loginWebView.observe("loading") { (oldValue, newValue) -> Void in
            if oldValue == true && newValue == false {
                self.login()
            }
        }
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
//		
//		let user = Locator.user
//		if user.isLoggedIn == false {
//			let loginVC = Locator.loginViewController
//			loginVC.modalPresentationStyle = .Custom
//			loginVC.transitioningDelegate = loginVC
//			
//			let usageContainerVC = Locator.usageContainerViewController
//			usageContainerVC.presentViewController(loginVC, animated: true, completion: nil)
//		}
	}
	
	func addUsageContainerViewController() {
		let usageContainerNavigationController = Locator.usageContainerNavigationController
		addChildViewController(usageContainerNavigationController)
		view.addSubview(usageContainerNavigationController.view)
		
		usageContainerNavigationController.didMoveToParentViewController(self)
	}
}

extension RootViewController {
    func login() {
        log.debug()
        loginWebView.evaluateJavaScript("document.readyState") { [unowned self] (result, error) -> Void in
            guard error == nil else {
                log.error(error)
                return
            }
            
            log.debug("Login Page Loaded")
            
            if self.loginTask == nil {
                self.loginTask = delay(1) {
                    // Fill in username
                    self.loginWebView.evaluateJavaScript("document.getElementById('capture_signIn_userID').value='5197812862'", completionHandler: nil)
                    
                    // Fill in password
                    self.loginWebView.evaluateJavaScript("document.getElementById('capture_signIn_currentPassword').value='Shanxi142301!'", completionHandler: nil)
                    
                    // Click Login button
                    // <button class="capture_secondary capture_btn capture_primary" type="submit"><span class="janrain-icon-16 janrain-icon-key"></span><ins translate="global.cta.logIn">Log In</ins></button>
                    self.loginWebView.evaluateJavaScript("document.evaluate('//button[@class=\"capture_secondary capture_btn capture_primary\"][@type=\"submit\"]', document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.click()") { result, error in
                        guard error == nil else {
                            log.error(error)
                            return
                        }
                        
                        log.debug("Login Button Clicked")
                    }
                }
            }
        }
    }
}

extension RootViewController : WKNavigationDelegate {
    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
        log.debug()
    }
    
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        log.debug()
    }
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        log.debug()
    }
    
	func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
		log.debug()
	}
    
    func webView(webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        log.debug()
    }
    
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        log.debug()
    }
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        log.debug(navigationAction.request)
        log.debug(navigationAction.navigationType)
        decisionHandler(.Allow)
    }
    
    func webView(webView: WKWebView, decidePolicyForNavigationResponse navigationResponse: WKNavigationResponse, decisionHandler: (WKNavigationResponsePolicy) -> Void) {
        log.debug()
        decisionHandler(.Allow)
    }
}

