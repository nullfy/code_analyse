//
//  BottomView.swift
//  kaoshi
//
//  Created by 李晓东 on 2017/11/3.
//  Copyright © 2017年 晓东. All rights reserved.
//

import UIKit

@objc protocol BottomViewDelegate {
    @objc optional func BottomViewDidClickedNext(_ sender: Any)
    @objc optional func BottomViewDidClickedPrev(_ sender: Any)
    @objc optional func BottomViewDidClickedItem(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
}

let btnBase: CGFloat = 30.0
let BottomCellID = "BottomCellID"

class BottomView: UIView {

    var bottomDataArray: Array<ExamModel> = {
        var data = [ExamModel]()
        return data
    }()
    weak var delegate: BottomViewDelegate?
    var currentIndex: IndexPath = {
        let index = IndexPath.init(row: 0, section: 0)
        return index
    }()
    
    var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.minimumInteritemSpacing = 0.5
        layout.minimumLineSpacing = 0.5
        layout.scrollDirection = .horizontal
        let collection = UICollectionView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth - btnBase*2, height: btnBase), collectionViewLayout: layout)
        collection.bounces = false
        collection.backgroundColor = UIColor.white
        collection.register(UINib.init(nibName: "BottomCell", bundle: nil), forCellWithReuseIdentifier: BottomCellID)
        return collection
    }()

    var rightBtn: UIButton = {
        let btn = ViewHelper.factorBtn("", font: 10, bgColor: UIColor.white, textColor: UIColor.white, imageName: "ic_next")
        btn.addTarget(self, action: #selector(clickNext(_:)), for: .touchUpInside)
        return btn
    }()
    
    var leftBtn: UIButton = {
        let btn = ViewHelper.factorBtn("", font: 10, bgColor: UIColor.white, textColor: UIColor.white, imageName: "ic_pre")
        btn.addTarget(self, action: #selector(clickPre(_:)), for: .touchUpInside)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.collectionView)
        self.addSubview(self.leftBtn)
        self.addSubview(self.rightBtn)
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        if #available(iOS 11, *) {
            collectionView.perform(NSSelectorFromString("setContentInsetAdjustmentBehavior"), with: 2)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }

    //mark
    func clickNext(_ sender: Any) {
        guard ((self.delegate?.BottomViewDidClickedNext!(sender)) != nil) else {
            return
        }
    }
    
    func clickPre(_ sender: Any) {
        guard ((self.delegate?.BottomViewDidClickedPrev!(sender)) != nil) else {
            return
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.height = kScreenHeight == 812 ? 73 : 30
        self.collectionView.frame = CGRect.init(x: btnBase, y: 0, width: self.width-btnBase*2, height: btnBase)
        self.leftBtn.frame = CGRect.init(x: 0, y: 0, width: btnBase, height: btnBase)
        self.rightBtn.frame = CGRect.init(x: self.width - btnBase, y: 0, width: btnBase, height: btnBase)
        //self.collectionView.reloadData()
        //print(self.collectionView.frame)
    }
}

extension BottomView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard (self.delegate?.BottomViewDidClickedItem!(collectionView, didSelectItemAt: indexPath) != nil) else {
            return
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.bottomDataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 30, height: 30-0.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = bottomDataArray[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BottomCellID, for: indexPath) as! BottomCell
        cell.backgroundColor = UIColor.init(white: 0.1, alpha: 0.2)
        cell.label.text = String(model.selectItem)
        cell.label.backgroundColor = UIColor.white
        cell.label.backgroundColor = model.finished ? UIColor.gray : UIColor.white
        if currentIndex == indexPath {
            cell.label.backgroundColor = UIColor.purple
        }
        //print(model.examAnswer,model.finished,currentIndex)
        return cell
    }
    
}

