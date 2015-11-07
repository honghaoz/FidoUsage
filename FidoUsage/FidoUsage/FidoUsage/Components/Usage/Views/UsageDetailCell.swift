//
//  UsageDetailCell.swift
//  FidoUsage
//
//  Created by Honghao Zhang on 2015-11-02.
//  Copyright © 2015 Honghao Zhang. All rights reserved.
//

import UIKit
import ChouTi

class UsageDetailCell: UITableViewCell {

	let titleLabel = UILabel()
	let usageMeterView = UsageMeterView()
	let includedPairView = SingleTitleContentPairView()
	let usedPairView = SingleTitleContentPairView()
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
		titleLabel.text = "Usage"
		
		usageMeterView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(usageMeterView)
		usageMeterView.progressBarView.forgroundColor = UIColor.fidoTealColor()
		if #available(iOS 8.2, *) {
		    usageMeterView.minLabel.font = UIFont.systemFontOfSize(12, weight: UIFontWeightThin)
			usageMeterView.maxLabel.font = UIFont.systemFontOfSize(12, weight: UIFontWeightThin)
			usageMeterView.currentLabel.font = UIFont.systemFontOfSize(12, weight: UIFontWeightThin)
		} else {
			usageMeterView.minLabel.font = UIFont.helveticaNenueThinFont(12)
			usageMeterView.maxLabel.font = UIFont.helveticaNenueThinFont(12)
			usageMeterView.currentLabel.font = UIFont.helveticaNenueThinFont(12)
		}
		
		usageMeterView.minLabel.text = "0 GB"
		usageMeterView.maxLabel.text = "Total: 2.5 GB"
		usageMeterView.currentLabel.text = "2.33 GB"
		
		[includedPairView, usedPairView, remainingPairView].forEach {
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
		
		includedPairView.titleLabel.text = "Included:"
		includedPairView.contentLabel.text = "2.5 GB"
		
		usedPairView.titleLabel.text = "Used:"
		usedPairView.contentLabel.text = "2.33 GB"
		
		remainingPairView.titleLabel.text = "Remaining:"
		remainingPairView.contentLabel.text = "167.8 MB"
		
		setupConstraints()
	}
	
	private func setupConstraints() {
		preservesSuperviewLayoutMargins = false
		
		layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
		
		let views = [
			"titleLabel" : titleLabel,
			"usageMeterView" : usageMeterView,
			"includedPairView" : includedPairView,
			"usedPairView" : usedPairView,
			"remainingPairView" : remainingPairView
		]
		
		let metrics = [
			"vertical_spacing" : 16.0,
			"meter_height" : 68.0,
			"detail_v_spacing" : 6.0
		]
		
		var constraints = [NSLayoutConstraint]()
		
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-[titleLabel]-(vertical_spacing)-[usageMeterView(meter_height)]-(vertical_spacing)-[includedPairView]-(detail_v_spacing)-[usedPairView]-|", options: [.AlignAllLeading], metrics: metrics, views: views)
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[usageMeterView]-|", options: [], metrics: metrics, views: views)
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:[usedPairView]-(>=0)-[remainingPairView]-|", options: [.AlignAllBaseline], metrics: metrics, views: views)
		
		// Adjust content label
		constraints.append(NSLayoutConstraint(item: includedPairView.contentLabel, attribute: .Leading, relatedBy: .Equal, toItem: usedPairView.contentLabel, attribute: .Leading, multiplier: 1.0, constant: 0.0))
		includedPairView.horizontalSpacing = 10
		usedPairView.horizontalSpacing = 10
		remainingPairView.horizontalSpacing = 10
		
		NSLayoutConstraint.activateConstraints(constraints)
	}
}

extension UsageDetailCell : TableViewCellInfo {
	static func identifier() -> String {
		return NSStringFromClass(UsageDetailCell.self)
	}
	
	static func estimatedRowHeight() -> CGFloat {
		return 184.5
	}
	
	static func registerInTableView(tableView: UITableView) {
		tableView.registerClass(UsageDetailCell.self, forCellReuseIdentifier: UsageDetailCell.identifier())
	}
}
