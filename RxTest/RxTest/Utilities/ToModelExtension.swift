//
//  ToModelExtension.swift
//  RxTest
//
//  Created by 李晓东 on 2017/11/21.
//  Copyright © 2017年 晓东. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import HandyJSON

extension Response {
    func mapModel<T: HandyJSON>(_ type: T.Type) -> T {
        let jsonStr = String.init(data: data, encoding: .utf8)
        return JSONDeserializer<T>.deserializeFrom(json: jsonStr)!
    }
}

extension ObservableType where E == Response {
    public func mapModel<T: HandyJSON>(_ type: T.Type) -> Observable<T> {
        return flatMap{ response -> Observable<T> in
            return Observable.just(response.mapModel(T.self))
        }
    }
}
