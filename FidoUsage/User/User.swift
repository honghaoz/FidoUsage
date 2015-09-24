//
//  User.swift
//  FidoUsage
//
//  Created by Honghao Zhang on 2015-09-22.
//  Copyright © 2015 Honghao Zhang. All rights reserved.
//

import Foundation
import Loggerithm
let log = Loggerithm()

public class User {
	static public let sharedInstance = User()
	
	public var number = ""
	public var password = ""
	public var isRemembered: Bool = true
	public var isLoggedIn: Bool = false
	
	private let numberKey = "Username"
	private let passwordKey = "Password"
	private let isRememberedKey = "Remembered"
	
	let defaults = NSUserDefaults(suiteName: "group.com.honghaoz.fidoUsage")
	
	public func save() {
		guard let defaults = defaults else {
			log.error("defaults is nil")
			return
		}
		
		defaults.setBool(isRemembered, forKey: isRememberedKey)
		defaults.setObject(number, forKey: numberKey)
		defaults.setObject(password, forKey: passwordKey)
		defaults.synchronize()
	}
	
	
	public func load() -> Bool {
		guard let defaults = defaults else {
			log.error("defaults is nil")
			return false
		}
		
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
