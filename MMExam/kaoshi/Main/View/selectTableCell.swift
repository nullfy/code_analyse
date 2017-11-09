//
//  selectTableCell.swift
//  kaoshi
//
//  Created by 李晓东 on 2017/11/6.
//  Copyright © 2017年 晓东. All rights reserved.
//

import UIKit

enum QuestionType: Int {
    case selection = 1      //选择题
    case fill = 2           //填空题
    case short_answer = 3   //简答题
    case translation = 4    //翻译题
    case zhs_to_pinyin = 5  //拼音
    case pinyin_to_zhs = 6  //看拼音写词语
    case en_to_zhs = 7      //英译汉
    case personality = 8    //个性测试
    case judgement = 9      //判断题
    case character = 10      //字母题
    case none
}

@objc protocol SelectTableCellDelegate {
    
    @objc optional func questionCellConfirmClick(_ sender: Any)
    @objc optional func questionCellEditConfirmClick(_ sender: Any)
    @objc optional func questionCellAClick(_ sender: Any)
    @objc optional func questionCellBClick(_ sender: Any)
    @objc optional func questionCellCClick(_ sender: Any)
    @objc optional func questionCellDClick(_ sender: Any)
    @objc optional func questionCellEClick(_ sender: Any)
    @objc optional func questionCellTextViewDidChange(_ sender: Any)
}

class selectTableCell: UITableViewCell {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var confirmBtn: UIButton!
    
    @IBOutlet weak var itemA: UILabel!
    @IBOutlet weak var itemB: UILabel!
    @IBOutlet weak var itemC: UILabel!
    @IBOutlet weak var itemD: UILabel!
    @IBOutlet weak var itemE: UILabel!
    
    @IBOutlet weak var btnA: UIButton!
    @IBOutlet weak var btnB: UIButton!
    @IBOutlet weak var btnC: UIButton!
    @IBOutlet weak var btnD: UIButton!
    @IBOutlet weak var btnE: UIButton!
    
    @IBOutlet weak var editConfirmBtn: UIButton!
    @IBOutlet weak var editContainer: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textConfirmBtn: UIButton!
    
    @IBOutlet weak var containerWidth: NSLayoutConstraint!
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    @IBOutlet weak var confirmTopConstraint: NSLayoutConstraint!
    
    weak var delegate: SelectTableCellDelegate?
    var questionModel: QuestionModel?
    var isHeightCalculated: Bool = false
    var cacheBottom: CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var superv = self.superview
        while superv?.className() != NSStringFromClass(UITableView.self) {
            superv = superv?.superview
        }
        self.width = (superv?.height)!
        
        let cal = containerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        cacheBottom = cal.height
        
