//
//  APIManager.swift
//  RxTest
//
//  Created by 李晓东 on 2017/11/20.
//  Copyright © 2017年 晓东. All rights reserved.
//

import Foundation
import Moya

enum APIManager {
    case getLaunchImage
    case getNewsList
    case getMoreNews(String)
    case getThemeList
    case getThemeDesc(Int)
    case getNewsDesc(Int)
}


extension APIManager: TargetType {
    var headers: [String : String]? {
        return ["User-Agent" : "iPhone8" ]
    }

    //Mark: TargetType 是一个协议，定义了一个网络请求所需要的东西，什么baseURL，parameters、method
    //Mark: Moya 的插件机制，提供了两个借口，willSendRequest 和 didReceiveResponse，可以在请求发出前和请求收到后做一些额外的处理，并且不和猪功能耦合

    var baseURL: URL {
        switch self {
        case .getLaunchImage:
            return URL.init(string: "https://pic1.zhimg/com/v2-0c60043dbf69f80d8972dad5b12a57f4.jpg")!
        case .getThemeList:
            return URL.init(string: "http://news-at.zhihu.com/api/")!
        case .getMoreNews(_):
            return URL.init(string: "http://news-at.zhihu.com/api/")!
        case .getNewsDesc(_):
            return URL.init(string: "http://news-at.zhihu.com/api/")!
        case .getThemeDesc(_):
            return URL.init(string: "http://news-at.zhihu.com/api/")!
        default:
            return URL.init(string: "http://news-at.zhihu.com/api/")!
        }
    }
    
    var path: String {
        switch self {
        case .getLaunchImage:
            return ""
        case .getNewsList:
            return "4/news/latest"
        case .getMoreNews(let date):
            return "4/news/before/" + date
        case .getThemeList:
            return "4/themes"
        case .getThemeDesc(let id):
            return "4/theme/\(id)"
        case .getNewsDesc(let id):
            return "4/news/\(id)"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var parameters: [String: Any]? {
        return nil
    }
    
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var validate: Bool {
        return false
    }
}


