//
//  Easy_088_Merge_Sorted_Array.swift
//  algorithms
//
//  Created by 李晓东 on 2017/9/27.
//  Copyright © 2017年 XD. All rights reserved.
//

import Cocoa
/*
 
 https://leetcode.com/problems/merge-sorted-array/
 
 #88 Merge Sorted Array
 
 Level: easy
 
 Given two sorted integer arrays nums1 and nums2, merge nums2 into nums1 as one sorted array.
 
 Note:
 You may assume that nums1 has enough space (size that is greater or equal to m + n) to hold additional elements from nums2. The number of elements initialized in nums1 and nums2 are m and n respectively.
 
 Inspired by @leetchunhui at https://leetcode.com/discuss/8233/this-is-my-ac-code-may-help-you
 
 题解：给定两个已排序的数组，合并为一个，同时排好序
 1、从后往前填充
 */
class Easy_088_Merge_Sorted_Array: NSObject {
    static func merge(num1: inout [Int], m: Int, num2: [Int], n: Int) {
        var i = m - 1
        var j = n - 1
        var k = m + n - 1
        while i >= 0 && j >= 0 {
            if num1[i] > num2[j] {
                num1[k] = num1[i]
                k -= 1
                i -= 1
            } else {
                num1[k] = num2[j]
                k -= 1
                j -= 1
            }
        }
        while j >= 0 {
            num1[k] = num2[j]
            k -= 1
            j -= 1
        }
    }
}
