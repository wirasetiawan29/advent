//
//  AddToCartViewController.swift
//  Granth

import UIKit
import Alamofire
import GoogleMobileAds

class AddToCartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, GADBannerViewDelegate {
    
//        MARK:-
//        MARK:- Outlets
    
    @IBOutlet weak var constraintHeaderTop: NSLayoutConstraint!
    
    @IBOutlet weak var tblBookList: UITableView!
    
    @IBOutlet weak var lblPriceDetail: UILabel!
    @IBOutlet weak var lblTotalMRP: UILabel!
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var lblTotalMRPPrice: UILabel!
    @IBOutlet weak var lblTotalPrice: UILabel!
    @IBOutlet weak var lblTotalAmount: UILabel!
    @IBOutlet weak var lblTotalAmountPrice: UILabel!
    @IBOutlet weak var lblHeaderTitle: UILabel!
    @IBOutlet weak var lblWishlistBadge: UILabel!
    
    @IBOutlet weak var btnCotinue: UIButton!
    @IBOutlet weak var btnClosePopup: UIButton!
    
    @IBOutlet weak var imgConfromOrderDot: UIImageView!
    @IBOutlet weak var imgInfoDot: UIImageView!
    @IBOutlet weak var cvWishlist: UICollectionView!
    
    @IBOutlet weak var vwPriceDetail: UIView!
    @IBOutlet weak var vwPopUpBackground: UIView!
    @IBOutlet weak var vwPopUpWishlist: UIView!
    @IBOutlet weak var vwBanner: UIView!
    
    @IBOutlet weak var constraintVwBannerHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintTblHeight: NSLayoutConstraint!
    
    var arrCart = NSArray()
    var arrWishlist = NSArray()
    var strTotalPriceAmount = NSString()
    
    var bannerView: GADBannerView!
    
    //        MARK:-
    //        MARK:- View Life Cycles.
    
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
        self.view.backgroundColor = UIColor.primaryColor()
        self.imgInfoDot = THelper.setTintColor(self.imgInfoDot, tintColor: UIColor.init(hexString: "6AC259"))
        self.imgConfromOrderDot = THelper.setTintColor(self.imgConfromOrderDot, tintColor: UIColor.lightGray)
        getCartAPI()
        
        self.lblTotal.text = LanguageLocal.myLocalizedString(key: "TOTAL")
        self.lblPriceDetail.text = LanguageLocal.myLocalizedString(key: "PRICE_DETAIL")
        self.lblTotalAmount.text = LanguageLocal.myLocalizedString(key: "TOTAL_AMOUNT")
        self.btnCotinue.setTitle(LanguageLocal.myLocalizedString(key: "CONTINUE"), for: .normal)
        
        
        if TPreferences.readBoolean(IS_LOGINING) {
            self.lblWishlistBadge.isHidden = false
            self.lblWishlistBadge.layer.cornerRadius = lblWishlistBadge.frame.height / 2
            self.lblWishlistBadge.layer.masksToBounds = true
            self.lblWishlistBadge.text = TPreferences.readString(WISHLIST_TOTAL_ITEM)
        }else {
            self.lblWishlistBadge.isHidden = true
        }
        
        self.btnCotinue.layer.cornerRadius = 5.0
        self.btnCotinue.layer.borderColor = UIColor.lightGray.cgColor
        self.btnCotinue.layer.shadowOpacity = 0.5
        self.btnCotinue.layer.shadowRadius = 1.0
        self.btnCotinue.layer.shadowOffset = CGSize(width: 1, height: 3)
        
