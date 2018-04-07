//
//  Medium_079_Word_Search.swift
//  algorithms
//
//  Created by 李晓东 on 2018/4/3.
//  Copyright © 2018年 XD. All rights reserved.
//

/*
 
 https://leetcode.com/problems/word-search/
 
 #79 Word Search
 
 Level: medium
 
 Given a 2D board and a word, find if the word exists in the grid.
 
 The word can be constructed from letters of sequentially adjacent cell, where "adjacent" cells are those horizontally or vertically neighboring. The same letter cell may not be used more than once.
 
 For example,
 Given board =
 
 [
 ['A','B','C','E'],
 ['S','F','C','S'],
 ['A','D','E','E']
 ]
 word = "ABCCED", -> returns true,
 word = "SEE", -> returns true,
 word = "ABCB", -> returns false.
 
 题解：给定一个装有字符的二维数组 然后再输入一串字符串，判断数组中是否包含字符串中的字符，重复的字符也必须要再数组中出现重复的次数才算
 
 */


import Foundation

struct Medium_079_Word_Search {
    let dirs = [[1, 0], [-1, 0], [0, 1], [0, -1]]
    
    func exist(_ board: [[Character]], _ word: String) -> Bool {
        
        if board.count == 0 || board[0].count == 0 {
            return false
        }
        
        let m = board.count, n = board[0].count
        var arr = [Character]()
        for i in word.characters {
            arr.append(i)
        }
        
        var seen = Array(repeating: Array(repeating: false, count: n), count: m)
        
        for i in 0..<m {
            
            for j in 0..<n {
                
                if dfs(board, i, j, arr, 0, &seen) {
                    return true
                }
            }
        }
        
        return false
    }
    
    func dfs(_ board: [[Character]], _ i: Int, _ j: Int, _ arr: [Character], _ idx: Int, _ seen: inout [[Bool]]) -> Bool {
        
        if idx == arr.count {
            return true
        }
        
        let m = board.count, n = board[0].count
        
        if i < 0 || i >= m || j < 0 || j >= n || board[i][j] != arr[idx] || seen[i][j] {
            return false
        }
        
        seen[i][j] = true
        
        for dir in dirs {
            
            if dfs(board, i + dir[0], j + dir[1], arr, idx + 1, &seen) {
                return true
            }
        }
        
        seen[i][j] = false
        return false
    }
}
