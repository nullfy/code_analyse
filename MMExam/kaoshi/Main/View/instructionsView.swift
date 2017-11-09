//
//  instructionsView.swift
//  kaoshi
//
//  Created by 李晓东 on 2017/10/31.
//  Copyright © 2017年 晓东. All rights reserved.
//

import UIKit

@objc protocol instructionDelegate: NSObjectProtocol {
    @objc optional func clickExamBtn(_ sender: Any)
    @objc optional func clickCharactersExamBtn(_ sender: Any)
}

class instructionsView: UIView {

    @IBOutlet weak var examTopConstraint: NSLayoutConstraint!
    
    weak var delegate: instructionDelegate?
    
    @IBOutlet weak var examBtn: UIButton!
    @IBOutlet weak var instructBtn: UIButton!
    
    @IBOutlet weak var Examinmation: UILabel!
    
    @IBAction func charactersClicked(_ sender: Any) {
        self.delegate?.clickCharactersExamBtn!(sender)
    }

    @IBAction func examClicked(_ sender: Any) {
        self.delegate?.clickExamBtn!(sender)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var barHeight: CGFloat = 42
        if UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.portrait ||
            UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.portraitUpsideDown {
            barHeight = self.height == 812 ? 98 : 74
        }
        self.examTopConstraint.constant = barHeight
    }
}
