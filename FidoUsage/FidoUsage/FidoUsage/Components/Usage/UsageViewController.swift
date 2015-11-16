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
import DGElasticPullToRefresh

class UsageViewController : UIViewController {
	
    var sectionTitle: String
	
	let tableView = UITableView(frame: CGRectZero, style: .Plain)
	var loadingView: LoadingMorphingLabel?
	
	var data: [String: AnyObject]?
	
	private var isRequesting: Bool = false
	
	private var viewHasAppeared: Bool = false
	
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
		// Table View
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

		let circleLoadingView = DGElasticPullToRefreshLoadingViewCircle()
		circleLoadingView.tintColor = UIColor.fidoTealColor()
		circleLoadingView.circleLineWidth = 1.5
		
		tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
			self?.updateData({ _ -> Void in
				self?.tableView.dg_stopLoading()
			})
			}, loadingView: circleLoadingView)
		tableView.dg_setPullToRefreshFillColor(UIColor.fidoYellowColor())
		tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)
		
		// Loading view
		loadingView = LoadingMorphingLabel()
		loadingView!.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(loadingView!)
		
		loadingView!.loopCount = Int.max
		loadingView!.delayDuration = 1.5
		loadingView!.morphingEffect = .Scale
		loadingView!.morphingDuration = 1.0
		
		if #available(iOS 8.2, *) {
			loadingView!.morphingLabel.font = UIFont.systemFontOfSize(20, weight: UIFontWeightRegular)
		} else {
			loadingView!.morphingLabel.font = UIFont.helveticaNeueLightFont(20)!
		}
		
		loadingView!.texts = ["Loading...", "\(sectionTitle) Usage..."]
		loadingView!.setHidden(true)
		
		setupConstraints()
	}
	
	private func setupConstraints() {
		tableView.fullSizeInSuperview()
		loadingView?.centerInSuperview()
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		if !viewHasAppeared {
			updateData()
			viewHasAppeared = true
		}
	}
	
	deinit {
		tableView.dg_removePullToRefresh()
	}
	
	func updateData(completion: ((Bool) -> Void)? = nil) {
		if !isRequesting {
			isRequesting = true
			
			let client = Locator.client
			
			loadingView?.texts = ["Loading...", "\(sectionTitle) Usage..."]
			loadingView?.currentTextIndex = 1
			loadingView?.setHidden(false, animated: true, duration: 0.5)
			loadingView?.startLoop()
			
			log.info("Requesting \(self.sectionTitle) ...")
			
			client.showViewUsgaeForSection(sectionTitle, completion: { (succeed, table) in
				if succeed {
					self.data = table
					self.tableView.reloadData()

					self.tableView.setHidden(false, animated: true, duration: 0.5)
					
					self.loadingView?.endLoop()
					self.loadingView?.setHidden(true, animated: true, duration: 0.5, completion: { _ in
						self.loadingView?.removeFromSuperview()
						self.loadingView = nil
					})
					
					completion?(true)
				} else {
					self.view.insertSubview(self.loadingView!, aboveSubview: self.tableView)
					self.tableView.setHidden(false, animated: true, duration: 0.5)
					self.loadingView?.currentTextIndex = 0
					self.loadingView?.texts = ["Loading \(self.sectionTitle) Usage Failed!", "Pull To Refresh..."]
				
					completion?(false)
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
			
			// Only enabel red progress bar for non-unlimited 
			let summaryData = (data?[FidoHTMLParser.usageTableKey] as? [AnyObject])?[indexPath.section] as? [String : String]
			if let includedString = summaryData?[FidoHTMLParser.usageTableIncludedKey] where includedString == "Unlimited" {
				cell.usageMeterView.shouldShowDifferentColor = false
			} else {
				cell.usageMeterView.shouldShowDifferentColor = true
			}
			
			cell.usageMeterView.progressBarView.setPercent(0.0, animated: false)
			
			delay(seconds: 0.1, completion: { () -> () in
				cell.usageMeterView.progressBarView.animated = true
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
			
			cell.usageMeterView.progressBarView.setPercent(0.0, animated: false)
			
			delay(seconds: 0.1, completion: { () -> () in
				cell.usageMeterView.progressBarView.animated = true
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
