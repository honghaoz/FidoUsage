//
//  UsageViewController.swift
//  FidoUsage
//
//  Created by Honghao Zhang on 2015-09-18.
//  Copyright © 2015 Honghao Zhang. All rights reserved.
//

import UIKit
import ChouTi
import Client

class UsageViewController : UIViewController {
	
    var sectionTitle: String
	
	let tableView = UITableView(frame: CGRectZero, style: .Plain)
	
	var data: [String: AnyObject]?
	
	private var isRequesting: Bool = false
	
    init(sectionTitle: String) {
		self.sectionTitle = sectionTitle
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupViews()
    }
	
	private func setupViews() {
		tableView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(tableView)
		
		tableView.separatorStyle = .None
		tableView.allowsSelection = false
		
		tableView.dataSource = self
		tableView.delegate = self
		tableView.rowHeight = UITableViewAutomaticDimension
		
		tableView.canCancelContentTouches = true
		tableView.delaysContentTouches = true
		
		tableView.setHidden(true)
		
		UsageDetailCell.registerInTableView(tableView)
		BillingCycleDetailCell.registerInTableView(tableView)
		SeparatorCell.registerInTableView(tableView)

		setupConstraints()
	}
	
	private func setupConstraints() {
		if #available(iOS 9.0, *) {
		    tableView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
			tableView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
			tableView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
			tableView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
		} else {
		    // Fallback on earlier versions
		}
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		if !isRequesting {
			isRequesting = true
			
			let client = Locator.client
			
			log.info("Requesting \(self.sectionTitle) ...")
			
			client.showViewUsgaeForSection(sectionTitle, completion: { (succeed, table) in
				if succeed {
//					let existedSections = NSIndexSet(indexesInRange: NSRange(location: 0, length: self.tableView.numberOfSections))
//					self.data = [:]
//					self.tableView.deleteSections(existedSections, withRowAnimation: .None)
//					
//					self.data = table
//
//					self.tableView.insertSections(NSIndexSet(indexesInRange: NSRange(location: 0, length: table?[FidoHTMLParser.usageTableKey]?.count ?? 0)), withRowAnimation: .None)
					
					self.data = table
					self.tableView.reloadData()

					self.tableView.setHidden(false, animated: true, duration: 0.5)
				} else {
					log.error("Requesting \(self.sectionTitle) failed")
				}
				
				self.isRequesting = false
			})
		}
	}
}

extension UsageViewController : UITableViewDataSource {
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return data?[FidoHTMLParser.usageTableKey]?.count ?? 0
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 3
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell: UITableViewCell
		
		switch indexPath.row {
		case 0:
			cell = tableView.dequeueReusableCellWithIdentifier(UsageDetailCell.identifier()) as! UsageDetailCell
		case 1:
			cell = tableView.dequeueReusableCellWithIdentifier(SeparatorCell.identifier()) as! SeparatorCell
		case 2:
			cell = tableView.dequeueReusableCellWithIdentifier(BillingCycleDetailCell.identifier()) as! BillingCycleDetailCell
		default:
			return UITableViewCell()
		}
		
