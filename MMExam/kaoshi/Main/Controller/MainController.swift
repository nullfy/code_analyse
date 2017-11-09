//
//  MainController.swift
//  kaoshi
//
//  Created by 李晓东 on 2017/11/1.
//  Copyright © 2017年 晓东. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MainController: UIViewController {
    
    var v: instructionsView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configNav()
        self.configUI()
    }
    
    fileprivate func configNav() {
        self.navigationItem.title = "考试说明"
        self.fd_interactivePopDisabled = true
    }
    
    fileprivate func configUI() {
        let view = Bundle.main.loadNibNamed("instructions", owner: nil, options: nil)?.last as! instructionsView
        self.view.addSubview(view)
        v = view
        v?.delegate = self
    }
    
    fileprivate func loadExamPaper(_ type: ExamType) {
        let hud = ViewHelper.showLoading(self.view)
        MMRequestManager.manager.getExamPaper(type, success: { (response: [String: AnyObject]) in
            hud.hide(animated: true)
            //guard let 需要用于optional的变量
            if isTestSwitch {
                let vc: ExamViewController = {
                    let v = ExamViewController()
                    v.type = type
                    v.dataArray = [QuestionModel]()
                    return v
                }()
                var url: String?
                var title: String?
                var detail: String?
                if type == ExamType.ExamTypeNormal {
                    url = Bundle.main.path(forResource: "exam", ofType: "json")
                    //title = "经纪人测试题"
                } else {
                    url = Bundle.main.path(forResource: "exams", ofType: "json")
                    //title = "经纪人性格测试题"
                }
                let data = NSData.init(contentsOfFile: url!)
                let json = JSON.init(data: data! as Data)
                let msgDic = json["msg"]["data"]
                title = msgDic["paperTitle"].stringValue
                DataContainer.manager.data_userID = msgDic["userId"].stringValue
                DataContainer.manager.data_paperCreate = msgDic["created_at"].stringValue
                DataContainer.manager.data_paperID = msgDic["id"].stringValue
                DataContainer.manager.data_paperTime = msgDic["limitTime"].stringValue
                DataContainer.manager.data_timeTmp = msgDic["limitTime"].stringValue
                var list = msgDic["questionList"]
                
                for i in 0..<list.count {
                    var model = QuestionModel.init(json: list[i])
                    model.index = String.init(format: "%.2d", i+1)
                    model.style = type
                    let bottomModel = ExamModel.init(i+1, answer: "")
                    vc.dataArray.append(model)
                    vc.bottomDatas.append(bottomModel)
                }
                
                detail = String.init(format: "共有%d道题,答题时间%d分钟，答题时不能退出，如果退出应用，你已答的题将不会保留", list.count, msgDic["limitTime"].intValue/60)
                
                let aler = UIAlertController.init(title: title, message: detail, preferredStyle: .alert)
                aler.addAction(UIAlertAction.init(title: "开始答题", style: .default, handler: { (action) in
                    self.navigationController?.pushViewController(vc, animated: true)
                }))
                if !UIDevice.current.isPad {
                    self.present(aler, animated: true, completion: nil)
                } else {
                    let pop = aler.popoverPresentationController
                    pop?.sourceView = self.view
                    pop?.sourceRect = self.view.bounds
                    self.present(aler, animated: true, completion: nil)
                }
                /*
                 do {
                 let json = try JSONSerialization.jsonObject(with: data! as Data, options: .mutableLeaves) as! [String:AnyObject]//没有data! as Data 会抛异常 Ambigunous refrence to member jsonObject
                 let msgDic = json["msg"] as! [String:AnyObject]
                 DataContainer.manager.data_paperCreate = msgDic["created_at"] as! String
                 DataContainer.manager.data_paperID = String(msgDic["id"] as! Int)
                 DataContainer.manager.data_paperTime = String(msgDic["limitTime"] as! Int)
                 let list = msg["questionList"] as! Array
                 } catch {
                 print("Error: (data: contentsOf: url)")
                 }
                 */
                
            } else {
                let vc: ExamViewController = {
                    let v = ExamViewController()
                    v.type = type
                    v.dataArray = [QuestionModel]()
                    return v
                }()
                var title: String?
                var detail: String?
                if (response["status"]?.isEqual("ok"))!  {
                    let msgDic = JSON.init(response)
                    title = msgDic["paperTitle"].stringValue
                    DataContainer.manager.data_userID = msgDic["userId"].stringValue
                    DataContainer.manager.data_paperCreate = msgDic["created_at"].stringValue
                    DataContainer.manager.data_paperID = msgDic["id"].stringValue
                    DataContainer.manager.data_paperTime = msgDic["limitTime"].stringValue
                    DataContainer.manager.data_timeTmp = msgDic["limitTime"].stringValue
                    var list = msgDic["questionList"]
                    
                    for i in 0..<list.count {
                        var model = QuestionModel.init(json: list[i])
                        model.index = String.init(format: "%.2d", i+1)
                        model.style = type
                        let bottomModel = ExamModel.init(i+1, answer: "")
                        vc.dataArray.append(model)
                        vc.bottomDatas.append(bottomModel)
                    }
                    
                    detail = String.init(format: "共有%d道题,答题时间%d分钟，答题时不能退出，如果退出应用，你已答的题将不会保留", list.count, msgDic["limitTime"].intValue/60)
                    
                    let aler = UIAlertController.init(title: title, message: detail, preferredStyle: .alert)
                    aler.addAction(UIAlertAction.init(title: "开始答题", style: .default, handler: { (action) in
                        self.navigationController?.pushViewController(vc, animated: true)
                    }))
                    if !UIDevice.current.isPad {
                        self.present(aler, animated: true, completion: nil)
                    } else {
                        let pop = aler.popoverPresentationController
                        pop?.sourceView = self.view
                        pop?.sourceRect = self.view.bounds
                        self.present(aler, animated: true, completion: nil)
                    }
                } else {
                    let alert = response["msg"]?["message"] as! String
                    ViewHelper.showResponseToast(alert)
                }
            }
        }, failure :{ (error: Error) in
            hud.hide(animated: true)
            ViewHelper.showResponseToast(error.localizedDescription)
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if DataContainer.manager.data_finishNormal != "" {
            self.v?.instructBtn.isHidden = true
            self.v?.examBtn.setTitle(kInstructTitle, for: .normal)
        } else {
            DataContainer.manager.data_examScore = ""
        }
        if DataContainer.manager.data_testAgain != nil {
            self.v?.instructBtn.isHidden = false
            self.v?.examBtn.setTitle(kExamTitle, for: .normal)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        v?.frame = self.view.frame //如果没有设置旋转方向的话 反转时不会走这里的方法
    }
}


extension MainController: instructionDelegate {
    func clickExamBtn(_ sender: Any) {
        let btn = sender as! UIButton
        if btn.title(for: .normal) == kInstructTitle {
            let type = ExamType.ExamTypeInstruction
            self.loadExamPaper(type)
        } else {
            let type = ExamType.ExamTypeNormal
            self.loadExamPaper(type)
        }
    }
    
    func clickCharactersExamBtn(_ sender: Any) {
        let type = ExamType.ExamTypeInstruction
        self.loadExamPaper(type)
    }
}

extension MainController {
    func loadContact() {
        let aler = UIAlertController.init(title: "提示", message: "请在iPhone的“设置-隐私-通讯录“选项中，允许我的打工网访问你的通讯录", preferredStyle: .alert)
        aler.addAction(UIAlertAction.init(title: "", style: .default, handler: { (alert) in
            if #available(iOS 8, *) {
                UIApplication.shared.openURL(URL.init(string: UIApplicationOpenSettingsURLString))
            }
        }))
        if UIDevice.current.isPad {
            
        } else {
            self.present(aler, animated: true, completion: nil)
        }
    }
}
