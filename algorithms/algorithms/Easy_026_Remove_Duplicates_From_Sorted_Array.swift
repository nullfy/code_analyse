//
//  Easy_026_Remove_Duplicates_From_Sorted_Array.swift
//  algorithms
//
//  Created by 李晓东 on 2017/9/15.
//  Copyright © 2017年 XD. All rights reserved.
//

/*
 
 https://leetcode.com/problems/remove-duplicates-from-sorted-array/
 
 #26 Remove Duplicates from Sorted Array
 
 Level: easy
 
 Given a sorted array, remove the duplicates in place such that each element appear only once and return the new length.
 
 Do not allocate extra space for another array, you must do this in place with constant memory.
 
 For example,
 Given input array nums = [1,1,2],
 
 Your function should return length = 2, with the first two elements of nums being 1 and 2 respectively. It doesn't matter what you leave beyond the new length.
 
 Inspired by @liyangguang1988 at https://leetcode.com/discuss/10314/my-solution-time-o-n-space-o-1
 题解：移除已排序数组中的重复数，同时返回去重后的数组个数
 1.先把数组个数少于2的特殊情况标出
 2.O(n) 一层循环去比较相邻两个元素是否相同，同时用一个tag来表示不相同的次数
 3.tag 就是去重后的数组个数
 */

import Cocoa

class Easy_026_Remove_Duplicates_From_Sorted_Array: NSObject {
    class func removeDuplicated(_ array: inout [Int]) -> Int {
        if array.count < 2 {
            return array.count
        }
        var index: Int = 1
        let n: Int = array.count
        for i in 1 ..< n {
            if array[i] != array[i-1] {
                array[index] = array[i]
                index += 1
            }
        }
        return index
    }
}
