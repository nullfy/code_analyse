//
//  Medium_098_Validate_Binary_Search_Tree.swift
//  algorithms
//
//  Created by null on 2018/6/6.
//  Copyright © 2018年 XD. All rights reserved.
//

import Foundation

/*
 
 https://leetcode.com/problems/validate-binary-search-tree/
 
 #98 Validate Binary Search Tree
 
 Given a binary tree, determine if it is a valid binary search tree (BST).
 
 Assume a BST is defined as follows:
 
 The left subtree of a node contains only nodes with keys less than the node's key. The right subtree of a node contains only nodes with keys greater than the node's key. Both the left and right subtrees must also be binary search trees.
 
 Inspired by [@jakwings](https://leetcode.com/discuss/14886/order-traversal-please-rely-buggy-int_max-int_min-solutions)
 
 */

class Medium_098_Validate_Binary_Search_Tree {
    class Node {
        var left: Node?
        var right: Node?
        var val: Int
        init(val: Int, left: Node?, right: Node?) {
            self.val = val
            self.left = left
            self.right = right
        }
    }
    
    class func isValidBSTRecursionHelper(current: Node?, pre: inout Node?) -> Bool {
        if current == nil {
            return true
        } else {
            if isValidBSTRecursionHelper(current: current?.left, pre: &pre) == false {
                return false
            }
            if pre != nil && (pre?.val)! > (current?.val)! {
                return false
            }
            pre = current
            return isValidBSTRecursionHelper(current: current!, pre: &pre)
        }
        
    }
    
    class func isValidBST(_ root: Node?) -> Bool {
        var prev: Node? = nil
        return isValidBSTRecursionHelper(current: root, pre: &prev)
    }
}
