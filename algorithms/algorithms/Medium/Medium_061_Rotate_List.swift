//
//  Medium_061_Rotate_List.swift
//  algorithms
//
//  Created by 李晓东 on 2018/2/5.
//  Copyright © 2018年 XD. All rights reserved.
//

/*
 
 https://leetcode.com/problems/rotate-list/
 
 #62 Rotate List
 
 Level: medium
 
 Given a list, rotate the list to the right by k places, where k is non-negative.
 
 For example:
 Given 1->2->3->4->5->NULL and k = 2,
 return 4->5->1->2->3->NULL.
 
 Inspired by @reeclapple at https://leetcode.com/discuss/9533/share-my-java-solution-with-explanation
 
 题解：链表反转
 1.快慢指针来解，快指针先走k 步，然后两个指针一起走，当快指针走到末尾时，慢指针的下一个位置就是新的顺序的头节点，
 
 */


import Foundation

class Medium_061_Rotate_List {
    class Node {
        var value: Int?
        var next: Node?
    }
    
    class func rotateRight(head: Node?, k: Int) -> Node? {
        if head == nil || head?.next == nil {
            return head
        }
        
        let dummy: Node = Node()
        dummy.next = head
        
        var fast: Node? = dummy
        var slow: Node? = dummy
        
        var i = 0
        while fast?.next != nil {
            fast = fast?.next
            i += 1
        }
        
        let count = i - k%i
        for _ in 0..<count {
            slow = slow?.next
        }
        
        fast?.next = dummy.next
        dummy.next = slow?.next
        slow?.next = nil
        return dummy.next
        
    }
}
