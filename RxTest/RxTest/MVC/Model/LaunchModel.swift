//
//  LaunchModel.swift
//  RxTest
//
//  Created by 李晓东 on 2017/11/20.
//  Copyright © 2017年 晓东. All rights reserved.
//

import Foundation
import HandyJSON

struct LaunchModel: HandyJSON {
    var creatives: [LaunchModelImage]?
}

struct LaunchModelImage: HandyJSON {
    var url: String?
    var text: String?
    var start_time: Int?
    var impression_tracks: [String]?
}
