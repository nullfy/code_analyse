//
//  ThemeTableViewCell.swift
//  RxTest
//
//  Created by 李晓东 on 2017/11/21.
//  Copyright © 2017年 晓东. All rights reserved.
//

import UIKit



class ThemeTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var nameLeft: NSLayoutConstraint!
    @IBOutlet weak var homeIco: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            name.font = UIFont.boldSystemFont(ofSize: 15)
            name.textColor = UIColor.white
            contentView.backgroundColor = UIColor.colorWithHex(0x1D2328)
            homeIco.image = UIImage.init(named: "Menu_Icon_Home_Highlight")
        } else {
            name.font = UIFont.boldSystemFont(ofSize: 15)
            name.textColor = UIColor.colorWithHex(0x95999D)
            contentView.backgroundColor = UIColor.clear
            homeIco.image = UIImage.init(named: "Menu_Icon_Home")
        }
    }

}
