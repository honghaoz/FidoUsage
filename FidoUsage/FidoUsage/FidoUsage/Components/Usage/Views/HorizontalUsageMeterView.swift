//
//  HorizontalUsageMeterView.swift
//  FidoUsage
//
//  Created by Honghao Zhang on 2015-11-02.
//  Copyright © 2015 Honghao Zhang. All rights reserved.
//

import UIKit

class HorizontalUsageMeterView: UIView {
	
	let backgroundMeterLayer = CAShapeLayer()
	let forgroundMeterLayer = CAShapeLayer()
	
	var percent: CGFloat = 0.33 {
		didSet {
			precondition(0.0 <= percent && percent <= 1.0, "Percetn must in range 0.0 to 1.0, inclusive.")
			setNeedsLayout()
			layoutIfNeeded()
		}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		backgroundMeterLayer.frame = bounds
		forgroundMeterLayer.frame = CGRect(x: 0.0, y: 0.0, width: bounds.width * percent, height: bounds.height)
		
		backgroundMeterLayer.cornerRadius = bounds.height / 2.0
		forgroundMeterLayer.cornerRadius = bounds.height / 2.0
	}
	
	private func commonInit() {
		backgroundMeterLayer.backgroundColor = UIColor(white: 0.8, alpha: 1.0).CGColor
		forgroundMeterLayer.backgroundColor = UIColor(white: 0.2, alpha: 1.0).CGColor
		
		layer.addSublayer(backgroundMeterLayer)
		layer.addSublayer(forgroundMeterLayer)
	}
}
