//
//  UsageMeterView.swift
//  FidoUsage
//
//  Created by Honghao Zhang on 2015-11-02.
//  Copyright © 2015 Honghao Zhang. All rights reserved.
//

import UIKit
import ChouTi

class UsageMeterView: UIView {
	let minLabel = UILabel()
	let maxLabel = UILabel()
	let currentLabel = UILabel()
	
	let progressBarView = ProgressBarView()
	
	var shouldShowDifferentColor: Bool = true
	var criticalColor: UIColor = UIColor.redColor()
	var mediateColor: UIColor = UIColor.yellowColor()
	var peacefulColor: UIColor = UIColor.greenColor()
	
	private var currentLabelHorizontalPositionConstraint: NSLayoutConstraint!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	private func commonInit() {
		minLabel.translatesAutoresizingMaskIntoConstraints = false
		addSubview(minLabel)
		minLabel.textColor = UIColor.darkTextColor()
		minLabel.text = "0"
		
		maxLabel.translatesAutoresizingMaskIntoConstraints = false
		addSubview(maxLabel)
		maxLabel.textColor = UIColor.darkTextColor()
		maxLabel.text = "100"
		
		currentLabel.translatesAutoresizingMaskIntoConstraints = false
		addSubview(currentLabel)
		currentLabel.textColor = UIColor.darkTextColor()
		currentLabel.text = "Current"
		
		minLabel.font = UIFont.systemFontOfSize(14)
		maxLabel.font = UIFont.systemFontOfSize(14)
		currentLabel.font = UIFont.systemFontOfSize(14)
		
		progressBarView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(progressBarView)

		currentLabel.textColor = UIColor.blueColor()
		
		progressBarView.delegate = self
		progressBarView.animationDuration = 1.5
		
		setupConstraints()
	}
	
	private func setupConstraints() {
		preservesSuperviewLayoutMargins = false
		layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		
		let views = [
			"minLabel" : minLabel,
			"maxLabel" : maxLabel,
			"currentLabel" : currentLabel,
			"progressBarView" : progressBarView
		]
		
		let metrics = [
			"vertical_spacing" : 4.0
		]
		
		var constraints = [NSLayoutConstraint]()
		
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[progressBarView]-|", options: [], metrics: metrics, views: views)
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-[minLabel]-(vertical_spacing)-[progressBarView]", options: [.AlignAllLeading], metrics: metrics, views: views)
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-[maxLabel]-(vertical_spacing)-[progressBarView]", options: [.AlignAllTrailing], metrics: metrics, views: views)
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:[progressBarView]-(vertical_spacing)-[currentLabel]-|", options: [], metrics: metrics, views: views)
		
		currentLabelHorizontalPositionConstraint = NSLayoutConstraint(item: currentLabel, attribute: .CenterX, relatedBy: .Equal, toItem: progressBarView, attribute: .Trailing, multiplier: progressBarView.percent.safeMulpilter(), constant: 0.0)
		currentLabelHorizontalPositionConstraint.priority = 750
		
		// Constraints avoids exceeding bounds
		let leadingMaxConstraint = NSLayoutConstraint(item: currentLabel, attribute: .Leading, relatedBy: .GreaterThanOrEqual, toItem: progressBarView, attribute: .Leading, multiplier: 1.0, constant: 0.0)
		let trailingMaxConstraint = NSLayoutConstraint(item: currentLabel, attribute: .Trailing, relatedBy: .LessThanOrEqual, toItem: progressBarView, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
		
		constraints += [leadingMaxConstraint, trailingMaxConstraint, currentLabelHorizontalPositionConstraint]
				
		NSLayoutConstraint.activateConstraints(constraints)
	}
}

extension UsageMeterView : ProgressBarViewDelegate {
	func progressBarView(progressBarView: ProgressBarView, willSetToPercent percent: CGFloat) {
		
	}
	
	func progressBarView(progressBarView: ProgressBarView, didSetToPercent percent: CGFloat) {
		let newColor: UIColor
		
		if shouldShowDifferentColor {
			switch percent {
			case 0 ..< 0.7:
				newColor = peacefulColor
			case 0.7 ..< 0.9:
				newColor = mediateColor
			case 0.9 ... 1.0:
				newColor = criticalColor
			default:
				newColor = peacefulColor
			}
		} else {
			newColor = peacefulColor
		}
		
		currentLabelHorizontalPositionConstraint.active = false
		currentLabelHorizontalPositionConstraint = NSLayoutConstraint(item: currentLabel, attribute: .CenterX, relatedBy: .Equal, toItem: progressBarView, attribute: .Trailing, multiplier: percent.safeMulpilter(), constant: 0.0)
		currentLabelHorizontalPositionConstraint.priority = 750
		currentLabelHorizontalPositionConstraint.active = true
		
		if isVisible && progressBarView.animated {
			UIView.animateWithDuration(progressBarView.animationDuration) { () -> Void in
				self.layoutIfNeeded()
				self.progressBarView.forgroundColor = newColor
				self.currentLabel.textColor = newColor
			}
		} else {
			self.setNeedsLayout()
		}
	}
}
