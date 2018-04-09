//
//  Medium_073_Set_Matrix_Zeroes.swift
//  algorithms
//
//  Created by 李晓东 on 2018/3/28.
//  Copyright © 2018年 XD. All rights reserved.
//

/*
 
 https://leetcode.com/problems/set-matrix-zeroes/
 
 #73 Set Matrix Zeroes
 
 Given a m x n matrix, if an element is 0, set its entire row and column to 0. Do it in place.
 
 Follow up:
 Did you use extra space?
 A straight forward solution using O(mn) space is probably a bad idea.
 A simple improvement uses O(m + n) space, but still not the best solution.
 Could you devise a constant space solution?
 
 Inspired by @mzchen at https://leetcode.com/discuss/15997/any-shortest-o-1-space-solution
 
 题解：给定一个 m x n 的矩阵，如果有一个元素为0，将整行整列都设为0
 
 这道题中说的空间复杂度为O(mn)的解法自不用多说，直接新建一个和matrix等大小的矩阵，然后一行一行的扫，只要有0,就将新建的矩阵的对应行全赋0，行扫完再扫列，然后把更新完的矩阵赋给matrix即可，这个算法的空间复杂度太高。将其优化到O(m+n)的方法是，用一个长度为m的一维数组记录各行中是否有0，用一个长度为n的一维数组记录各列中是否有0，最后直接更新matrix数组即可。这道题的要求是用O(1)的空间，那么我们就不能新建数组，我们考虑就用原数组的第一行第一列来记录各行各列是否有0.
 
 - 先扫描第一行第一列，如果有0，则将各自的flag设置为true
 - 然后扫描除去第一行第一列的整个数组，如果有0，则将对应的第一行和第一列的数字赋0
 - 再次遍历除去第一行第一列的整个数组，如果对应的第一行和第一列的数字有一个为0，则将当前值赋0
 - 最后根据第一行第一列的flag来更新第一行第一列
 */

import Foundation

struct Medium_073_Set_Matrix_Zeroes {
    
    static func setZeros(_ matrix: inout [[Int]]) {
        var row_has_zero = false
        var col_has_zero = false
        let m = matrix.count
        let n = matrix[0].count
        print("loop0\n",matrix[0],"\n",matrix[1],"\n",matrix[2],"\n\n")
        
        //遍历首行
        for i in 0..<n {
            if matrix[0][i] == 0 {
                row_has_zero = true
                break
            }
        }
        
        //遍历第一列
        for i in 0..<m {
            if matrix[i][0] == 0 {
                col_has_zero = true
                break
            }
        }
        
        /*
         这里的逻辑是如果某行某列的一个元素为0 那么就将第1行该列位元素改为0，第一列的该行位元素置为0
         比如说matrix[2][3] 为0 那么matrix[0][3] matrix[2][0] 改为0
        */
        for i in 1..<m {
            for j in 1..<n {
                if matrix[i][j] == 0 {
                    matrix[0][j] = 0
                    matrix[i][0] = 0
                    print("loop1\n",matrix[0],"\n",matrix[1],"\n",matrix[2],"\n\n")
                }
            }
        }
        
        /*
         这里的逻辑是如果某行第0个元素为0 那么就将第1行该列位元素改为0，第一列的该行位元素置为0
         比如说matrix[2][0] 为0 那么第三行的元素都会设置为0
         如果说matrix[0][3] 为0 那么第四列的元素都会设置为0
         */
        for i in 1..<m {
            for j in 1..<n {
                if matrix[i][0] == 0 || matrix[0][j] == 0 {
                    matrix[i][j] = 0
                    print("loop2\n",matrix[0],"\n",matrix[1],"\n",matrix[2],"\n\n")
                }
            }
        }

        if row_has_zero {
            for i in 0..<n {
                matrix[0][i] = 0
                print("loop3\n",matrix[0],"\n",matrix[1],"\n",matrix[2],"\n\n")
            }
        }
        
        if col_has_zero {
            for i in 0..<m {
                matrix[i][0] = 0
                print("loop4\n",matrix[0],"\n",matrix[1],"\n",matrix[2],"\n\n")
            }
        }
    }
}
