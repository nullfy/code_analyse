//
//  Medium_002_Add_Two_Numbers.swift
//  algorithms
//
//  Created by 李晓东 on 2017/10/10.
//  Copyright © 2017年 XD. All rights reserved.
//
/*
 
 https://oj.leetcode.com/problems/add-two-numbers/
 
 #2 Add Two Numbers
 
 Level: medium
 
 You are given two linked lists representing two non-negative numbers. The digits are stored in reverse order and each of their nodes contain a single digit. Add the two numbers and return it as a linked list.
 
 Input: (2 -> 4 -> 3) + (5 -> 6 -> 4)
 Output: 7 -> 0 -> 8
 
 Inspired by @potpie at https://oj.leetcode.com/discuss/2308/is-this-algorithm-optimal-or-what
 题解：传入两个链表，逐位相加，逢十向后进1
 
 */
class Medium_002_Add_Two_Numbers {
    class ListNode {
        var val: Int
        var next: ListNode?
        init() {
            val = 0
            next = nil
        }
        init(nodeValue: Int, nodeNext: ListNode?) {
            val = nodeValue
            next = nodeNext
        }
    }
    
    static func addNumbers(_ l1: ListNode?,_ l2: ListNode?) -> ListNode? {
        var tmp1: ListNode? = l1
        var tmp2: ListNode? = l2
        let dump: ListNode = ListNode.init()
        var curr: ListNode = dump
        var sum: Int = 0
        
        while tmp1 != nil || tmp2 != nil {
            sum /= 10
            if let n = tmp1 {
                sum += n.val
                tmp1 = n.next
            }
            
            if let n = tmp2 {
                sum += n.val
                tmp2 = n.next
            }
            curr.next = ListNode.init(nodeValue: sum%10, nodeNext: nil)
            if let n = curr.next {
                curr = n
            }
        }
        if  sum/10 == 1 {
            curr.next = ListNode.init(nodeValue: 1, nodeNext: nil)
        }
        return dump.next
    }
    
    static func ali() {
        let l1 = ListNode.init(nodeValue: 3, nodeNext: ListNode.init(nodeValue: 4, nodeNext: ListNode.init(nodeValue: 5, nodeNext: nil)))
        let l2 = ListNode.init(nodeValue: 3, nodeNext: ListNode.init(nodeValue: 4, nodeNext: ListNode.init(nodeValue: 5, nodeNext: nil)))
        let result = addNumbers(l1, l2)
        print(result!)
    }
}
