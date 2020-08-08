//
//  AboutViewController.swift
//  Granth

import UIKit
import GoogleMobileAds

class AboutViewController: UIViewController, GADInterstitialDelegate {

//        MARK:-
//        MARK:- Outlets.
    
    @IBOutlet weak var constraintHeaderTop: NSLayoutConstraint!
    
    @IBOutlet weak var btnGranth: UIButton!
    
//        MARK:-
//        MARK:- Variables.
    
    var attrs = [NSAttributedString.Key.foregroundColor : UIColor.black,
        NSAttributedString.Key.underlineStyle : 1] as [NSAttributedString.Key : Any] as [NSAttributedString.Key : Any]
    var attributedString = NSMutableAttributedString(string:"")
    
    var interstitial: GADInterstitial!

//        MARK:-
//        MARK:- View Life Cycles.

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.SetUpObject()
    }
    
//        MARK:-
//        MARK:- SetUpObject Methods.
    
    func SetUpObject() {
        if #available(iOS 11.0, *) {
            
        } else {
            constraintHeaderTop.constant = UIApplication.shared.statusBarFrame.size.height
        }
        
        let buttonTitleStr = NSMutableAttributedString(string:"Granth", attributes:attrs)
        attributedString.append(buttonTitleStr)
        btnGranth.setAttributedTitle(attributedString, for: .normal)
        
        interstitial = GADInterstitial(adUnitID: INTERSTITIAL_ID)
        let request = GADRequest()
        interstitial.load(request)
        interstitial.delegate = self
    }
    
    //MARK:-
    //MARK:- GADInterstitialDelegate
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        interstitial.present(fromRootViewController: self)
    }
    
    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    //        MARK:-
    //        MARK:- UIButton Clicked Events.
    
    @IBAction func btnBack_Clicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnGranth_Clicked(_ sender: Any) {
        guard let url = URL(string: "https://www.google.com") else { return }
        UIApplication.shared.open(url)
    }
}
