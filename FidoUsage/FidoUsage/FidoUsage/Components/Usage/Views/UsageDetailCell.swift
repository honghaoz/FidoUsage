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
//	let usageDetailView = 
	
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
		
		setupConstraints()
	}
	
	private func setupConstraints() {
		preservesSuperviewLayoutMargins = false
		
		layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
		
		let views = [
			"titleLabel" : titleLabel,
			"usageMeterView" : usageMeterView,
		]
		
		let metrics = [
			"vertical_spacing" : 8.0,
			"meter_height" : 64.0
		]
		
		var constraints = [NSLayoutConstraint]()
		
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-[titleLabel]-(vertical_spacing)-[usageMeterView(meter_height)]-|", options: [.AlignAllLeading], metrics: metrics, views: views)
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[usageMeterView]-|", options: [], metrics: metrics, views: views)
		
		NSLayoutConstraint.activateConstraints(constraints)
	}
}

extension UsageDetailCell : TableViewCellInfo {
	static func identifier() -> String {
		return NSStringFromClass(UsageDetailCell.self)
	}
	
	static func estimatedRowHeight() -> CGFloat {
		return 8.0 + 20.0 + 8.0 + 70.0 + 8.0
	}
	
	static func registerInTableView(tableView: UITableView) {
		tableView.registerClass(UsageDetailCell.self, forCellReuseIdentifier: UsageDetailCell.identifier())
	}
}
