//
//  FidoHTMLParser.swift
//  FidoUsage
//
//  Created by Honghao Zhang on 2015-08-12.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import Foundation
//import ChouTi
import Ji

public class FidoHTMLParser {
	static public let sharedInstance = FidoHTMLParser()
	
	let fidoNumberKey = "Fido number"
	let accountHolderKey = "Account holder"
	
    var results = [String: AnyObject]()
	
	func parseAccountDetails(homeHTMLString: String) -> [String: String] {
		var resultsDict = [String: String]()
		guard let ji = Ji(htmlString: homeHTMLString) else {
			log.error("Setup Ji doc failed")
			return resultsDict
		}
		
		if let fidoNumber = ji.xPath("//div[@id='fidoNumberDetails']/span/text()")?.first?.content?.trimmed() {
			resultsDict[fidoNumberKey] = fidoNumber
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
				
				if aNode["style"] == "display:none;" { continue }
				
				if let tabName = aNode.firstChildWithName("span")?.value {
					tabs.append(tabName)
				}
			}
		}
		
		return tabs
	}
	
	func parseUsageDetail(viewUsageHTMLString: String) -> [String: String] {
		var table = [String: String]()
		guard let ji = Ji(htmlString: viewUsageHTMLString) else {
			log.error("Setup Ji doc failed")
			return table
		}
		
		// Get usage details
		guard let liNodes = ji.xPath("//ul[@class='usageContent']/li") else {
			log.error("liNodes not found")
			return table
		}
		
		let currentVisibleLiNodes = liNodes.filter { $0["class"] != "hideLink" }
		
		if currentVisibleLiNodes.count == 0 {
			log.error("No visible liNode found")
			return table
		}
		
		if currentVisibleLiNodes.count > 1 {
			log.warning("More than 1 visible liNodes (\(currentVisibleLiNodes.count)) found")
		}
		
		let currentLiNode = currentVisibleLiNodes.first!
		
		let headers = getTableHeadersForLiNode(currentLiNode)
		let contents = getTableContentsForLiNode(currentLiNode, headers: headers)
		
		if headers.count != contents.count {
			log.error("headers.count != contents.count")
			return table
		}
		
		for (index, header) in headers.enumerate() {
			table[header] = contents[index]
		}

		return table
	}
	
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
}
