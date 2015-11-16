//
//  RootViewController.swift
//  FidoUsage
//
//  Created by Honghao Zhang on 2015-09-18.
//  Copyright © 2015 Honghao Zhang. All rights reserved.
//

import UIKit
import ChouTi

class RootViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		addUsageContainerViewController()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		let user = Locator.user
		if user.isLoggedIn == false {
			let loginVC = Locator.loginViewController
			loginVC.modalPresentationStyle = .Custom
			loginVC.transitioningDelegate = loginVC
			
			let usageContainerVC = Locator.usageContainerViewController
			usageContainerVC.presentViewController(loginVC, animated: true, completion: nil)
		}
	}
	
	func addUsageContainerViewController() {
		let usageContainerNavigationController = Locator.usageContainerNavigationController
		addChildViewController(usageContainerNavigationController)
		view.addSubview(usageContainerNavigationController.view)
		
		usageContainerNavigationController.didMoveToParentViewController(self)
	}
}
