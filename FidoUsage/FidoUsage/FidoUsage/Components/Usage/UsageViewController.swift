//
//  UsageViewController.swift
//  FidoUsage
//
//  Created by Honghao Zhang on 2015-09-18.
//  Copyright © 2015 Honghao Zhang. All rights reserved.
//

import UIKit

class UsageViewController : UIViewController {

	let tableView = UITableView(frame: CGRectZero, style: .Grouped)
	
	var data = [String: AnyObject]()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupViews()
    }
	
	private func setupViews() {
		tableView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(tableView)
		
		tableView.separatorStyle = .None
		
		tableView.dataSource = self
		tableView.delegate = self
		tableView.rowHeight = UITableViewAutomaticDimension
		
		tableView.canCancelContentTouches = true
		tableView.delaysContentTouches = true
		
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
		return 3
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 4
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0: return "Voice"
		case 1: return "Data"
		case 2: return "Messaging"
		default: return nil
		}
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("Cell")
		if cell == nil {
			cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
		}
		
		switch indexPath.section {
		case 0:
			switch indexPath.row {
			case 0:
				cell.textLabel?.text = "Type"
//				cell.detailTextLabel?.text = data["Voice"]?["Type"]
			case 1:
				cell.textLabel?.text = "Included"
//				cell.detailTextLabel?.text = data["Voice"]?["Included"]
			case 2:
				cell.textLabel?.text = "Used"
//				cell.detailTextLabel?.text = data["Voice"]?["Used"]
			case 3:
				cell.textLabel?.text = "Remaining"
//				cell.detailTextLabel?.text = data["Voice"]?["Remaining"]
			default:
				break
			}
		case 1:
			switch indexPath.row {
			case 0:
				cell.textLabel?.text = "Type"
//				cell.detailTextLabel?.text = data["Data"]?["Type"]
			case 1:
				cell.textLabel?.text = "Included"
//				cell.detailTextLabel?.text = data["Data"]?["Included"]
			case 2:
				cell.textLabel?.text = "Used"
//				cell.detailTextLabel?.text = data["Data"]?["Used"]
			case 3:
				cell.textLabel?.text = "Remaining"
//				cell.detailTextLabel?.text = data["Data"]?["Remaining"]
			default:
				break
			}
		case 2:
			switch indexPath.row {
			case 0:
				cell.textLabel?.text = "Type"
//				cell.detailTextLabel?.text = data["Messaging"]?["Type"]
			case 1:
				cell.textLabel?.text = "Included"
//				cell.detailTextLabel?.text = data["Messaging"]?["Included"]
			case 2:
				cell.textLabel?.text = "Used"
//				cell.detailTextLabel?.text = data["Messaging"]?["Used"]
			case 3:
				cell.textLabel?.text = "Remaining"
//				cell.detailTextLabel?.text = data["Messaging"]?["Remaining"]
			default:
				break
			}
		default:
			break
		}
		
		return cell
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
	}
}
