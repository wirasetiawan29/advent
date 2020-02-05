//
//  TransactionHistoryViewController.swift
//  Granth

import UIKit
import Alamofire
import GoogleMobileAds

class TransactionHistoryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, GADBannerViewDelegate {
    
    //        MARK:-
    //        MARK:- Outlets
    
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var cvTransaction: UICollectionView!
    
    @IBOutlet weak var vwNoRecord: UIView!
    @IBOutlet weak var lblTotalCartItem: UILabel!
    @IBOutlet weak var constraintHeightArea: NSLayoutConstraint!
    
    @IBOutlet weak var vwBanner: UIView!
    @IBOutlet weak var constraintVwBannerHeight: NSLayoutConstraint!
    
    var arrTransaction = NSArray()
    
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
            self.constraintHeightArea.constant = UIApplication.shared.statusBarFrame.size.height
        }
        self.lblHeader.text = LanguageLocal.myLocalizedString(key: "TRANSACTION_HISTORY")
        
        if TPreferences.readBoolean(IS_LOGINING) {
            self.lblTotalCartItem.isHidden = false
            self.lblTotalCartItem.layer.cornerRadius = self.lblTotalCartItem.layer.frame.height / 2
            self.lblTotalCartItem.text = TPreferences.readString(CART_TOTAL_ITEM)
        }else {
            self.lblTotalCartItem.isHidden = true
        }
        self.getTranSactionAPI()
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
        return self.arrTransaction.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        self.cvTransaction.register(UINib(nibName: "TransactionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TransactionCell")
        let cell = self.cvTransaction.dequeueReusableCell(withReuseIdentifier: "TransactionCell", for: indexPath) as! TransactionCollectionViewCell
        let dicTransaction: NSDictionary = self.arrTransaction[indexPath.item] as! NSDictionary
        let dicTemp: NSDictionary = self.convertToDictionary(text:"\(dicTransaction.value(forKey: "other_transaction_detail") ?? "")")! as NSDictionary
        
        cell.lblDateTime.text = "\(dicTemp.value(forKey: "TXNDATE") ?? "")"
        cell.lblBookName.text = "\(dicTransaction.value(forKey: BOOK_NAME) ?? "")"
        cell.lblCode.text = "\(dicTransaction.value(forKey: TXN_ID) ?? "")"
        cell.lblBookPrice.text = "\(PRICE_SIGN) \(dicTransaction.value(forKey: TOTAL_AMOUNT) ?? "")"
        cell.lbltransactionStatus.text = "Transcation \(dicTransaction.value(forKey: PAYMENT_STATUS) ?? "")"
        cell.vwMain.layer.cornerRadius = 5.0
        THelper.setHeaderShadow(view: cell)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cvTransaction.frame.width - 16 , height: 110)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    //        MARK:-
    //        MARK:- Other Methods..
    
    @objc func receiveNotification(_ notification: Notification?) {
        if let aNotification = notification {
            print("\(aNotification)")
        }
        self.lblTotalCartItem.text = TPreferences.readString(CART_TOTAL_ITEM)
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
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
    
    //MARK:-
    //MARK:- API Calling..
    
    func getTranSactionAPI() {
        THelper.ShowProgress(vc: self)
        let Auth_header = [ "Authorization" : "Bearer \(TPreferences.readString(API_TOKEN)!)"]

        Alamofire.request(TPreferences.getCommonURL(GET_TRANSACTION_HISTORY)!,method: .get, parameters: nil, encoding: JSONEncoding.default,headers: Auth_header).responseJSON { (response:DataResponse<Any>) in
            switch(response.result) {
            case .success( _):
                THelper.hideProgress(vc: self)
                if let data = response.result.value{
                    print(data)
                    var dicData = NSDictionary()
                    dicData = data as! NSDictionary
                    self.arrTransaction = dicData.value(forKey: "data") as! NSArray
                    self.cvTransaction.reloadData()
                    if self.arrTransaction.count == 0 {
                        self.cvTransaction.isHidden = true
                        self.vwNoRecord.isHidden = false
                    }else {
                        self.cvTransaction.isHidden = false
                        self.vwNoRecord.isHidden = true
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
    
}
