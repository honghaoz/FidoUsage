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
		
		let usageNavigationController = Locator.usageNavigationController
		addChildViewController(usageNavigationController)
		view.addSubview(usageNavigationController.view)
		
		usageNavigationController.didMoveToParentViewController(self)
		
		Client().loginWithNumber("5197812862", password: "")
	}
}

