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
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let logoImageView = UIImageView(image: UIImage(asset: .FidoLogo))
		navigationItem.titleView = logoImageView
		
		setupViews()
    }
	
	private func setupViews() {
		tableView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(tableView)
		
		tableView.backgroundColor = UIColor.whiteColor()
		tableView.separatorStyle = .None
		
		tableView.dataSource = self
		tableView.delegate = self
		tableView.rowHeight = UITableViewAutomaticDimension
		
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
				cell.detailTextLabel?.text = "Anytime"
			case 1:
				cell.textLabel?.text = "Type"
				cell.detailTextLabel?.text = "Anytime"
			case 2:
				cell.textLabel?.text = "Type"
				cell.detailTextLabel?.text = "Anytime"
			case 3:
				cell.textLabel?.text = "Type"
				cell.detailTextLabel?.text = "Anytime"
			default:
				break
			}
		case 1:
			switch indexPath.row {
			case 0:
				cell.textLabel?.text = "Type"
				cell.detailTextLabel?.text = "Anytime"
			case 1:
				cell.textLabel?.text = "Type"
				cell.detailTextLabel?.text = "Anytime"
			case 2:
				cell.textLabel?.text = "Type"
				cell.detailTextLabel?.text = "Anytime"
			case 3:
				cell.textLabel?.text = "Type"
				cell.detailTextLabel?.text = "Anytime"
			default:
				break
			}
		case 2:
			switch indexPath.row {
			case 0:
				cell.textLabel?.text = "Type"
				cell.detailTextLabel?.text = "Anytime"
			case 1:
				cell.textLabel?.text = "Type"
				cell.detailTextLabel?.text = "Anytime"
			case 2:
				cell.textLabel?.text = "Type"
				cell.detailTextLabel?.text = "Anytime"
			case 3:
				cell.textLabel?.text = "Type"
				cell.detailTextLabel?.text = "Anytime"
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
		//
	}
}
