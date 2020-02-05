//
//  THelper.swift

import Foundation
import UIKit
import FCAlertView
import Alamofire
import MBProgressHUD
import Toast_Swift
import SDWebImage

let MSG_REQUEST_PROGRESS = "Request in process"

class THelper {
    
    class func setTintColor(_ imageView: UIImageView?, tintColor color: UIColor?) -> UIImageView? {
        imageView?.image = imageView?.image?.withRenderingMode(.alwaysTemplate)
        if let aColor = color {
            imageView?.tintColor = aColor
        }
        return imageView
    }
    
    class func setButtonTintColor(_ button: UIButton?, imageName: String?, state: UIControl.State, tintColor color: UIColor?) -> UIButton? {
        button?.setImage((UIImage(named: imageName ?? ""))?.withRenderingMode(.alwaysTemplate), for: state)
        button?.tintColor = color
        return button
    }
    
    class func removeSpecialCharactersAndAlphabatics(_ string: String?) -> String? {
        let notAllowedChars = CharacterSet(charactersIn: "0123456789").inverted
        return string?.components(separatedBy: notAllowedChars).joined(separator: "")
    }
    
    class func removeWhitespaceAndNewline(_ string: String?) -> String? {
        if string == nil {
            return ""
        }
        print(string?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? "")
        let replaced = string?.trimmingCharacters(in: NSCharacterSet.whitespaces)
        return replaced
//        return string?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    class func displayAlert(_ view: UIViewController?, title: String?, message: String?) {
        let alert = FCAlertView()
        alert.titleFont = UIFont(name: PRIMARY_FONT, size: CGFloat(SIZE_MEDIUM))
        alert.subtitleFont = UIFont(name: PRIMARY_FONT, size: CGFloat(SIZE_SMALL))
        alert.titleColor = UIColor.primaryColor()
        alert.doneButtonTitleColor = UIColor.primaryColor()
        alert.showAlert(inView: view, withTitle: title, withSubtitle: message, withCustomImage: nil, withDoneButtonTitle: "OK", andButtons: nil)
    }
    
    class func displayAlert(_ view: UIViewController?, title: String?, message: String?, tag: Int, firstButton: String?, doneButton: String?) {
        let alert = FCAlertView()
        alert.titleFont = UIFont(name: PRIMARY_FONT, size: CGFloat(SIZE_MEDIUM))
        alert.subtitleFont = UIFont(name: PRIMARY_FONT, size: CGFloat(SIZE_SMALL))
        alert.titleColor = UIColor.primaryColor()
        alert.doneButtonTitleColor = UIColor.primaryColor()
        alert.firstButtonTitleColor = UIColor.primaryColor()
        alert.tag = tag
        alert.delegate = view as? FCAlertViewDelegate
        alert.showAlert(inView: view, withTitle: title, withSubtitle: message, withCustomImage: nil, withDoneButtonTitle: doneButton, andButtons: [firstButton as Any])
        //    [alert addButton:firstButton withActionBlock:nil];
    }
    
    class func displayImage(_ vc: UIViewController?, imageView: UIImageView?) {
        // Create image info
        let imageInfo = JTSImageInfo()
        imageInfo.image = imageView?.image
        imageInfo.referenceRect = (imageView?.frame)!
        imageInfo.referenceView = imageView?.superview
        imageInfo.referenceContentMode = (imageView?.contentMode)!
        imageInfo.referenceCornerRadius = (imageView?.layer.cornerRadius)!
        // Setup view controller
        let imageView = JTSImageViewController(imageInfo: imageInfo, mode: JTSImageViewControllerMode.image, backgroundStyle: JTSImageViewControllerBackgroundOptions.blurred)
        // Present the view controller.
        imageView?.show(from: vc, transition: JTSImageViewControllerTransition.fromOriginalPosition)
    }
    
    class func toast(_ message: String? , vc: UIViewController) {
//        iToast.makeText(message).setDuration(1000).show()
        vc.view.makeToast(message)
    }
    
    class func convertLocalDatetoSeraverDate(_ strdate: String?) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        let datecurrunt = strdate
        let date: Date? = dateFormatter.date(from: datecurrunt ?? "")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let aDate = date {
            return dateFormatter.string(from: aDate)
        }
        return nil
    }
    
