//
//  Medium_080_Remove_Duplicates_From_Sorted_Array_II.swift
//  algorithms
//
//  Created by 李晓东 on 2018/4/11.
//  Copyright © 2018年 XD. All rights reserved.
//

/*
 
 https://leetcode.com/problems/remove-duplicates-from-sorted-array-ii/
 
 #80 Remove Duplicates from Sorted Array II
 
 Level: medium
 
 Follow up for "Remove Duplicates":
 What if duplicates are allowed at most twice?
 
 For example,
 Given sorted array nums = [1,1,1,2,2,3],
 
 Your function should return length = 5, with the first five elements of nums being 1, 1, 2, 2 and 3. It doesn't matter what you leave beyond the new length.
 
 Inspired by @dragonmigo at https://leetcode.com/discuss/2754/is-it-possible-to-solve-this-question-in-place
 题解: 给定一个已排序的数组，里面的元素最大的重复的元素为2,返回移除重复元素后的数组长度
 
 */

import Foundation

struct Medium_080_Remove_Duplicates_From_Sorted_Array_II {
    static func removeDuplicates(_ nums: inout [Int]) -> Int {
        let n = nums.count
        if n <= 2 {
            return n
        }
        var len = 2
        var iterator = 2
        while iterator < n {
            if nums[iterator] != nums[len - 2] {
                nums[len] = nums[iterator]
                len += 1
            }
            iterator += 1
        }
        return len
    }
}
