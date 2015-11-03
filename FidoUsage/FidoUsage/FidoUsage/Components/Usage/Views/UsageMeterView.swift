//
//  UsageMeterView.swift
//  FidoUsage
//
//  Created by Honghao Zhang on 2015-11-02.
//  Copyright © 2015 Honghao Zhang. All rights reserved.
//

import UIKit

class UsageMeterView: UIView {
	let minLabel = UILabel()
	let maxLabel = UILabel()
	let currentLabel = UILabel()
	
	let meterView = HorizontalUsageMeterView()
	
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
		
		if #available(iOS 8.2, *) {
			minLabel.font = UIFont.systemFontOfSize(12, weight: UIFontWeightThin)
			maxLabel.font = UIFont.systemFontOfSize(12, weight: UIFontWeightThin)
			currentLabel.font = UIFont.systemFontOfSize(12, weight: UIFontWeightThin)
		} else {
			minLabel.font = UIFont.helveticaNenueThinFont(12)
			maxLabel.font = UIFont.helveticaNenueThinFont(12)
			currentLabel.font = UIFont.helveticaNenueThinFont(12)
		}
		
		meterView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(meterView)
		
		meterView.addObserver(self, forKeyPath: "percent", options: [.New], context: nil)
		
		setupConstraints()
	}
	
	private func setupConstraints() {
		preservesSuperviewLayoutMargins = false
		layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		
		let views = [
			"minLabel" : minLabel,
			"maxLabel" : maxLabel,
			"currentLabel" : currentLabel,
			"meterView" : meterView
		]
		
		let metrics = [
			"vertical_spacing" : 4.0
		]
		
		var constraints = [NSLayoutConstraint]()
		
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[meterView]-|", options: [], metrics: metrics, views: views)
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-[minLabel]-(vertical_spacing)-[meterView]", options: [.AlignAllLeading], metrics: metrics, views: views)
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-[maxLabel]-(vertical_spacing)-[meterView]", options: [.AlignAllTrailing], metrics: metrics, views: views)
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:[meterView]-(vertical_spacing)-[currentLabel]-|", options: [], metrics: metrics, views: views)
		
		currentLabelHorizontalPositionConstraint = NSLayoutConstraint(item: currentLabel, attribute: .CenterX, relatedBy: .Equal, toItem: meterView, attribute: .Leading, multiplier: meterView.percent, constant: 0.0)
		currentLabelHorizontalPositionConstraint.priority = 750
		
		// Constraints avoids exceeding bounds
		let leadingMaxConstraint = NSLayoutConstraint(item: currentLabel, attribute: .Leading, relatedBy: .GreaterThanOrEqual, toItem: meterView, attribute: .Leading, multiplier: 1.0, constant: 0.0)
		let trailingMaxConstraint = NSLayoutConstraint(item: currentLabel, attribute: .Trailing, relatedBy: .LessThanOrEqual, toItem: meterView, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
		
		constraints += [leadingMaxConstraint, trailingMaxConstraint, currentLabelHorizontalPositionConstraint]
				
		NSLayoutConstraint.activateConstraints(constraints)
	}
	
	deinit {
		meterView.removeObserver(self, forKeyPath: "contentSize", context: nil)
	}
	
	override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
		if object === meterView {
			guard let newPercent = change?[NSKeyValueChangeNewKey] as? CGFloat else { return }
			currentLabelHorizontalPositionConstraint.active = false
			currentLabelHorizontalPositionConstraint = NSLayoutConstraint(item: currentLabel, attribute: .CenterX, relatedBy: .Equal, toItem: meterView, attribute: .Leading, multiplier: newPercent, constant: 0.0)
			currentLabelHorizontalPositionConstraint.priority = 750
			currentLabelHorizontalPositionConstraint.active = true
		}
	}
}
