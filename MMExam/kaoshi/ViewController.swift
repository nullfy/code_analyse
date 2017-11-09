//
//  ViewController.swift
//  kaoshi
//
//  Created by 李晓东 on 2017/10/31.
//  Copyright © 2017年 晓东. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var v: LoginView?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fd_prefersNavigationBarHidden = true
        self.configUI()
    }

    func configUI() {
        let login = Bundle.main.loadNibNamed("login", owner: nil, options: nil)?.last as! LoginView
        login.delegate = self
        v = login
        self.view.addSubview(login)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        v?.frame = self.view.frame
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

extension ViewController: LoginViewDelegate {
    func loginButtonClick(_ sender: UIButton) {
        self.navigationController?.pushViewController(MainController(), animated: true)
    }
}
