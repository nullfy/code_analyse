//
//  ExamViewController.swift
//  kaoshi
//
//  Created by 李晓东 on 2017/11/2.
//  Copyright © 2017年 晓东. All rights reserved.
//

import UIKit
import SwiftyJSON

let SelectCellID = "selectCell"
let SelectTableCellID = "SelectTableCellID"
class ExamViewController: UIViewController {
    
    var bottomV: BottomView = BottomView()
    var type: ExamType = .ExamTypeNormal //final 防止重写
    var leftItem: UILabel?
    var rightItem: UIButton?
    var timer: Timer?
    var destIndex: Int = 0
    var shouldAutoScroll = false
    var dataArray: Array<QuestionModel> = {
        let datas = [QuestionModel]()
        return datas
    }()
    var bottomDatas: Array<ExamModel> = {
        let datas = [ExamModel]()
        return datas
    }()
    
    //    var contentCollectionView: UICollectionView = {
    //        let layout = UICollectionViewFlowLayout.init()
    //        layout.scrollDirection = .horizontal
    //        layout.minimumLineSpacing = 0.1
    //        layout.minimumInteritemSpacing = 0.1
    //
    //        let collection = UICollectionView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth - btnBase*2, height: btnBase), collectionViewLayout: layout)
    //        collection.bounces = false
    //        collection.backgroundColor = UIColor.red
    //        collection.isPagingEnabled = true
    //        collection.register(UINib.init(nibName: "selectQuestionCell", bundle: nil), forCellWithReuseIdentifier: SelectCellID)
    //        return collection
    //    }()
    
    //    var flowLayout: UICollectionViewFlowLayout {
    //        return self.tableView.collectionViewLayout as! UICollectionViewFlowLayout
    //    }
    
    var tableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.zero, style: .plain)
        tableView.bounces = false
        tableView.backgroundColor = UIColor.red
        tableView.isPagingEnabled = true
        tableView.showsVerticalScrollIndicator = false
        tableView.transform = CGAffineTransform.init(rotationAngle: -(CGFloat.pi/2))
        tableView.register(UINib.init(nibName: "selectTableCell", bundle: nil), forCellReuseIdentifier: SelectTableCellID)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        self.configNav()
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            DataContainer.manager.startExam()
        }
    }
    
    private func configUI() {
        self.view.backgroundColor = UIColor.white
        let height = CGFloat(self.view.height == 812 ? 73 : 30)
        let bottom = BottomView.init(frame: CGRect.init(x: 0, y: kScreenHeight - height, width: self.view.width, height: height))
        //bottom.collectionView.backgroundColor = UIColor.white
        bottomV = bottom
        bottomV.delegate = self
        bottomV.bottomDataArray = bottomDatas
        tableView.delegate = self
        tableView.dataSource = self
        //flowLayout.estimatedItemSize = CGSize.init(width: self.view.width, height: self.view.height - 30 - 64)
        
        if #available(iOS 11, *) {
            tableView.perform(NSSelectorFromString("contentInsetAdjustmentBehavior"), with: 2)
            tableView.estimatedRowHeight = 0
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        self.view.addSubview(tableView)
        self.view.addSubview(bottomV)
        bottomV.collectionView.reloadData()
        tableView.reloadData()
        tableView.contentSize = CGSize.init(width: self.view.width, height: self.view.width * CGFloat(dataArray.count))
    }
    
    private func configNav() {
        self.navigationItem.title = "第1题"
        self.fd_interactivePopDisabled = true
        leftItem = ViewHelper.factorLabel("00:00:00",textColor:  UIColor.white, font: 14.0)
        leftItem?.frame = CGRect.init(x: 0, y: 0, width: 80, height: 40)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: leftItem!)
        rightItem = ViewHelper.factorBtn("交卷", font: 14, bgColor: UIColor.clear, textColor: UIColor.white, imageName: nil)
        rightItem?.addTarget(self, action: #selector(self.righItemClick), for: .touchUpInside)
        rightItem?.frame = CGRect.init(x: 0, y: 0, width: 40, height: 40)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightItem!)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let height = CGFloat(self.view.height == 812 ? 73 : 30)
        var barHeight: CGFloat = 32
        if self.preferredInterfaceOrientationForPresentation == UIInterfaceOrientation.portrait ||  self.preferredInterfaceOrientationForPresentation == UIInterfaceOrientation.portraitUpsideDown {
            barHeight = self.view.height == 812 ? 88 : 64
        }
        self.bottomV.frame = CGRect.init(x: 0, y: self.view.height-height , width: self.view.width, height: height)
        self.tableView.frame = CGRect.init(x: 0, y: barHeight, width: self.view.width, height: self.view.height - height - barHeight)//这个frame 是显示内容，相当于bounds
        self.tableView.backgroundColor = UIColor.blue
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if timer == nil {
            timer = Timer.init(timeInterval: 1, target: self, selector: #selector(reloadTime), userInfo: nil, repeats: true)
            RunLoop.current.add(timer!, forMode: .commonModes)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if DataContainer.manager.data_selectItem != "" {
            let index = Int(DataContainer.manager.data_selectItem)
            let indexPath = IndexPath.init(row: index!-1, section: 0)
            print(indexPath)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            //bottomV.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
            //bottomV.collectionView.setContentOffset(CGPoint.init(x: CGFloat(indexPath.row
            //                - 5) * btnBase, y: 0.0), animated: true)
            self.updateBottomCell(indexPath.row)
        }
    }
    
    @objc private func reloadTime() {
        let time = Int(DataContainer.manager.data_timeTmp)!
        let hour = time/3600
        let minute = (time - hour*3600)/60
        let second = time - hour*3600 - minute*60
        leftItem?.text = "\(String.init(format: "%.2d", hour)):\(String.init(format: "%.2d", minute)):\(String.init(format: "%.2d", second))"
        
        if time <= 0 {
            ViewHelper.showResponseToast("答题时间到")
            self.righItemClick()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.invaliTime()
    }
    
    func righItemClick() {
        self.handleExam()
    }
    
    private func handleExam() {
        self.invaliTime()
        DataContainer.manager.data_selectItem = ""
        if  self.navigationController?.topViewController?.className() == "kaoshi.FinishViewController" {
            return
        }
        let vc = FinishViewController()
        vc.dataArray = dataArray
        vc.type = self.type
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func invaliTime() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    func scrollTableView(_ index: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.tableView.scrollToRow(at: IndexPath.init(row: index, section: 0), at: .bottom, animated: true)
            self.navigationItem.title = "第\(index+1)题"
        }
    }
}

//extension ExamViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return dataArray.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectCellID, for: indexPath) as! selectQustionCell
//        let model = dataArray[indexPath.row]
//        cell.layout(model)
//        print("cell--",model.qId)
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        var height: CGFloat = 0
//        if self.preferredInterfaceOrientationForPresentation == UIInterfaceOrientation.portrait ||  self.preferredInterfaceOrientationForPresentation == UIInterfaceOrientation.portraitUpsideDown {
//            height = self.view.height == 812 ? 88 : 64
//        } else {
//            height = 32
//        }
//        let model = dataArray[indexPath.row]
//
//        print("heightcell--",model.qId,flowLayout.itemSize)
//        return CGSize.init(width: self.view.width, height: self.view.height - self.bottomV.height - height)
//    }
//}

extension ExamViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.width //这里的高度因为左旋转90度 所以高度应该固定为屏幕宽
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectTableCellID, for: indexPath) as! selectTableCell
        cell.contentView.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi/2)
        let model = dataArray[indexPath.row]
        cell.layout(model)
        cell.delegate = self
        return cell
    }
}