        self.vwPriceDetail.layer.borderColor = UIColor.lightGray.cgColor
        self.vwPriceDetail.layer.cornerRadius = 5.0
        self.vwPriceDetail.layer.shadowOpacity = 0.5
        self.vwPriceDetail.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.vwPriceDetail.layer.shadowRadius = 1.0
        self.getWishlistAPI()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        vwPopUpBackground.addGestureRecognizer(tap)
        
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
    //MARK:- UITapGestureRecognizer.
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        vwPopUpBackground.isHidden = true
        vwPopUpWishlist.isHidden = true
    }
    
    //        MARK:-
    //        MARK:- TableView Delegate and Data Sources.
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if IPAD {
            self.constraintTblHeight.constant = CGFloat((200 * arrCart.count))
        }else {
            self.constraintTblHeight.constant = CGFloat((150 * arrCart.count))
        }
       return arrCart.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if IPAD {
            return 200
        }else {
            return 150
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.tblBookList.register(UINib(nibName: "AddCartTableViewCell", bundle: nil), forCellReuseIdentifier: "AddCartCell")
        let cell = self.tblBookList.dequeueReusableCell(withIdentifier: "AddCartCell") as! AddCartTableViewCell
        
        let dicCart: NSDictionary = arrCart[indexPath.item] as! NSDictionary
        cell.lblBookName.text = "\(dicCart.value(forKey: NAME) ?? "")"
        cell.lblAuthorName.text = "By \(dicCart.value(forKey: AUTHOR_NAME) ?? "")"
        cell.lblBookPrice.text = "\(PRICE_SIGN)\(dicCart.value(forKey: PRICE) ?? "")"
        THelper.setImage(img: cell.imgBook, url: URL(string: "\(dicCart.value(forKey: FRONT_COVER) ?? "")")!, placeholderImage: PLACEHOLDERIMAGE)
        
        cell.btnMoveToWishlist.tag = indexPath.row
        cell.btnMoveToWishlist.addTarget(self, action: #selector(btnMoveToWishlist_Clicked(_:)), for: UIControl.Event.touchUpInside)
        
        cell.btnRemove.tag = indexPath.row
        cell.btnRemove.addTarget(self, action: #selector(btnRemove_Clicked(_:)), for: UIControl.Event.touchUpInside)
        
        cell.selectionStyle = .none
        return cell
    }
    
    //MARK:-
    //MARK:- UICollectionView Delegate and DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrWishlist.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        self.cvWishlist.register(UINib(nibName: "WishListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WishListCell")
        let cell = self.cvWishlist.dequeueReusableCell(withReuseIdentifier: "WishListCell", for: indexPath) as! WishListCollectionViewCell
        
        cell.layer.cornerRadius = 5.0
        cell.layer.shadowColor = UIColor.viewAllColor().cgColor
        cell.layer.shadowOpacity = 1.0
        cell.layer.shadowRadius = 1.0
        cell.layer.shadowOffset = .zero
        
        cell.imgBook.layer.cornerRadius = 5.0
        
        let dicWishlist: NSDictionary = arrWishlist[indexPath.item] as! NSDictionary
        THelper.setImage(img: cell.imgBook, url: URL(string: "\(dicWishlist.value(forKey: FRONT_COVER) ?? "")")!, placeholderImage: PLACEHOLDERIMAGE)
        
        cell.lblBookName.text = "\(dicWishlist.value(forKey: NAME) ?? "")"
        cell.lblBookPrice.text = "\(PRICE_SIGN) \(dicWishlist.value(forKey: PRICE) ?? "")"
        
        cell.btnMoveToCart.tag = indexPath.row
        cell.btnMoveToCart.addTarget(self, action: #selector(btnMoveToCart_Clicked(_:)), for: UIControl.Event.touchUpInside)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 140, height: 280)
    }
    
    //        MARK:-
    //        MARK:- UIButton Clicked Events
    
    
    @IBAction func btnContinue_Clicked(_ sender: Any) {
        let vc = ConfirmPlaceOrderViewController(nibName: "ConfirmPlaceOrderViewController", bundle: nil)
        vc.strTotalPriceAmount = strTotalPriceAmount
        vc.arrCart = arrCart
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func btnBack_Clicked(_ sender: Any) {
         NotificationCenter.default.post(name: NSNotification.Name("Cart_item"), object: self, userInfo: ["flag":"1"])
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnWishlist_Clicked(_ sender: Any) {
        vwPopUpBackground.isHidden = false
        vwPopUpWishlist.isHidden = false
    }
    
    @IBAction func btnClosePopup_Clicked(_ sender: Any) {
        vwPopUpBackground.isHidden = true
        vwPopUpWishlist.isHidden = true
    }
    
    @objc func btnMoveToWishlist_Clicked(_ sender: UIButton) {
        let dicCart: NSDictionary = arrCart[sender.tag] as! NSDictionary
        addToWishlistAPI(strBookId: "\(dicCart.value(forKey: BOOK_ID) ?? "")", strCartMappingId: "\(dicCart.value(forKey: CART_MAPPING_ID) ?? "")", isWishlist: 1)
    }
    
    @objc func btnRemove_Clicked(_ sender: UIButton) {
        let dicCart: NSDictionary = arrCart[sender.tag] as! NSDictionary
        RemoveFromCartAPI(strCartMappingId: "\(dicCart.value(forKey: CART_MAPPING_ID) ?? "")")
    }
    
    @objc func btnMoveToCart_Clicked(_ sender: UIButton) {
        let dicWishlist: NSDictionary = arrWishlist[sender.tag] as! NSDictionary
        addToCartAPI(strBookId: "\(dicWishlist.value(forKey: BOOK_ID) ?? "")")
    }
    
    //MARK:-
    //MARK:- API Calling
    
    func getCartAPI() {
        THelper.ShowProgress(vc: self)
        
        let Auth_header = [ "Authorization" : "Bearer \(TPreferences.readString(API_TOKEN)!)"]
        
        Alamofire.request(TPreferences.getCommonURL(USER_CART)!,method: .get, parameters: nil, encoding: JSONEncoding.default,headers: Auth_header).responseJSON { (response:DataResponse<Any>) in
            switch(response.result) {
            case .success( _):
                THelper.hideProgress(vc: self)
                if let data = response.result.value{
                    print(data)
                    var dicData = NSDictionary()
                    dicData = data as! NSDictionary
                    self.arrCart = dicData.value(forKey: "data") as! NSArray
                    
                    TPreferences.writeString(CART_TOTAL_ITEM, value: "\(self.arrCart.count)")
                    
                    var totalprice:Double = 0
                    var totalDisPrice:Double = 0
                    var price = Double()
                    var disPrice = Double()
                    var dicTemp = NSDictionary()
                    
                    for i in 0..<self.arrCart.count {
                        dicTemp = self.arrCart[i] as! NSDictionary
                        price = dicTemp.value(forKey: PRICE) as! Double
                        disPrice = dicTemp.value(forKey: "discounted_price") as! Double
                        
                        totalprice = totalprice + price
                        totalDisPrice = totalDisPrice + disPrice
                    }
                    
                    self.lblTotalMRPPrice.text = "\(PRICE_SIGN)\(totalprice)"
                    self.lblTotalPrice.text = "\(PRICE_SIGN)\(totalprice - totalDisPrice)"
                    self.lblTotalAmountPrice.text = "\(PRICE_SIGN)\(totalprice - totalDisPrice)"
                    self.strTotalPriceAmount = "\(totalprice - totalDisPrice)" as NSString
                    
                    self.tblBookList.reloadData()
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
                    self.lblWishlistBadge.text = "\(self.arrWishlist.count)"
                    TPreferences.writeString(WISHLIST_TOTAL_ITEM, value: "\(self.arrWishlist.count)")
                    
                    self.cvWishlist.reloadData()
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
                    self.getCartAPI()
                    self.addToWishlistAPI(strBookId: strBookId, strCartMappingId: "", isWishlist: 0)
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
    
    func addToWishlistAPI(strBookId: String, strCartMappingId: String, isWishlist: Int) {
        THelper.ShowProgress(vc: self)
        let param = [BOOK_ID:strBookId,
                     IS_WISHLIST:isWishlist
            ] as [String : Any]
        print(param)
        
        let Auth_header = [ "Authorization" : "Bearer \(TPreferences.readString(API_TOKEN)!)"]
        
        Alamofire.request(TPreferences.getCommonURL(ADD_REMOVE_WISHLIST_BOOK)!,method: .post, parameters: param, encoding: JSONEncoding.default,headers: Auth_header).responseJSON { (response:DataResponse<Any>) in
            switch(response.result) {
            case .success( _):
                THelper.hideProgress(vc: self)
                if let data = response.result.value{
                    print(data)
                    if isWishlist == 1 {
                        self.RemoveFromCartAPI(strCartMappingId: strCartMappingId)
                    }
                    else {
                        self.getWishlistAPI()
                    }
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
    
    func RemoveFromCartAPI(strCartMappingId: String) {
        THelper.ShowProgress(vc: self)
        let param = [ID:strCartMappingId
            ] as [String : Any]
        print(param)
        
        let Auth_header = [ "Authorization" : "Bearer \(TPreferences.readString(API_TOKEN)!)"]
        
        Alamofire.request(TPreferences.getCommonURL(REMOVE_FROM_CART)!,method: .post, parameters: param, encoding: JSONEncoding.default,headers: Auth_header).responseJSON { (response:DataResponse<Any>) in
            switch(response.result) {
            case .success( _):
                THelper.hideProgress(vc: self)
                if let data = response.result.value{
                    print(data)
                    self.getCartAPI()
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
