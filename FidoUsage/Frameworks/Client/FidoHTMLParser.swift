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
	
	/**
	[
		"usage_table" : [[String : String]],
		"usage_meter" : [[String : [String : String]]]
	]
	
	- parameter viewUsageHTMLString: usage html string
	
	- returns: []
	*/
	func parseUsageDetail(viewUsageHTMLString: String) -> [String : AnyObject] {
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
		let usageDetails = getUsageMetersForLiNode(currentLiNode)
		
		log.info(table)
		log.info(usageDetails)
		
		return [
			"usage_table" : table,
			"usage_meter" : usageDetails
		]
	}
	
	/**
	[
		["Remaining": "Unlimited", "Type": "Incoming/Outgoing Evenings and Weekends usage", "Included": "Unlimited", "Used": "38 min"],
		...
	]
	
	- parameter liNode: Current visible liNode
	
	- returns: Table
	*/
	private func getUsageTableForLiNode(liNode: JiNode) -> [[String : String]] {
		var tables = [[String : String]]()
		
		let headers = getTableHeadersForLiNode(liNode)
		let contents = getTableContentsForLiNode(liNode, headers: headers)
		
		if contents.count % headers.count == 0 {
			log.error("headers.count doesn't match contents.count")
			return tables
		}
		
		for eachTableContent in contents {
			var table = [String : String]()
			for (index, header) in headers.enumerate() {
				table[header] = eachTableContent[index].removeTabsAndReplaceNewlineWithEmptySpace()
			}
			tables.append(table)
		}
		
		return tables
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
	[
		["Unlimited", "Incoming/Outgoing Evenings and Weekends usage", "Unlimited", "38 min"],
		...
	]
	
	- parameter liNode:  Current visible liNode
	- parameter headers: Corresponding Table Headers
	
	- returns: Table contents
	*/
	private func getTableContentsForLiNode(liNode: JiNode, headers: [String]) -> [[String]] {
		var results = [[String]]()
		
		let divs = liNode.xPath(".//div[@class='clearBoth font12px']/div[1]/div")
		if divs.count == 0 {
			log.error("No divs found")
			return results
		}
		
		for div in divs {
			if let id = div["id"] where id.containsString("usageRow") {
				var tableContents = [String]()
				for i in 0 ..< headers.count {
					if let contentString = div.childrenWithName("div")[i].content?.trimmed() {
						tableContents.append(contentString)
					}
				}
				results.append(tableContents)
			}
		}
		
		return results
	}
	
	/**
	[
		[
		"usage_text_section":
			[
				"included": "Unlimited",
				"remaining": "Unlimited",
				"used": "256 min",
				"usage_title": "Usage (Minutes)"
			],
		"billing_cycle_meter_section": 
			[
				"begin_date": "Oct 04, 2015",
				"passed_percent": "87",
				"today": "Today, Oct 30",
				"end_date": "Nov 03, 2015"
			],
		"billing_text_section": 
			[
				"days_remaining": "4 days",
				"billing_cycle_title": "Billing Cycle",
				"days_into_cycle": "27 days"
			],
		"usage_meter_section": 
			[
				"min": "0 min",
				"used": "256 min",
				"max": "256 min",
				"usage_percent": "100"
			]
		],
	
		...
	]
	
	- parameter liNode: Current visible liNode
	
	- returns: Usage detail dictionary
	*/
	private func getUsageMetersForLiNode(liNode: JiNode) -> [[String : [String : String]]] {
		var results = [[String : [String : String]]]()
		
		let sectionDivs = liNode.xPath("//div[contains(@class, 'usageSection')]")

		for sectionDiv in sectionDivs {
			results.append(fourSectionsFromSectionDiv(sectionDiv))
		}
		
		return results
	}
	
	private func fourSectionsFromSectionDiv(sectionDiv: JiNode) -> [String : [String : String]] {
		var resultDict = [String : [String : String]]()
		
		let divsInSection = sectionDiv.xPath("./div")
		for divInSection in divsInSection {
			// Right Sections Text, usually have usage detail and billing cycle
			if let classAttributes = divInSection["class"] where classAttributes.containsString("usageTextSection") {
				// Usage Details
				if divInSection.xPath("./div[@id='included']").count > 0 {
					var usageTextStrings = [String]()
					for div in divInSection.childrenWithName("div") {
						guard let divString = div.content?.normalizeSpaces() else {
							log.error("No divString found")
							continue
						}
						usageTextStrings.append(divString)
					}
					
					let usageTextDict = usageTextSectionFromStrings(usageTextStrings)
					resultDict["usage_text_section"] = usageTextDict
				}
				
				// Billing Cycle
				if divInSection.firstChildWithName("div")?.value == "Billing Cycle" {
					var billingStrings = [String]()
					for div in divInSection.childrenWithName("div") {
						guard let divString = div.content?.normalizeSpaces() else {
							log.error("No divString found")
							continue
						}
						billingStrings.append(divString)
					}
					
					let billingTextDict = billingCycleTextSectionFromStrings(billingStrings)
					resultDict["billing_text_section"] = billingTextDict
				}
			} else if divInSection.xPath(".//div[@id='usageMeterSection']").count > 0 {
				// Usage meter
				var meterStrings = [String]()
				for div in divInSection.childrenWithName("div") {
					if let meterChartDiv = div.xPath(".//div[contains(@id, 'usageMeter')]").first {
						guard let style = meterChartDiv["style"] else {
							log.error("No style attribute found")
							continue
						}
						meterStrings.append(style)
						continue
					}
					
					for div in div.children {
						guard let divString = div.content?.normalizeSpaces() else {
							log.error("No div string found")
							continue
						}
						meterStrings.append(divString)
					}
				}
				
				let meterDict = usageMeterFromStrings(meterStrings)
				resultDict["usage_meter_section"] = meterDict
				
			} else if divInSection.xPath("./div[@id='billingCycle']").count > 0 {
				// Billing meter
				var meterStrings = [String]()
				for div in divInSection.childrenWithName("div") {
					if div["id"] == "billingCycle" {
						for div in div.childrenWithName("div") {
							if let meterChartDiv = div.xPath(".//div[@id='BillingMeter']").first {
								guard let style = meterChartDiv["style"] else {
									log.error("No style attribute found")
									continue
								}
								meterStrings.append(style)
							} else {
								guard let divString = div.content?.normalizeSpaces() else {
									log.error("No div string found")
									continue
								}
								
								meterStrings.append(divString)
							}
						}
					}
					
					if let todayDiv = div.xPath(".//div[@id='todayDate']").first {
						guard let todayString = todayDiv.content?.normalizeSpaces() else {
							log.error("No todayDiv string found")
							continue
						}
						meterStrings.append(todayString)
					}
				}
				
				let billingCycleMeterDict = billingCycleMeterFromStrings(meterStrings)
				resultDict["billing_cycle_meter_section"] = billingCycleMeterDict
				
			} else {
				log.error("What's this section?")
			}
		}
		
		return resultDict
	}
	
	// MARK: - Four Sections
	
	private func usageMeterFromStrings(strings: [String]) -> [String : String] {
		var results = [String : String]()
		for (index, string) in strings.enumerate() {
			switch index {
			case 0:// where string.containsString("min"):
				results["min"] = string
			case 1:// where string.containsString("min"):
				results["max"] = string
			case 2 where !string.containsString("%"):
				results["usage_percent"] = "100"
			case 2 where string.containsString("%"):
				results["usage_percent"] = string.percentNumberString()
			case 3 where string.containsString("used:"):
				continue
			case 4:// where string.containsString("min"):
				results["used"] = string
			default:
				log.error("Not handled string!")
			}
		}
		
		return results
	}
	
	private func billingCycleMeterFromStrings(strings: [String]) -> [String : String] {
		var results = [String : String]()
		for (index, string) in strings.enumerate() {
			switch index {
			case 0:
				results["begin_date"] = string
			case 1:
				results["end_date"] = string
			case 2 where !string.containsString("%"):
				results["passed_percent"] = "100"
			case 2 where string.containsString("%"):
				results["passed_percent"] = string.percentNumberString()
			case 3 where string.containsString("Today"):
				results["today"] = string
			default:
				log.error("Not handled string!")
			}
		}
		
		return results
	}
	
	private func usageTextSectionFromStrings(strings: [String]) -> [String : String] {
		var results = [String : String]()
		for (index, string) in strings.enumerate() {
			switch index {
			case 0 where string.containsString("Usage"):
				results["usage_title"] = string
			case 1 where string.containsString("Included"):
				results["included"] = ""
			case 2:
				if results.indexForKey("included") != nil {
					results["included"] = string
				} else {
					log.error("included key not existed")
				}
			case 3 where string.containsString("Used"):
				results["used"] = ""
			case 4:
				if results.indexForKey("used") != nil {
					results["used"] = string
				} else {
					log.error("used key not existed")
				}
			case 5 where string.containsString("Remaining"):
				results["remaining"] = ""
			case 6:
				if results.indexForKey("remaining") != nil {
					results["remaining"] = string
				} else {
					log.error("remaining key not existed")
				}
			default:
				log.error("Not handled string!")
			}
		}
		
		return results
	}
	
	private func billingCycleTextSectionFromStrings(strings: [String]) -> [String : String] {
		let dayPattern = try! NSRegularExpression(pattern: "(?<=:)(.+)", options: [])
		
		var results = [String : String]()
		for (index, string) in strings.enumerate() {
			switch index {
			case 0:
				if !string.containsString("Billing") {
					log.warning("Billing Cycle is not found")
				}
				results["billing_cycle_title"] = string
			case 1:
				if let dayString = string.firstMatchStringForRegex(dayPattern) {
					results["days_into_cycle"] = dayString.normalizeSpaces()
				} else {
					log.error("day string not found")
				}
			case 2:
				if let dayString = string.firstMatchStringForRegex(dayPattern) {
					results["days_remaining"] = dayString.normalizeSpaces()
				} else {
					log.error("day string not found")
				}
			default:
				log.error("Not handled string!")
			}
		}
		
		return results
	}
}
