//
//  LoginViewController.swift
//  FidoUsage
//
//  Created by Honghao Zhang on 2015-09-22.
//  Copyright © 2015 Honghao Zhang. All rights reserved.
//

import UIKit

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
		
		Locator.client.loginWithNumber(number, password: password) {[unowned self] (succeed, resultHTMLString) in
			if succeed {
				guard let homeHTMLString = resultHTMLString else {
					log.error("homeHTMLString is nil")
					return
				}
				log.debug("Succeed")
				
				self.user.isLoggedIn = true
				self.user.number = number
				self.user.password = password
				self.user.save()
				
				Locator.fidoParser.parseAccountDetails(homeHTMLString)
				
				self.dismissViewControllerAnimated(true, completion: {_ in
					Locator.rootViewController.showUsageViewController()
				})
				
			} else {
				log.error("")
			}
		}
	}
}
