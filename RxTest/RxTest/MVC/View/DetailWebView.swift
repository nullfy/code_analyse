//
//  DetailWebView.swift
//  RxTest
//
//  Created by 李晓东 on 2017/11/21.
//  Copyright © 2017年 晓东. All rights reserved.
//

import UIKit

class DetailWebView: UIWebView {

    //Mark: 头部图片
    var img = UIImageView().then {
        $0.frame = CGRect.init(x: 0, y: 0, width: ScreenWidth, height: 200)
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    //Mark: 头部图片阴影遮罩
    var maskImg = UIImageView().then {
        $0.frame = CGRect.init(x: 0, y: 100, width: ScreenWidth, height: 100)
        $0.image = UIImage.init(named: "Home_Image_Mask")
    }
    
    //Mark: 标题
    var titleLab = UILabel().then {
        $0.frame = CGRect.init(x: 15, y: 150, width: ScreenWidth - 30, height: 26)
        $0.font = UIFont.boldSystemFont(ofSize: 21)
        $0.numberOfLines = 2
        $0.textColor = UIColor.white
    }
    
    var imgLab = UILabel().then {
        $0.frame = CGRect.init(x: 15, y: 180, width: ScreenWidth-30, height: 16)
        $0.font = UIFont.systemFont(ofSize: 10)
        $0.textAlignment = .right
        $0.textColor = UIColor.white
    }
    
    var previousLab = UILabel().then {
        $0.frame = CGRect.init(x: 15, y: -40, width: ScreenWidth-30, height: 20)
        $0.text = "载入上一篇"
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.textAlignment = .right
        $0.textColor = UIColor.white
    }
    
    var nextLab = UILabel().then {
        $0.frame = CGRect.init(x: 15, y: ScreenHeight + 40, width: ScreenWidth-30, height: 20)
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.text = "载入下一篇"
        $0.textAlignment = .center
        $0.textColor = UIColor.white
    }

    var waitView = UIView().then {
        $0.backgroundColor = UIColor.white
        $0.frame = CGRect.init(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
        let acv = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
        acv.center = $0.center
        acv.startAnimating()
        $0.addSubview(acv)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        img.addSubview(maskImg)
        scrollView.addSubview(img)
        scrollView.addSubview(titleLab)
        scrollView.addSubview(imgLab)
        scrollView.addSubview(previousLab)
        scrollView.addSubview(nextLab)
        scrollView.addSubview(waitView)
        backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
