//
//  ProgressBarView.swift
//  FidoUsage
//
//  Created by Honghao Zhang on 2015-11-02.
//  Copyright © 2015 Honghao Zhang. All rights reserved.
//

import UIKit

protocol ProgressBarViewDelegate : class {
	func progressBarView(progressBarView: ProgressBarView, willSetToPercent percent: CGFloat)
	func progressBarView(progressBarView: ProgressBarView, didSetToPercent percent: CGFloat)
}

class ProgressBarView: UIView {
	
	var forgroundColor: UIColor = UIColor(white: 0.2, alpha: 1.0) {
		didSet {
			forgroundMeterLayer.backgroundColor = forgroundColor.CGColor
		}
	}
	let forgroundMeterLayer = CAShapeLayer()
	
	weak var delegate: ProgressBarViewDelegate?
	
	var percent: CGFloat = 0.33 {
		didSet {
			precondition(0.0 <= percent && percent <= 1.0, "Percetn must in range 0.0 to 1.0, inclusive.")
			setNeedsLayout()
			layoutIfNeeded()
			delegate?.progressBarView(self, didSetToPercent: percent)
		}
	}
	
	func setPercent(percent: CGFloat, animated: Bool = false) {
		if animated {
			// TODO:
		} else {
			self.percent = percent
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
		
		forgroundMeterLayer.frame = CGRect(x: 0.0, y: 0.0, width: bounds.width * percent, height: bounds.height)
		
		layer.cornerRadius = bounds.height / 2.0
		forgroundMeterLayer.cornerRadius = bounds.height / 2.0
	}
	
	private func commonInit() {
		backgroundColor = UIColor(white: 0.9, alpha: 1.0)
		forgroundMeterLayer.backgroundColor = forgroundColor.CGColor
		
		layer.addSublayer(forgroundMeterLayer)
	}
}
