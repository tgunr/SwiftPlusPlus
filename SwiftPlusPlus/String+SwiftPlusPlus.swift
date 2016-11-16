//
//  String+Helpers.swift
//  lists
//
//  Copyright (c) 2014 Drewag, LLC. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

extension String {
    /**
        - parameter times: the number of times to repeat the string

        - returns: a string by repeating it 'times' times
    */
    public func stringByRepeatingNTimes(_ times: Int, separator: String = "") -> String {
        var result = ""
        for i in 0..<times {
            result += self
            if i < times - 1 {
                result += separator
            }
        }
        return result
    }

    public func substringFromIndex(_ fromIndex: Int) -> String {
        let first = self.startIndex
        let i = self.index(first, offsetBy: fromIndex)
        return self.substring(from: i)
    }

    public func substringToIndex(_ toIndex: Int) -> String {
        let first = self.startIndex
        let i = self.index(first, offsetBy: toIndex)
        return self.substring(to: i)
    }

    public var isValidEmail: Bool {
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"

        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
}

public func /(lhs: String, rhs: String) -> String {
    return (lhs as NSString).appendingPathComponent(rhs)
}
