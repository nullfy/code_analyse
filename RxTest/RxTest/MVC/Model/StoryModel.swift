//
//  StoryModel.swift
//  RxTest
//
//  Created by 李晓东 on 2017/11/20.
//  Copyright © 2017年 晓东. All rights reserved.
//

import Foundation
import HandyJSON

struct listModel: HandyJSON {
    var date: String?
    var stories: [storyModel]?
    var top_stories: [storyModel]?
}


struct storyModel: HandyJSON {
    var ga_prefix: String?
    var id: Int?
    var images: [String]?
    var title: String?
    var type: Int?
    var image: String?
    var multpic = false
}
