//
//  Medium_069_Sqrt_X.swift
//  algorithms
//
//  Created by 李晓东 on 2018/3/26.
//  Copyright © 2018年 XD. All rights reserved.
//

/*
 
 https://leetcode.com/problems/sqrtx/
 
 #69 Sqrt(x)
 
 Level: medium
 
 Implement int sqrt(int x).
 
 Compute and return the square root of x.
 
 Inspired by @tyuan73 at https://leetcode.com/discuss/8897/share-my-o-log-n-solution-using-bit-manipulation

 题解：实现平方根函数
 1.二分法 主要涉及位运算 
 2.从最大的Int64 开始右移位 当ans 的平方进入目标X 的范围时
 
 a |= b  ===> a = a|b
 a ^= b  ===> a = a^b
 */

import Foundation


struct Meidum_069_Sqrt_X {
    static func mySqrt(_ x: Int) -> Int {
        var ans: Int64 = 0
        var bit: Int64 = 1 << 16
        
        while bit > 0 {
            ans |= bit
            print("ans:\(ans)\n")
            if ans * ans > Int64(x) {
                ans ^= bit
                print("ans:\(ans)\n")
            }
            bit >>= 1
            print("bit:\(bit)\n\n")
        }
        return Int(ans)
    }
}
