//
//  Medium_048_Rotate_Image.swift
//  algorithms
//
//  Created by 李晓东 on 2018/1/2.
//  Copyright © 2018年 XD. All rights reserved.
//

/*
 
 https://leetcode.com/problems/rotate-image/
 
 #48 Rotate Image
 
 Level: medium
 
 You are given an n x n 2D matrix representing an image.
 
 Rotate the image by 90 degrees (clockwise).
 
 Follow up:
 Could you do this in-place?
 
 Inspired by @shichaotan at https://leetcode.com/discuss/20589/a-common-method-to-rotate-the-image 
 
 题解：给定一个n*n 的二维数组，将它看作是图片，要求是将它顺时针旋转90度
 我们可以将其想象为N个正方形，每个正方形的边长分别为N，N-1，N-2...2，1。每一次的旋转，其实都是正方形上的四个元素之间的相互替换。所以本质上我们只需遍历每种长度正方形上的一条边，就可以完成这个正方形的旋转。最后实现整个数组矩阵的旋转
 */

import Foundation

struct Medium_048_Rotate_Image {
    static func rotate(_ matrix: inout [[Int]]) {
        let n = matrix.count
        for i in 0..<n/2 {
            matrix.swapAt(i, n-1-i)
        }
        for i in 0..<n {
            for j in i+1..<n {
                let tmp = matrix[i][j]
                matrix[i][j] = matrix[j][i]
                matrix[j][i] = tmp;
            }
        }
    }
}