        let bottom = confirmBtn.bottom+40 > self.width ? confirmBtn.bottom+40 : self.width
        containerWidth.constant = self.height
        containerHeight.constant = bottom
        scrollView.contentSize = CGSize.init(width: self.height, height: bottom)
        //print("\nlayoutsubv-----\((questionModel?.qId)!)==========\(confirmBtn.bottom)=====\(bottom,cal)")
        //print("2-----subvi--\((questionModel?.qId)!)","bottom--\(confirmBtn.bottom)","size--",scrollView.contentSize)
    }
    
    func layout(_ model: QuestionModel) {
        questionModel = model
        let questionType: QuestionType = QuestionType(rawValue: model.qType)!
        var type = ""
        switch questionType {
        case .selection:
            type = "选择题"
            break
        case .fill:
            type = "填空题"
            break
        case .short_answer:
            type = "简答题"
            break
        case .translation:
            type = "翻译题"
            break
        case .zhs_to_pinyin:
            type = "拼音"
            break
        case .pinyin_to_zhs:
            type = "看拼音写词语"
            break
        case .en_to_zhs:
            type = "英译汉"
            break
        case .personality:
            type = "个性测试"
            break
        case .judgement:
            type = "判断题"
            break
        case .character:
            type = "26字母"
            break
        default: break
        }
        let answer = questionModel?.answer
        self.cancelSelectSender()
        if answer == "A" {
            self.clickSender(btnA.self)
        } else if answer == "B" {
            self.clickSender(btnB.self)
        } else if answer == "C" {
            self.clickSender(btnC.self)
        } else if answer == "D" {
            self.clickSender(btnD.self)
        } else if answer == "E" {
            self.clickSender(btnE.self)
        }
        
        textView.text = ""
        titleLabel.text = "\(model.index). \(type)(\(model.qPoint)分)"
        questionLabel.text = model.qTitle
        itemC.isHidden = false
        itemD.isHidden = false
        itemE.isHidden = false
        btnC.isHidden = false
        btnD.isHidden = false
        btnE.isHidden = false
        editContainer.isHidden = true
        let selects = model.qSelects
        confirmTopConstraint.constant = 20
        if selects.count == 5 {
            itemA.text = selects[0]["select"] as? String
            itemB.text = selects[1]["select"] as? String
            itemC.text = selects[2]["select"] as? String
            itemD.text = selects[3]["select"] as? String
            itemE.text = selects[4]["select"] as? String
        } else if selects.count == 4 {
            itemA.text = selects[0]["select"] as? String
            itemB.text = selects[1]["select"] as? String
            itemC.text = selects[2]["select"] as? String
            itemD.text = selects[3]["select"] as? String
            btnE.isHidden = true
            itemE.isHidden = true
            confirmTopConstraint.constant = 0
        } else if selects.count == 3 {
            itemA.text = selects[0]["select"] as? String
            itemB.text = selects[1]["select"] as? String
            itemC.text = selects[2]["select"] as? String
            
            itemD.isHidden = true
            itemE.isHidden = true
            btnD.isHidden = true
            btnE.isHidden = true
            confirmTopConstraint.constant = -20
        } else if selects.count == 0 {
            if model.qType == 9 {//判断题
                itemC.isHidden = true
                btnC.isHidden = true
                itemD.isHidden = true
                btnD.isHidden = true
                itemE.isHidden = true
                btnE.isHidden = true
                itemA.text = "是"
                itemB.text = "否"
                confirmTopConstraint.constant = -40
            } else if (model.qType <= 7 && model.qType >= 2) || model.qType == 11{
                itemC.isHidden = true
                btnC.isHidden = true
                itemD.isHidden = true
                btnD.isHidden = true
                itemE.isHidden = true
                btnE.isHidden = true
                textView.layer.borderColor = UIColor.black.cgColor
                textView.layer.borderWidth = 0.5
                editContainer.isHidden = false
                textView.text = questionModel?.answer
            }
            
        }
        if model.style == .ExamTypeInstruction {
            confirmBtn.isHidden = true
            editConfirmBtn.isHidden = true
        }
        //let size = containerView.systemLayoutSizeFitting(CGSize.init(width: self.width, height: 0))
        //        let size1 = questionLabel.systemLayoutSizeFitting(CGSize.init(width: self.width, height: 0))
        cacheBottom = size.height
        //print("layout--\(Int(model.qId)!)","size--\(size)",size)
    }

    @IBAction func clickConfirm(_ sender: Any) {
        guard self.delegate?.questionCellConfirmClick!(self) != nil else {
            return
        }
    }
    
    @IBAction func clickEditConfirm(_ sender: Any) {
        guard self.delegate?.questionCellEditConfirmClick!(self) != nil else {
            return
        }
    }
    
    @IBAction func clickA(_ sender: Any) {
        self.clickSender(sender)
        guard self.delegate?.questionCellAClick!(self) != nil else {
            return
        }
        questionModel?.answer = "A"
    }
    
    @IBAction func clickB(_ sender: Any) {
        self.clickSender(sender)
        guard self.delegate?.questionCellBClick!(self) != nil else {
            return
        }
        questionModel?.answer = "B"
    }
    
    @IBAction func clickC(_ sender: Any) {
        self.clickSender(sender)
        guard self.delegate?.questionCellCClick!(self) != nil else {
            return
        }
        questionModel?.answer = "C"
    }
    
    @IBAction func clickD(_ sender: Any) {
        self.clickSender(sender)
        guard self.delegate?.questionCellDClick!(self) != nil else {
            return
        }
        questionModel?.answer = "D"
    }
    
    @IBAction func clickE(_ sender: Any) {
        self.clickSender(sender)
        guard self.delegate?.questionCellEClick!(self) != nil else {
            return
        }
        questionModel?.answer = "E"
    }
    
    private func clickSender(_ sender: Any) {
        let n = self.questionModel?.qSelects.count
        for i in 0..<n! {
            let tmp: UIButton = self.viewWithTag(i+200) as! UIButton
            tmp.isSelected = false
        }

        let btn = sender as! UIButton
        btn.isSelected = true
        print("select---",btn.tag)
    }
    
    private func cancelSelectSender() {
        //let n = self.questionModel?.qSelects.count
        for i in 0...3 {
            let tmp: UIButton = self.viewWithTag(i+200) as! UIButton
            tmp.isSelected = false
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if editContainer.isHidden == false {
            editContainer.endEditing(true)
        }
        return super.hitTest(point, with: event)
    }
}

extension selectTableCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard self.delegate?.questionCellTextViewDidChange!(self) != nil else {
            return
        }
    }
}
