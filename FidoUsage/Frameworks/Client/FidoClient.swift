//
//  FidoClient.swift
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

public class FidoClient {
    static let loginURL = "https://www.fido.ca/web/Fido.portal?_nfpb=true&_windowLabel=FidoSignIn_1_1&FidoSignIn_1_1_actionOverride=%2Fcom%2Ffido%2Fportlets%2Fecare%2Faccount%2Fsignin%2FsignIn"
	static let viewUsageURL = "https://www.fido.ca/web/page/portal/Fido/Ecare_MSSPostPaid"
	static let sectionUsageURL = "https://www.fido.ca/web/Fido.portal?_nfpb=true&_windowLabel=mobileSelfServe_1_2&mobileSelfServe_1_2_actionOverride=%2Fcom%2Ffido%2Fportlets%2Fecare%2FmobileSelfServeUsage%2FmanagePostPaidUsage"
    static public let sharedInstance = FidoClient()
	
	let fidoParser = FidoHTMLParser()
	
	enum Page {
		case Login // Not logged in
		case Home
		case ViewUsage(String)
	}
	
	var currentPage: Page = .Login
	var currentHTMLString: String?
	
	// Account Informations
	public var numberString: String?
	public var accountHolderName: String?
	
	var accountInformationDictionary: [String : String]?
	
	// Sections
	public var usageSections: [String]?
	
	// Usage Details
	public static var usageTableKey = "usage_table"
	public static var usageMeterkey = "usage_meter"
	public var usageDetails = [String : AnyObject]()
}


// MARK: - Login
extension FidoClient {
	/**
	Login with number and password
	
	- parameter number:     Fido number
	- parameter password:   Fido password
	- parameter completion: First Boolean, true for login successful. Second dictionary is reuslt dictionary
	*/
	public func loginWithNumber(number: String, password: String, completion: ((Bool, [String : String]?) -> Void)? = nil) {
		switch currentPage {
		case .Login:
			POSTLoginWithNumber(number, password: password) { [unowned self] (succeed, htmlString) in
				if !succeed {
					completion?(false , nil)
					return
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
					let accountInfo = self.fidoParser.parseAccountDetails(htmlString)
					self.accountInformationDictionary = accountInfo
					self.numberString = accountInfo[FidoHTMLParser.numberKey]
					self.accountHolderName = accountInfo[FidoHTMLParser.accountHolderKey]
					completion?(true, self.accountInformationDictionary)
				}
			}
		default:
			// TODO: Need to verify time out
			completion?(true, self.accountInformationDictionary)
		}
	}
	
	/**
	POST for login
	
	- parameter number:     Fido number
	- parameter password:   Fido password
	- parameter completion: POST status and result html string
	*/
	private func POSTLoginWithNumber(number: String, password: String, completion: ((Bool, String?) -> Void)? = nil) {
		let parameters = [
			"FidoSignIn_1_1{actionForm.fidonumber}": number,
			"FidoSignIn_1_1{actionForm.password}": password,
			"FidoSignIn_1_1{actionForm.failureFlag}": "false",
			"FidoSignIn_1_1{actionForm.loginAsGAM}": "false"
		]
		
		Alamofire.request(.POST, self.dynamicType.loginURL, parameters: parameters).responseString { [unowned self] response in
			if !response.result.isSuccess {
				log.error("Login: network request failed!")
				completion?(false, nil)
			} else {
				guard let htmlString = response.result.value else {
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
extension FidoClient {
	/**
	Go to view usage page
	
	- parameter completion: (successful, sections)
	*/
	public func gotoViewUsagePage(completion: ((Bool, [String]?) -> Void)? = nil) {
		switch currentPage {
		case .ViewUsage(_):
			completion?(true, self.usageSections)
			return
		default:
			GETViewUsagePage({ [unowned self] (succeed, htmlString) in
				if !succeed {
					completion?(false, nil)
					return
				}
				
				guard let htmlString = htmlString else {
					log.error("Unwrapp htmlString failed")
					completion?(false, nil)
					return
				}
				
				let sections = self.fidoParser.parseUsageSections(htmlString)
				self.usageSections = sections
				if sections.count == 0 {
					log.warning("Sections are zero")
					completion?(false, [])
				} else {
					self.currentPage = .ViewUsage(sections[0])
					completion?(true, sections)
				}
			})
		}
	}
	
	/**
	GET usage main page
	
	- parameter completion: (request status, html string)
	*/
	private func GETViewUsagePage(completion: ((Bool, String?) -> Void)? = nil) {
		Alamofire.request(.GET, self.dynamicType.viewUsageURL, parameters: nil).responseString(completionHandler: { [unowned self] response in
			if !response.result.isSuccess {
				log.error("View Usage: network request failed!")
				completion?(false, nil)
			} else {
				guard let htmlString = response.result.value else {
					log.error("View Usage: getting htmlString failed!")
					completion?(false, nil)
					return
				}
				
				self.currentHTMLString = htmlString
				completion?(true, htmlString)
			}
		})
	}
	
	/**
	Show usage for the section
	
	- parameter section:    section key
	- parameter completion: (successful, result dictionary)
	*/
	public func showViewUsgaeForSection(section: String, completion: ((Bool, [String : AnyObject]?) -> Void)? = nil) {
		switch currentPage {
		case .ViewUsage(section):
			if let currentHTMLString = self.currentHTMLString {
				let detail = self.fidoParser.parseUsageDetail(currentHTMLString)
				self.usageDetails[section] = detail
				completion?(true, detail)
			} else {
				fallthrough
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
				let detail = self.fidoParser.parseUsageDetail(htmlString)
				self.usageDetails[section] = detail
				completion?(true, detail)
			})
		}
	}
	
	private func POSTViewUsagePageForSection(section: String, completion: ((Bool, String?) -> Void)? = nil) {
		let parameters = ["selectedUsageType": section]
		Alamofire.request(.POST, self.dynamicType.sectionUsageURL, parameters: parameters).responseString(completionHandler: { response in
			if !response.result.isSuccess {
				log.error("View Usage: network request failed!")
				completion?(false, nil)
			} else {
				guard let htmlString = response.result.value else {
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
