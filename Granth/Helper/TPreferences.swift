//
//  TPreferences.swift

import Foundation

let WALKTHROUGH = "walk_through"
let USER_ID = "user_id"
var IS_LOGINING = "is_Login"
let UDID = "Device_id"
let API_TOKEN = "api_token"
let CONTACT_NUMBER = "contact_number"
let EMAIL = "email"
let USERNAME = "username"
let WISHLIST_TOTAL_ITEM = "wishlist_total_item"
let CART_TOTAL_ITEM = "cart_total_item"
let PASSWORD = "password"
let REMEMBER = "remeber"
let AUTHKEY = ""
let PAYTM = "paytm"

class TPreferences {
    
    class func getURLString(_ urlString: String?) -> String? {
        print("\(BASEURL + ("user" + (urlString ?? "")))")
        return BASEURL + ("user" + (urlString ?? ""))
    }

    class func getCommonURL(_ urlString: String?) -> String? {
        print("\(BASEURL + (urlString ?? ""))")
        return BASEURL + (urlString ?? "")
    }
    
    class func readString(_ key: String?) -> String? {
        var value = UserDefaults.standard.string(forKey: key ?? "")
        if value == nil {
            value = ""
        }
        return value
    }
    
    class func writeString(_ key: String?, value: String?) {
        if value == nil {
            UserDefaults.standard.setValue("", forKey: key!)
            return
        }
        UserDefaults.standard.setValue(value, forKey: key!)
    }
    
    class func writeObject(_ key: String?, value: Any?) {
        if value == nil {
            UserDefaults.standard.set("", forKey: key ?? "")
            return
        }
        let myData = NSKeyedArchiver.archivedData(withRootObject: value!)
        UserDefaults.standard.set(myData, forKey: key ?? "")
    }
    
    class func readObject(_ key: String?) -> Any? {
        let recovedUserJsonData = UserDefaults.standard.object(forKey: key ?? "")
        if recovedUserJsonData == nil {
            return ""
        }
        else {
            var value = NSKeyedUnarchiver.unarchiveObject(with: recovedUserJsonData as! Data)
            if value == nil {
                value = ""
            }
            return value
        }
    }
    
    class func removePreference(_ key: String?) {
        UserDefaults.standard.removeObject(forKey: key ?? "")
    }
    
    class func readBoolean(_ key: String?) -> Bool {
        let value: Bool = UserDefaults.standard.bool(forKey: key ?? "")
        return value
    }
    
    class func writeBoolean(_ key: String?, value: Bool) {
        UserDefaults.standard.set(value, forKey: key ?? "")
    }
    
}
