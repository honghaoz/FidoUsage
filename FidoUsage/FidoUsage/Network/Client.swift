//
//  Client.swift
//  FidoUsage
//
//  Created by Honghao Zhang on 2015-08-12.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import Foundation
import Alamofire
import Ji

class Client {
    static let loginURL = "https://www.fido.ca/web/Fido.portal?_nfpb=true&_windowLabel=FidoSignIn_1_1&FidoSignIn_1_1_actionOverride=%2Fcom%2Ffido%2Fportlets%2Fecare%2Faccount%2Fsignin%2FsignIn"
	static let viewUsageURL = "https://www.fido.ca/web/page/portal/Fido/Ecare_MSSPostPaid"
	static let individualUsageURL = "https://www.fido.ca/web/Fido.portal?_nfpb=true&_windowLabel=mobileSelfServe_1_2&mobileSelfServe_1_2_actionOverride=%2Fcom%2Ffido%2Fportlets%2Fecare%2FmobileSelfServeUsage%2FmanagePostPaidUsage"
    static let sharedInstance = Client()
}


// MARK: - Login
extension Client {
	func loginWithNumber(number: String, password: String, completion: ((Bool, String?) -> Void)? = nil) {
		let parameters = [
			"FidoSignIn_1_1{actionForm.fidonumber}": number,
			"FidoSignIn_1_1{actionForm.password}": password,
			"FidoSignIn_1_1{actionForm.failureFlag}": "false",
			"FidoSignIn_1_1{actionForm.loginAsGAM}": "false"
		]
		
		Alamofire.request(.POST, Client.loginURL, parameters: parameters).responseString { (_, _, result) in
			if !result.isSuccess {
				log.error("Login: network request failed!")
				completion?(false, nil)
			} else {
				guard let htmlString = result.value else {
					log.error("Login: getting htmlString failed!")
					completion?(false, nil)
					return
				}
				
				completion?(self.loginValidationWithResultHtmlString(htmlString), htmlString)
			}
		}
	}
	
	private func loginValidationWithResultHtmlString(htmlString: String) -> Bool {
		let ji = Ji(htmlString: htmlString)
		if let _ = ji?.xPath("//div[@id='accountName']")?.first?.value {
			return true
		}
		
		return false
	}
}

extension Client {
	func gotoViewUsagePage(completion: ((Bool, String?) -> Void)? = nil) {
		Alamofire.request(.GET, Client.viewUsageURL, parameters: nil).responseString(completionHandler: { (_, _, result) in
			if !result.isSuccess {
				log.error("View Usage: network request failed!")
				completion?(false, nil)
			} else {
				guard let htmlString = result.value else {
					log.error("View Usage: getting htmlString failed!")
					completion?(false, nil)
					return
				}
				
				completion?(true, htmlString)
			}
		})
	}
	
	func showUsagePageForSection(section: String, completion: ((Bool, String?) -> Void)? = nil) {
		log.debug("")
		let parameters = ["selectedUsageType": section]
		Alamofire.request(.POST, Client.individualUsageURL, parameters: parameters).responseString(completionHandler: { (_, _, result) in
			if !result.isSuccess {
				log.error("View Usage: network request failed!")
				completion?(false, nil)
			} else {
				guard let htmlString = result.value else {
					log.error("View Usage: getting htmlString failed!")
					completion?(false, nil)
					return
				}
				
				completion?(true, htmlString)
			}
		})
	}
}
