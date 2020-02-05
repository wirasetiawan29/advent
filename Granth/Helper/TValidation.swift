//
//  TValidation.swift

import UIKit

class TValidation {
    
    class func isValidEmail(_ checkString: String?) -> Bool {
        if checkString == nil || (checkString == "") {
            return false
        }
        if checkString?.contains("..") ?? false {
            return false
        }
        if checkString?.contains(".@") ?? false {
            return false
        }
        if (((checkString as NSString?)?.substring(to: 1)) == ".") {
            return false
        }
        let regex = "[a-zA-Z0-9+._%-+]{1,256}\\@[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}(\\.[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25})+"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        if !(predicate.evaluate(with: checkString) == true) {
            return false
        }
        return true
    }

    class func isAlphaNumeric(_ checkString: String?) -> Bool {
        return Int((checkString as NSString?)?.range(of: "^[a-zA-Z0-9]+$", options: .regularExpression).location ?? 0) != NSNotFound
    }
    
    class func isAlphaNumeric(withDotAndSpace checkString: String?) -> Bool {
        return Int((checkString as NSString?)?.range(of: "^[a-zA-Z0-9. ]+$", options: .regularExpression).location ?? 0) != NSNotFound
    }
    
    class func isAlphabaticOnly(_ checkString: String?) -> Bool {
        return Int((checkString as NSString?)?.range(of: "^[a-zA-Z ]+$", options: .regularExpression).location ?? 0) != NSNotFound
    }
    
    class func isNumericOnly(_ checkString: String?) -> Bool {
        return Int((checkString as NSString?)?.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted).location ?? 0) == NSNotFound
    }
    
    class func isNumericOnly(withDot checkString: String?) -> Bool {
        return Int((checkString as NSString?)?.range(of: "^[0-9]\\d*(\\.\\d+)?$", options: .regularExpression).location ?? 0) != NSNotFound
    }
    
    class func compare(_ text1: String?, string text2: String?) -> Bool {
        return text1 == text2
    }
    
    class func checkStringGreaterThan(_ string: String?, length: Int) -> Bool {
        return (string?.count ?? 0) > length
    }
    
    class func isNull(_ object: Any?) -> Bool {
        return object is NSNull
    }
    
    class func isString(_ object: Any?) -> Bool {
        return object is String
    }
    
    class func isDictionary(_ object: Any?) -> Bool {
        return object is NSDictionary
    }
    
    class func isArray(_ object: Any?) -> Bool {
        return object is NSArray
    }
    
    class func validateUrl(_ string: String?) -> Bool {
        if string == nil {
            return false
        }
        let urlRegEx = "^(http(s)?://)?((www)?\\.)?[\\w]+\\.[\\w]+"
        let urlTest = NSPredicate(format: "SELF MATCHES %@", urlRegEx)
        return urlTest.evaluate(with: string)
    }
    
    class func isValidURL(_ string: String?) -> Bool {
        if string == nil {
            return false
        }
        var isValidURL = false
        let candidateURL = URL(string: string ?? "")
        if candidateURL != nil && candidateURL?.scheme != nil && candidateURL?.host != nil {
            isValidURL = true
        }
        return isValidURL
    }

    class func isHavingSpace(_ string: String?) -> Bool {
        if string == nil {
            return false
        }
        if string?.contains(" ") ?? false {
            return false
        }
        return true
    }    
}
