//
//  KSConstants.swift
//  kaoshi
//
//  Created by 李晓东 on 2017/10/31.
//  Copyright © 2017年 晓东. All rights reserved.
//

import UIKit
import Foundation
import YYKit

var kScreenWidth = UIScreen.main.bounds.width
var kScreenHeight = UIScreen.main.bounds.height

let kLeftPadding = 8
let kTopPadding = 8

let kInstructTitle = "开始性格测试"
let kExamTitle = "开始答题"

enum ExamType: String {
    case ExamTypeNormal
    case ExamTypeInstruction
}
