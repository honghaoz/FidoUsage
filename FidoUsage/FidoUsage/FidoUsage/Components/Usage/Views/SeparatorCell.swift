//
//  SeparatorCell.swift
//  FidoUsage
//
//  Created by Honghao Zhang on 2015-11-04.
//  Copyright © 2015 Honghao Zhang. All rights reserved.
//

import UIKit
import ChouTi

class SeparatorCell: UITableViewCell {

	var separatorView: UIView = UIView() {
		didSet {
			
		}
	}
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	private func commonInit() {
		separatorView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(separatorView)
		separatorView.backgroundColor = UIColor(white: 0.5, alpha: 1.0)
		
		setupConstraints()
	}
	
	private func setupConstraints() {
		preservesSuperviewLayoutMargins = false
		
		let views = [
			"separatorView" : separatorView
		]
		
		var constraints = [NSLayoutConstraint]()
		
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-[separatorView(0.5)]-|", options: [], metrics: nil, views: views)
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[separatorView]-|", options: [], metrics: nil, views: views)
		
		NSLayoutConstraint.activateConstraints(constraints)
	}
}

extension SeparatorCell : TableViewCellInfo {
	static func identifier() -> String {
		return NSStringFromClass(SeparatorCell.self)
	}
	
	static func estimatedRowHeight() -> CGFloat {
		return 16.5
	}
	
	static func registerInTableView(tableView: UITableView) {
		tableView.registerClass(SeparatorCell.self, forCellReuseIdentifier: SeparatorCell.identifier())
	}
}