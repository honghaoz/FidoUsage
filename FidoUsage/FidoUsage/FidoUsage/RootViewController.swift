//
//  RootViewController.swift
//  FidoUsage
//
//  Created by Honghao Zhang on 2015-09-18.
//  Copyright © 2015 Honghao Zhang. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		let user = Locator.user
		if !user.isLoggedIn {
			let loginVC = Locator.loginViewController
			presentViewController(loginVC, animated: true, completion: nil)
		}
	}
	
	func showUsageViewController() {
		let usageNavigationController = Locator.usageNavigationController
		addChildViewController(usageNavigationController)
		view.addSubview(usageNavigationController.view)
		
		usageNavigationController.didMoveToParentViewController(self)
	}
}
