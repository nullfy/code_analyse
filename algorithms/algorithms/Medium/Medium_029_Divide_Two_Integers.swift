//
//  Medium_029_Divide_Two_Integers.swift
//  algorithms
//
//  Created by 李晓东 on 2017/12/4.
//  Copyright © 2017年 XD. All rights reserved.
//

import Foundation

/*
 
 https://leetcode.com/problems/divide-two-integers/
 
 #29 Divide Two Integers
 
 Level: meidum
 
 Divide two integers without using multiplication, division and mod operator.
 
 If it is overflow, return MAX_INT.
 
 Inspired by @lucastan & @ngcl at https://leetcode.com/discuss/11358/simple-o-log-n-2-c-solution
 
 题解：不使用系统除法，自己实现 除法运算
 */

struct Medium_029_Divide_Two_Integers {
    static func divide(dividend: Int, divisor: Int) -> Int { //     30/2    被除数／除数
        if divisor == 0 {
            return Int.max
        }
        if divisor == 1 {
            return dividend
        }
        
        if dividend == Int.min && divisor == Int.min {
            return 1
        }
        
        if dividend == Int.min && abs(divisor) == 1 {
            return Int.max
        }
        
        var result: UInt = 0
        var absDividend: UInt = dividend == Int.min ? UInt(UInt(Int.max) + 1) : UInt(abs(dividend))
        let absDivisor: UInt = divisor == Int.min ? UInt(UInt(Int.max) + 1) : UInt(abs(divisor))
        
        while absDividend >= absDivisor {
            var tmp: UInt = UInt(absDivisor)
            var power: UInt = 1
            while (tmp << 1) < absDividend {
                tmp <<= 1
                power <<= 1
            }
            result += power
            absDividend -= tmp
        }
        
        if (dividend < 1 && divisor > 0) || (dividend > 0 && divisor < 0){
            return 0 - Int(result)
        }
        return Int(result)
    }
}














