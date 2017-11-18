//
//  FinishViewController.swift
//  kaoshi
//
//  Created by 李晓东 on 2017/11/6.
//  Copyright © 2017年 晓东. All rights reserved.
//

import UIKit

class FinishViewController: UIViewController {
    
    var leftItem: UIButton?
    var rightItem: UIButton?
    var dataArray: [QuestionModel]?
    var finishView: finishView?
    var type: ExamType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DataContainer.manager.data_selectItem = ""
        self.configNav()
        self.configUI()
    }
    
    func configUI() {
        let finish = Bundle.main.loadNibNamed("finishView", owner: nil, options: nil)?.last as! finishView
        finish.dumpArray = dataArray!
        finish.delegate = self
        finishView = finish
        if #available(iOS 11, *) {
            finish.collectionView.perform(NSSelectorFromString("contentInsetAdjustmentBehavior"), with: 2)
            //finish.collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        view.addSubview(finish)
    }
    
    private func configNav() {
        self.navigationItem.title = "答题卡"
        self.fd_interactivePopDisabled = true
        
        rightItem = ViewHelper.factorBtn("确定交卷", font: 13, bgColor: UIColor.clear, textColor: UIColor.white, imageName: nil)
        rightItem?.addTarget(self, action: #selector(self.rightItemClick), for: .touchUpInside)
        rightItem?.frame = CGRect.init(x: 0, y: 0, width: 65, height: 40)
        rightItem?.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 0)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightItem!)
        
        if Int(DataContainer.manager.data_timeTmp)! > 0 {
            leftItem = ViewHelper.factorBtn("", font: 14, bgColor: UIColor.clear, textColor: UIColor.white, imageName: "icon_back")
            leftItem?.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -20, bottom: 0, right: 0)
            leftItem?.addTarget(self, action: #selector(self.leftItemClick), for: .touchUpInside)
            leftItem?.frame = CGRect.init(x: 0, y: 0, width: 40, height: 40)
            self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: leftItem!)
        }
    }
    
    func leftItemClick() {
        if Int(DataContainer.manager.data_timeTmp)! > 3 {
            self.navigationController?.popViewController(animated: true)
        } else {
            ViewHelper.showResponseToast("答题时间已到")
        }
    }
    
    func rightItemClick() {
        var datas = [[String: Any]]()
        guard dataArray != nil else {
            return
        }
        for model in dataArray! {
            let dic = ["answer": model.answer,
                       "qOrder": model.qOrder] as [String : Any]
            datas.append(dic)
        }
        if isTestSwitch {
            let vc = ScoreViewController()
            vc.type = self.type
            if self.type == ExamType.ExamTypeNormal {
                vc.score = "智力分数 : 0"
                DataContainer.manager.data_examScore = vc.score
            } else {
                if DataContainer.manager.data_finishNormal != "" {
                    vc.score = "\(DataContainer.manager.data_examScore!)\n性格测试得分请咨询人事"
                } else {
                    vc.score = "性格测试得分请咨询人事"
                }
            }
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            MMRequestManager.manager.submitExamPaper(datas, success: { (response) in
                let msg = response["msg"].dictionaryValue
                ViewHelper.showResponseToast(msg["message"]?.stringValue)
                if response["status"].stringValue == "ok" {
                    let vc = ScoreViewController()
                    vc.type = self.type
                    if self.type == ExamType.ExamTypeNormal {
                        vc.score = String.init(format: "智力分数: %@", (msg["totalScore"]?.stringValue)!)
                        DataContainer.manager.data_examScore = vc.score
                    } else {
                        if DataContainer.manager.data_finishNormal != "" {
                            vc.score = "\(DataContainer.manager.data_examScore!)\n性格测试得分请咨询人事"
                        } else {
                            vc.score = "性格测试得分请咨询人事"
                        }
                    }
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }, failure: { (error) in
                ViewHelper.showResponseToast(error.localizedDescription)
            })
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        finishView?.frame = CGRect.init(x: 0, y: 0, width: self.view.width, height: self.view.height)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension FinishViewController: FinishViewDelegate {
    func finishViewDidSelecteItem(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = finishView?.detailArray[indexPath.section][indexPath.row]
        DataContainer.manager.data_selectItem = (model?.index)!
        self.leftItemClick()
    }
}
