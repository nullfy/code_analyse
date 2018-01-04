//
//  Medium_050_Pow_X_N.swift
//  algorithms
//
//  Created by 李晓东 on 2018/1/4.
//  Copyright © 2018年 XD. All rights reserved.
//

/*
 
 https://leetcode.com/problems/powx-n/
 
 #50 Pow(x, n)
 
 Level: medium
 
 Implement pow(x, n).
 
 Inspired by @pei heng at https://leetcode.com/discuss/17005/short-and-easy-to-understand-solution
 
 题解：求x 的 n 次方
 1.比如说2^4  (2*2)^2 (4*4)^1
 2.进而可以推出 x^n  (x*x)^n/2 如果n 为单数就是 x* x^n/2
 3.特殊情况像n 为负数 或者x 为0，进行特殊处理
 */

import Foundation

struct Medium_050_Pow_X_N {
    static func myPow(x arg0: Double, n arg1: Int) -> Double {
        var x = arg0
        var n = arg1
        if n == 0 {
            return 1
        }
        if n < 0 {
            n = -n
            x = 1/x
        }
        return (n%2 == 0) ? myPow(x: x*x, n: n/2) : x  * myPow(x: x*x, n: n/2)
    }
}