		configureCell(cell, withIndexPath: indexPath)
		return cell
	}
    
    private func configureCell(cell: UITableViewCell, withIndexPath indexPath: NSIndexPath) {
        switch cell {
        case let cell as SeparatorCell:
            cell.separatorView.backgroundColor = UIColor(white: 0.75, alpha: 1.0)
			
        case let cell as UsageDetailCell:
			guard
			let usageMeterSection = ((data?[FidoHTMLParser.usageMeterKey] as? [AnyObject])?[indexPath.section] as? [String : AnyObject])?[FidoHTMLParser.usageMeterUsageMeterSectionKey] as? [String : String],
			let usageTextSection = ((data?[FidoHTMLParser.usageMeterKey] as? [AnyObject])?[indexPath.section] as? [String : AnyObject])?[FidoHTMLParser.usageMeterUsageTextSectionKey] as? [String : String] else {
					break
			}
			
			cell.usageMeterView.minLabel.text = usageMeterSection[FidoHTMLParser.usageMeterMinKey]
			cell.usageMeterView.maxLabel.text = usageMeterSection[FidoHTMLParser.usageMeterMaxKey]
			cell.usageMeterView.currentLabel.text = usageMeterSection[FidoHTMLParser.usageMeterUsedKey]
			
			delay(seconds: 0.1, completion: { () -> () in
				if let percentString = usageMeterSection[FidoHTMLParser.usageMeterUsagePercentKey] {
					cell.usageMeterView.progressBarView.percent = CGFloat(NSNumberFormatter().numberFromString(percentString) ?? 0) / 100.0
				} else {
					cell.usageMeterView.progressBarView.percent = 0.0
				}
			})
			
			cell.titleLabel.text = usageTextSection[FidoHTMLParser.usageMeterUsageTitleKey]
			cell.includedPairView.contentLabel.text = usageTextSection[FidoHTMLParser.usageMeterIncludedKey]
			cell.usedPairView.contentLabel.text = usageTextSection[FidoHTMLParser.usageMeterUsedKey]
			cell.remainingPairView.contentLabel.text = usageTextSection[FidoHTMLParser.usageMeterRemainingKey]
			
        case let cell as BillingCycleDetailCell:
			guard
			let billingMeterSection = ((data?[FidoHTMLParser.usageMeterKey] as? [AnyObject])?[indexPath.section] as? [String : AnyObject])?[FidoHTMLParser.usageMeterBillingCycleMeterSectionKey] as? [String : String],
				let billingTextSection = ((data?[FidoHTMLParser.usageMeterKey] as? [AnyObject])?[indexPath.section] as? [String : AnyObject])?[FidoHTMLParser.usageMeterBillingCycleTextSectionKey] as? [String : String] else {
					break
			}
			
			cell.usageMeterView.minLabel.text = billingMeterSection[FidoHTMLParser.usageMeterBillingCycleBeginKey]
			cell.usageMeterView.maxLabel.text = billingMeterSection[FidoHTMLParser.usageMeterBillingCycleEndKey]
			cell.usageMeterView.currentLabel.text = billingMeterSection[FidoHTMLParser.usageMeterBillingCycleTodayKey]
			
			delay(seconds: 0.1, completion: { () -> () in
				if let percentString = billingMeterSection[FidoHTMLParser.usageMeterBillingCyclePassedPercentKey] {
					cell.usageMeterView.progressBarView.percent = CGFloat(NSNumberFormatter().numberFromString(percentString) ?? 0) / 100.0
				} else {
					cell.usageMeterView.progressBarView.percent = 0.0
				}
			})
			
			cell.titleLabel.text = billingTextSection[FidoHTMLParser.usageMeterBillingCycleTitleKey]
			cell.daysInPairView.contentLabel.text = billingTextSection[FidoHTMLParser.usageMeterBillingCycleDaysIntoCycleKey]
			cell.remainingPairView.contentLabel.text = billingTextSection[FidoHTMLParser.usageMeterBillingCycleDaysRemainingKey]
			
        default:
            break
        }
    }
}

extension UsageViewController : UITableViewDelegate {
	// MARK: - Rows
	func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
	
	// MARK: - Selections
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		print("did selected: \(indexPath)")
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
	
	func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
		return 80
	}
	
	func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
		view.backgroundColor = UIColor(white: 0.0, alpha: 0.08)
		
		view.layoutMargins = UIEdgeInsets(top: 22, left: 8, bottom: 22, right: 8)
		
		if let data = (data?[FidoHTMLParser.usageTableKey] as? [AnyObject])?[section] as? [String : String] {
			let summaryView = UsageSummaryView(data: data)
			summaryView.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview(summaryView)
			
			summaryView.fullSizeMarginInSuperview()
		}
		
		return view
	}
}
