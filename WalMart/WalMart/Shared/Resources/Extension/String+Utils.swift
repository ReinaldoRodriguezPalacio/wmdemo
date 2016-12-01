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
        
        if self.utf16.count <= 1 {
            return self.uppercased()
        }
        
        var upperCaseTitle  = ""
        let arrayTitle = self.components(separatedBy: " ")
        let arrayTitleResult = arrayTitle.filter {$0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != ""}
        if(arrayTitleResult.count > 1){
            
            let titleWord1 = arrayTitleResult[0] as NSString
                let titleWord2 = arrayTitleResult[1] as NSString
                
                let resultString1 = titleWord1.substring(with: NSRange(location: 0,length: 1))
                let resultString2 = titleWord2.substring(with: NSRange(location: 0,length: 1))
                
                let resultTitle = resultString1 + resultString2
                
                upperCaseTitle = resultTitle.uppercased()
                
            }else{
                let titleWord = arrayTitleResult[0] as NSString
                let resultString = titleWord.substring(with: NSRange(location: 0,length: 2))
                upperCaseTitle = resultString.uppercased()
                
            }
        
        return upperCaseTitle
    }

    var stringByDecodingURLFormat: String {
        var result = self.replacingOccurrences(of: "+", with: " ", options: .literal, range: nil)
        result = result.replacingPercentEscapes(using: String.Encoding.utf8)!
        return result
    }

    func parametersFromQueryString() -> Dictionary<String, String> {
        var parameters = Dictionary<String, String>()

        let scanner = Scanner(string: self)

        var key: NSString?
        var value: NSString?

        while !scanner.isAtEnd {
            key = nil
            scanner.scanUpTo("=", into: &key)
            scanner.scanString("=", into: nil)

            value = nil
            scanner.scanUpTo("&", into: &value)
            scanner.scanString("&", into: nil)

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
