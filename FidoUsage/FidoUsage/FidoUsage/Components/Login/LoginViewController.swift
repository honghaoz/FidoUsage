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

	@IBOutlet weak var numberField: TextField!
	@IBOutlet weak var passwordField: TextField!
	@IBOutlet weak var loginButton: UIButton!
	@IBOutlet weak var separatorView: UIView!
	
	@IBOutlet weak var separatorViewHeightConstraint: NSLayoutConstraint!
	
	let user = Locator.user
	
	let animator = DropPresentingAnimator()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		animator.animationDuration = 0.75
		animator.shouldDismissOnTappingOutsideView = false
		animator.presentingViewSize = CGSize(width: ceil(screenWidth * 0.7), height: 160)
		
		setupViews()
		loadFromUser()
    }
	
	private func setupViews() {
		view.layer.cornerRadius = 10.0
		
		numberField.layer.cornerRadius = 4.0
		numberField.textHorizontalPadding = 10.0
		numberField.textVerticalPadding = 10.0
		
		passwordField.layer.cornerRadius = 4.0
		passwordField.textHorizontalPadding = 10.0
		passwordField.textVerticalPadding = 10.0
		
		view.clipsToBounds = false
		view.layer.shadowColor = UIColor.blackColor().CGColor
		view.layer.shadowOffset = CGSizeZero
		view.layer.shadowRadius = 15.0
		view.layer.shadowOpacity = 0.8
		
		numberField.keyboardType = .PhonePad
		numberField.font = UIFont.systemFontOfSize(20)
		
		passwordField.secureTextEntry = true
		passwordField.font = UIFont.systemFontOfSize(20)
		
		separatorViewHeightConstraint.constant = 0.5
		separatorView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
		
		loginButton.titleLabel?.tintColor = UIColor.fidoTealColor()
		
		view.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		view.layer.shadowPath = UIBezierPath(rect: view.bounds).CGPath
	}
	
	private func loadFromUser() {
		if user.load() {
			numberField.text = user.number
			passwordField.text = user.password
		}
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
					Locator.usageContainerViewController.loadData()
				})
			} else {
				log.error("Login failed")
			}
		}
	}
}

extension LoginViewController : UIViewControllerTransitioningDelegate {
	func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		animator.presenting = true
		return animator
	}
	
	func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		animator.presenting = false
		return animator
	}
}
