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
import Loggerithm

let log = Loggerithm()

public class Client {
    static let loginURL = "https://www.fido.ca/web/Fido.portal?_nfpb=true&_windowLabel=FidoSignIn_1_1&FidoSignIn_1_1_actionOverride=%2Fcom%2Ffido%2Fportlets%2Fecare%2Faccount%2Fsignin%2FsignIn"
	static let viewUsageURL = "https://www.fido.ca/web/page/portal/Fido/Ecare_MSSPostPaid"
	static let sectionUsageURL = "https://www.fido.ca/web/Fido.portal?_nfpb=true&_windowLabel=mobileSelfServe_1_2&mobileSelfServe_1_2_actionOverride=%2Fcom%2Ffido%2Fportlets%2Fecare%2FmobileSelfServeUsage%2FmanagePostPaidUsage"
    static public let sharedInstance = Client()
	
	let fidoParser = FidoHTMLParser()
	
	enum Page {
		case Login // Not logged in
		case Home
		case ViewUsage(String)
	}
	
	var currentPage: Page = .Login
	var currentHTMLString: String?
	var accountInformationDictionary: [String: String]?
}


// MARK: - Login
extension Client {
	public func loginWithNumber(number: String, password: String, completion: ((Bool, [String: String]?) -> Void)? = nil) {
		switch currentPage {
		case .Login:
			POSTLoginWithNumber(number, password: password) { [unowned self] (succeed, htmlString) in
				if !succeed {
					completion?(false , nil)
				}
				
				guard let htmlString = htmlString else {
					log.error("htmlString is nil")
					completion?(false , nil)
					return
				}
				
				if !self.loginValidationWithResultHtmlString(htmlString) {
					completion?(false, nil)
				} else {
					self.currentPage = .Home
					self.accountInformationDictionary = self.fidoParser.parseAccountDetails(htmlString)
					completion?(true, self.accountInformationDictionary)
				}
			}
		default:
			// TODO: Need to verify time out
			completion?(true, self.accountInformationDictionary)
		}
	}
	
	private func POSTLoginWithNumber(number: String, password: String, completion: ((Bool, String?) -> Void)? = nil) {
		let parameters = [
			"FidoSignIn_1_1{actionForm.fidonumber}": number,
			"FidoSignIn_1_1{actionForm.password}": password,
			"FidoSignIn_1_1{actionForm.failureFlag}": "false",
			"FidoSignIn_1_1{actionForm.loginAsGAM}": "false"
		]
		
		Alamofire.request(.POST, Client.loginURL, parameters: parameters).responseString { [unowned self] (_, _, result) in
			if !result.isSuccess {
				log.error("Login: network request failed!")
				completion?(false, nil)
			} else {
				guard let htmlString = result.value else {
					log.error("Login: getting htmlString failed!")
					completion?(false, nil)
					return
				}
				
				self.currentHTMLString = htmlString
				completion?(true, htmlString)
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

// MARK: - View Usage
extension Client {
	public func gotoViewUsagePage(completion: ((Bool, [String]?) -> Void)? = nil) {
		switch currentPage {
		case .ViewUsage(_):
			// TODO:
			return
		default:
			GETViewUsagePage({ [unowned self] (succeed, htmlString) in
				if succeed {
					guard let htmlString = htmlString else {
						log.error("Unwrapp htmlString failed")
						completion?(false, nil)
						return
					}
					
					let sections = self.fidoParser.parseUsageSections(htmlString)
					if sections.count == 0 {
						log.error("Sections are zero")
						completion?(false, [])
					} else {
						self.currentPage = .ViewUsage(sections[0])
						completion?(true, sections)
					}
					
				} else {
					completion?(false, nil)
				}
			})
		}
	}
	
	private func GETViewUsagePage(completion: ((Bool, String?) -> Void)? = nil) {
		Alamofire.request(.GET, Client.viewUsageURL, parameters: nil).responseString(completionHandler: { [unowned self] (_, _, result) in
			if !result.isSuccess {
				log.error("View Usage: network request failed!")
				completion?(false, nil)
			} else {
				guard let htmlString = result.value else {
					log.error("View Usage: getting htmlString failed!")
					completion?(false, nil)
					return
				}
				
				self.currentHTMLString = htmlString
				completion?(true, htmlString)
			}
		})
	}
	
	public func showViewUsgaeForSection(section: String, completion: ((Bool, [String: String]?) -> Void)? = nil) {
		switch currentPage {
		case .ViewUsage(section):
			if let currentHTMLString = self.currentHTMLString {
				completion?(true, self.fidoParser.parseUsageDetail(currentHTMLString))
			} else {
				completion?(false, nil)
			}
		default:
			POSTViewUsagePageForSection(section, completion: { [unowned self] (succeed, htmlString) in
				if !succeed {
					completion?(false, nil)
					return
				}
				
				guard let htmlString = htmlString else {
					log.error("Unwrapp htmlString failed")
					completion?(false, nil)
					return
				}
				
				self.currentPage = .ViewUsage(section)
				completion?(true, self.fidoParser.parseUsageDetail(htmlString))
			})
		}
	}
	
	private func POSTViewUsagePageForSection(section: String, completion: ((Bool, String?) -> Void)? = nil) {
		let parameters = ["selectedUsageType": section]
		Alamofire.request(.POST, Client.sectionUsageURL, parameters: parameters).responseString(completionHandler: { (_, _, result) in
			if !result.isSuccess {
				log.error("View Usage: network request failed!")
				completion?(false, nil)
			} else {
				guard let htmlString = result.value else {
					log.error("View Usage: getting htmlString failed!")
					completion?(false, nil)
					return
				}
				
				self.currentHTMLString = htmlString
				completion?(true, htmlString)
			}
		})
	}
}
