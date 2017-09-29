//
//  Easy_100_Same_Tree.swift
//  algorithms
//
//  Created by 李晓东 on 2017/9/29.
//  Copyright © 2017年 XD. All rights reserved.
//

import Cocoa

class Easy_100_Same_Tree: NSObject {
    class Node {
        var left: Node?
        var right: Node?
        var val: Int
        init(value: Int, left: Node?, right: Node?) {
            self.val = value
            self.left = left
            self.right = right
        }
    }
    
    class func isSameTree_recursion(p: Node?, q: Node?) -> Bool {
        if p == nil || q == nil {
            return p == nil && q == nil
        } else {
            return p!.val == q!.val && isSameTree(p: p?.left, q: q?.left) && isSameTree(p: p?.right, q: q?.right)
        }
    }
    
    class func isSameTree_iteration(p: Node?, q: Node?) -> Bool {
        if p == nil || q == nil {
            return (p == nil && q == nil)
        }
        var stack_p: [Node] = []
        var stack_q: [Node] = []
        stack_p.append(p!)
        stack_q.append(q!)
        while stack_p.isEmpty == false && stack_q.isEmpty == false {
            let tmp_p: Node = stack_p.removeLast()
            let tmp_q: Node = stack_q.removeLast()
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
    
    class func isSameTree(p: Node?, q: Node?) -> Bool {
        return isSameTree_iteration(p: p, q: q)
    }
}