//    convert string to dictionary
    
     class func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    //convert server date to local UserFormated Date
    
    class func convertLocaldate(_ str: String?) -> String? {
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let date: Date? = dateFormatter1.date(from: str ?? "")
        
        let currentTimeZone = NSTimeZone.local as NSTimeZone //Local time zone
        let utcTimeZone = NSTimeZone(abbreviation: "UTC")
        
        var currentGMTOffset: Int? = nil
        if let aDate = date {
            currentGMTOffset = currentTimeZone.secondsFromGMT(for: aDate)
        }
        var gmtOffset: Int? = nil
        if let aDate = date {
            gmtOffset = utcTimeZone?.secondsFromGMT(for: aDate)
        }
        let gmtInterval = TimeInterval((currentGMTOffset ?? 0) - (gmtOffset ?? 0))
        
        var destinationDate: Date? = nil
        if let aDate = date {
            destinationDate = Date(timeInterval: gmtInterval, since: aDate)
        }
        let dateFormatters = DateFormatter()
        dateFormatters.dateFormat = "dd/MM/yyyy"
        dateFormatters.timeZone = NSTimeZone.system
        if let aDate = destinationDate {
            return dateFormatters.string(from: aDate)
        }
        return nil
    }
    
    class func convertLocaldateServerdate(_ str: String?) -> String? {
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "dd/MM/yyyy"
        let date: Date? = dateFormatter1.date(from: str ?? "")
        
        let currentTimeZone = NSTimeZone.local as NSTimeZone //Local time zone
        let utcTimeZone = NSTimeZone(abbreviation: "UTC")
        
        var currentGMTOffset: Int? = nil
        if let aDate = date {
            currentGMTOffset = currentTimeZone.secondsFromGMT(for: aDate)
        }
        var gmtOffset: Int? = nil
        if let aDate = date {
            gmtOffset = utcTimeZone?.secondsFromGMT(for: aDate)
        }
        let gmtInterval = TimeInterval((currentGMTOffset ?? 0) - (gmtOffset ?? 0))
        
        var destinationDate: Date? = nil
        if let aDate = date {
            destinationDate = Date(timeInterval: gmtInterval, since: aDate)
        }
        let dateFormatters = DateFormatter()
        dateFormatters.dateFormat = "yyyy-MM-dd hh:mm:ss"
        dateFormatters.timeZone = NSTimeZone.system
        if let aDate = destinationDate {
            return dateFormatters.string(from: aDate)
        }
        return nil
    }
    
    class func convert24Hours(_ str12Time: String?) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        let date: Date? = dateFormatter.date(from: str12Time ?? "")
        
        dateFormatter.dateFormat = "HH:mm:ss"
        if let aDate = date {
            return dateFormatter.string(from: aDate)
        }
        return nil
    }
    
    class func convert12Hours(_ str24Time: String?) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let date: Date? = dateFormatter.date(from: str24Time ?? "")
        
        dateFormatter.dateFormat = "hh:mm a"
        if let aDate = date {
            return dateFormatter.string(from: aDate)
        }
        return nil
    }

    class func dateFormatter(_ date1: String?, format1: String?, format2: String?) -> String? {
        var dateFormatter = DateFormatter() // here we create NSDateFormatter object for change the Format of date..
        dateFormatter.dateFormat = format1 ?? "" //// here set format of date which is in your output date (means above str with format)
        
        let date: Date? = dateFormatter.date(from: date1 ?? "") // here you can fetch date from string with define format
        
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format2 ?? "" // here set format which you want...
        
        if let aDate = date {
            return dateFormatter.string(from: aDate)
        }
        return nil
    }

    class func setImageName() -> String? {
        //    return [NSString stringWithFormat:@"IMG_%d.JPG",(int)([[NSDate date] timeIntervalSince1970]*10.0)];
        let y = Double(Date().timeIntervalSince1970) * 11
        var strDouble = "\(y)"
        let arr = strDouble.components(separatedBy: ".")
        if !(arr.isEmpty) && arr.count > 1 {
            strDouble = strDouble.replacingOccurrences(of: ".", with: "")
        }
        return "IMG_\(strDouble).JPG"
    }
    
    class func setImageName(name :String) -> String? {
        let y = Double(Date().timeIntervalSince1970) * 11
        var strDouble = "\(y)"
        let arr = strDouble.components(separatedBy: ".")
        if !(arr.isEmpty) && arr.count > 1 {
            strDouble = strDouble.replacingOccurrences(of: ".", with: "")
        }
        return "IMG_\(name)_\(strDouble).JPG"
    }
    
    class func compressImageFromSize(image: UIImage?) -> Data? {
        var compression: CGFloat = 0.9
        let maxCompression: CGFloat = 0.1
        let maxFileSize: Int = 100 * 1024
        var imageData:Data = image!.jpegData(compressionQuality: compression)!
        print(String(format: "%lu", UInt(imageData.count )))
        while (imageData.count ) > maxFileSize && compression > maxCompression {
            compression -= 0.1
            imageData =  image!.jpegData(compressionQuality: compression)!
        }
        print(String(format: "%lu", UInt(imageData.count )))
        return imageData
    }
    
    class func setDocumentName(extantion :String) -> String! {

            let y = Double(Date().timeIntervalSince1970) * 11
            var strDouble = "\(y)"
            let arr = strDouble.components(separatedBy: ".")
            if arr.count > 1 {
                strDouble = strDouble.replacingOccurrences(of: ".", with: "")
            }
            return "Attachment_\(strDouble).\(extantion)"
    }
    
