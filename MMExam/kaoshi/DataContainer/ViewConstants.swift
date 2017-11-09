//
//  ViewConstants.swift
//  kaoshi
//
//  Created by 李晓东 on 2017/11/1.
//  Copyright © 2017年 晓东. All rights reserved.
//

import Foundation
import Toaster
import MBProgressHUD

let kToastShowTime = 1.5

extension UIColor {
    class func rgbColor(_ red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor.init(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
    }
    
    class func randomColor() -> UIColor {
        return self.rgbColor(CGFloat(arc4random()%255), green: CGFloat(arc4random()%255), blue: CGFloat(arc4random()%255))
    }
}

class ViewHelper {
    class func showFieldToast(_ text: String) {
        Toast.init(text: text, delay: 0.5, duration: kToastShowTime).show()
    }
    
    class func showLoading(_ view: UIView) -> MBProgressHUD {
        let loading = MBProgressHUD.showAdded(to: view, animated: true)
        loading.detailsLabel.text = "加载中..."
        loading.isUserInteractionEnabled = true
        return loading
    }
    
    class func showResponseToast(_ text: String?) {
        let loading = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        loading.mode = .text
        //loading.bezelView.backgroundColor = UIColor.init(white: 0.1, alpha: 0.9)
        if text == nil {
            loading.detailsLabel.text = "网络发生错误"
        } else {
            loading.detailsLabel.text = text
        }
        //loading.detailsLabel.textColor = UIColor.white
        loading.isUserInteractionEnabled = true
        loading.hide(animated: true, afterDelay: kToastShowTime)
    }
    
    class func factorLabel(_ text: String, textColor: UIColor?, font: CGFloat) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: font)
        if textColor != nil {
            label.textColor = textColor!
        } else {
            label.textColor = UIColor.black
        }
        return label
    }
    
    class func factorBtn (_ text: String, font: CGFloat, bgColor: UIColor?, textColor: UIColor?, imageName: String?) -> UIButton {
        let btn = UIButton()
        btn.backgroundColor = bgColor != nil ? bgColor : UIColor.white
        btn.titleLabel?.font = UIFont.systemFont(ofSize: font)
        btn.setTitle(text, for: .normal)
        btn.setTitleColor(textColor != nil ? textColor : UIColor.black, for: .normal)
        if imageName != nil {
             btn.setImage(UIImage.init(named: imageName!), for: .normal)
        }
        return btn
    }
    
    class func factorImageView(_ imageName: String, frame: CGRect) -> UIImageView {
        let imageV = UIImageView()
        imageV.image = UIImage.init(named: imageName)
        imageV.frame = frame
        return imageV
    }
    
    class func factorTextField(_ text: String, font: CGFloat) -> UITextField {
        let field = UITextField()
        field.text = text
        field.font = UIFont.systemFont(ofSize: font)
        field.textColor = UIColor.black
        return field
    }
}
