//
//  ForgotPasswordViewController.swift
//  Granth

import UIKit
import Alamofire
import GoogleMobileAds

class ForgotPasswordViewController: UIViewController, GADBannerViewDelegate {
    
    //     MARK:-
    //     MARK:- Oultlets.
    
    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var btnSendrequest: UIButton!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var constraintHeaderTop: NSLayoutConstraint!
    
    @IBOutlet weak var vwBanner: UIView!
    @IBOutlet weak var constraintVwBannerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var txtEmail: UITextField!
    
    var bannerView: GADBannerView!
    
    //     MARK:-
    //     MARK:- view life cycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.SetUpObject()
    }
    
    //     MARK:-
    //     MARK:- SetUpObject Methods.
    
    func SetUpObject() {
        if #available(iOS 11.0, *) {
            
        } else {
            constraintHeaderTop.constant = UIApplication.shared.statusBarFrame.size.height
        }
        self.lblHeader.text = LanguageLocal.myLocalizedString(key: "FORGOT_PASSWORD")
        viewEmail.layer.cornerRadius = 5.0
        viewEmail.layer.borderColor = UIColor.lightGray.cgColor
        viewEmail.layer.borderWidth = 1.0
        btnSendrequest.layer.cornerRadius = 5.0
        
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
    
    
    //     MARK:-
    //     MARK:- UIButton Click Event.
    
    @IBAction func btnSendrequest(_ sender: Any) {
       ForgotPasswordAPI()
    }
    

    @IBAction func btnBack_Clicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:-
    //MARK:- API Calling..
    
    func ForgotPasswordAPI() {
        THelper.ShowProgress(vc: self)
        let Auth_header = ["Authorization" : "Bearer \(TPreferences.readString(API_TOKEN)!)"]
        
        let param = [EMAIL_ID:  "\(self.txtEmail.text ?? "")"] as [String : Any]
        
        Alamofire.request(TPreferences.getCommonURL(FORGOT_PASSWORD)!,method: .post, parameters: param, encoding: JSONEncoding.default,headers: Auth_header).responseJSON { (response:DataResponse<Any>) in
            switch(response.result) {
            case .success( _):
                THelper.hideProgress(vc: self)
                if let data = response.result.value{
                    print(data)
                    var dicData = NSDictionary()
                    dicData = data as! NSDictionary
                    print(dicData)
                    THelper.toast(dicData.value(forKey: "message") as? String, vc: self)
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
