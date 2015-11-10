//
//  UsageSummaryView.swift
//  FidoUsage
//
//  Created by Honghao Zhang on 2015-11-04.
//  Copyright © 2015 Honghao Zhang. All rights reserved.
//

import UIKit
import ChouTi
import Client

class UsageSummaryView: UIView {
	var tableCollectionView = TextTableCollectionView()
	
	var data: [String : String]?
	
	convenience init(data: [String : String]) {
		self.init(frame: CGRectZero)
		
		self.data = data
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	private func commonInit() {
		tableCollectionView.separatorLineWidth = 0.0
		tableCollectionView.textTableDataSource = self
		tableCollectionView.textTableDelegate = self
		
		tableCollectionView.titleTextColor = UIColor.darkTextColor()
		tableCollectionView.contentTextColor = UIColor.darkTextColor()
		
		tableCollectionView.horizontalPadding = 10.0
		tableCollectionView.verticalPadding = 2.0
		
		if #available(iOS 8.2, *) {
			tableCollectionView.titleFont = UIFont.systemFontOfSize(15, weight: UIFontWeightRegular)
			tableCollectionView.contentFont = UIFont.systemFontOfSize(14, weight: UIFontWeightThin)
		} else {
			tableCollectionView.titleFont = UIFont.helveticaNeueLightFont(17)
			tableCollectionView.contentFont = UIFont.helveticaNenueThinFont(17)
		}
		
		tableCollectionView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(tableCollectionView)
		
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

extension UsageSummaryView : TextTableCollectionViewDataSource {
	func numberOfColumnsInTableCollectionView(tableCollectionView: TextTableCollectionView) -> Int {
		return data?.count ?? 0
	}
	
	func tableCollectionView(tableCollectionView: TextTableCollectionView, numberOfRowsInColumn column: Int) -> Int {
		return 1
	}
	
	func tableCollectionView(tableCollectionView: TextTableCollectionView, layout collectionViewLayout: TableCollectionViewLayout, titleForColumn column: Int) -> String {
		switch column {
		case 0:
			return FidoHTMLParser.usageTableTypeKey
		case 1:
			return FidoHTMLParser.usageTableIncludedKey
		case 2:
			return FidoHTMLParser.usageTableUsedKey
		case 3:
			return FidoHTMLParser.usageTableRemainingKey
		default:
			return ""
		}
	}
	
	func tableCollectionView(tableCollectionView: TextTableCollectionView, layout collectionViewLayout: TableCollectionViewLayout, contentForColumn column: Int, row: Int) -> String {
		switch column {
		case 0:
			return data?[FidoHTMLParser.usageTableTypeKey] ?? ""
		case 1:
			return data?[FidoHTMLParser.usageTableIncludedKey] ?? ""
		case 2:
			return data?[FidoHTMLParser.usageTableUsedKey] ?? ""
		case 3:
			return data?[FidoHTMLParser.usageTableRemainingKey] ?? ""
		default:
			return ""
		}
	}
}

extension UsageSummaryView : TextTableCollectionViewDelegate {
	func tableCollectionView(tableCollectionView: TextTableCollectionView, configureTitleLabel titleLabel: UILabel, atColumn column: Int) {
		titleLabel.preferredMaxLayoutWidth = screenWidth / 3.5
	}
	
	func tableCollectionView(tableCollectionView: TextTableCollectionView, configureContentLabel contentLabel: UILabel, atColumn column: Int, row: Int) {
		contentLabel.numberOfLines = 2
		contentLabel.preferredMaxLayoutWidth = screenWidth / 3.5
		
		let contentString = self.tableCollectionView(tableCollectionView, layout: tableCollectionView.tableLayout, contentForColumn: column, row: row)
		if contentString.characters.count > 16 {
			if #available(iOS 8.2, *) {
				contentLabel.font = UIFont.systemFontOfSize(12, weight: UIFontWeightThin)
			} else {
				contentLabel.font =  UIFont.helveticaNenueThinFont(10)
			}
		}
	}
}
