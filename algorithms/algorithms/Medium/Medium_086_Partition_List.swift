//
//  Medium_086_Partition_List.swift
//  algorithms
//
//  Created by null on 2018/4/27.
//  Copyright © 2018年 XD. All rights reserved.
//

/*
 
 https://leetcode.com/problems/partition-list/
 
 #86 Partition List
 
 Level: medium
 
 Given a linked list and a value x, partition it such that all nodes less than x come before nodes greater than or equal to x.
 
 You should preserve the original relative order of the nodes in each of the two partitions.
 
 For example,
 Given 1->4->3->2->5->2 and x = 3,
 return 1->2->2->4->3->5.
 
 Inspired by @shichaotan at https://leetcode.com/discuss/21032/very-concise-one-pass-solution
 
 题解：给定一个链表 与一个定值
 
 */

import Foundation


class Medium_086_Partition_List {
    class ListNode {
        var val: Int
        var next: ListNode?
        init(_ val: Int) {
            self.val = val
            self.next = nil
        }
    }
    
    func partition(_ head: ListNode?, _ x: Int) -> ListNode? {
        var h = head
        let sentineA: ListNode? = ListNode(0)
        let sentineB: ListNode? = ListNode(0)
        var pA: ListNode? = sentineA
        var pB: ListNode? = sentineB
        
        while h != nil {
            if (h?.val)! < x {
                pA?.next = h
                pA = pA?.next
            } else {
                pB?.next = h
                pB = pB?.next
            }
            h = h?.next
        }
        
        pB?.next = nil
        pA?.next = sentineB?.next
        return sentineA?.next
    }
}
