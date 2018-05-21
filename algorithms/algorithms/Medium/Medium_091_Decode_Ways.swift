//
//  Medium_091_Decode_Ways.swift
//  algorithms
//
//  Created by null on 2018/5/21.
//  Copyright © 2018年 XD. All rights reserved.
//

import Foundation

/*
 
 https://leetcode.com/problems/decode-ways/
 
 #91 Decode Ways
 
 Level: medium
 
 A message containing letters from A-Z is being encoded to numbers using the following mapping:
 
 'A' -> 1
 'B' -> 2
 ...
 'Z' -> 26
 Given an encoded message containing digits, determine the total number of ways to decode it.
 
 For example,
 Given encoded message "12", it could be decoded as "AB" (1 2) or "L" (12).
 
 The number of ways decoding "12" is 2.
 
 Inspired by @manky at https://leetcode.com/discuss/8527/dp-solution-java-for-reference
 
 题解: 给定一个字符串 将字符转换成对应的数字
 如：A -> 1
 要注意的点是 AB-> (1 2) 同时 L->12 
 
 这题直接用dic 对应取一下是不是快点
 */

private extension String {
    subscript (index: Int) -> Character {
        return self[self.characters.index(self.startIndex, offsetBy: index)]
    }
    
    subscript (range: Range<Int>) -> String {
        return String(self[self.characters.index(self.startIndex, offsetBy: range.lowerBound)..<self.characters.index(self.startIndex, offsetBy: range.upperBound, limitedBy: self.endIndex)!])
    }
}

struct Medium_091_Decode_Ways {
    static func numDecodings(_ s: String) -> Int {
        let n: Int = s.characters.count //记录字符串的长度
        if n == 0 {
            return 0
        }
        
        var meno: [Int] = Array<Int>(repeatElement(0, count: n+1))
        meno[n] = 1
        meno[n-1] = s[n-1] != "0" ? 1 : 0
        for i in (0 ... n-2).reversed() {
            if s[i] == "0" {
                continue
            } else {
                meno[i] = Int(s[i..<i+2])! <= 26 ? meno[i+1]+meno[i+2] : meno[i+1]
            }
        }
        return meno[0]
    }
}
