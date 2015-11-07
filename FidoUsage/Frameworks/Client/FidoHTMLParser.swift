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
	
	static public let numberKey = "number"
	static public let accountHolderKey = "account_holder"
	
	static public let usageTableKey = "usage_table"
	static public let usageMeterKey = "usage_meter"
	
	static public let usageTableIncludedKey = "Included"
	static public let usageTableUsedKey = "Used"
	static public let usageTableRemainingKey = "Remaining"
	static public let usageTableTypeKey = "Type"
	
	static public let usageMeterUsageMeterSectionKey = "usage_meter_section"
	static public let usageMeterUsageTextSectionKey = "usage_text_section"
	
	static public let usageMeterMinKey = "min"
	static public let usageMeterMaxKey = "max"
	static public let usageMeterUsedKey = "used"
	static public let usageMeterUsagePercentKey = "usage_percent"
	
	static public let usageMeterUsageTitleKey = "usage_title"
	static public let usageMeterIncludedKey = "included"
	static public let usageMeterRemainingKey = "remaining"
	
	static public let usageMeterBillingCycleMeterSectionKey = "billing_cycle_meter_section"
	static public let usageMeterBillingCycleTextSectionKey = "billing_text_section"
	
	static public let usageMeterBillingCycleBeginKey = "begin_date"
	static public let usageMeterBillingCycleEndKey = "end_date"
	static public let usageMeterBillingCyclePassedPercentKey = "passed_percent"
	static public let usageMeterBillingCycleTodayKey = "today"
	
	static public let usageMeterBillingCycleTitleKey = "billing_cycle_title"
	static public let usageMeterBillingCycleDaysIntoCycleKey = "days_into_cycle"
	static public let usageMeterBillingCycleDaysRemainingKey = "days_remaining"
	
	func parseAccountDetails(homeHTMLString: String) -> [String : String] {
		var resultsDict = [String : String]()
		guard let ji = Ji(htmlString: homeHTMLString) else {
			log.error("Setup Ji doc failed")
			return resultsDict
		}
		
		if let fidoNumber = ji.xPath("//div[@id='fidoNumberDetails']/span/text()")?.first?.content?.trimmed() {
			resultsDict[FidoHTMLParser.numberKey] = fidoNumber
		}
		
		if let accountHolder = ji.xPath("//div[@id='accountName']")?.first?.value?.trimmed() {
			resultsDict[FidoHTMLParser.accountHolderKey] = accountHolder
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
			FidoHTMLParser.usageTableKey : table,
			FidoHTMLParser.usageMeterKey : usageDetails
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
					resultDict[FidoHTMLParser.usageMeterUsageTextSectionKey] = usageTextDict
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
					resultDict[FidoHTMLParser.usageMeterBillingCycleTextSectionKey] = billingTextDict
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
				resultDict[FidoHTMLParser.usageMeterUsageMeterSectionKey] = meterDict
				
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
				resultDict[FidoHTMLParser.usageMeterBillingCycleMeterSectionKey] = billingCycleMeterDict
				
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
				results[FidoHTMLParser.usageMeterMinKey] = string
			case 1:// where string.containsString("min"):
				results[FidoHTMLParser.usageMeterMaxKey] = string
			case 2 where !string.containsString("%"):
				results[FidoHTMLParser.usageMeterUsagePercentKey] = "100"
			case 2 where string.containsString("%"):
				results[FidoHTMLParser.usageMeterUsagePercentKey] = string.percentNumberString()
			case 3 where string.containsString("used:"):
				continue
			case 4:// where string.containsString("min"):
				results[FidoHTMLParser.usageMeterUsedKey] = string
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
				results[FidoHTMLParser.usageMeterBillingCycleBeginKey] = string
			case 1:
				results[FidoHTMLParser.usageMeterBillingCycleEndKey] = string
			case 2 where !string.containsString("%"):
				results[FidoHTMLParser.usageMeterBillingCyclePassedPercentKey] = "100"
			case 2 where string.containsString("%"):
				results[FidoHTMLParser.usageMeterBillingCyclePassedPercentKey] = string.percentNumberString()
			case 3 where string.containsString("Today"):
				results[FidoHTMLParser.usageMeterBillingCycleTodayKey] = string
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
				results[FidoHTMLParser.usageMeterUsageTitleKey] = string
			case 1 where string.containsString("Included"):
				results[FidoHTMLParser.usageMeterIncludedKey] = ""
			case 2:
				if results.indexForKey("included") != nil {
					results[FidoHTMLParser.usageMeterIncludedKey] = string
				} else {
					log.error("included key not existed")
				}
			case 3 where string.containsString("Used"):
				results[FidoHTMLParser.usageMeterUsedKey] = ""
			case 4:
				if results.indexForKey("used") != nil {
					results[FidoHTMLParser.usageMeterUsedKey] = string
				} else {
					log.error("used key not existed")
				}
			case 5 where string.containsString("Remaining"):
				results[FidoHTMLParser.usageMeterRemainingKey] = ""
			case 6:
				if results.indexForKey("remaining") != nil {
					results[FidoHTMLParser.usageMeterRemainingKey] = string
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
				results[FidoHTMLParser.usageMeterBillingCycleTitleKey] = string
			case 1:
				if let dayString = string.firstMatchStringForRegex(dayPattern) {
					results[FidoHTMLParser.usageMeterBillingCycleDaysIntoCycleKey] = dayString.normalizeSpaces()
				} else {
					log.error("day string not found")
				}
			case 2:
				if let dayString = string.firstMatchStringForRegex(dayPattern) {
					results[FidoHTMLParser.usageMeterBillingCycleDaysRemainingKey] = dayString.normalizeSpaces()
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
