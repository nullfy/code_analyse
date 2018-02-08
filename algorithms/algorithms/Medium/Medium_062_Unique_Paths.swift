//
//  Medium_062_Unique_Paths.swift
//  algorithms
//
//  Created by 李晓东 on 2018/2/5.
//  Copyright © 2018年 XD. All rights reserved.
//

/*
 
 https://leetcode.com/problems/unique-paths/
 
 #62 Unique Paths
 
 Level: medium
 
 A robot is located at the top-left corner of a m x n grid (marked 'Start' in the diagram below).
 
 The robot can only move either down or right at any point in time. The robot is trying to reach the bottom-right corner of the grid (marked 'Finish' in the diagram below).
 
 How many possible unique paths are there?
 
 Inspired by @d40a at https://leetcode.com/discuss/9110/my-ac-solution-using-formula
 
 题解:给定一个m * n的二维风格，从方格的左上角开始走，每次只能向下或者向右走一步，直到到方格的右下角结束，求总共有多少条路径
 */

import Foundation

struct Medium_062_Unique_Paths {
    static func uniquePaths(m: Int, n: Int) -> Int {
        let N = n + m - 2
        let k = min(m - 1, n - 1)
        var result = 1
        for i in 1...k {
            result = result * (N - k + i) / i
        }
        return result;
    }
}
