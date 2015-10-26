//
//  String+Extensions.swift
//  FidoUsage
//
//  Created by Honghao Zhang on 2015-10-26.
//  Copyright © 2015 Honghao Zhang. All rights reserved.
//

import Foundation

public extension String {
	
	/**
	Return whitespace and newline trimmed string.
	
	- returns: whitespace and newline trimmed string
	*/
	public func trimmed() -> String {
		return self.whitespaceAndNewlineTrimmed()
	}
	
	/**
	Return whitespace and newline trimmed string.
	
	- returns: whitespace and newline trimmed string
	*/
	public func whitespaceAndNewlineTrimmed() -> String {
		return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
	}
	
	/**
	Return whitespace trimmed string.
	
	- returns: whitespace trimmed string
	*/
	public func whitespaceTrimmed() -> String {
		return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
	}
}
