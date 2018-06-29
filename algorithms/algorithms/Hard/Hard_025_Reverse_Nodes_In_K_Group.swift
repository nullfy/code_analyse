//
//  Hard_025_Reverse_Nodes_In_K_Group.swift
//  algorithms
//
//  Created by null on 2018/6/29.
//  Copyright © 2018年 XD. All rights reserved.
//

/*
 
 https://leetcode.com/problems/reverse-nodes-in-k-group/
 
 #25 Reverse Nodes in k-Group
 
 Level: hard
 
 Given a linked list, reverse the nodes of a linked list k at a time and return its modified list.
 
 If the number of nodes is not a multiple of k then left-out nodes in the end should remain as it is.
 
 You may not alter the values in the nodes, only nodes itself may be changed.
 
 Only constant memory is allowed.
 
 For example,
 Given this linked list: 1->2->3->4->5
 
 For k = 2, you should return: 2->1->4->3->5
 
 For k = 3, you should return: 3->2->1->4->5
 
 Inspired by @sean hyuntaek and @shpolsky at https://leetcode.com/discuss/6113/my-solution-accepted-in-java and https://leetcode.com/discuss/21301/short-but-recursive-java-code-with-comments

 题解：给定一个链表，一个数值k
 截止到k 对链表进行反转
 */

import Foundation

class Hard_025_Reverse_Nodes_In_K_Group {
    class Node {
        var val: Int
        var next: Node?
        init(val: Int, next: Node?) {
            self.val = val
            self.next = next
        }
    }
    
    class func reverseKGroup(head: Node?, k: Int) -> Node? {
        if head == nil {
            return nil
        }
        let dummy: Node = Node.init(val: 0, next: head)
        var prev: Node? = dummy //自定义一个链表头
        var curr: Node? = head //指向传入链表头的当前指针
        
        while curr != nil {
            var pilot: Node? = prev?.next
            var remaining: Int = k
            while pilot != nil && remaining > 0 {
                remaining -= 1
                pilot = pilot?.next
            }
            if remaining > 0 {
                break
            }
            while curr?.next !== pilot {
                let tmp: Node? = curr?.next?.next
                curr?.next?.next = prev?.next
                prev?.next = curr?.next
                curr?.next = tmp
            }
            prev = curr
            curr = curr?.next
        }
        return dummy.next
    }
}
