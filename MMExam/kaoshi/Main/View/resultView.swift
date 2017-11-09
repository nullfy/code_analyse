//
//  resultView.swift
//  kaoshi
//
//  Created by 李晓东 on 2017/11/9.
//  Copyright © 2017年 晓东. All rights reserved.
//

import UIKit

class resultView: UIView {

    @IBOutlet weak var topConstrain: NSLayoutConstraint!
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var continueBtn: UIButton!
    weak var delegate: ResultViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func resultViewClickContinue(_ sender: Any) {
        guard self.delegate?.resultViewDidClickContinue(sender) != nil else {
            return
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var barHeight: CGFloat = 62
        if UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.portrait ||
            UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.portraitUpsideDown {
            barHeight = self.height == 812 ? 118 : 94
        }
        self.topConstrain.constant = barHeight
    }
}


@objc protocol ResultViewDelegate {
    @objc func resultViewDidClickContinue(_ sender: Any)
}
