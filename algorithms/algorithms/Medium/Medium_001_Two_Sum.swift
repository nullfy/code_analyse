//
//  Medium_001_Two_Sum.swift
//  algorithms
//
//  Created by 李晓东 on 2017/9/16.
//  Copyright © 2017年 XD. All rights reserved.
//

import Cocoa
/*
 
 https://oj.leetcode.com/problems/two-sum/
 
 #1 Two Sum
 
 Level: medium
 
 Given an array of integers, find two numbers such that they add up to a specific target number.
 
 The function twoSum should return indices of the two numbers such that they add up to the target, where index1 must be less than index2. Please note that your returned answers (both index1 and index2) are not zero-based.
 
 You may assume that each input would have exactly one solution.
 
 Input: numbers={2, 7, 11, 15}, target=9
 Output: index1=1, index2=2
 
 Inspired by @naveed.zafar at https://leetcode.com/discuss/10947/accepted-c-o-n-solution
 
 题解：给定一个值，一个数组，数组中有两个数相加等于该值，假设只有一对数符合该情况
 
 利用哈希表来实现可以O(n)
 1.一层遍历数组中的各个元素
 2.用给定的值减去当前遍历到的元素，以结果为key，元素下标为value存入dic
 3.下一轮循环中如果该元素被减得到的结果在dic中找得到，那么取得的value就是要找的下标
 */

class Medium_001_Two_Sum: NSObject {
    static func twoSum(_ numbers: [Int], target: Int) -> [Int] {
        var hasMap = [Int : Int]()
        var resut = [Int]()
        for i in 0 ..< numbers.count {
            let find: Int = target - numbers[i]
            if let index = hasMap[find] {
                resut.append(index+1)
                resut.append(i+1)
                return resut
            } else {
                hasMap[numbers[i]] = i
            }
        }
        return resut
    }
}
