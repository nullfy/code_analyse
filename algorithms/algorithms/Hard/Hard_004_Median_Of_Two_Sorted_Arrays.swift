//
//  Hard_004_Median_Of_Two_Sorted_Arrays.swift
//  algorithms
//
//  Created by null on 2018/6/20.
//  Copyright © 2018年 XD. All rights reserved.
//

import Foundation

/*
 
 https://leetcode.com/problems/median-of-two-sorted-arrays/
 
 #4 Median of Two Sorted Arrays
 
 Level: hard
 
 There are two sorted arrays A and B of size m and n respectively. Find the median of the two sorted arrays. The overall run time complexity should be O(log (m+n)).
 
 Inspired by @MissMary at https://leetcode.com/discuss/15790/share-my-o-log-min-m-n-solution-with-explanation
 
 */

struct Hard_004_Median_Of_Two_Sorted_Arrays {
    static func findMedianSortedArrays(_ a: [Int], _ b: [Int]) -> Double { //保证a 的元素个数比b的小
        let m = a.count
        let n = b.count
        
        if m > n {
            return findMedianSortedArrays(b, a)
        }
        var tmpMin = 0
        var tmpMax = m
        while tmpMin <= tmpMax {
            let i = (tmpMin + tmpMax) / 2 //中间值
            let j = ((m + n + 1) / 2 ) - i
            
            if j > 0 && i < m && b[j - 1] > a[i] {
                tmpMin = i + 1
            } else if i > 0 && j < n && a[i - 1] > b[j] {
                tmpMax = i - 1
            } else {
                var firstNum: Int
                if i == 0 {
                    firstNum = b[j - 1]
                } else if j == 0 {
                    firstNum = a[i - 1]
                } else {
                    firstNum = max(a[i - 1], b[j - 1])
                }
                
                if (m + n) & 1 != 0 {
                    return Double(firstNum)
                }
                
                var secondNum : Int
                if i == m {
                    secondNum = b[j]
                } else if j == n {
                    secondNum = a[i]
                } else {
                    secondNum = min(a[i], b[j])
                }
                return Double((firstNum + secondNum)) / 2.0
            }
        }
        return 0.0
    }
}
