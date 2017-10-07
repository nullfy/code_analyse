//
//  Easy_101_Symmetric_Tree.swift
//  algorithms
//
//  Created by 李晓东 on 2017/10/6.
//  Copyright © 2017年 XD. All rights reserved.
//

import Cocoa
/*
 
 https://leetcode.com/problems/symmetric-tree/
 
 #101 Symmetric Tree
 
 Level: easy
 
 Given a binary tree, check whether it is a mirror of itself (ie, symmetric around its center).
 
 For example, this binary tree is symmetric:
 
 1
 / \
 2   2
 / \ / \
 3  4 4  3
 
 But the following is not:
 
  1
 / \
 2   2
  \   \
   3    3
 
 Inspired by [@xuanaux](https://leetcode.com/discuss/456/recusive-solution-symmetric-optimal-solution-inordertraversal)
 
 题解：对称树
 
 */

class Easy_101_Symmetric_Tree: NSObject {
    class TreeNode {
        var left: TreeNode?
        var right: TreeNode?
        var val: Int
        init(value: Int, left: TreeNode?, right: TreeNode?) {
            self.val = value
            self.left = left
            self.right = right
        }
    }
    
    class func isSymmetric(_ root: TreeNode?) -> Bool {
        if root == nil {
            return false
        }
        var stack_1: [TreeNode?] = []
        var stack_2: [TreeNode?] = []
        stack_1.append(root)
        stack_2.append(root)
        
        while stack_1.isEmpty == false && stack_2.isEmpty == false {
            let tmp_1: TreeNode? = stack_1.popLast()!
            let tmp_2: TreeNode? = stack_2.popLast()!
            if tmp_1 == nil && tmp_2 == nil {
                continue
            }
            if tmp_1 == nil || tmp_2 == nil {
                return false
            }
            if tmp_1?.val != tmp_2?.val {
                return false
            }
            
            stack_1.append(tmp_1?.right)
            stack_2.append(tmp_2?.left)
            stack_1.append(tmp_1?.left)
            stack_2.append(tmp_2?.right)
        }
        
        return true
    }
    
}
