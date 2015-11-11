//
//  LoginViewController.swift
//  FidoUsage
//
//  Created by Honghao Zhang on 2015-09-22.
//  Copyright © 2015 Honghao Zhang. All rights reserved.
//

import UIKit
import Client
import ChouTi
import LTMorphingLabel

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
		
		let label = LoadingMorphingLabel()
		
		label.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(label)
		
		label.loopCount = Int.max
		label.delayDuration = 0.5
		label.centerInSuperview()
		label.morphingLabel.morphingEffect = .Fall
		
		label.texts = ["春眠不觉晓", "处处蚊子咬", "问君何所去", "撕🐑是傻逼", "是呆逼"]
		
//		label123.text = "123"
		
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
		
		log.info("Login with number: \(number)")
		Locator.client.loginWithNumber(number, password: password) {[unowned self] (succeed, resultDict) in
			if succeed {
				log.debug("Login Results: \(resultDict)")
		
				self.user.isLoggedIn = true
				self.user.number = number
				self.user.password = password
				self.user.save()
		
				self.dismissViewControllerAnimated(true, completion: {_ in
					Locator.rootViewController.showUsageViewController()
				})
				
			} else {
				log.error("Login failed")
			}
		}
	}
}
