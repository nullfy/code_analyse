//
//  Medium_093_Restore_IP_Addresses.swift
//  algorithms
//
//  Created by null on 2018/5/23.
//  Copyright © 2018年 XD. All rights reserved.
//

/*
 
 https://leetcode.com/problems/restore-ip-addresses/
 
 #93 Restore IP Addresses
 
 Level: medium
 
 Given a string containing only digits, restore it by returning all possible valid IP address combinations.
 
 For example:
 Given "25525511135",
 
 return ["255.255.11.135", "255.255.111.35"]. (Order does not matter)
 
 Inspired by @fiona_mao at https://leetcode.com/discuss/12790/my-code-in-java
 题解：这题很明朗，对一串字符串分解成ip地址
 
 */

import Foundation

private extension String {
    
    //根据range 截取字符串
    subscript (range: Range<Int>) -> String {
        return String(self[self.characters.index(self.startIndex, offsetBy: range.lowerBound) ..< self.characters.index(self.startIndex, offsetBy: range.upperBound, limitedBy: self.endIndex)!])
    }
}

struct Medium_093_Restore_IP_Addresses {
    static func restoreIPAddress(_ s: String) -> [String] {
        var res = Array<String>()
        let len: Int = s.characters.count
        for i in 1..<min(4, len-2) {
            for j in i+1 ..< min(j+4, len) {
                for k in j+1 ..< min(j+4, len) {
                    let s0: String = s[0..<i]
                    let s1: String = s[i..<j]
                    let s2: String = s[j..<k]
                    let s3: String = s[k..<len]
                    if isValid(s0) && isValid(s1) && isValid(s2) && isValid(s3) {
                        res.append("\(s0).\(s1).\(s2).\(s3)")
                    }
                }
            }
        }
        return res
    }
    
    private static func isValid(_ s: String) -> Bool {
        let len = s.characters.count
        if len > 3 || len == 0 || Int(s)! > 255 || (len > 1 && s.characters.first == "0") {
            return false
        }
        return true
    }
}
