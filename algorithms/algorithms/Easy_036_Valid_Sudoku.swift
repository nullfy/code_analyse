//
//  Easy_036_Valid_Sudoku.swift
//  algorithms
//
//  Created by 李晓东 on 2017/9/19.
//  Copyright © 2017年 XD. All rights reserved.
//

import Cocoa
/*
 
 https://leetcode.com/problems/valid-sudoku/
 
 #36 Valid Sudoku
 
 Level: easy
 
 Determine if a Sudoku is valid, according to: Sudoku Puzzles - The Rules.
 
 "Each row must have the numbers 1-9 occuring just once."
 
 "Each column must have the numbers 1-9 occuring just once."
 
 "And the numbers 1-9 must occur just once in each of the 9 sub-boxes of the grid."
 
 The Sudoku board could be partially filled, where empty cells are filled with the character '.'.
 
 A partially filled sudoku which is valid.
 
 Note:
 A valid Sudoku board (partially filled) is not necessarily solvable. Only the filled cells need to be validated.
 
 Inspired by @bigwolfandtiger at https://leetcode.com/discuss/17990/sharing-my-easy-understand-java-solution-using-set
 题解：数独有效性验证
 只要验证当前已经填充等数字是合法的就可以，因此只需要判断9x9网格的每一行、每一列，9个小九宫格是否合法，如果三者中有一个不合法，则该数字不合法
 1.三个循环、各判断行、列、小九宫格是否合法
 */

class Easy_036_Valid_Sudoku: NSObject {
    class func isPartiallyValid(board: [[Character]], x1: Int, y1: Int, x2: Int, y2: Int) ->Bool {
        var singleSet: Set<Character> = Set()
        for i in x1...x2 {
            for j in y1...y2 {
                if board[i][j] != "." {
                    if singleSet.contains(board[i][j]) == true {
                        return false
                    } else {
                        singleSet.insert(board[i][j])
                    }
                }
            }
        }
        return true
    }
}
