//
//  finishView.swift
//  kaoshi
//
//  Created by 李晓东 on 2017/11/6.
//  Copyright © 2017年 晓东. All rights reserved.
//

import UIKit

//let FinishCellID = "FinishCellID"
let TitleCellID = "TitleCellID"
class finishView: UIView {

    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var delegate: FinishViewDelegate?
    
    var datasDic: [String : [QuestionModel]] = [String : [QuestionModel]]()
    var titleArray: [String] = [String]()
    var detailArray: [[QuestionModel]] = [[QuestionModel]]()
    var dumpArray: [QuestionModel] = {
        var datas = [QuestionModel]()
        return datas
    }(){
        didSet {
            var dic: [String : Int] = [String : Int]()
            for model in dumpArray {
                if dic[model.qTypeName] == nil {
                    dic[model.qTypeName] = 1
                    datasDic[model.qTypeName] = [QuestionModel]()
                    datasDic[model.qTypeName]?.append(model)
                } else {
                    var count = dic[model.qTypeName]!
                    count += 1
                    dic[model.qTypeName] = count
                    datasDic[model.qTypeName]?.append(model)
                }
            }
            for key in datasDic.keys {
                let datas = datasDic[key]?.sorted(by: {Int($0.index)! < Int($1.index)!} )
                titleArray.append(key)
                detailArray.append(datas!)
            }
            titleArray.reverse()
            detailArray.reverse()
            
            var count = 0
            let length = dumpArray.count > 10 ? 2 : 1
            for model in dumpArray {
                if model.answer != "" {
                    count += 1
                }
            }
            let subLength = count > 10 ? 2 : 1
            let title = NSMutableAttributedString.init(string: String.init(format: "共%d题,已答%d题", dumpArray.count, count))
            title.font = UIFont.systemFont(ofSize: 15)
            title.color = UIColor.black
            title.setColor(UIColor.red, range: NSRange.init(location: 1, length: length))
            title.setColor(UIColor.red, range: NSRange.init(location: title.length-1-subLength, length: subLength))
            titleLabel.attributedText = title
            titleLabel.textAlignment = .center
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.register(UINib.init(nibName: "BottomCell", bundle: nil), forCellWithReuseIdentifier: BottomCellID)
        collectionView.register(UINib.init(nibName: "CollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: TitleCellID)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var barHeight: CGFloat = 32
        if UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.portrait ||
            UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.portraitUpsideDown {
            barHeight = self.height == 812 ? 88 : 64
        }
        self.titleLabel.width = self.width
        self.titleTopConstraint.constant = barHeight
        self.collectionView.width = self.width
        //print(self.frame, titleLabel.frame, collectionView.frame)
    }
}

extension finishView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return titleArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return detailArray[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BottomCellID, for: indexPath) as! BottomCell
        let models = detailArray[indexPath.section]
        let model = models[indexPath.row]
        cell.label.text = model.index
        cell.label.layer.cornerRadius = 15
        cell.label.layer.borderWidth = 0.5
        cell.label.layer.masksToBounds = true
        if model.answer != "" {
            cell.label.backgroundColor = UIColor.green
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var cell: CollectionReusableView = CollectionReusableView()
        if kind == UICollectionElementKindSectionHeader {
            cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TitleCellID, for: indexPath) as! CollectionReusableView
            cell.titleLabel.text = titleArray[indexPath.section]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard self.delegate?.finishViewDidSelecteItem(collectionView, didSelectItemAt: indexPath) != nil else {
            return
        }
    }
}

@objc protocol FinishViewDelegate {
    @objc func finishViewDidSelecteItem(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
}
