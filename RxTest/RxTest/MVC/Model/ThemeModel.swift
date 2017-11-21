//
//  ThemeModel.swift
//  RxTest
//
//  Created by 李晓东 on 2017/11/20.
//  Copyright © 2017年 晓东. All rights reserved.
//

import Foundation
import HandyJSON


struct ThemeResponseModel: HandyJSON {
    var others: [ThemeModel]?
}


struct ThemeModel: HandyJSON {
    var color: String?
    var thumbnail: String?
    var id: Int?
    var description: String?
    var name: String?
}
