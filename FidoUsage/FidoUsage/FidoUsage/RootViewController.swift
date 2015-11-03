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
		
//		let user = Locator.user
//		if user.isLoggedIn == false {
//			let loginVC = Locator.loginViewController
//			presentViewController(loginVC, animated: true, completion: nil)
//		}
		
		showUsageViewController()
	}
	
	func showUsageViewController() {
		let usageContainerNavigationController = Locator.usageContainerNavigationController
		addChildViewController(usageContainerNavigationController)
		view.addSubview(usageContainerNavigationController.view)
		
		usageContainerNavigationController.didMoveToParentViewController(self)
	}
}
