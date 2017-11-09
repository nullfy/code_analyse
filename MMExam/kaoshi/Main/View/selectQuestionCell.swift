//
//  selectQustionswift
//  kaoshi
//
//  Created by 李晓东 on 2017/11/3.
//  Copyright © 2017年 晓东. All rights reserved.
//

import UIKit


@objc protocol QuestionCellDelegate {

    @objc optional func questionCellConfirmClick(_ sender: Any)
    @objc optional func questionCellAClick(_ sender: Any)
    @objc optional func questionCellBClick(_ sender: Any)
    @objc optional func questionCellCClick(_ sender: Any)
    @objc optional func questionCellDClick(_ sender: Any)
}


class selectQustionCell: UITableViewCell {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var confirmBtn: UIButton!
    
    @IBOutlet weak var itemA: UILabel!
    @IBOutlet weak var itemB: UILabel!
    @IBOutlet weak var itemC: UILabel!
    @IBOutlet weak var itemD: UILabel!
    @IBOutlet weak var btnA: UIButton!
    @IBOutlet weak var btnB: UIButton!
    @IBOutlet weak var btnC: UIButton!
    @IBOutlet weak var btnD: UIButton!
    
    @IBOutlet weak var containerWidth: NSLayoutConstraint!
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    @IBOutlet weak var confirmTopConstraint: NSLayoutConstraint!
    
    var questionModel: QuestionModel?
    var isHeightCalculated: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bottom = confirmBtn.bottom+40 > self.height ? confirmBtn.bottom+40 : self.height
        containerWidth.constant = self.width
        containerHeight.constant = self.bottom
        scrollView.contentSize = CGSize.init(width: self.width, height: bottom)
        //print("layoutsubv-----\((questionModel?.qId)!)==========")
        //print("2-----subvi--\((questionModel?.qId)!)","bottom--\(confirmBtn.bottom)","size--",scrollView.contentSize)
    }
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        
//        scrollView.contentSize = CGSize.init(width: self.width, height: self.height)
//        let bottom = confirmBtn.bottom+40 > self.height ? confirmBtn.bottom+40 : self.height
//        containerHeight.constant = self.bottom
//        print("reuse-----\((questionModel?.qId)!)",scrollView.contentSize)
//    }
//    
//    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        print("layoutfitter-----\((questionModel?.qId)!)",scrollView.contentSize)
//        return super.preferredLayoutAttributesFitting(layoutAttributes)
//    }
    
    func layout(_ model: QuestionModel) {
        questionModel = model
        titleLabel.text = "\(model.qId). 选择题(\(model.qPoint)分)"
        questionLabel.text = model.qTitle
        itemD.isHidden = false
        btnD.isHidden = false
        let selects = model.qSelects
        confirmTopConstraint.constant = 20
        if selects.count == 4 {
            itemA.text = selects[0] as? String
            itemB.text = selects[1] as? String
            itemC.text = selects[2] as? String
            itemD.text = selects[3] as? String
        } else if selects.count == 3 {
            itemA.text = selects[0] as? String
            itemB.text = selects[1] as? String
            itemC.text = selects[2] as? String
            itemD.isHidden = true
            btnD.isHidden = true
            confirmTopConstraint.constant = 0
        }
//        let size = self.containerView.systemLayoutSizeFitting(CGSize.init(width: self.width, height: 0))
//        let size1 = questionLabel.systemLayoutSizeFitting(CGSize.init(width: self.width, height: 0))
        
        //print("1-----","layout--\(Int(model.qId)!-1)","bottom--\(confirmBtn.bottom)","size--\(size)",size1)
    }
    
    @IBAction func clickConfirm(_ sender: Any) {
        
    }
    
    @IBAction func clickA(_ sender: Any) {
    }
    
    @IBAction func clickB(_ sender: Any) {
    
    }
    
    @IBAction func clickC(_ sender: Any) {
    }
    
    @IBAction func clickD(_ sender: Any) {
    }
    
    private func clickSender(_ sender: Any) {
        let btn = sender as! UIButton
        btn.isSelected = true
        
    }
}
