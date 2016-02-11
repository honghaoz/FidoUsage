//
//  Ji+Extensions.swift
//  FidoUsage
//
//  Created by Honghao Zhang on 2015-11-28.
//  Copyright © 2015 Honghao Zhang. All rights reserved.
//

import Foundation
import Ji
import Loggerithm

extension JiNode {
	func fromActionURL() -> String? {
		guard name == "form" else {
			log.error("node is not a form node")
			return nil
		}
		
		return self["action"]
	}
	
	func formParameters() -> [String : String] {
		guard self.name == "form" else {
			log.error("node is not a form node")
			return [:]
		}
		
		var parameters = [String : String]()
		
		for inputNode in self.childrenWithName("input") {
			guard let name = inputNode["name"], value = inputNode["value"] else {
				log.warning("name/value is not found in input node.")
				continue
			}
			
			parameters[name] = value
		}
		
		return parameters
	}
}
