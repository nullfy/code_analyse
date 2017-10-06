//
//  Easy_100_Same_Tree.swift
//  algorithms
//
//  Created by 李晓东 on 2017/9/29.
//  Copyright © 2017年 XD. All rights reserved.
//

import Cocoa
/*
 
 https://leetcode.com/problems/same-tree/
 
 #100 Same Tree
 
 Level: easy
 
 Given two binary trees, write a function to check if they are equal or not.
 
 Two binary trees are considered equal if they are structurally identical and the nodes have the same value.
 
 Inspired by [@JohnWeiGitHub](https://leetcode.com/discuss/3470/seeking-for-better-solution) and [@scott](https://leetcode.com/discuss/22197/my-non-recursive-method)
 题解： 相同树、对称树
 复杂度： O(N)  O(h)递归栈空间
 1、如果两个根节点一个为空，一个不为空，或者两个根节点的值不同，直接返回false
 2、如果两个节点都是空，则是一样，返回true
 3、以上是特殊情况，以下是一般情况
 4、递归左右节点，如果递归结果有一个或以上为假，就返回假，否则说明左右子树完全一样
 
 */

class Easy_100_Same_Tree: NSObject {
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
    
    class func isSameTree(p: TreeNode?, q: TreeNode?) -> Bool {
        return isSameTree_iteration(p: p, q: q)
    }
    
    //迭代
    class func isSameTree_iteration(p: TreeNode?, q: TreeNode?) -> Bool {
        if p == nil || q == nil {
            return (p == nil && q == nil)
        }
        var stack_p: [TreeNode] = []
        var stack_q: [TreeNode] = []
        stack_p.append(p!)
        stack_q.append(q!)
        while stack_p.isEmpty == false && stack_q.isEmpty == false {
            let tmp_p: TreeNode = stack_p.removeLast()
            let tmp_q: TreeNode = stack_q.removeLast()
            if tmp_p.val != tmp_q.val {
                return false
            }
            if tmp_p.left != nil {
                stack_p.append(tmp_p.left!)
            }
            if tmp_q.left != nil {
                stack_q.append(tmp_q.left!)
            }
            if stack_p.count != stack_q.count {
                return false
            }
            if tmp_p.right != nil {
                stack_p.append(tmp_p.right!)
            }
            if tmp_q.right != nil {
                stack_q.append(tmp_q.right!)
            }
            if stack_q.count != stack_q.count {
                return false
            }
        }
        return stack_q.count == stack_q.count
    }
    
    //递归
    class func isSameTree_recursion(p: TreeNode?, q: TreeNode?) -> Bool {
        if p == nil || q == nil {
            return p == nil && q == nil
        } else {
            return p!.val == q!.val && isSameTree_recursion(p: p?.left, q: q?.left) && isSameTree_recursion(p: p?.right, q: q?.right)
        }
    }
}
