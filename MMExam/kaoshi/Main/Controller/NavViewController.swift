//
//  NavViewController.swift
//  kaoshi
//
//  Created by 李晓东 on 2017/11/1.
//  Copyright © 2017年 晓东. All rights reserved.
//

import UIKit

class NavViewController: UINavigationController {

    //override class func load() //swift is not permited
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.tintColor = UIColor.white
        self.navigationBar.setBackgroundImage(UIImage.init(color: #colorLiteral(red: 0.1058074012, green: 0.423573643, blue: 0.9617976546, alpha: 1)), for: .any, barMetrics: .default )
        
        let attributes = NSMutableDictionary()
        attributes[NSForegroundColorAttributeName] = UIColor.white
        attributes[NSFontAttributeName] = UIFont.systemFont(ofSize: 18)
        self.navigationBar.titleTextAttributes = attributes as? [String : Any]
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewController.className() == "kaoshi.MainController" ||
            viewController.className() == "kaoshi.FinishViewController" ||
            viewController.className() == "kaoshi.ScoreViewController" {
            let lefItem = UIBarButtonItem.init(customView: UIView())
            viewController.navigationItem.leftBarButtonItem = lefItem
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.all
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }
}
