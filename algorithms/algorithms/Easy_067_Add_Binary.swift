//
//  Easy_067_Add_Binary.swift
//  algorithms
//
//  Created by 李晓东 on 2017/9/25.
//  Copyright © 2017年 XD. All rights reserved.
//

import Cocoa
/*
 
 https://leetcode.com/problems/add-binary/
 
 #67 Add Binary
 
 Given two binary strings, return their sum (also a binary string).
 
 For example,
 a = "11"
 b = "1"
 Return "100".
 
 Inspired by @makuiyu at https://leetcode.com/discuss/25593/short-code-by-c
 题解：字符串形式的二进制的加法
 1、引入一个变量记录同位相加的结果
 2、还有一个变量用来记录是否需要进位，当该变量为的值为2的时候就需要进位
 3、逆序便利字符串逐位相加
 */

private extension String {
    subscript (index: Int) -> Character {
        return self[self.characters.index(self.startIndex, offsetBy: index)]
    }
}

class Easy_067_Add_Binary: NSObject {
    class func addbinary(a: String, b: String) -> String {
        var s = ""
        var c: Int = 0
        var i = a.characters.count - 1
        var j = b.characters.count - 1
        let characterDic: [Character : Int] = [
            "0" : 0,
            "1" : 1,
            "2" : 2,
            "3" : 3,
            "4" : 4,
            "5" : 5,
            "6" : 6,
            "7" : 7,
            "8" : 8,
            "9" : 9,
        ]
        let intDic: [Int: String] = [
            0 : "0",
            1 : "1",
            2 : "2",
            3 : "3",
            4 : "4",
            5 : "5",
            6 : "6",
            7 : "7",
            8 : "8",
            9 : "9",
        ]
        while i >= 0 || j >= 0 || c == 1 {
            c += i >= 0 ? characterDic[a[i]]! : 0
            i -= 1
            c += j >= 0 ? characterDic[b[j]]! : 0
            j -= 1
            s = intDic[c%2]! + s
            c /= 2 //这里就是用于判断是不是要进一
        }
        return s
    }
    
}
