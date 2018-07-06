//
//  Hard_041_First_Missing_Positive.swift
//  algorithms
//
//  Created by null on 2018/7/6.
//  Copyright © 2018年 XD. All rights reserved.
//

/*
 
 https://leetcode.com/problems/first-missing-positive/
 
 #41 First Missing Positive
 
 Level: hard
 
 Given an unsorted integer array, find the first missing positive integer.
 
 For example,
 Given [1,2,0] return 3,
 and [3,4,-1,1] return 2.
 
 Your algorithm should run in O(n) time and uses constant space.
 
 Inspired by @makuiyu at https://leetcode.com/discuss/24013/my-short-c-solution-o-1-space-and-o-n-time
 题解: 给定一个未排序的数组，找到缺少的正整数
 */


import Foundation

class Hard_041_First_Missing_Positive {
    static func firstMissPositive(_ n: [Int]) -> Int {
        var nums = n
        for i in 0 ..< nums.count {
            while nums[i] > 0 && nums[i] <= nums.count && nums[nums[i] - 1] != nums[i] {
                nums.swapAt(i, nums[i] - 1)
            }
        }
        
        for i in 0 ..< nums.count {
            if (nums[i] != i+1) {
                return i + 1
            }
        }
        return nums.count + 1;
    }
}
