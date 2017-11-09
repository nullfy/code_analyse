//
//  LoginView.swift
//  kaoshi
//
//  Created by 李晓东 on 2017/10/31.
//  Copyright © 2017年 晓东. All rights reserved.
//

import UIKit
import Toaster

@objc protocol LoginViewDelegate: NSObjectProtocol {
    @objc optional func loginButtonClick(_ sender: UIButton)
}

class LoginView: UIView {

    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    weak var delegate: LoginViewDelegate?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DataContainer.manager.data_selectItem = ""
    }
    
    override func layoutSubviews() {
        self.widthConstraint.constant = self.width > 414 ? 334 : self.width-40
        self.topConstraint.constant = self.height < 414 ? 40 : (self.height > 568 ? 100 : 70)
        //print("top---",self.topConstraint.constant)
    }

    @IBAction func clickLoginBtn(_ sender: Any) {
        self.endEditing(true)
        var aler: NSString = ""
        
        if phoneField.text == nil {
            aler = "清填写手机号"
        }
        
        if nameField.text == nil {
            aler = "清填写姓名"
        }
        
        if aler.length > 0 {
            ViewHelper.showFieldToast(aler as String)
            return
        }
        DataContainer.manager.data_name = nameField.text!
        DataContainer.manager.data_phone = phoneField.text!
        guard self.delegate?.loginButtonClick!(sender as! UIButton) != nil else {
            return
        }
    }
}

extension LoginView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.nameField.isFirstResponder {
            self.nameField.resignFirstResponder()
            self.phoneField.becomeFirstResponder()
        }
        
        return true
    }
}
