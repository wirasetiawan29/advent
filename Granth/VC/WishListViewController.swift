//
//  WishListViewController.swift
//  Granth

import UIKit
import Alamofire
import GoogleMobileAds

class WishListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, GADBannerViewDelegate {

//        MARK:-
//        MARK:- Outlets
    
    @IBOutlet weak var constraintHeaderTop: NSLayoutConstraint!
    
    @IBOutlet weak var vwBanner: UIView!
    @IBOutlet weak var constraintVwBannerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var vwNoRecord: UIView!
    @IBOutlet weak var lblTotalCartItem: UILabel!
    @IBOutlet weak var cvWishList: UICollectionView!
    
    var arrWishlist = NSArray()
    
    var bannerView: GADBannerView!
    
//        MARK:-
//        MARK:- UIView Life Cycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.SetUpObject()
    }
    
//        MARK:-
//        MARK:- SetUpObject Method.
    
    func SetUpObject() {
        if #available(iOS 11.0, *) {
            
        } else {
            constraintHeaderTop.constant = UIApplication.shared.statusBarFrame.size.height
        }
        getWishlistAPI()
        if TPreferences.readBoolean(IS_LOGINING) {
            self.lblTotalCartItem.isHidden = false
            self.lblTotalCartItem.layer.cornerRadius = self.lblTotalCartItem.layer.frame.height / 2
            self.lblTotalCartItem.text = TPreferences.readString(CART_TOTAL_ITEM)
        }else {
            self.lblTotalCartItem.isHidden = true
        }
        
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
        return arrWishlist.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        self.cvWishList.register(UINib(nibName: "WishListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WishListCell")
        let cell = self.cvWishList.dequeueReusableCell(withReuseIdentifier: "WishListCell", for: indexPath) as! WishListCollectionViewCell
        cell.imgBook.layer.cornerRadius = 5.0
        
        let dicWishlist: NSDictionary = arrWishlist[indexPath.item] as! NSDictionary
        THelper.setImage(img: cell.imgBook, url: URL(string: "\(dicWishlist.value(forKey: FRONT_COVER) ?? "")")!, placeholderImage: PLACEHOLDERIMAGE)
        
        cell.lblBookName.text = "\(dicWishlist.value(forKey: NAME) ?? "")"
        cell.lblBookPrice.text = "\(PRICE_SIGN) \(dicWishlist.value(forKey: PRICE) ?? "")"
        
        cell.btnMoveToCart.tag = indexPath.item
        cell.btnMoveToCart.addTarget(self, action: #selector(btnAddToCart_Clicked(_:)), for: UIControl.Event.touchUpInside)
        
        THelper.setShadow(view: cell)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if IPAD {
            return CGSize(width: (cvWishList.frame.width / 3), height: 300)
        }else {
            return CGSize(width: cvWishList.frame.width / 2, height: 280)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dicWishlist: NSDictionary = arrWishlist[indexPath.item] as! NSDictionary
        let vc = BookDetailViewController(nibName: "BookDetailViewController", bundle: nil)
        vc.strBookId = "\(dicWishlist.value(forKey: BOOK_ID) ?? "")"
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
    
    
//        MARK:-
//        MARK:- UIButton Clicked Events
    
    @IBAction func btnBack_Clicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCart_Clicked(_ sender: Any) {
        let vc = AddToCartViewController(nibName: "AddToCartViewController", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func btnAddToCart_Clicked(_ sender: UIButton) {
        let dicWishlist: NSDictionary = arrWishlist[sender.tag] as! NSDictionary
        let bookId:String = "\(dicWishlist.value(forKey: BOOK_ID) ?? "")"
        addToCartAPI(strBookId: bookId)
    }
    
    //MARK:-
    //MARK:- API Calling
    
    func getWishlistAPI() {
        THelper.ShowProgress(vc: self)
        
        let Auth_header = [ "Authorization" : "Bearer \(TPreferences.readString(API_TOKEN)!)"]
        
        Alamofire.request(TPreferences.getCommonURL(USER_WISHLIST_BOOK)!,method: .get, parameters: nil, encoding: JSONEncoding.default,headers: Auth_header).responseJSON { (response:DataResponse<Any>) in
            switch(response.result) {
            case .success( _):
                THelper.hideProgress(vc: self)
                if let data = response.result.value{
                    print(data)
                    var dicData = NSDictionary()
                    dicData = data as! NSDictionary
                    self.arrWishlist = dicData.value(forKey: "data") as! NSArray
                    if self.arrWishlist.count == 0 {
                        self.cvWishList.isHidden = true
                    }else {
                        self.cvWishList.isHidden = false
                    }
                    self.cvWishList.reloadData()
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
    
    func addToCartAPI(strBookId: String) {
        THelper.ShowProgress(vc: self)
        let param = [USER_ID:TPreferences.readString(USER_ID) ?? "",
                     BOOK_ID:strBookId,
                     ADDED_QTY:"1"
            ] as [String : Any]
        print(param)
        
        let Auth_header = [ "Authorization" : "Bearer \(TPreferences.readString(API_TOKEN)!)"]
        
        Alamofire.request(TPreferences.getCommonURL(ADD_TO_CART)!,method: .post, parameters: param, encoding: JSONEncoding.default,headers: Auth_header).responseJSON { (response:DataResponse<Any>) in
            switch(response.result) {
            case .success( _):
                THelper.hideProgress(vc: self)
                if let data = response.result.value{
                    print(data)
                    var dicData = NSDictionary()
                    dicData = data as! NSDictionary
                    THelper.toast("\(dicData.value(forKey: MESSAGE) ?? "")", vc: self)
                    self.removeFromWishlistAPI(strBookId: strBookId)
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
    
    func removeFromWishlistAPI(strBookId: String) {
        THelper.ShowProgress(vc: self)
        let param = [BOOK_ID:strBookId,
                     IS_WISHLIST:0
            ] as [String : Any]
        print(param)
        
        let Auth_header = [ "Authorization" : "Bearer \(TPreferences.readString(API_TOKEN)!)"]
        
        Alamofire.request(TPreferences.getCommonURL(ADD_REMOVE_WISHLIST_BOOK)!,method: .post, parameters: param, encoding: JSONEncoding.default,headers: Auth_header).responseJSON { (response:DataResponse<Any>) in
            switch(response.result) {
            case .success( _):
                THelper.hideProgress(vc: self)
                if let data = response.result.value{
                    print(data)
                    self.getWishlistAPI()
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
