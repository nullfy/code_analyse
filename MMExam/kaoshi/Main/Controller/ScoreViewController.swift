//
//  ScoreViewController.swift
//  kaoshi
//
//  Created by 李晓东 on 2017/11/9.
//  Copyright © 2017年 晓东. All rights reserved.
//

import UIKit

class ScoreViewController: UIViewController {

    var score: String = "0"
    var continueTitle: String = "继续性格测试"
    var scoreView: resultView?
    var type: ExamType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "提交成功"
        self.fd_interactivePopDisabled = true
        let score = Bundle.main.loadNibNamed("resultView", owner: nil, options: nil)?.last as! resultView
        score.delegate = self
        score.resultLabel.text = self.score
        scoreView = score
        if self.type == ExamType.ExamTypeInstruction &&  DataContainer.manager.data_finishNormal == "" {
            continueTitle = "继续答题"
        }
        
        if self.type == ExamType.ExamTypeInstruction && DataContainer.manager.data_finishNormal != "" {
            continueTitle = "重新测试"
        }
        
        score.continueBtn.setTitle(continueTitle, for: .normal)
        self.view.addSubview(score)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scoreView?.frame = self.view.frame
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ScoreViewController:ResultViewDelegate {
    func resultViewDidClickContinue(_ sender: Any) {
        if self.type == ExamType.ExamTypeNormal {
            DataContainer.manager.data_testAgain = nil
            DataContainer.manager.data_finishNormal = Data_FinishNormal
        } else {
            DataContainer.manager.data_finishNormal = ""
            DataContainer.manager.data_testAgain = Data_TestAgain
        }

        guard let vc = self.navigationController?.viewControllers[1] else {
            return
        }
        self.navigationController?.popToViewController(vc, animated: true)
    }
}
