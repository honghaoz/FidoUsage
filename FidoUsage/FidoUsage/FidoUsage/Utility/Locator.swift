//
//  Locator.swift
//  FidoUsage
//
//  Created by Honghao Zhang on 2015-08-10.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import UIKit
import ChouTi
import CoreData
import Client
import User

class Locator {
    static let sharedInstance = Locator()
	
	class var appDelegate: AppDelegate {
		return UIApplication.sharedApplication().delegate as! AppDelegate
	}
	
	class var client: FidoClient { return FidoClient.sharedInstance }
	class var fidoParser: FidoHTMLParser { return FidoHTMLParser.sharedInstance }
	
	class var user: User { return User.sharedInstance }
	
    // MARK: - Root View Controller
    private lazy var _rootViewController: RootViewController = {
		if let controller = Locator.appDelegate.window?.rootViewController as?  RootViewController {
			return controller
		} else {
			log.error("Getting root view controller failed.")
			return RootViewController()
		}
    }()
	
    class var rootViewController: RootViewController {
		set {
			sharedInstance._rootViewController = newValue
		}
		
		get {
			return sharedInstance._rootViewController
		}
    }
	
	// MARK: - Login View Controller
	private lazy var _loginViewController: LoginViewController = {
		return UIViewController.viewControllerInStoryboard("Login", viewControllerName: "LoginViewController") as! LoginViewController
	}()
	
	class var loginViewController: LoginViewController {
		return sharedInstance._loginViewController
	}
	
	// MARK: - Usage Container View Controller
	private lazy var _usageContainerViewController: UsageContainerViewController = {
		return UsageContainerViewController()
	}()
	
	class var usageContainerViewController: UsageContainerViewController {
		return sharedInstance._usageContainerViewController
	}
	
	class var usageContainerNavigationController: BaseNavigationController {
		return BaseNavigationController(rootViewController: usageContainerViewController)
	}
}
