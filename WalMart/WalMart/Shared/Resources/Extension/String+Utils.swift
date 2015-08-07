//
//  String+Utils.swift
//  SAMS
//
//  Created by Gerardo Ramirez on 06/08/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation



extension String{
    
    //
    var listIconString : String {
        
        if count(self.utf16) <= 1 {
            return self.uppercaseString
        }
        
        var upperCaseTitle  = ""
        let arrayTitle = self.componentsSeparatedByString(" ")
        let arrayTitleResult = arrayTitle.filter {$0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) != ""}
        if(arrayTitleResult.count > 1){
            
            let titleWord1 = arrayTitleResult[0] as NSString
                let titleWord2 = arrayTitleResult[1] as NSString
                
                let resultString1 = titleWord1.substringWithRange(NSRange(location: 0,length: 1))
                let resultString2 = titleWord2.substringWithRange(NSRange(location: 0,length: 1))
                
                let resultTitle = resultString1 + resultString2
                
                upperCaseTitle = resultTitle.uppercaseString
                
            }else{
                let titleWord = arrayTitleResult[0] as NSString
                let resultString = titleWord.substringWithRange(NSRange(location: 0,length: 2))
                upperCaseTitle = resultString.uppercaseString
                
            }
        
        return upperCaseTitle
    }

    var stringByDecodingURLFormat: String {
        var result = self.stringByReplacingOccurrencesOfString("+", withString: " ", options: .LiteralSearch, range: nil)
        result = result.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        return result
    }

    func parametersFromQueryString() -> Dictionary<String, String> {
        var parameters = Dictionary<String, String>()

        let scanner = NSScanner(string: self)

        var key: NSString?
        var value: NSString?

        while !scanner.atEnd {
            key = nil
            scanner.scanUpToString("=", intoString: &key)
            scanner.scanString("=", intoString: nil)

            value = nil
            scanner.scanUpToString("&", intoString: &value)
            scanner.scanString("&", intoString: nil)

            if key != nil && value != nil {
                parameters.updateValue(value! as String, forKey: key! as String)
            }
        }
        
        return parameters
    }

//@implementation NSURL (QueryString)
//
//- (NSMutableDictionary *)dictionaryForQueryString {
//    return [[self query] dictionaryFromQueryStringComponents];
//}
//
//@end


    
}