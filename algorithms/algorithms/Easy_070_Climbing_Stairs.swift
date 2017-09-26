//
//  Easy_070_Climbing_Stairs.swift
//  algorithms
//
//  Created by 李晓东 on 2017/9/25.
//  Copyright © 2017年 XD. All rights reserved.
//

import Cocoa
/*
 
 https://leetcode.com/problems/climbing-stairs/
 
 #70 Climbing Stairs
 
 Level: easy
 
 You are climbing a stair case. It takes n steps to reach to the top.
 
 Each time you can either climb 1 or 2 steps. In how many distinct ways can you climb to the top?
 
 Inspired by @facetothefate at https://leetcode.com/discuss/2809/easy-solutions-for-suggestions
 题解：爬楼梯，你可以一次爬两阶 也可以一次爬一阶，求传入一个台阶数，输出一共有多少解法
 1、假设有n 层，因为每次只能爬1步或者2步，那么爬到n 层的方法要么是从 n-1 层一步上来，要不就是n-2 层2步上来的，所以递推公式很容易得出就是f(n) = f(n-1) + f(n-2)
 2、
 */
class Easy_070_Climbing_Stairs: NSObject {
    class func climbStairs(_ n: Int) -> Int {
        if n == 0 || n == 1 {
            return 1
        }
        var one = 1
        var two = 1
        var result = 0
        for _ in 2 ... n {
            result = one + two
            two = one
            one = result
        }
        return result
    }
}