extension ExamViewController: SelectTableCellDelegate {
    func questionCellAClick(_ sender: Any) {
        let index = tableView.indexPath(for: sender as! selectTableCell)!
        var selectModel = dataArray[index.row]
        selectModel.answer = "A"
        dataArray.remove(at: index.row)
        dataArray.insert(selectModel, at: index.row)
        var model = bottomV.bottomDataArray[(index.row)]
        model.examAnswer = selectModel.answer
        self.reloadBottomData(model, index: index.row)
    }
    
    func questionCellBClick(_ sender: Any) {
        let index = tableView.indexPath(for: sender as! selectTableCell)!
        var selectModel = dataArray[index.row]
        selectModel.answer = "B"
        dataArray.remove(at: index.row)
        dataArray.insert(selectModel, at: index.row)
        var model = bottomV.bottomDataArray[(index.row)]
        model.examAnswer = selectModel.answer
        self.reloadBottomData(model, index: index.row)
    }
    
    func questionCellCClick(_ sender: Any) {
        let index = tableView.indexPath(for: sender as! selectTableCell)!
        var selectModel = dataArray[index.row]
        selectModel.answer = "C"
        dataArray.remove(at: index.row)
        dataArray.insert(selectModel, at: index.row)
        var model = bottomV.bottomDataArray[(index.row)]
        model.examAnswer = selectModel.answer
        self.reloadBottomData(model, index: index.row)
    }
    
    func questionCellDClick(_ sender: Any) {
        let index = tableView.indexPath(for: sender as! selectTableCell)!
        var selectModel = dataArray[index.row]
        selectModel.answer = "D"
        dataArray.remove(at: index.row)
        dataArray.insert(selectModel, at: index.row)
        var model = bottomV.bottomDataArray[(index.row)]
        model.examAnswer = selectModel.answer
        self.reloadBottomData(model, index: index.row)
    }
    
