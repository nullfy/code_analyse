//
//  File.swift
//  algorithms
//
//  Created by 李晓东 on 2018/3/26.
//  Copyright © 2018年 XD. All rights reserved.
//

/*
 
 https://leetcode.com/problems/minimum-path-sum/
 
 #64 Minimum Path Sum
 
 Level: medium
 
 Given a m x n grid filled with non-negative numbers, find a path from top left to bottom right which minimizes the sum of all numbers along its path.
 
 Note: You can only move either down or right at any point in time.
 
 Inspired by @wdj0xda at https://leetcode.com/discuss/17111/my-java-solution-using-dp-and-no-extra-space

 题解：给定一个网格里面填满了非负数，找到一条从左上角到右下角同时满足格子里的数求和最小的路线 每次只能进行向下或者向右
 1. 不妨可以逆着推一下每次只要找到上一步的上一或者左一的最小值就好
 
 */

import Foundation

struct Medium_064_Minimum_Path_Sum {
    static func minPathSum(_ g: [[Int]]) -> Int {
        var grid = g
        if grid.count == 0 {
            return 0
        }
        let rows = grid.count  // 行数
        let cols = grid[0].count //列数

        for i in 0..<rows {
            for j in 0 ..< cols {
                if i == 0 && j != 0 {
                    grid[i][j] = grid[i][j] + grid[i][j-1]
                } else if i != 0 && j == 0 {
                    grid[i][j] = grid[i-1][j] + grid[i][j]
                } else if i != 0 && j != 0 {
                    let tmp = min(grid[i-1][j], grid[i][j-1])
                    grid[i][j] = tmp + grid[i][j]
                }
            }
        }
        return grid[rows-1][cols-1]
    }
}
