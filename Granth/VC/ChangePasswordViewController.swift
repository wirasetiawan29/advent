//
//  ChangePasswordViewController.swift
//  Granth

import UIKit
import  Alamofire
import GoogleMobileAds

class ChangePasswordViewController: UIViewController, GADBannerViewDelegate {
    
//        MARK:-
//        MARK:- Outlets.
    
    @IBOutlet weak var vwOldPassword: UIView!
    @IBOutlet weak var vwNewPassword: UIView!
    @IBOutlet weak var vwConfirmPassword: UIView!
    
    @IBOutlet weak var btnChangePassword: UIButton!
    
    @IBOutlet weak var vwBanner: UIView!
    @IBOutlet weak var constraintVwBannerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var txtOldPassword: UITextField!
    @IBOutlet weak var txtNewPassword: UITextField!
    @IBOutlet weak var txtReEnterPassword: UITextField!
    
    @IBOutlet weak var constraintHeightArea: NSLayoutConstraint!
    
    var bannerView: GADBannerView!
    
//        MARK:-
//        MARK:- View Life Cycles.
    
    override func viewDidLoad() {
        super.viewDidLoad()
      self.SetUpObject()
    }

    
//        MARK:-
//        MARK:- SetUpObject Methods.
    
    func SetUpObject() {
        if #available(iOS 11.0, *) {
            
        } else {
            self.constraintHeightArea.constant = UIApplication.shared.statusBarFrame.size.height
        }
        
        vwOldPassword.layer.cornerRadius = 5.0
        vwNewPassword.layer.cornerRadius = 5.0
        vwConfirmPassword.layer.cornerRadius = 5.0
        btnChangePassword.layer.cornerRadius = 5.0
        vwOldPassword.layer.borderColor = UIColor.lightGray.cgColor
        vwOldPassword.layer.borderWidth = 1.0
        vwNewPassword.layer.borderColor = UIColor.lightGray.cgColor
        vwNewPassword.layer.borderWidth = 1.0
        vwConfirmPassword.layer.borderColor = UIColor.lightGray.cgColor
        vwConfirmPassword.layer.borderWidth = 1.0
        
        self.btnChangePassword.setTitle(LanguageLocal.myLocalizedString(key: "CHANGE_PASSWORD"), for: .normal)
        
        if IPAD {
            bannerView = GADBannerView(adSize: kGADAdSizeFullBanner)
        }
        else {
            bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        }
        bannerView.adUnitID = BANNER_ID
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
    }
    
    //     MARK:-
    //     MARK:- GADBannerViewDelegate
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        if IPAD {
            constraintVwBannerHeight.constant = 60
        }
        else {
            constraintVwBannerHeight.constant = 50
        }
        vwBanner.addSubview(bannerView)
    }
    
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        constraintVwBannerHeight.constant = 0
    }
    
//        MARK:-
//        MARK:- UIButton Clicked Events
    
    @IBAction func btnBack_clicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func btnChangePassword_Clicked(_ sender: Any) {
        if txtOldPassword.text == "\(TPreferences.readString(PASSWORD) ?? "")" {
            if self.txtNewPassword.text!.count >= 6 {
                if txtNewPassword.text != "\(TPreferences.readString(PASSWORD) ?? "")" {
                    if self.txtNewPassword.text == self.txtReEnterPassword.text {
                        ChangePasswordAPI()
                    }else{
                        THelper.toast("Password does not match.", vc: self)
                    }
                }
                else {
                    THelper.toast("New password should not be equal to old password.", vc: self)
                }
            }else {
                THelper.toast("Password should contain atleast 6 characters.", vc: self)
            }
        }
        else {
            THelper.toast("Existing password does not match.", vc: self)
        }
    }
    
    //MARK:-
    //MARK:- API Calling..
    
    func ChangePasswordAPI() {
        THelper.ShowProgress(vc: self)
        let Auth_header = ["Authorization" : "Bearer \(TPreferences.readString(API_TOKEN)!)"]
        
        let param = [EMAIL_ID: TPreferences.readString(EMAIL) ?? "",
                     OLD_PASSWORD: txtOldPassword.text ?? "",
                     NEW_PASSWORD: txtNewPassword.text ?? ""
            ] as [String : Any]
        
        Alamofire.request(TPreferences.getCommonURL(CHANGE_PASSWORD)!,method: .post, parameters: param, encoding: JSONEncoding.default,headers: Auth_header).responseJSON { (response:DataResponse<Any>) in
            switch(response.result) {
            case .success( _):
                THelper.hideProgress(vc: self)
                if let data = response.result.value{
                    print(data)
                    var dicData = NSDictionary()
                    dicData = data as! NSDictionary
                    print(dicData)
                    THelper.toast(dicData.value(forKey: "message") as? String, vc: self)
                    self.navigationController?.popViewController(animated: true)
                }
                break
                
            case .failure(_):
                THelper.hideProgress(vc: self)
                THelper.toast(response.result.error?.localizedDescription ?? "Something went wrong", vc: self)
                print(response.result.error?.localizedDescription ?? "Something went wrong")
                break
            }
        }
    }
}
