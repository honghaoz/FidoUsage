//
//  Client.swift
//  FidoUsage
//
//  Created by Honghao Zhang on 2015-08-12.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import Foundation
import Alamofire

class Client {
    let loginURL = "https://www.fido.ca/web/Fido.portal?_nfpb=true&_windowLabel=FidoSignIn_1_1&FidoSignIn_1_1_actionOverride=%2Fcom%2Ffido%2Fportlets%2Fecare%2Faccount%2Fsignin%2FsignIn"
    static let sharedInstance = Client()
//    let parser = InfoSessionSourceHTMLParser()
	
	func loginWithNumber(number: String, password: String, completion: ((NSURLRequest?, NSHTTPURLResponse?, NSData?, ErrorType?) -> Void)? = nil) {
		let parameters = [
			"FidoSignIn_1_1{actionForm.fidonumber}": "5197812862",
			"FidoSignIn_1_1{actionForm.password}": "Zhh358279765099",
			"FidoSignIn_1_1{actionForm.failureFlag}": "false",
			"FidoSignIn_1_1{actionForm.loginAsGAM}": "false"
		]
		
//		Alamofire.request(.POST, loginURL, parameters: parameters).responseString { _, _, result in
//			print("Success: \(result.isSuccess)")
//			print("Response String: \(result.value)")
//		}
		
		Alamofire.request(.POST, loginURL, parameters: parameters).responseString { (_, _, result) -> Void in
			if !result.isSuccess {
				log.error("Login Failed!")
			} else {
				
			}
		}
	}
}
