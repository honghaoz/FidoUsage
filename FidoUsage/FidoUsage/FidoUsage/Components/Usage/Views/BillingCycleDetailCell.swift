//
//  BillingCycleDetailCell.swift
//  FidoUsage
//
//  Created by Honghao Zhang on 2015-11-04.
//  Copyright © 2015 Honghao Zhang. All rights reserved.
//

import UIKit
import ChouTi

class BillingCycleDetailCell: UITableViewCell {

	let titleLabel = UILabel()
	let usageMeterView = UsageMeterView()
	let daysInPairView = SingleTitleContentPairView()
	let remainingPairView = SingleTitleContentPairView()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	private func commonInit() {
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		addSubview(titleLabel)
		
		titleLabel.font = UIFont.systemFontOfSize(17)
		titleLabel.textColor = UIColor.darkTextColor()
		titleLabel.text = "Billing Cycle"
		
		usageMeterView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(usageMeterView)
		usageMeterView.progressBarView.forgroundColor = UIColor(white: 0.15, alpha: 1.0)
		if #available(iOS 8.2, *) {
			usageMeterView.minLabel.font = UIFont.systemFontOfSize(12, weight: UIFontWeightThin)
			usageMeterView.maxLabel.font = UIFont.systemFontOfSize(12, weight: UIFontWeightThin)
			usageMeterView.currentLabel.font = UIFont.systemFontOfSize(12, weight: UIFontWeightThin)
		} else {
			usageMeterView.minLabel.font = UIFont.helveticaNenueThinFont(12)
			usageMeterView.maxLabel.font = UIFont.helveticaNenueThinFont(12)
			usageMeterView.currentLabel.font = UIFont.helveticaNenueThinFont(12)
		}
	
		usageMeterView.minLabel.text = "Oct 04, 2015"
		usageMeterView.maxLabel.text = "Nov 03, 2015"
		usageMeterView.currentLabel.text = "Today, Nov 02"
		
		[daysInPairView, remainingPairView].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			addSubview($0)
			$0.layoutMargins = UIEdgeInsetsZero
			if #available(iOS 8.2, *) {
				$0.titleLabel.font = UIFont.systemFontOfSize(14, weight: UIFontWeightRegular)
				$0.contentLabel.font = UIFont.systemFontOfSize(14, weight: UIFontWeightThin)
			} else {
				$0.titleLabel.font = UIFont.helveticaNeueLightFont(14)
				$0.contentLabel.font = UIFont.helveticaNenueThinFont(14)
			}
		}
		
		daysInPairView.titleLabel.text = "Days into Cycle:"
		daysInPairView.contentLabel.text = "30 days"
		
		remainingPairView.titleLabel.text = "Days remaining:"
		remainingPairView.contentLabel.text = "1 days"
		
		setupConstraints()
	}
	
	private func setupConstraints() {
		preservesSuperviewLayoutMargins = false
		
		layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
		
		let views = [
			"titleLabel" : titleLabel,
			"usageMeterView" : usageMeterView,
			"daysInPairView" : daysInPairView,
			"remainingPairView" : remainingPairView
		]
		
		let metrics = [
			"vertical_spacing" : 16.0,
			"meter_height" : 68.0,
			"detail_v_spacing" : 6.0
		]
		
		var constraints = [NSLayoutConstraint]()
		
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-[titleLabel]-(vertical_spacing)-[usageMeterView(meter_height)]-(vertical_spacing)-[daysInPairView]-(detail_v_spacing)-[remainingPairView]-|", options: [.AlignAllLeading], metrics: metrics, views: views)
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[usageMeterView]-|", options: [], metrics: metrics, views: views)
		
		// Adjust content label
		constraints.append(NSLayoutConstraint(item: daysInPairView.contentLabel, attribute: .Leading, relatedBy: .Equal, toItem: remainingPairView.contentLabel, attribute: .Leading, multiplier: 1.0, constant: 0.0))
		daysInPairView.horizontalSpacing = 10
		remainingPairView.horizontalSpacing = 10
		
		NSLayoutConstraint.activateConstraints(constraints)
	}
}

extension BillingCycleDetailCell : TableViewCellInfo {
	static func identifier() -> String {
		return NSStringFromClass(BillingCycleDetailCell.self)
	}
	
	static func estimatedRowHeight() -> CGFloat {
		return 182.5
	}
	
	static func registerInTableView(tableView: UITableView) {
		tableView.registerClass(BillingCycleDetailCell.self, forCellReuseIdentifier: BillingCycleDetailCell.identifier())
	}
}
