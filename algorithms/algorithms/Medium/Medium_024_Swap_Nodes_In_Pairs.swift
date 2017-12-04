//
//  Medium_024_Swap_Nodes_In_Pairs.swift
//  algorithms
//
//  Created by 李晓东 on 2017/12/4.
//  Copyright © 2017年 XD. All rights reserved.
//

import Foundation
/*
 
 https://leetcode.com/problems/swap-nodes-in-pairs/
 
 #24 Swap Nodes in Pairs
 
 Level: medium
 
 Given a linked list, swap every two adjacent nodes and return its head.
 
 For example,
 Given 1->2->3->4, you should return the list as 2->1->4->3.
 
 Your algorithm should use only constant space. You may not modify the values in the list, only nodes itself can be changed.
 
 Inspired by @mike3 at https://leetcode.com/discuss/3608/seeking-for-a-better-solution
 
 题解：给定一组链表，以2 为单位对调元素的位置
 
 */


class Medium_024_Swap_Nodes_In_Paris {
    class Node {
        var next: Node?
        var val: Int
        init(val: Int, next: Node?) {
            self.val = val
            self.next = next
        }
    }
    
    class func swap(next1: Node, next2: Node) -> Node {
        next1.next = next2.next;
        next2.next = next1;
        return next2;
    }
    
    class func swapParis(_ head: Node?) -> Node? {
        let dummy: Node = Node.init(val: 0, next: nil);
        dummy.next = head;
        var curr: Node? = dummy;
        while curr?.next != nil && curr?.next?.next != nil {
            curr?.next = swap(next1: (curr?.next!)!, next2: (curr?.next?.next)!)
            curr = curr?.next?.next
        }
        return dummy.next
    }
}
















