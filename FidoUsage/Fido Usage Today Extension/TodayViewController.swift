//
//  TodayViewController.swift
//  Fido Usage Today Extension
//
//  Created by Honghao Zhang on 2015-09-24.
//  Copyright © 2015 Honghao Zhang. All rights reserved.
//

import UIKit
import NotificationCenter
import Client
import Loggerithm

let log = Loggerithm()

class TodayViewController: UIViewController, NCWidgetProviding {
        
	@IBOutlet weak var helloLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
		
		log.debug("haha")
		
		let client = Client.sharedInstance
		let number = "5197812862"
		let password = "Zhh358279765099"
		
		log.info("Login with number: \(number)")
		client.loginWithNumber(number, password: password) { [unowned self] (succeed, resultDict) in
			if succeed {
				log.debug("Login Results: \(resultDict)")
				
				self.helloLabel.text = resultDict!["Account holder"]
				
				log.info("Goto View Usage Page ...")
				client.gotoViewUsagePage { (succeed, sections) in
					guard let sections = sections else {
						log.error("Sections are emtpy")
						return
					}
					log.debug("Usage Sections: \(sections)")
				}
			} else {
				log.error("")
			}
		}
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
    }
    
}
