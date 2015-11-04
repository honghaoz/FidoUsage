//
//  UsageSummaryView.swift
//  FidoUsage
//
//  Created by Honghao Zhang on 2015-11-04.
//  Copyright © 2015 Honghao Zhang. All rights reserved.
//

import UIKit
import ChouTi

class UsageSummaryView: UIView {
	let tableLayout = TableCollectionViewLayout()
	var tableCollectionView: TableCollectionView!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	private func commonInit() {
		tableLayout.separatorLineWidth = 0.0
		tableCollectionView = TableCollectionView(frame: CGRectZero, collectionViewLayout: tableLayout)
		tableCollectionView.tableLayoutDataSource = self
		
		tableCollectionView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(tableCollectionView)
		
		tableLayout.titleTextColor = UIColor.darkTextColor()
		tableLayout.contentTextColor = UIColor.darkTextColor()
		
		tableLayout.horizontalPadding = 10.0
		tableLayout.verticalPadding = 2.0
		
		if #available(iOS 8.2, *) {
			tableLayout.titleFont = UIFont.systemFontOfSize(15, weight: UIFontWeightRegular)
			tableLayout.contentFont = UIFont.systemFontOfSize(14, weight: UIFontWeightThin)
		} else {
			tableLayout.titleFont = UIFont.helveticaNeueLightFont(17)
			tableLayout.contentFont = UIFont.helveticaNenueThinFont(17)
		}
		
		setupConstraints()
	}
	
	private func setupConstraints() {
		var constraints = [NSLayoutConstraint]()
		
		constraints.append(NSLayoutConstraint(item: tableCollectionView, attribute: .TopMargin, relatedBy: .Equal, toItem: self, attribute: .TopMargin, multiplier: 1.0, constant: 0.0))
		constraints.append(NSLayoutConstraint(item: tableCollectionView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
		constraints.append(NSLayoutConstraint(item: tableCollectionView, attribute: .BottomMargin, relatedBy: .Equal, toItem: self, attribute: .BottomMargin, multiplier: 1.0, constant: 0.0))
		
		NSLayoutConstraint.activateConstraints(constraints)
	}
}

extension UsageSummaryView : TableLayoutDataSource {
	func numberOfColumnsInCollectionView(collectionView: UICollectionView) -> Int {
		return 4
	}
	
	func collectionView(collectionView: UICollectionView, numberOfRowsInColumn column: Int) -> Int {
		return 1
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: TableCollectionViewLayout, titleForColumn column: Int) -> String {
		switch column {
		case 0:
			return "Type"
		case 1:
			return "Included"
		case 2:
			return "Used"
		case 3:
			return "Remaining"
		default:
			return ""
		}
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: TableCollectionViewLayout, contentForColumn column: Int, row: Int) -> String {
		switch column {
		case 0:
			return "Anytime"
		case 1:
			return "2.5 GB"
		case 2:
			return "2.33 GB"
		case 3:
			return "167.8 MB"
		default:
			return ""
		}
	}
}
