//
//  FeedbackViewController.swift
//  Granth

import UIKit
import Alamofire
import GoogleMobileAds

class FeedbackViewController: UIViewController, GADBannerViewDelegate {

    //     MARK:-
    //     MARK:- Oultlets.
    
    @IBOutlet weak var vwName: UIView!
    @IBOutlet weak var vwEmail: UIView!
    @IBOutlet weak var vwMsg: UIView!
    
    @IBOutlet weak var vwBanner: UIView!
    @IBOutlet weak var constraintVwBannerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var constraintHeaderTop: NSLayoutConstraint!
    
    @IBOutlet weak var btnFeedback: UIButton!
    
    @IBOutlet weak var txtvwMsg: UITextView!
    
    @IBOutlet weak var txtMsg: UITextView!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtName: UITextField!
    
    var bannerView: GADBannerView!
    
    //     MARK:-
    //     MARK:- view life cycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()
       SetUpObject()
    }
    
//     MARK:-
//     MARK:- SetUpObject Methods.
    
    func SetUpObject() {
        if #available(iOS 11.0, *) {
            
        } else {
            constraintHeaderTop.constant = UIApplication.shared.statusBarFrame.size.height
        }
        
        if TPreferences.readBoolean(IS_LOGINING) {
            self.txtEmail.text = TPreferences.readString(EMAIL)
            self.txtName.text = TPreferences.readString(NAME)
        }else {
            self.txtEmail.text = ""
            self.txtName.text = ""
        }
        
        vwName.layer.cornerRadius = 5.0
        vwEmail.layer.cornerRadius = 5.0
        vwMsg.layer.cornerRadius = 5.0
        btnFeedback.layer.cornerRadius = 5.0
        
        vwName.layer.borderColor = UIColor.lightGray.cgColor
        vwName.layer.borderWidth = 1.0
        vwEmail.layer.borderColor = UIColor.lightGray.cgColor
        vwEmail.layer.borderWidth = 1.0
        vwMsg.layer.borderColor = UIColor.lightGray.cgColor
        vwMsg.layer.borderWidth = 1.0
        
        txtvwMsg.text = "Message"
        txtvwMsg.textColor = UIColor.lightGray
        
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
    
    @IBAction func btnFeedback_Clicked(_ sender: Any) {
       self.FeedBackAPI()
    }
    
    @IBAction func btnBack_Cicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:-
    //MARK:- API Calling..
    
    func FeedBackAPI() {
        THelper.ShowProgress(vc: self)
        let Auth_header = ["Authorization" : "Bearer \(TPreferences.readString(API_TOKEN)!)"]
        
        let param = [EMAIL: TPreferences.readString(EMAIL) ?? "",
                     NAME: TPreferences.readString(NAME) ?? "",
                     COMMENT: self.txtMsg.text ?? ""
            ] as [String : Any]
        
        Alamofire.request(TPreferences.getCommonURL(ADD_FEEDBACK)!,method: .post, parameters: param, encoding: JSONEncoding.default,headers: Auth_header).responseJSON { (response:DataResponse<Any>) in
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
