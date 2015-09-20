//
//  BaseNavigationController.swift
//  FidoUsage
//
//  Created by Honghao Zhang on 2015-09-18.
//  Copyright © 2015 Honghao Zhang. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {

	override func viewDidLoad() {
		super.viewDidLoad()
		
		UINavigationBar.appearance().translucent = false
		UINavigationBar.appearance().barTintColor = UIColor.fidoYellowColor()
	}
}
