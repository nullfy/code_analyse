//
//  NewsDetailModel.swift
//  RxTest
//
//  Created by 李晓东 on 2017/11/20.
//  Copyright © 2017年 晓东. All rights reserved.
//

import Foundation
import HandyJSON

struct NewsDetailModel: HandyJSON {
    var body: String?
    var ga_prefix: String?
    var id: Int?
    var image: String?
    var image_source: String?
    var share_url: String?
    var title: String?
    var type: Int?
    var images: [String]?
    var css: [String]?
    var js: [String]?
}
