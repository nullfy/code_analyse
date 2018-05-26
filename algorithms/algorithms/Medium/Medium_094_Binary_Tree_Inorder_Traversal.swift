//
//  Medium_094_Binary_Tree_Inorder_Traversal.swift
//  algorithms
//
//  Created by null on 2018/5/26.
//  Copyright © 2018年 XD. All rights reserved.
//

import Foundation

/*
 
 https://leetcode.com/problems/binary-tree-inorder-traversal/
 
 #94 Binary Tree Inorder Traversal
 
 Given a binary tree, return the inorder traversal of its nodes' values.
 
 For example:
 Given binary tree {1,#,2,3}, 后面的题目中也有输入[1, null, 2, 3]
 1
 \
 2
 /
 3
 return [1,3,2].
 
 Note: Recursive solution is trivial, could you do it iteratively?
 
 Inspired by @lvlolitte at https://leetcode.com/discuss/19765/iterative-solution-in-java-simple-and-readable and @blue_y at https://leetcode.com/discuss/11295/morris-traversal-no-recursion-no-stack
 题解：二叉树的中序遍历顺序为左-根-右，可以有递归和非递归来解
 
 
 二叉树遍历分为三种：
 1.前序遍历：访问根节点的操作发生在遍历其左右子树之前
 2.中序遍历：访问根节点的操作发生在遍历其左右子树之中
 3.后序遍历：访问根节点的操作发生在遍历其左右子树之后
 
 
 */

struct Medium_094_Binary_Tree_Inorder_Traversal {
    class Node {
        var val: Int
        var left: Node?
        var right: Node?
        init(val: Int, left: Node?, right: Node?) {
            self.val = val
            self.left = left
            self.right = right
        }
    }
    
    static func inorderTraversal(_ root: Node?) -> [Int] {
        return inorderTraversal_mirror(root)
    }
    
    static func inorderTraversal_mirror(_ r: Node?) -> [Int] {
        var root = r
        if root == nil {
            return []
        } else {
            var res: [Int] = []
            var pre: Node? = nil
            while root != nil {
                if root?.left == nil {
                    res.append((root?.val)!)
                    root = root?.right
                } else {
                    pre = root?.left
                    while pre?.right != nil && pre?.right !== root { //这里不能用 !=  === 恒等于 == 表示是否值相同，===表示是否引用相同的对象
                        pre = pre?.right
                    }
                    if pre?.right == nil {
                        pre?.right = root
                        root = root?.left
                    } else {
                        pre?.right = nil
                        res.append((root?.val)!)
                        root = root?.right
                    }
                }
            }
            return res
        }
    }
}
