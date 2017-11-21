//
//  RefreshView.swift
//  RxTest
//
//  Created by 李晓东 on 2017/11/21.
//  Copyright © 2017年 晓东. All rights reserved.
//

import UIKit
import Then

class RefreshView: UIView {

    let cicleLayer = CAShapeLayer()
    
    let indicatorView = UIActivityIndicatorView().then {
        $0.frame = CGRect.init(x: 0, y: 0, width: 16, height: 16)
    }
    
    fileprivate var refreshing = false
    fileprivate var endRef = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createCircleLayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createCircleLayer() {
        cicleLayer.path = UIBezierPath.init(arcCenter: CGPoint.init(x: 8, y: 8),
                                            radius: 8,
                                            startAngle: CGFloat.pi/2,
                                            endAngle: CGFloat.pi*3/2,
                                            clockwise: true).cgPath
        cicleLayer.strokeColor = UIColor.white.cgColor
        cicleLayer.fillColor = UIColor.clear.cgColor
        cicleLayer.strokeStart = 0.0
        cicleLayer.strokeEnd = 0.0
        cicleLayer.lineWidth = 1.0
        cicleLayer.lineCap = kCALineCapRound
        cicleLayer.bounds = CGRect.init(x: 0, y: 0, width: 16, height: 16)
        cicleLayer.anchorPoint = CGPoint.init(x: 0.5, y: 0.5)
        layer.addSublayer(cicleLayer)
    }
}


extension RefreshView {
    func pullToRefresh(progress: CGFloat) {
        cicleLayer.strokeEnd = progress
    }
    
    func beginRefresh(begin: @escaping () -> Void) {
        if refreshing {
            return
        }
        refreshing = true
        cicleLayer.removeFromSuperlayer()
        addSubview(indicatorView)
        indicatorView.startAnimating()
        begin()
    }
    
    func endRefresh() {
        refreshing = false
        indicatorView.stopAnimating()
        indicatorView.removeFromSuperview()
    }
    
    func resetLayer() {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) { 
            self.createCircleLayer()
        }
    }
}

