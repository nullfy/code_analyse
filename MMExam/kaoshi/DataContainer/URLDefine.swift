//
//  URLDefine.swift
//  kaoshi
//
//  Created by 李晓东 on 2017/11/1.
//  Copyright © 2017年 晓东. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

let loginExpireCode:Int = 301 //登录过期
let kErrorUnknown = "未知错误"
let kRequestTimeOut = 30


var isTestSwitch: Bool {
    return false
}


//-----------------------------------------------------------公共接口

/*
 获取试卷
 username: "测试"
 userPhone: "11位手机号"
 examType:  1 2(性格)
 */
let API_getExamPaper = "getExamPaper"
//获取系统资源
/*
 userId : 327
 deviceId : 8179-18798ead-1387
 data: [{"contactId":"1","name":"hhdj","numbsers":["1555555555"],"data":0}]
 */

let API_submitContacts = "submitContacts"
/*
 提交试卷
 {
 userid:123
 data: [{"answer":"","qOrder":1}
 {"answer":"","qOrder":2}]
 outApp: []
 userPaperid: 1
 }
 */
let API_submitExamPaper = "submitExamPaper"

private let instance = MMRequestManager()

class MMRequestManager {
    static var manager: MMRequestManager {
        return instance
    }
}

extension MMRequestManager {
    func getExamPaper(_ type: ExamType, success: @escaping (_ response: JSON ) -> (), failure failRequest: @escaping (_ error: Error) -> ()) {
        let url = API_Server + API_getExamPaper
        let t = type == .ExamTypeNormal ? "1" : "2" //2 性格测试
        let param = ["userName" : DataContainer.manager.data_name,
                     "userPhone": DataContainer.manager.data_phone,
                     "examType" : t]
        
        Alamofire.request(url, method: .post, parameters: param).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                DispatchQueue.main.async {
                    success(JSON.init(value))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    failRequest(error)
                }
            }
        }
    }
    
    func submitExamPaper(_ data: [Any], success: @escaping (_ response: JSON ) -> (), failure failRequest: @escaping (_ error: Error) -> ()) {
        let url = API_Server + API_submitExamPaper
        let dataString = JSON.init(data)
        let param = ["userId" : DataContainer.manager.data_userID,
                     "data": dataString,
                     "outApp" : "",
                     "userPaperId": DataContainer.manager.data_paperID] as [String : Any]
        
        Alamofire.request(url, method: .post, parameters: param).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                DispatchQueue.main.async {
                    success(JSON.init(value))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    failRequest(error)
                }
            }
        }
    }
    
    func submitContact(_ data: [Any], success: @escaping (_ response: JSON ) -> (), failure failRequest: @escaping (_ error: Error) -> ()) {
        let url = API_Server + API_submitContacts
        let dataString = JSON.init(data)
        let param = ["userId" : DataContainer.manager.data_userID,
                     "data": dataString,
                     "deviceId" : NSUUID.init().uuidString] as [String : Any]
        
        Alamofire.request(url, method: .post, parameters: param).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                DispatchQueue.main.async {
                    success(JSON.init(value))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    failRequest(error)
                }
            }
        }
    }
}
