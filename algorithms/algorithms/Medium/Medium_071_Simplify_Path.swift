//
//  Medium_071_Simplify_Path.swift
//  algorithms
//
//  Created by 李晓东 on 2018/3/27.
//  Copyright © 2018年 XD. All rights reserved.
//

/*
 
 https://leetcode.com/problems/simplify-path/
 
 #71 Simplify Path
 
 Level: medium
 
 Given an absolute path for a file (Unix-style), simplify it.
 
 For example,
 path = "/home/", => "/home"
 path = "/a/./b/../../c/", => "/c"
 
 Corner Cases:
 Did you consider the case where path = "/../"?
 In this case, you should return "/".
 Another corner case is the path might contain multiple slashes '/' together, such as "/home//foo/".
 In this case, you should ignore redundant slashes and return "/home/foo".
 
 Inspired by @monaziyi at https://leetcode.com/discuss/24939/c-10-lines-solution
 
 题解：简化路径
 1.这道题让简化给定的路径，光根据题目中给的那一个例子还真不太好总结出规律，应该再加上两个例子 path = "/a/./b/../c/", => "/c"和path = "/a/./b/c/", => "/a/b/c"， 这样我们就可以知道中间是"."的情况直接去掉，是".."时删掉它上面挨着的一个路径，而下面的边界条件给的一些情况中可以得知，如果是空的话返回"/"，如果有多个"/"只保留一个。那么我们可以把路径看做是由一个或多个"/"分割开的众多子字符串
 
 注意split 函数 与 map函数的耗时会长一点，第二种解法的耗时更短，两者思路其实是一样，都是通过／字符将路径分割成数组，然后遍历元素按顺序放到新的数组中，然后根据上面的规则，如果只有一个. 则pass,如果有两个.. 就将回退一步路径，也就是将数组中的末尾元素移除，最后返回新数组中的元素
 */


import Foundation

struct Medium_071_Simplify_Path {
    
    static func simplifyPath(_ path: String) -> String {
        let arr = path.characters.split(separator: "/").map(String.init)
        var stack = [String]()
        
        for s in arr {
            if s == "" || s == "." { continue }
            if s == ".." { _ = stack.popLast(); continue; }
            stack.append(s)
        }
        return stack.isEmpty ? "/" : "/" + stack.joined(separator:"/")
    }
 
    /*
    static func simplifyPath(_ path: String) -> String {
        var path = path
        path.append("/")
        
        let components = formComponents(fromPath: path)
        
        var parsedComponents: [String] = []
        for component in components {
            if component == "." {
                // skip
            } else if component == ".." {
                parsedComponents.popLast()
            } else {
                parsedComponents.append(component)
            }
        }
        
        var newPath = ""
        for component in parsedComponents {
            newPath.append("/")
            newPath.append(component)
        }
        
        return newPath.isEmpty ? "/" : newPath
    }
    
    static func formComponents(fromPath path: String) -> [String] {
        var components: [String] = []
        var component = ""
        for character in path.characters {
            if character == "/" {
                if !component.isEmpty {
                    components.append(component)
                    component = ""
                }
            } else {
                component.append(character)
            }
        }
        
        if !component.isEmpty {
            components.append(component)
        }
        
        return components
    }
 */
}
