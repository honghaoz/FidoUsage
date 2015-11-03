//
//  LoginViewController.swift
//  FidoUsage
//
//  Created by Honghao Zhang on 2015-09-22.
//  Copyright © 2015 Honghao Zhang. All rights reserved.
//

import UIKit
import Client

class LoginViewController: UIViewController {

	@IBOutlet weak var numberField: UITextField!
	@IBOutlet weak var passwordField: UITextField!
	@IBOutlet weak var rememberSwitch: UISwitch!
	@IBOutlet weak var loginButton: UIButton!
	
	let user = Locator.user
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setupViews()
		
		loadFromUser()
    }
	
	private func setupViews() {
		numberField.keyboardType = .PhonePad
		passwordField.secureTextEntry = true
	}
	
	private func loadFromUser() {
		if user.load() {
			numberField.text = user.number
			passwordField.text = user.password
		}
		
		user.isRemembered = rememberSwitch.on
	}
	
	@IBAction func rememberSwitchTapped(sender: UISwitch) {
		user.isRemembered = rememberSwitch.on
	}
	
	@IBAction func loginButtonTapped(sender: UIButton) {
		guard let number = numberField.text, password = passwordField.text where !number.isEmpty && !password.isEmpty else {
			log.error("Number/Password invalid")
			return
		}
		
//		log.info("Login with number: \(number)")
//		Locator.client.loginWithNumber(number, password: password) {[unowned self] (succeed, resultDict) in
//			if succeed {
//				log.debug("Login Results: \(resultDict)")
//		
//				self.user.isLoggedIn = true
//				self.user.number = number
//				self.user.password = password
//				self.user.save()
		
				self.dismissViewControllerAnimated(true, completion: {_ in
					Locator.rootViewController.showUsageViewController()
				})
				
//			} else {
//				log.error("Login failed")
//			}
//		}
	}
}
