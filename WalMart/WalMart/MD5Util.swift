//
//  MD5Util.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 3/3/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

func delay(_ seconds: Double, completion:@escaping ()->()) {
    let popTime = DispatchTime.now() + Double(Int64(Double(NSEC_PER_SEC) * seconds)) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: popTime) { 
        completion()
    }
}

extension Data {
    func MD5() -> NSString {
        let digestLength = Int(CC_MD5_DIGEST_LENGTH)
        let md5Buffer = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLength)
        
        CC_MD5(bytes, CC_LONG(count), md5Buffer)
        let output = NSMutableString(capacity: Int(CC_MD5_DIGEST_LENGTH * 2))
        for i in 0..<digestLength {
            output.appendFormat("%02x", md5Buffer[i])
        }
        
        return NSString(format: output)
    }
}

extension NSString {
    func MD5() -> NSString {
        let digestLength = Int(CC_MD5_DIGEST_LENGTH)
        let md5Buffer = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLength)
        CC_MD5(utf8String, CC_LONG(strlen(utf8String)), md5Buffer)
        
        let output = NSMutableString(capacity: Int(CC_MD5_DIGEST_LENGTH * 2))
        for i in 0..<digestLength {
            output.appendFormat("%02x", md5Buffer[i])
        }
        
        return NSString(format: output)
    }
}

extension String {
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
    
    func toIntNoDecimals() -> Int? {
        var checkedString = self
        if let dotRange = checkedString.range(of: ".") {
            checkedString.removeSubrange(dotRange.lowerBound..<checkedString.endIndex)
        }
        return Int(checkedString)
    }
    
}
