//
//  FidoHTMLParser.swift
//  FidoUsage
//
//  Created by Honghao Zhang on 2015-08-12.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import Foundation
import ChouTi
import Ji

public class FidoHTMLParser {
	static public let sharedInstance = FidoHTMLParser()
	
	let numberKey = "number"
	let accountHolderKey = "account_holder"
	
    var results = [String : AnyObject]()
	
	func parseAccountDetails(homeHTMLString: String) -> [String : String] {
		var resultsDict = [String : String]()
		guard let ji = Ji(htmlString: homeHTMLString) else {
			log.error("Setup Ji doc failed")
			return resultsDict
		}
		
		if let fidoNumber = ji.xPath("//div[@id='fidoNumberDetails']/span/text()")?.first?.content?.trimmed() {
			resultsDict[numberKey] = fidoNumber
		}
		
		if let accountHolder = ji.xPath("//div[@id='accountName']")?.first?.value?.trimmed() {
			resultsDict[accountHolderKey] = accountHolder
		}
		
		for (key, value) in resultsDict {
			results[key] = value
		}
		
		return resultsDict
	}
	
	func parseUsageSections(viewUsageHTMLString: String) -> [String] {
		var tabs = [String]()
		guard let ji = Ji(htmlString: viewUsageHTMLString) else {
			log.error("Setup Ji doc failed")
			return tabs
		}
		
		// Setup tabs
		if let tabsNode = ji.xPath("//div[@class='tab']")?.first {
			for node in tabsNode {
				guard let aNode = node.firstChild else {
					log.warning("Get first child failed")
					continue
				}
				
				if aNode["style"] == "display:none;" {
					continue
				}
				
				if let tabName = aNode.firstChildWithName("span")?.value {
					tabs.append(tabName)
				}
			}
		}
		
		return tabs
	}
	
	func parseUsageDetail(viewUsageHTMLString: String) -> [String : String] {
		guard let ji = Ji(htmlString: viewUsageHTMLString) else {
			log.error("Setup Ji doc failed")
			return [:]
		}
		
		// Get usage details
		guard let currentVisibleLiNodes = ji.xPath("//ul[@class='usageContent']/li[not(contains(@class, 'hideLink'))]") else {
			log.error("liNodes not found")
			return [:]
		}
		
		if currentVisibleLiNodes.count == 0 {
			log.error("No visible liNode found")
			return [:]
		}
		
		if currentVisibleLiNodes.count > 1 {
			log.warning("More than 1 visible liNodes (\(currentVisibleLiNodes.count)) found")
		}
		
		let currentLiNode = currentVisibleLiNodes.first!
		let table = getUsageTableForLiNode(currentLiNode)
		getUsageMetersForLiNode(currentLiNode)
		
		return table
	}
	
	/**
	["Remaining": "Unlimited", "Type": "Incoming/Outgoing Evenings and Weekends usage", "Included": "Unlimited", "Used": "38 min"]
	
	- parameter liNode: Current visible liNode
	
	- returns: Table
	*/
	private func getUsageTableForLiNode(liNode: JiNode) -> [String : String] {
		var table = [String : String]()
		
		let headers = getTableHeadersForLiNode(liNode)
		let contents = getTableContentsForLiNode(liNode, headers: headers)
		
		if headers.count != contents.count {
			log.error("headers.count != contents.count")
			return table
		}
		
		for (index, header) in headers.enumerate() {
			table[header] = contents[index].removeTabsAndReplaceNewlineWithEmptySpace()
		}
		
		return table
	}
	
	/**
	["Remaining", "Type", "Included", "Used"]
	
	- parameter liNode: Current visible liNode
	
	- returns: Table Headers
	*/
	private func getTableHeadersForLiNode(liNode: JiNode) -> [String] {
		var tableHeaders = [String]()
		if let tableHeaderNode = liNode.xPath(".//div[@class='tableHeader']").first {
			for node in tableHeaderNode {
				if let headerText = node.value?.trimmed() where !headerText.isEmpty {
					tableHeaders.append(headerText)
				}
			}
		}
		return tableHeaders
	}
	
	/**
	["Unlimited", "Incoming/Outgoing Evenings and Weekends usage", "Unlimited", "38 min"]
	
	- parameter liNode:  Current visible liNode
	- parameter headers: Corresponding Table Headers
	
	- returns: Table contents
	*/
	private func getTableContentsForLiNode(liNode: JiNode, headers: [String]) -> [String] {
		var tableContents = [String]()
		
		if let div = liNode.xPath(".//div[@class='clearBoth font12px']/div[1]/div[1]").first {
			for i in 0 ..< headers.count {
				if let contentString = div.childrenWithName("div")[i].content?.trimmed() {
					tableContents.append(contentString)
				}
			}
		}
		return tableContents
	}
	
	/**
	[
	 "min": "0 min",
	 "max": "237 min",
	 "used": "237 min"
	 "usage": [
	  "Included:": "Unlimited"
	  "Used:": "237 min"
	  "Remaining:" "Unlimited"
	 ]
	]
	
	- parameter liNode: Current visible liNode
	
	- returns: Usage detail dictionary
	*/
	private func getUsageMetersForLiNode(liNode: JiNode) -> [String : String] {
		let sectionDivs = liNode.xPath("//div[contains(@class, 'usageSection')]/div")
		for section in sectionDivs {
			// Right Sections Text, usually have usage detail and billing cycle
			if let classAttributes = section["class"] where classAttributes.containsString("usageTextSection") {
				// Usage Details
				if section.xPath("./div[@id='included']").count > 0 {
					for div in section.childrenWithName("div") {
						print(div.content?.normalizeSpaces())
					}
				}
				
				// Billing Cycle
				if section.firstChildWithName("div")?.value == "Billing Cycle" {
					for div in section.childrenWithName("div") {
						print(div.content?.normalizeSpaces())
					}
				}
			} else if section.xPath(".//div[@id='usageMeterSection']").count > 0 {
				// Usage meter
				for (index, div) in section.childrenWithName("div").enumerate() {
					if let meterChartDiv = div.xPath(".//div[contains(@id, 'usageMeter')]").first {
						print("style: \(meterChartDiv["style"])")
						continue
					}
					
					for div in div.children {
						print("div: \(div.content?.normalizeSpaces())")
					}
				}
			} else if section.xPath("./div[@id='billingCycle']").count > 0 {
				// Billing meter
				for div in section.childrenWithName("div") {
					if div["id"] == "billingCycle" {
						for div in div.childrenWithName("div") {
							if let meterChartDiv = div.xPath(".//div[@id='BillingMeter']").first {
								print("style: \(meterChartDiv["style"])")
								continue
							}
							print(div.content?.normalizeSpaces())
						}
					}
					
					if let todayDiv = div.xPath(".//div[@id='todayDate']").first {
						print("today: \(todayDiv.content?.normalizeSpaces())")
						continue
					}
				}
			} else {
				print("What's this section?")
			}
		}
		
		return [:]
	}
}
