//
//  Medium_053_Maximum_Subarray.swift
//  algorithms
//
//  Created by 李晓东 on 2018/1/5.
//  Copyright © 2018年 XD. All rights reserved.
//

/*
 
 https://leetcode.com/problems/maximum-subarray/
 
 #53 Maximum Subarray
 
 Level: medium
 
 Find the contiguous subarray within an array (containing at least one number) which has the largest sum.
 
 For example, given the array [−2,1,−3,4,−1,2,1,−5,4],
 the contiguous subarray [4,−1,2,1] has the largest sum = 6.
 
 Inspired by @john6 at https://leetcode.com/discuss/1832/ive-idea-stucked-the-exception-situation-could-somebody-help
 题解：给定一个数组,求出数组中连续元素求和最大的子数组
 1.一层遍历各个元素，每一次循环中选出
 */

import Foundation

struct Medium_053_Maxinum_Subarray {
    static func maxSubArray(_ n: [Int]) -> Int {
        var nums = n
        var best = nums[0]
        var current = nums[0]
        
        for i in 1..<nums.count {
            current = max(current+nums[i], nums[i])
            print(current, best)
            best = max(current, best)
        }
        return best
    }
}

