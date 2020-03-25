//
//  ReViewViewController.swift
//  Granth

import UIKit
import Alamofire
import GoogleMobileAds

class ReViewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {
    
    //        MARK:-
    //        MARK:- Outlets
    
    @IBOutlet weak var tblReview: UITableView!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var constraintTblReviewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var constraintHeaderTop: NSLayoutConstraint!
    
    @IBOutlet weak var vwBanner: UIView!
    @IBOutlet weak var constraintVwBannerHeight: NSLayoutConstraint!
    
    //        MARK:-
    //        MARK:- Variables
    
    var strBookId = String()
    var arrReview = NSArray()
    
    var bannerView: GADBannerView!
    
    //        MARK:-
    //        MARK:- UIView Life Cycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetUpObject()
    }
    
    //        MARK:-
    //        MARK:- SetUpObject Methods.
    
    func SetUpObject() {
        if #available(iOS 11.0, *) {
            
        } else {
            constraintHeaderTop.constant = UIApplication.shared.statusBarFrame.size.height
        }
        self.getReviewAPI(strBookId: strBookId)
        
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
    
    //MARK:-
    //MARK:- UITableview Delegate & Data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        constraintTblReviewHeight.constant = CGFloat(arrReview.count * 85)
        return arrReview.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tblReview.register(UINib(nibName: "TopReviewsTableCell", bundle: nil), forCellReuseIdentifier: "ReviewCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! TopReviewsTableCell
        
        let dicBookRating: NSDictionary = arrReview[indexPath.row] as! NSDictionary
        cell.lblName.text = "\(dicBookRating.value(forKey: USER_NAME) ?? "")"
        cell.lblComment.text = "\(dicBookRating.value(forKey: REVIEW) ?? "")"
        cell.lblDate.text = "\(dicBookRating.value(forKey: CREATED_AT) ?? "")"
        if TValidation.isNull((dicBookRating.value(forKey: PROFILE_IMAGE))) {
            cell.imgReviewer.image = UIImage(named: PLACEHOLDERIMAGE)
        }else {
            THelper.setImage(img: cell.imgReviewer, url: URL(string: "\(dicBookRating.value(forKey: PROFILE_IMAGE) ?? PROFILE_IMAGE)")!, placeholderImage: PLACEHOLDERIMAGE)
        }
        cell.vwRating.rating = dicBookRating.value(forKey: RATING) as! Double
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    //MARK:-
    //MARK:- UIButton Clicked Events.
    
    @IBAction func btnBack_Clicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:-
    //MARK:- API Calling..
    
    func getReviewAPI(strBookId: String) {
        THelper.ShowProgress(vc: self)
        let param = [BOOK_ID:strBookId]
        Alamofire.request(TPreferences.getCommonURL(BOOK_RATING_LIST)!,method: .post, parameters: param, encoding: JSONEncoding.default,headers: nil).responseJSON { (response:DataResponse<Any>) in
            switch(response.result) {
            case .success( _):
                THelper.hideProgress(vc: self)
                if let data = response.result.value{
                    print(data)
                    var dicData = NSDictionary()
                    dicData = data as! NSDictionary
                    var arrTemp = NSArray()
                    arrTemp = dicData.allValues as NSArray
                    self.arrReview = arrTemp [0] as! NSArray
                    self.tblReview.reloadData()
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
