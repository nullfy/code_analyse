//
//  BaseModel.swift
//  kaoshi
//
//  Created by 李晓东 on 2017/11/2.
//  Copyright © 2017年 晓东. All rights reserved.
//

import UIKit
import SwiftyJSON

struct BaseModel {
    let userId          :     String
    let id              :     Int
    let paperTitle      :     String
    let limitTime       :     Int
    let created_at      :     String
    let updated_at      :     String
    let totalNumbers    :     Int
    let questionList    :     Array<Any>
    init(json:JSON) {
        self.userId = json["userId"].stringValue
        self.id = json["id"].intValue
        self.paperTitle = json["paperTitle"].stringValue
        self.limitTime = json["limitTime"].intValue
        self.created_at = json["created_at"].stringValue
        self.updated_at = json["updated_at"].stringValue
        self.totalNumbers = json["totalNumbers"].intValue
        self.questionList = json["qustionList"].arrayValue
    }
}


struct QuestionModel {
    var style        :     ExamType
    var answer       :     String
    var index        :     String //自定义的序号
    let qId          :     String
    let qPoint       :     String
    let qTitle       :     String
    let qSelects     :     Array<AnyObject>
    let qOrder       :     Int
    let qType        :     Int      //1 选择题 2填空题 3简答题 4翻译题 5拼音 6看拼音写词语 7英译汉 8个性测试 9判断题
    let qTypeName    :     String
    
    init(json:JSON) {
        self.style = .ExamTypeNormal
        self.index = ""
        self.answer = ""
        self.qId = json["qId"].stringValue
        self.qPoint = json["qPoint"].stringValue
        self.qOrder = json["qOrder"].intValue
        self.qTitle = json["qTitle"].stringValue
        self.qType = json["qType"].intValue
        self.qTypeName = json["qTypeName"].stringValue
        self.qSelects = json["qSelects"].arrayObject! as Array<AnyObject>
    }
}

struct SelectedModel {
    let select      :       String
    init(json: JSON) {
        self.select = json["select"].stringValue
    }
}

struct ExamModel {
    var selectItem  :       Int
    var examAnswer  :       String
    var finished    :       Bool
    init(_ index: Int, answer: String) {
        self.selectItem = index
        self.examAnswer = answer
        self.finished = false
    }
}
