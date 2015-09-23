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

class Locator {
    static let sharedInstance = Locator()
	
	class var appDelegate: AppDelegate {
		return UIApplication.sharedApplication().delegate as! AppDelegate
	}
	
	class var client: Client { return Client.sharedInstance }
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
//
//	// MARK: - Left Menu View Controller
//	private lazy var _leftMenuViewController: LeftMenuViewController = {
//		let controller = UIViewController.viewControllerInStoryboard("Main", viewControllerName: "LeftMenuViewController") as! LeftMenuViewController
//		return controller
//	}()
//	
//	class var leftMenuViewController: LeftMenuViewController {
//		return sharedInstance._leftMenuViewController
//	}
	
	// MARK: - Login View Controller
	private lazy var _loginViewController: LoginViewController = {
		return UIViewController.viewControllerInStoryboard("Login", viewControllerName: "LoginViewController") as! LoginViewController
	}()
	
	class var loginViewController: LoginViewController {
		return sharedInstance._loginViewController
	}
	
	// MARK: - Usage View Controller
	private lazy var _usageViewController: UsageViewController = {
		return UIViewController.viewControllerInStoryboard("Main", viewControllerName: "UsageViewController") as! UsageViewController
	}()
	
	class var usageViewController: UsageViewController {
		return sharedInstance._usageViewController
	}
	
	class var usageNavigationController: BaseNavigationController {
		return BaseNavigationController(rootViewController: usageViewController)
	}
//
//	// MARK: - Ticket View Controller
//	private lazy var _ticketViewController: TicketViewController = { return TicketViewController() }()
//	
//	class var ticketViewController: TicketViewController {
//		return sharedInstance._ticketViewController
//	}
//	
//	class var ticketNavigationController: BaseNavigationController {
//		return BaseNavigationController(rootViewController: ticketViewController)
//	}
}