//    convert date format in only date and month
    class func convertdatetoonlyDM(_ strdate: String?) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let datecurrunt = strdate
        let date: Date? = dateFormatter.date(from: datecurrunt ?? "")
        dateFormatter.dateFormat = "dd/MM"
        if let aDate = date {
            return dateFormatter.string(from: aDate)
        }
        return nil
    }
    
    class func ShowProgress(vc: UIViewController) {
        let hud = MBProgressHUD.showAdded(to: vc.view, animated: true)
        hud.mode = .indeterminate
        hud.label.text = MSG_REQUEST_PROGRESS
    }
    
    class func hideProgress(vc: UIViewController) {
        _ = MBProgressHUD.hide(for: vc.view, animated: true)
    }
    
    class func setImage(img :UIImageView, url :URL, placeholderImage :String){
        img.sd_setImage(with: url, placeholderImage: UIImage(named:
            placeholderImage))
    }
    
    class func attributeText(price: String) -> NSMutableAttributedString {
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: price)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        
        return attributeString
    }
    
    class func plist(type: String) -> NSMutableDictionary? {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let path = "\(paths)/\(type).plist"
        let fileManager = FileManager.default
        if (!(fileManager.fileExists(atPath: path))) {
            let bundle : NSString = Bundle.main.path(forResource: "\(type)", ofType: "plist")! as NSString
            do {
                try fileManager.copyItem(atPath: bundle as String, toPath: path)
            } catch {
                print("copy failure.")
            }
        }
        else{
            print("file \(type).plist not found.")
        }
        
        let resultDictionary = NSMutableDictionary(contentsOfFile: path)
        return resultDictionary
    }
    
    class func writeToFile(type: String, resultDictionary: NSMutableDictionary?) {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let path = "\(paths)/\(type).plist"
        
        resultDictionary?.write(toFile: path, atomically: true)
    }
    
    class func getAppVersion() -> String {
        let appVersion:String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        return appVersion
    }
    
    class func getAppName() -> String {
        let appName:String = Bundle.main.infoDictionary!["CFBundleName"] as! String
        return appName
    }
    
    class func openLink(url:String) {
        guard let url = URL(string: url) else { return }
        UIApplication.shared.open(url)
    }
    
    class func setShadow(view:UIView) {
        view.layer.shadowColor   = UIColor.lightGray.cgColor;
        view.layer.shadowRadius  = 1.0;
        view.layer.shadowOpacity = 0.5;
        view.layer.shadowOffset  = CGSize(width: 1.0, height: 3.0);
        view.layer.masksToBounds = false;
    }
    
    class func rectForText(text: String, font: UIFont, maxSize: CGSize) -> CGSize {
        let attrString = NSAttributedString.init(string: text, attributes: [NSAttributedString.Key.font:font])
        let rect = attrString.boundingRect(with: maxSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        let size = CGSize(width: rect.size.width, height: rect.size.height)
        return size
    }
    
    class func setHeaderShadow(view:UIView) {
        view.layer.shadowColor   = UIColor.lightGray.cgColor;
        view.layer.shadowRadius  = 1.0;
        view.layer.shadowOpacity = 0.5;
        view.layer.shadowOffset  = CGSize(width: 0.0, height: 3.0);
        view.layer.masksToBounds = false;
    }
}
