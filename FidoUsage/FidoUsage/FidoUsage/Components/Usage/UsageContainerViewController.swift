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
	
	var usageViewControllers = [UsageViewController]()
	
	// MARK: - UI
	let menuPageViewController = MenuPageViewController()
	let underscoreImageView = UIImageView(image: UIImage(asset: .FidoTealUnderscore))
	let underscoreView = UIView()
	
	let menuWidth: CGFloat = 60.0
	let numberButton = UIButton(type: .Custom)
	
	convenience init() {
		self.init(sections: [])
	}
	
	init(sections: [String]) {
		super.init(nibName: nil, bundle: nil)
		commonInit()
		updateSections(sections)
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	private func commonInit() {
		menuPageViewController.menuView.setHidden(true)
		
		menuPageViewController.delegate = self
		menuPageViewController.dataSource = self
	}
	
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
		menuPageViewController.menuView.menuAlwaysCentered = true
		menuPageViewController.menuTitleHeight = 44
		
		menuPageViewController.menuView.scrollingOption = .Center
		
		menuPageViewController.menuView.autoScrollingEnabled = false
		menuPageViewController.menuView.backgroundColor = UIColor.fidoYellowColor()
		
		// Add child VC
		addChildViewController(menuPageViewController)
		view.addSubview(menuPageViewController.view)
		menuPageViewController.didMoveToParentViewController(self)
		
		// Underscore View setup
		underscoreView.backgroundColor = UIColor.clearColor()
		underscoreView.translatesAutoresizingMaskIntoConstraints = false
		menuPageViewController.menuView.addSubview(underscoreView)
		underscoreView.clipsToBounds = true
		underscoreView.addSubview(underscoreImageView)
		// Put underscore image below
		underscoreImageView.center = CGPoint(x: menuPageViewController.menuView.bounds.width / 2.0, y: 15)
		
		// Number button
		guard let leftNavigationBarBackgroundView = addLeftNavigationBarBackgroundView() else {
			log.error("leftNavigationBarBackgroundView is nil")
			return
		}
		
		numberButton.titleLabel?.font = UIFont.systemFontOfSize(11)
		numberButton.titleLabel?.numberOfLines = 2
		numberButton.setTitle("", forState: .Normal)
		numberButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
		numberButton.setTitleColor(UIColor.blackColor().colorWithAlphaComponent(0.3), forState: .Highlighted)
		numberButton.setTitleColor(UIColor.blackColor().colorWithAlphaComponent(0.3), forState: .Selected)
		
		numberButton.setHidden(true)
		
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
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		log.info("Requesting sections ...")
		Locator.client.gotoViewUsagePage({ (succeed, sections) -> Void in
			if let sections = Locator.client.usageSections {
				log.info("Got sections: \(sections)")
				
				self.updateSections(sections)
				if let dataIndex = sections.indexOf("Data") {
					self.menuPageViewController.selectedIndex = dataIndex
				} else {
					self.menuPageViewController.selectedIndex = sections.count / 2
				}
				
				let number = "\(Locator.client.numberString!)\n\(Locator.client.accountHolderName!)"
				self.numberButton.setTitle(number, forState: .Normal)
				
				self.numberButton.setHidden(false, animated: true, duration: 0.5)
			}
		})
	}
}

extension UsageContainerViewController {
    func updateSections(sections: [String]) {
		if sections.count > 0 {
			menuPageViewController.menuView.setHidden(false, animated: true, duration: 0.5)
		} else {
			menuPageViewController.menuView.setHidden(true)
		}
		
        usageViewControllers.removeAll()
        
        sections.forEach {
            self.usageViewControllers.append(UsageViewController(sectionTitle: $0))
        }
		
		menuPageViewController.menuView.spacingsBetweenMenus = (UIScreen.mainScreen().bounds.width - menuWidth * CGFloat(usageViewControllers.count)) / (CGFloat(usageViewControllers.count) + 1)

		menuPageViewController.reload()
		
		// Give some delay for menuPage to reload
		delay(seconds: 0.05) { () -> () in
			self.animateUnderScore(self.menuPageViewController.selectedIndex)
		}
    }
	
	func animateUnderScore(var index: Int) {
		if index < 0 {
			index = usageViewControllers.count / 2
		}
		
		guard let menuView = menuPageViewController.menuView.menuViewForIndex(index) else {
			return
		}
		
		let rect = menuView.frameRectInView(menuPageViewController.menuView)
		let x = rect.origin.x + rect.width / 2.0
		
		// if underscore image view is hidden, set x and width immediately and animte move up
		if underscoreImageView.center.y > underscoreView.bounds.height {
			if let label = menuView as? UILabel {
				underscoreImageView.bounds = CGRect(x: 0, y: 0, width: label.exactSize().width * 1.2, height: underscoreImageView.bounds.height)
			}
			
			underscoreImageView.center = CGPoint(x: x, y: underscoreImageView.center.y)
		}
		
		UIView.animateWithDuration(0.25, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveEaseInOut, animations: { [unowned self] () -> Void in
			
			if let label = menuView as? UILabel {
				self.underscoreImageView.bounds = CGRect(x: 0, y: 0, width: label.exactSize().width * 1.2, height: self.underscoreImageView.bounds.height)
			}
			
			self.underscoreImageView.center = CGPoint(x: x, y: self.underscoreView.bounds.height / 2.0)
			}, completion: nil)
	}
}

extension UsageContainerViewController : MenuPageViewControllerDataSource {
	func numberOfMenusInMenuPageViewController(menuPageViewController: MenuPageViewController) -> Int {
		return usageViewControllers.count
	}
	
	func menuPageViewController(menuPageViewController: MenuPageViewController, menuViewForIndex index: Int, contentView: UIView?) -> UIView {
		
		let labelBackgroundView = UIView()
		
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		labelBackgroundView.addSubview(label)
		
		label.font = UIFont.systemFontOfSize(20)
		label.text = usageViewControllers[index].sectionTitle
		
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
		log.debug("selected index: \(selectedIndex)")
		animateUnderScore(selectedIndex)
	}
}
