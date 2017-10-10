//
//  Medium_002_Add_Two_Numbers.swift
//  algorithms
//
//  Created by 李晓东 on 2017/10/10.
//  Copyright © 2017年 XD. All rights reserved.
//

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
    
    static func addNumbers(_ node1: ListNode?, node2: ListNode?) -> ListNode? {
        var tmp1: ListNode? = node1
        var tmp2: ListNode? = node2
        let dump: ListNode = ListNode()
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
}
