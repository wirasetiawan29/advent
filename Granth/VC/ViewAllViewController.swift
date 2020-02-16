//
//  ViewAllViewController.swift
//  Granth

import UIKit
import Alamofire
import GoogleMobileAds

class ViewAllViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, GADBannerViewDelegate {
    
    //MARK:-
    //MARK:- Outlet
    
    @IBOutlet weak var vwHeader: UIView!
    @IBOutlet weak var lblHeaderTitle: UILabel!
    @IBOutlet weak var cvBooks: UICollectionView!
    @IBOutlet weak var lblTotalCartItem: UILabel!
    @IBOutlet weak var vwNoRecord: UIView!
    
    @IBOutlet weak var vwBanner: UIView!
    @IBOutlet weak var constraintVwBannerHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintHeaderTop: NSLayoutConstraint!
    
    //MARK:-
    //MARK:- Variables
    
    var StrHeader = String()
    var strType = String()
    var strCat_id = String()
    var arrTopSearchBook = NSArray()
    
    var bannerView: GADBannerView!
    
    //MARK:-
    //MARK:- View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetUpObject()
    }
    
    //MARK:-
    //MARK:- SetUpObject Method
    
    func SetUpObject() {
        if #available(iOS 11.0, *) {
            
        } else {
            constraintHeaderTop.constant = UIApplication.shared.statusBarFrame.size.height
        }
        self.lblHeaderTitle.text = StrHeader
        if StrHeader == "Top Search Books" {
            getDashboardDetailsAPI(type: "\(TOP_SEARCH_BOOK_KEY)" as NSString, cat_id: "")
        }else if StrHeader == "Popular Books" {
            getDashboardDetailsAPI(type: "\(POPULAR_BOOK_KEY)" as NSString, cat_id: "")
        }else if StrHeader == "Recommanded Books" {
            getDashboardDetailsAPI(type: "\(RECOMMENDED_BOOK_KEY)" as NSString, cat_id: "")
        }else if StrHeader == "Top Selling Books" {
            getDashboardDetailsAPI(type: "\(TOP_SELLING_BOOK_KEY)" as NSString, cat_id: "")
        }else {
            getDashboardDetailsAPI(type: "\(CATEGORY)" as NSString, cat_id: "\(strCat_id)" as NSString)
        }
        self.lblTotalCartItem.text = TPreferences.readString(CART_TOTAL_ITEM)
        self.lblTotalCartItem.layer.cornerRadius = self.lblTotalCartItem.layer.frame.height / 2
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveNotification(_:)), name: NSNotification.Name("Cart_item"), object: nil)
        
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
    //MARK:- UICollectionView Delegate and DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrTopSearchBook.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        self.cvBooks.register(UINib(nibName: "HomeBooksCollectionCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        let cell = self.cvBooks.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! HomeBooksCollectionCell
        let dicBookDetail: NSDictionary = self.arrTopSearchBook[indexPath.item] as! NSDictionary
        print(dicBookDetail)
        cell.imgBookCover.layer.cornerRadius = 5.0
        THelper.setImage(img: cell.imgBookCover, url: URL(string: "\(dicBookDetail.value(forKey: FRONT_COVER) ?? "")")!, placeholderImage: PLACEHOLDERIMAGE)
        
        cell.lblBookName.text = "\(dicBookDetail.value(forKey: NAME) ?? "")"
        cell.lblBookPrice.text = "\(PRICE_SIGN) \(dicBookDetail.value(forKey: PRICE) ?? "")"
        
//        THelper.setShadow(view: cell)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if IPAD {
            return CGSize(width: (cvBooks.frame.width / 4) - 12, height: 230)
        }
        else {
            return CGSize(width: (cvBooks.frame.width / 3) - 12, height: 230)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dicBookDetail: NSDictionary = self.arrTopSearchBook[indexPath.item] as! NSDictionary
        let vc = BookDetailViewController(nibName: "BookDetailViewController", bundle: nil)
        vc.strBookId = "\(dicBookDetail.value(forKey: BOOK_ID) ?? "")"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //        MARK:-
    //        MARK:- Other Methods..
    
    @objc func receiveNotification(_ notification: Notification?) {
        if let aNotification = notification {
            print("\(aNotification)")
        }
        self.lblTotalCartItem.text = TPreferences.readString(CART_TOTAL_ITEM)
    }
    
    //MARK:-
    //MARK:- UIButton Clicked Events
    
    @IBAction func btnBack_clicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func btnMyCart_Clicked(_ sender: Any) {
        if TPreferences.readBoolean(IS_LOGINING) {
            let vc = AddToCartViewController(nibName: "AddToCartViewController", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            let vc = LoginViewController(nibName: "LoginViewController", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    @IBAction func btnSearch_clicked(_ sender: Any) {
        let vc = SearchViewController(nibName: "SearchViewController", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK:-
    //MARK:- API Calling
    
    func getDashboardDetailsAPI(type: NSString,cat_id: NSString) {
        THelper.ShowProgress(vc: self)
        let param = [TYPE: type,
                     PAGE: "1",
                     CATEGORY_ID : cat_id
            ]as [String : Any]
        
        Alamofire.request(TPreferences.getCommonURL(DASHBOARD_DETAIL)!,method: .get, parameters: param, encoding: JSONEncoding.default,headers: nil).responseJSON { (response:DataResponse<Any>) in
            switch(response.result) {
            case .success( _):
                THelper.hideProgress(vc: self)
                if let data = response.result.value{
                    print(data)
                    var dicData = NSDictionary()
                    dicData = data as! NSDictionary
                    print(dicData)
                    self.arrTopSearchBook = dicData.value(forKey: "data") as! NSArray
                    if self.arrTopSearchBook.count == 0 {
                        self.cvBooks.isHidden = true
                        self.vwNoRecord.isHidden = false
                    }else {
                        self.cvBooks.isHidden = false
                        self.vwNoRecord.isHidden = true
                    }
                    self.cvBooks.reloadData()
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
