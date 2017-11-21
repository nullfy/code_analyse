//
//  MenuViewController.swift
//  RxTest
//
//  Created by 李晓东 on 2017/11/20.
//  Copyright © 2017年 晓东. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya
import SwiftDate
import RxDataSources


class MenuViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let provider = RxMoyaProvider<APIManager>()
    let dispose = DisposeBag()
    let themeArr = Variable([ThemeModel]())
    var bindToNav: UITabBarController?
    var beganDate: Date?
    var endDate: Date?
    var showView = false {
        didSet {
            showView ? showMenu() : dismissMenu()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        provider
            .request(.getThemeList)
            .mapModel(ThemeResponseModel.self)
            .addDisposableTo(dispose)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


extension MenuViewController {
    static let shareInstance = createMenuView()
    
    private static func createMenuView() -> MenuViewController {
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let menuView = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as? MenuViewController
        menuView?.view.frame = CGRect.init(x: -255, y: 0, width: 255, height: ScreenHeight)
        return menuView!
    }
    
    func showThemeVC(_ model: ThemeModel) {
        if model.id == nil {
            bindToNav?.selectedIndex = 0
        } else {
            bindToNav?.selectedIndex = 1
            NotificationCenter.default.post(name: Notification.Name.init("setTheme"), object: nil, userInfo: ["Model":model])
            UserDefaults.standard.set(model.name, forKey: "themeName")
            UserDefaults.standard.set(model.thumbnail, forKey: "themeImgUrl")
            UserDefaults.standard.set(model.id!, forKey: "themeNameId")
        }
    }
    
    func swipeGesture(swipe: UISwipeGestureRecognizer) {
        if swipe.state == .ended {
            if swipe.direction == .left && showView {
                showView = false
            }
            
            if swipe.direction == .right && !showView {
                showView = true
            }
        }
    }
    
    func panGesture(pan: UIPanGestureRecognizer) {
        let offX = pan.translation(in: view).x
        if pan.state == .began {
            beganDate = Date()
        }
        
        if pan.state == .ended {
            endDate = Date()
            if endDate! < (beganDate! + 150000000.nanoseconds) {
                showView = offX > 0
                return
            }
        }
        
        if (0 < offX && offX <= 255 && !showView) || (offX < 0 && offX >= -255 && showView) {
            if pan.translation(in: view).x > 0 {
                moveMenu(pan.translation(in: view).x)
            } else {
                moveMenu(255+pan.translation(in: view).x)
            }
            
            if pan.state == .ended {
                if showView {
                    showView = pan.translation(in: view).x >= -175
                } else {
                    showView = pan.translation(in: view).x > 50
                }
            }
        }
    }
    
    func showMenu() {
        let view = UIApplication.shared.keyWindow?.subviews.first
        let menuView = UIApplication.shared.keyWindow?.subviews.last
        UIApplication.shared.keyWindow?.bringSubview(toFront: (UIApplication.shared.keyWindow?.subviews[1])!)
        UIView.animate(withDuration: 0.5) {
            view?.transform = CGAffineTransform.init(translationX: 225, y: 0)
            menuView?.transform = (view?.transform)!
        }
    }
    
    func dismissMenu() {
        let view = UIApplication.shared.keyWindow?.subviews.first
        let menuView = UIApplication.shared.keyWindow?.subviews.last
        UIApplication.shared.keyWindow?.bringSubview(toFront: (UIApplication.shared.keyWindow?.subviews[1])!)
        UIView.animate(withDuration: 0.5) {
            view?.transform = CGAffineTransform.init(translationX: 0, y: 0)
            menuView?.transform = (view?.transform)!
        }
    }
    
    func moveMenu(_ offX: CGFloat) {
        let view = UIApplication.shared.keyWindow?.subviews.first
        let menuView = UIApplication.shared.keyWindow?.subviews.last
        UIApplication.shared.keyWindow?.bringSubview(toFront: (UIApplication.shared.keyWindow?.subviews[1])!)
        UIView.animate(withDuration: 0.5) {
            view?.transform = CGAffineTransform.init(translationX: offX, y: 0)
            menuView?.transform = (view?.transform)!
        }
    }
    
}
