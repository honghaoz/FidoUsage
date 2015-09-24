//
//  TodayViewController.swift
//  Fido Usage Today Extension
//
//  Created by Honghao Zhang on 2015-09-24.
//  Copyright © 2015 Honghao Zhang. All rights reserved.
//

import UIKit
import NotificationCenter
import Loggerithm
import Client
import User

let log = Loggerithm()

class TodayViewController: UIViewController, NCWidgetProviding {
        
	@IBOutlet weak var helloLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.preferredContentSize = CGSize(width: 0, height: 37)
    }
	
	func update() {
		let user = User.sharedInstance
		if user.load() {
			log.debug("User info loaded")
			let client = FidoClient.sharedInstance
			let number = user.number
			let password = user.password
			
			log.info("Logging in with number: \(number)")
			helloLabel.text = "Logging in with number: \(number)"
			client.loginWithNumber(number, password: password) { [unowned self] (succeed, resultDict) in
				if succeed {
					log.debug("Login Results: \(resultDict)")
					
					self.helloLabel.text = String(format: "Logged in as: %@", resultDict!["Account holder"]!)
					
					log.info("Goto View Usage Page ...")
					client.gotoViewUsagePage { (succeed, sections) in
						guard let sections = sections else {
							log.error("Sections are emtpy")
							return
						}
						log.debug("Usage Sections: \(sections)")
						
						client.showViewUsgaeForSection(sections[1], completion: { (succeed, table) in
							let used = table!["Used"]!
							let remaining = table!["Remaining"]!
							
							self.helloLabel.text = "Used: \(used)   Remaining: \(remaining)"
							log.debug(self.helloLabel.text)
						})
					}
				} else {
					log.error("")
				}
			}
		} else {
			log.debug("User info is not existed")
			self.helloLabel.text  = "User info is not existed"
		}
	}
	
	func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
		return UIEdgeInsetsZero
	}
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
		log.info()
		
		update()
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
    }
}
