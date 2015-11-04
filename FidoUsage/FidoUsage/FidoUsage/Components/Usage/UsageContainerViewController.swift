//
//  UsageContainerViewController.swift
//  FidoUsage
//
//  Created by Honghao Zhang on 2015-10-26.
//  Copyright © 2015 Honghao Zhang. All rights reserved.
//

import UIKit
import ChouTi

class UsageContainerViewController : UIViewController {
	
	let usageViewControllers = [UsageViewController(), UsageViewController(), UsageViewController()]
	
	// MARK: - UI
	let menuPageViewController = MenuPageViewController()
	let underscoreImageView = UIImageView(image: UIImage(asset: .FidoTealUnderscore))
	let underscoreView = UIView()
	
	let menuWidth: CGFloat = 60.0
	let numberButton = UIButton(type: .Custom)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupViews()
		setupConstraints()
	}
	
	func setupViews() {
		let logoImageView = UIImageView(image: UIImage(asset: .FidoLogo))
		navigationItem.titleView = logoImageView
		
		self.automaticallyAdjustsScrollViewInsets = false
		self.navigationController?.navigationBar.hideBottomHairline()
		
		// MenuPageViewController
		menuPageViewController.menuTitleHeight = 44
		menuPageViewController.menuView.spacingsBetweenMenus = (UIScreen.mainScreen().bounds.width - menuWidth * CGFloat(usageViewControllers.count)) / (CGFloat(usageViewControllers.count) + 1)
		
		menuPageViewController.menuView.scrollingOption = .Center
		
		menuPageViewController.delegate = self
		menuPageViewController.dataSource = self
		
		menuPageViewController.selectedIndex = 1
		menuPageViewController.menuView.autoScrollingEnabled = false
		menuPageViewController.menuView.backgroundColor = UIColor.fidoYellowColor()
		
		// Add child VC
		addChildViewController(menuPageViewController)
		view.addSubview(menuPageViewController.view)
		menuPageViewController.didMoveToParentViewController(self)
		
		// Underscore View setup
		underscoreView.backgroundColor = UIColor.fidoYellowColor()
		underscoreView.translatesAutoresizingMaskIntoConstraints = false
		menuPageViewController.menuView.addSubview(underscoreView)
		
		underscoreView.addSubview(underscoreImageView)
		
		// Number button
		guard let leftNavigationBarBackgroundView = addLeftNavigationBarBackgroundView() else {
			log.error("leftNavigationBarBackgroundView is nil")
			return
		}
		
		numberButton.titleLabel?.font = UIFont.systemFontOfSize(11)
		numberButton.titleLabel?.numberOfLines = 2
		numberButton.setTitle("---", forState: .Normal)
		numberButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
		numberButton.setTitleColor(UIColor.blackColor().colorWithAlphaComponent(0.3), forState: .Highlighted)
		numberButton.setTitleColor(UIColor.blackColor().colorWithAlphaComponent(0.3), forState: .Selected)
		
		numberButton.translatesAutoresizingMaskIntoConstraints = false
		leftNavigationBarBackgroundView.addSubview(numberButton)
		numberButton.fullSizeInSuperview()
	}
	
	func setupConstraints() {
		let menuView = menuPageViewController.menuView
		if #available(iOS 9.0, *) {
		    underscoreView.bottomAnchor.constraintEqualToAnchor(menuView.bottomAnchor).active = true
			underscoreView.leadingAnchor.constraintEqualToAnchor(menuView.leadingAnchor).active = true
			underscoreView.trailingAnchor.constraintEqualToAnchor(menuView.trailingAnchor).active = true
			underscoreView.heightAnchor.constraintEqualToConstant(10).active = true
		} else {
		    // Fallback on earlier versions
		}
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		// Center menu view
		menuPageViewController.menuView.scrollWithSelectedIndex(usageViewControllers.count / 2, withOffsetPercent: 0.0, animated: false, ignoreAutoScrollingEnabled: true)
		// FIXME: width is not updated
		underscoreImageView.center = CGPoint(x: menuPageViewController.menuView.bounds.width / 2.0, y: underscoreImageView.center.y)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
//		let number = "\(Locator.client.numberString!)\n\(Locator.client.accountHolderName!)"
//		numberButton.setTitle(number, forState: .Normal)
	}
}

extension UsageContainerViewController : MenuPageViewControllerDataSource {
	func numberOfMenusInMenuPageViewController(menuPageViewController: MenuPageViewController) -> Int {
		return usageViewControllers.count
	}
	
	func menuPageViewController(menuPageViewController: MenuPageViewController, menuViewForIndex index: Int, contentView: UIView?) -> UIView {
		let labelBackgroundView = UIView()
		
		let label = UILabel()
		label.font = UIFont.systemFontOfSize(20)
		switch index {
		case 0:
			label.text = "Voice"
		case 1:
			label.text = "Data"
		case 2:
			label.text = "Message"
		default:
			label.text = "Title \(index)"
		}
		
		label.translatesAutoresizingMaskIntoConstraints = false
		
		labelBackgroundView.addSubview(label)
		
		if let contentView = contentView {
			labelBackgroundView.translatesAutoresizingMaskIntoConstraints = false
			contentView.addSubview(labelBackgroundView)
			
			if #available(iOS 9.0, *) {
				labelBackgroundView.topAnchor.constraintEqualToAnchor(contentView.topAnchor).active = true
				labelBackgroundView.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor).active = true
				labelBackgroundView.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor).active = true
				labelBackgroundView.trailingAnchor.constraintEqualToAnchor(contentView.trailingAnchor).active = true
				
				label.centerXAnchor.constraintEqualToAnchor(contentView.centerXAnchor).active = true
				label.centerYAnchor.constraintEqualToAnchor(contentView.centerYAnchor).active = true
			} else {
				// Fallback on earlier versions
			}
		}
		
		return label
	}
	
	func menuPageViewController(menuPageViewController: MenuPageViewController, viewControllerForIndex index: Int) -> UIViewController {
		return usageViewControllers[index]
	}
}

extension UsageContainerViewController : MenuPageViewControllerDelegate {
	func menuPageViewController(menuPageViewController: MenuPageViewController, menuWidthForIndex index: Int) -> CGFloat {
		return menuWidth
	}
	
	func menuPageViewController(menuPageViewController: MenuPageViewController, didSelectIndex selectedIndex: Int, selectedViewController: UIViewController) {
		print("selected: \(selectedIndex)")
		
		guard let menuView = menuPageViewController.menuView.menuViewForIndex(selectedIndex) else {
			return
		}
		
		// Updating underscore
		let rect = menuView.frameRectInView(menuPageViewController.menuView)
		let x = rect.origin.x + rect.width / 2.0
		
		UIView.animateWithDuration(0.25, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveEaseInOut, animations: { [unowned self] () -> Void in
			
			if let label = menuView as? UILabel {
				self.underscoreImageView.bounds = CGRect(x: 0, y: 0, width: label.exactSize().width * 1.2, height: self.underscoreImageView.bounds.height)
			}
			
			self.underscoreImageView.center = CGPoint(x: x, y: self.underscoreImageView.center.y)
		}, completion: nil)
	}
}
