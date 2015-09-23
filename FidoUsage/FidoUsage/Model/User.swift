//
//  User.swift
//  FidoUsage
//
//  Created by Honghao Zhang on 2015-09-22.
//  Copyright © 2015 Honghao Zhang. All rights reserved.
//

import Foundation

class User {
	static let sharedInstance = User()
	
	var number = ""
	var password = ""
	var isRemembered: Bool = true
	var isLoggedIn: Bool = false
	
	private let numberKey = "Username"
	private let passwordKey = "Password"
	private let isRememberedKey = "Remembered"
	
	func save() {
		let defaults = NSUserDefaults.standardUserDefaults()
		defaults.setBool(isRemembered, forKey: isRememberedKey)
		defaults.setObject(number, forKey: numberKey)
		defaults.setObject(password, forKey: passwordKey)
		defaults.synchronize()
	}
	
	
	func load() -> Bool {
		let defaults = NSUserDefaults.standardUserDefaults()
		self.isRemembered = defaults.boolForKey(isRememberedKey)
		if self.isRemembered {
			if let number = defaults.objectForKey(numberKey) as? String {
				self.number = number
			}
			
			if let password = defaults.objectForKey(passwordKey) as? String {
				self.password = password
			}
			return true
		}
		return false
	}
}