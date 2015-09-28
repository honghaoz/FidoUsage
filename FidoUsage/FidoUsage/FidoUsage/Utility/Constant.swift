//
//  Constant.swift
//  FidoUsage
//
//  Created by Honghao Zhang on 2015-08-12.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import Foundation
import Loggerithm
import ChouTi
import Watchdog

#if DEBUG
let DEBUG = true
let watchdog = Watchdog(threshold: 0.2) { duration in
	print("👮 Main thread was blocked for " + String(format:"%.2f", duration) + "s 👮")
}

#else
let DEBUG = false
#endif

let log = Loggerithm()
