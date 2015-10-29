//
//  UIImage+ImageAsset.swift
//  FidoUsage
//
//  Created by Honghao Zhang on 2015-09-01.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import UIKit

extension UIImage {
	
	enum ImageAssets: String {
		case AppIcon = "AppIcon"
		case LaunchImage = "LaunchImage"
		case FidoLogo = "FidoLogo"
		case FidoTealUnderscore = "FidoTealUnderscore"
	}
	
	convenience init!(asset: ImageAssets) {
		self.init(named: asset.rawValue)
	}
}
