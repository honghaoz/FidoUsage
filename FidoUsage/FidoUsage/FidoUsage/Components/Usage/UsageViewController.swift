//
//  UsageViewController.swift
//  FidoUsage
//
//  Created by Honghao Zhang on 2015-09-18.
//  Copyright © 2015 Honghao Zhang. All rights reserved.
//

import UIKit
import ChouTi

class UsageViewController : UIViewController {
	
	let tableView = UITableView(frame: CGRectZero, style: .Plain)
	
	var data = [String: AnyObject]()
	
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
		
//		log.info("Goto View Usage Page ...")
//		Locator.client.gotoViewUsagePage { (succeed, sections) in
//			guard let sections = sections else {
//				log.error("Sections are emtpy")
//				return
//			}
//			log.debug("Usage Sections: \(sections)")
//
//			var startIndex = 0
//
//			log.info("Getting section: \(sections[startIndex])")
//			Locator.client.showViewUsgaeForSection(sections[startIndex], completion: { (succeed, table) in
//				log.debug(table)
//				
//				self.data[sections[startIndex]] = table
//				self.tableView.reloadData()
//				if startIndex < sections.count {
//					startIndex++
//					log.info("Getting section: \(sections[startIndex])")
//					Locator.client.showViewUsgaeForSection(sections[startIndex], completion: { (succeed, table) in
//						log.debug(table)
//						
//						self.data[sections[startIndex]] = table
//						self.tableView.reloadData()
//						if startIndex < sections.count {
//							startIndex++
//							log.info("Getting section: \(sections[startIndex])")
//							Locator.client.showViewUsgaeForSection(sections[startIndex], completion: { (succeed, table) in
//								log.debug(table)
//								
//								self.data[sections[startIndex]] = table
//								self.tableView.reloadData()
//								
//								log.info(Locator.client.accountHolderName)
//								log.info(Locator.client.numberString)
//								log.info(Locator.client.usageSections)
//								log.info(Locator.client.usageDetails)
//							})
//						}
//					})
//				}
//			})
//		}
	}
}

extension UsageViewController : UITableViewDataSource {
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 3
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		
		switch indexPath.row {
		case 0:
			return tableView.dequeueReusableCellWithIdentifier(UsageDetailCell.identifier()) as! UsageDetailCell
		case 1:
			let separatorCell = tableView.dequeueReusableCellWithIdentifier(SeparatorCell.identifier()) as! SeparatorCell
			separatorCell.layoutMargins = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
			separatorCell.separatorView.backgroundColor = UIColor(white: 0.75, alpha: 1.0)
			return separatorCell
		case 2:
			return tableView.dequeueReusableCellWithIdentifier(BillingCycleDetailCell.identifier()) as! BillingCycleDetailCell
		default:
			return UITableViewCell()
		}
		
//		switch indexPath.section {
//		case 0:
//			switch indexPath.row {
//			case 0:
//				cell.textLabel?.text = "Type"
////				cell.detailTextLabel?.text = data["Voice"]?["Type"]
//			case 1:
//				cell.textLabel?.text = "Included"
////				cell.detailTextLabel?.text = data["Voice"]?["Included"]
//			case 2:
//				cell.textLabel?.text = "Used"
////				cell.detailTextLabel?.text = data["Voice"]?["Used"]
//			case 3:
//				cell.textLabel?.text = "Remaining"
////				cell.detailTextLabel?.text = data["Voice"]?["Remaining"]
//			default:
//				break
//			}
//			
//		default:
//			break
//		}
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
	
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 64
	}
	
	func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
		
		return view
	}
}
