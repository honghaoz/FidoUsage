//
//  FidoHTMLParser.swift
//  FidoUsage
//
//  Created by Honghao Zhang on 2015-08-12.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import Foundation
import Ji

class FidoHTMLParser {
	static let sharedInstance = FidoHTMLParser()
	
	let fidoNumberKey = "Fido number"
	let accountHolderKey = "Account holder"
	
    var results = [String: AnyObject]()
	
	func parseAccountDetails(homeHTMLString: String) -> [String: String] {
		var resultsDict = [String: String]()
		guard let ji = Ji(htmlString: homeHTMLString) else {
			log.error("Setup Ji doc failed")
			return resultsDict
		}
		
		if let fidoNumber = ji.xPath("//div[@id='fidoNumberDetails']/span/text()")?.first?.content?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) {
			resultsDict[fidoNumberKey] = fidoNumber
		}
		
		if let accountHolder = ji.xPath("//div[@id='accountName']")?.first?.value?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) {
			resultsDict[accountHolderKey] = accountHolder
		}
		
		for (key, value) in resultsDict {
			results[key] = value
		}
		
		log.debug(resultsDict)
		
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
		
		log.debug(tabs)
		return tabs
	}
	
	func parseUsageDetail(viewUsageHTMLString: String, forSectionIndex sectionIndex: Int) -> [String: String] {
		log.debug("")
		var resultsDict = [String: String]()
		guard let ji = Ji(htmlString: viewUsageHTMLString) else {
			log.error("Setup Ji doc failed")
			return resultsDict
		}
		
		// Get usage details
		// Get table
		var table = [String: String]()
		if let usageNode = ji.xPath("//ul[@class='usageContent']")?.first {
			let liNode = usageNode.childrenWithName("li")[sectionIndex]
			let headers = getTableHeadersForLiNode(liNode)
			log.debug(headers)
			let contents = getTableContentsForLiNode(liNode, headers: headers)
			
			log.debug(headers)
			log.debug(contents)
		}
		
//		log.debug(tableContents)
		
		log.debug(resultsDict)
		
		return resultsDict
	}
	
	private func getTableHeadersForLiNode(liNode: JiNode) -> [String] {
		var tableHeaders = [String]()
		if let tableHeaderNode = liNode.xPath(".//div[@class='tableHeader']").first {
			for node in tableHeaderNode {
				if let headerText = node.value?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) where !headerText.isEmpty {
					tableHeaders.append(headerText)
				}
			}
		}
		
		log.debug(tableHeaders)
		return tableHeaders
	}
	
	private func getTableContentsForLiNode(liNode: JiNode, headers: [String]) -> [String] {
		var tableContents = [String]()
		
		//div[@class="clearBoth font12px"]/div[1]/div[1]
		
		let divs = liNode.xPath(".//div[@class='clearBoth font12px']/div[1]/div[1]")
		for i in 0 ..< headers.count {
			if let contentString = divs[i].content?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) {
				tableContents.append(contentString)
			}
		}
		
		log.debug(tableContents)
		return tableContents
	}
}
