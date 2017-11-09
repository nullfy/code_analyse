//
//  DataConstants.swift
//  kaoshi
//
//  Created by 李晓东 on 2017/11/1.
//  Copyright © 2017年 晓东. All rights reserved.
//

import Foundation

let Data_Cache = UserDefaults.init()

let Data_UserPhone      = "Data_UserPhone"
let Data_UserID         = "Data_UserID"
let Data_UserName       = "Data_UserName"
let Data_PaperID        = "Data_PaperID"
let Data_PaperTime      = "Data_PaperTime"
let Data_TimeTmp        = "Data_TimeTmp"
let Data_PaperCreate    = "Data_PaperCreat"
let Data_TestAgain      = "Data_TestAgain"
let Data_ExamScore      = "Data_ExamScore"
let Data_SelectItem      = "Data_SelectItem"
let Data_FinishNormal     = "Data_FinishNormal"

class DataContainer {
    static let manager: DataContainer = {
        let instance = DataContainer()
        return instance
    }()
    
    @objc func startExam() {
        var time = Int(DataContainer.manager.data_timeTmp)!
        if time <= 0 {
            timer?.invalidate()
            timer = nil
            return
        }
        time -= 1
        DataContainer.manager.data_timeTmp = String.init(format: "%d", time)
        //print("time----",time)
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(startExam), userInfo: nil, repeats: true)
            RunLoop.current.add(timer!, forMode: .commonModes)
        }
    }
    
    var timer: Timer?
    var data_testAgain: String? {
        set(newValue) {
            Data_Cache.set(newValue, forKey: Data_TestAgain)
            Data_Cache.synchronize()
        }
        get {
            return Data_Cache.value(forKey: Data_TestAgain) as? String
        }
    }
    
    var data_examScore: String? {
        set(newValue) {
            Data_Cache.set(newValue, forKey: Data_ExamScore)
            Data_Cache.synchronize()
        }
        get {
            return Data_Cache.value(forKey: Data_ExamScore) as? String
        }
    }
    
    var data_phone: String {
        set(newValue) {
            Data_Cache.set(newValue, forKey: Data_UserPhone)
            Data_Cache.synchronize()
        }
        get {
            if Data_Cache.value(forKey: Data_UserPhone) == nil {
                return ""
            } else {
                return Data_Cache.value(forKey: Data_UserPhone) as! String
            }
        }
    }

    var data_userID: String {
        set(newValue) {
            Data_Cache.set(newValue, forKey: Data_UserID)
            Data_Cache.synchronize()
        }
        get {
            if Data_Cache.value(forKey: Data_UserID) == nil {
                return ""
            } else {
                return Data_Cache.value(forKey: Data_UserID) as! String
            }
        }
    }

    var data_selectItem: String {
        set(newValue) {
            Data_Cache.set(newValue, forKey: Data_SelectItem)
            Data_Cache.synchronize()
        }
        get {
            if Data_Cache.value(forKey: Data_SelectItem) == nil {
                return ""
            } else {
                return Data_Cache.value(forKey: Data_SelectItem) as! String
            }
        }
    }

    var data_name: String {
        set(newValue) {
            Data_Cache.set(newValue, forKey: Data_UserName)
            Data_Cache.synchronize()
        }
        get {
            if Data_Cache.value(forKey: Data_UserName) == nil {
                return ""
            } else {
                return Data_Cache.value(forKey: Data_UserName) as! String
            }
        }
    }
    
    var data_paperID: String {
        set(newValue) {
            Data_Cache.set(newValue, forKey: Data_PaperID)
            Data_Cache.synchronize()
        }
        get {
            if Data_Cache.value(forKey: Data_PaperID) == nil {
                return ""
            } else {
                return Data_Cache.value(forKey: Data_PaperID) as! String
            }
        }
    }

    var data_paperTime: String {
        set(newValue) {
            Data_Cache.set(newValue, forKey: Data_PaperTime)
            Data_Cache.synchronize()
        }
        get {
            if Data_Cache.value(forKey: Data_PaperTime) == nil {
                return ""
            } else {
                return Data_Cache.value(forKey: Data_PaperTime) as! String
            }
        }
    }
    
    var data_timeTmp: String {
        set(newValue) {
            Data_Cache.set(newValue, forKey: Data_TimeTmp)
            Data_Cache.synchronize()
        }
        get {
            if Data_Cache.value(forKey: Data_TimeTmp) == nil {
                return ""
            } else {
                return Data_Cache.value(forKey: Data_TimeTmp) as! String
            }
        }
    }
    
    var data_paperCreate: String {
        set(newValue) {
            Data_Cache.set(newValue, forKey: Data_PaperCreate)
            Data_Cache.synchronize()
        }
        get {
            if Data_Cache.value(forKey: Data_PaperCreate) == nil {
                return ""
            } else {
                return Data_Cache.value(forKey: Data_PaperCreate) as! String
            }
        }
    }
    
    var data_finishNormal: String {
        set(newValue) {
            Data_Cache.set(newValue, forKey: Data_FinishNormal)
            Data_Cache.synchronize()
        }
        get {
            if Data_Cache.value(forKey: Data_FinishNormal) == nil {
                return ""
            } else {
                return Data_Cache.value(forKey: Data_FinishNormal) as! String
            }
        }
    }
}
