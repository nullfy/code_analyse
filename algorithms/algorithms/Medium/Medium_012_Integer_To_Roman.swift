//
//  Medium_012_Integer_To_Roman.swift
//  algorithms
//
//  Created by 李晓东 on 2017/10/24.
//  Copyright © 2017年 XD. All rights reserved.
//

import Cocoa

/*
 https://leetcode.com/problems/integer-to-roman/
 
 #12 Integer To Roman
 
 Level: medium
 
 Given an integer, convert it to a roman numeral.
 
 Input is guaranteed to be within the range from 1 to 3999.
 
 Inspired by @flytosky at https://leetcode.com/discuss/1208/how-to-improve-code

 
 1 - 3999的整数 转罗马数字
 从高位开始求的每位数的值，再拼接每个数就可以
 
 */

class Medium_012_Integer_To_Roman: NSObject {
    
    private static var M: [String] = ["", "M", "MM", "MMM"]//0-3000 1000++
    private static var C: [String] = ["", "C", "CC", "CCC"] //0-900 100++
    private static var X: [String] = ["", "X", "XX", "XXX", "XL", "L", "LX", "LXX", "LXXX", "XC"] //0-90 10++
    private static var I: [String] = ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX"] //0-9 1++
    
    class func integerToRoman(num: Int) -> String {
        let m = M[num/1000]
        let c = C[(num%1000)/100]
        let x = X[(num%100)/10]
        let i = I[num%10]
        return m + c + x + i
    }

}