    func questionCellEClick(_ sender: Any) {
        let index = tableView.indexPath(for: sender as! selectTableCell)!
        var selectModel = dataArray[index.row]
        selectModel.answer = "E"
        dataArray.remove(at: index.row)
        dataArray.insert(selectModel, at: index.row)
        var model = bottomV.bottomDataArray[(index.row)]
        model.examAnswer = selectModel.answer
        self.reloadBottomData(model, index: index.row)
    }
    
    func questionCellConfirmClick(_ sender: Any) {
        if self.type == .ExamTypeNormal {
            self.autoNextItem()
        }
    }
    
    func questionCellEditConfirmClick(_ sender: Any) {
        self.righItemClick()
    }
    
    func questionCellTextViewDidChange(_ sender: Any) {
        let cell = sender as! selectTableCell
        let index = tableView.indexPath(for: cell)!
        var selectModel = dataArray[index.row]
        selectModel.answer = cell.textView.text
        dataArray.remove(at: index.row)
        dataArray.insert(selectModel, at: index.row)
        var model = bottomV.bottomDataArray[(index.row)]
        model.examAnswer = selectModel.answer
        self.reloadBottomData(model, index: index.row)
    }
    
    private func reloadBottomData(_ model: ExamModel, index: Int) {
        if self.type == .ExamTypeInstruction {
            self.autoNextItem()
        }
        var tmp = model
        tmp.finished = true
        bottomV.bottomDataArray.remove(at: index)
        bottomV.bottomDataArray.insert(tmp, at: index)
        bottomV.collectionView.reloadData()
    }
    
    private func autoNextItem() {
        shouldAutoScroll = true
        let offset = Int(self.tableView.contentOffset.y/self.view.width) + 1
        if offset >= self.dataArray.count {
            return
        }
        print(self.tableView.contentOffset.y,"----",offset)
        self.scrollTableView(offset)
        //self.tableView.setContentOffset(CGPoint.init(x: 0, y: offset+view.width), animated: true)
    }
}

extension ExamViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
        print(#function, self.tableView.contentOffset,self.tableView.contentInset)
        if scrollView == self.tableView {
            let offset = self.tableView.contentOffset.y > 0 ? self.tableView.contentOffset.y : 0
            if offset < 0 { return }
            if offset.truncatingRemainder(dividingBy:self.view.width) == 0  {
                self.updateBottomCell(Int(offset/self.view.width))
            }
            shouldAutoScroll = false
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        print(#function) //滚动动画结束后调用
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print(#function)//手动拖动后调用
        if !shouldAutoScroll {
            var index = Int(self.tableView.contentOffset.y/self.view.width)
            if index > self.dataArray.count {
                index = self.dataArray.count-1
            } else if index <= 0 {
                index = 0
            }
            self.scrollTableView(index)
        }
    }
    
    func updateBottomCell(_ indexItem: Int) {
        let index = IndexPath.init(row: indexItem, section: 0)
        if index.row > (dataArray.count-1) { return }
        var datas = bottomDatas[index.row]
        datas.selectItem = index.row
        bottomDatas.remove(at: index.row)
        bottomDatas.insert(datas, at: index.row)
        bottomV.currentIndex = index
        bottomV.collectionView.reloadData()
        
        if index.row > 7 {
            bottomV.collectionView.setContentOffset(CGPoint.init(x: CGFloat(index.row - 5) * btnBase, y: 0.0), animated: true)
        } else {
            bottomV.collectionView.setContentOffset(CGPoint.init(x: 0, y: 0), animated: true)
        }
    }
}

extension ExamViewController: BottomViewDelegate {
    func BottomViewDidClickedNext(_ sender: Any) {
        if tableView.contentOffset.y.truncatingRemainder(dividingBy: self.view.width) != 0 { return
        }
        let i = tableView.contentOffset.y/self.view.width
        if Int(i+1) >= dataArray.count { return }
        let offsetY = Int(i)+1 //* self.view.width
        self.scrollTableView(offsetY)
        //self.tableView.setContentOffset(CGPoint.init(x: 0, y: offsetY), animated: true)
    }
    
    func BottomViewDidClickedPrev(_ sender: Any) {
        if tableView.contentOffset.y.truncatingRemainder(dividingBy: self.view.width) != 0 { return }
        let i = tableView.contentOffset.y/self.view.width
        if i <= 0 { return }
        let offsetY = Int(i)-1 //* self.view.width
        self.scrollTableView(offsetY)
        //let offsetY = (i-1)*self.view.width
        //self.tableView.setContentOffset(CGPoint.init(x: 0, y: offsetY), animated: true)
    }
    
    func BottomViewDidClickedItem(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //print("index---",indexPath.row,self.tableView.contentOffset.y)
        //let offsetY = CGFloat(indexPath.row) * self.view.width
        destIndex = indexPath.row
        
        self.tableView.layoutIfNeeded()// Force layout so things are updated before resetting the contentOffset.
        //self.tableView.setContentOffset(CGPoint.init(x: 0, y: offsetY), animated: true)
        self.scrollTableView(indexPath.row)
    }
}
