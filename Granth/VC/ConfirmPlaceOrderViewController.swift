//
//  ConfirmPlaceOrderViewController.swift
//  Granth

import UIKit
import Alamofire
import PaymentSDK
import GoogleMobileAds

class ConfirmPlaceOrderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PayPalPaymentDelegate, PayPalFuturePaymentDelegate, PayPalProfileSharingDelegate, PGTransactionDelegate, GADBannerViewDelegate {

//        MARK:-
//        MARK:- Outlets
    
    @IBOutlet weak var constraintHeaderTop: NSLayoutConstraint!
    
    @IBOutlet weak var tblPayment: UITableView!
    
    @IBOutlet weak var vwPriceDetail: UIView!
    @IBOutlet weak var vwPopUpBackground: UIView!
    @IBOutlet weak var vwPopUpWishlist: UIView!

    @IBOutlet weak var imgDot: UIImageView!
    @IBOutlet weak var lblWishlistBadge: UILabel!
    @IBOutlet weak var lblPriceDetail: UILabel!
    @IBOutlet weak var lblTotalMRP: UILabel!
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var lblTotalMRPPrice: UILabel!
    @IBOutlet weak var lblTotalPrice: UILabel!
    @IBOutlet weak var lblTotalAmount: UILabel!
    @IBOutlet weak var lblTotalAmountPrice: UILabel!
    @IBOutlet weak var lblHeaderTitle: UILabel!
    
    @IBOutlet weak var btnCotinue: UIButton!
    @IBOutlet weak var btnClosePopup: UIButton!
    
    @IBOutlet weak var cvWishlist: UICollectionView!

    @IBOutlet weak var vwBanner: UIView!
    @IBOutlet weak var constraintVwBannerHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintTblHeight: NSLayoutConstraint!

//        MARK:-
//        MARK:- Variables.
    
    var arrPayment = NSArray()
    var strTotalPriceAmount = NSString()
    var arrWishlist = NSArray()
    var selectedIndex = Int()
    var arrCart = NSArray()
    var strPaymentType = String()
    
    var payPalConfig = PayPalConfiguration()
    
    var bannerView: GADBannerView!
    
    struct Checksum {
        var MID = String()
        var ORDER_ID = String()
        var CUST_ID = String()
        var MOBILE_NO = String()
        var EMAIL = String()
        var CHANNEL_ID = String()
        var WEBSITE = String()
        var TXN_AMOUNT = String()
        var INDUSTRY_TYPE_ID = String()
        var CHECKSUMHASH = String()
        var CALLBACK_URL = String()
    }
    
    var cs = Checksum()
    
    //Set environment connection.
    
    var environment:String = PayPalEnvironmentSandbox {
        willSet(newEnvironment) {
            if (newEnvironment != environment) {
                PayPalMobile.preconnect(withEnvironment: newEnvironment)
            }
        }
    }
    
//        MARK:-
//        MARK:- UIView Life Cycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.SetUpObject()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PayPalMobile.preconnect(withEnvironment: environment)
    }
    
//        MARK:-
//        MARK:- SetUpObject Method.
    
    func SetUpObject() {
        if #available(iOS 11.0, *) {
            
        } else {
            constraintHeaderTop.constant = UIApplication.shared.statusBarFrame.size.height
        }
        self.imgDot = THelper.setTintColor(self.imgDot, tintColor:  UIColor.init(hexString: "6AC259"))
        self.view.backgroundColor = UIColor.primaryColor()
        selectedIndex = -1
        
        if TPreferences.readBoolean(IS_LOGINING) {
            self.lblWishlistBadge.isHidden = false
            self.lblWishlistBadge.layer.cornerRadius = lblWishlistBadge.frame.height / 2
            self.lblWishlistBadge.layer.masksToBounds = true
            self.lblWishlistBadge.text = TPreferences.readString(WISHLIST_TOTAL_ITEM)
        }else {
            self.lblWishlistBadge.isHidden = true
        }
        
        if TPreferences.readBoolean(PAYTM) {
            arrPayment = ["Paytm", "Paypal"];
        }
        else {
            arrPayment = ["Paypal"];
        }
        tblPayment.reloadData()
        
        self.lblTotal.text = LanguageLocal.myLocalizedString(key: "TOTAL")
        self.lblPriceDetail.text = LanguageLocal.myLocalizedString(key: "PRICE_DETAIL")
        self.lblTotalAmount.text = LanguageLocal.myLocalizedString(key: "TOTAL_AMOUNT")
        self.btnCotinue.setTitle(LanguageLocal.myLocalizedString(key: "PLACE_ORDER"), for: .normal)
        self.lblTotalMRPPrice.text = "\(PRICE_SIGN)\(strTotalPriceAmount)"
        self.lblTotalPrice.text = "\(PRICE_SIGN)\(strTotalPriceAmount)"
        self.lblTotalAmountPrice.text = "\(PRICE_SIGN)\(strTotalPriceAmount)"
        
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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap( _:)))
        vwPopUpBackground.addGestureRecognizer(tap)
        
        //Configure the marchant
        self.configurePaypal(strMarchantName: "test")
        
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
            self.constraintTblHeight.constant = CGFloat((60 * arrPayment.count))
        }else {
            self.constraintTblHeight.constant = CGFloat((50 * arrPayment.count))
        }
        return arrPayment.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if IPAD {
            return 60
        }else {
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.tblPayment.register(UINib(nibName: "PaymentTableViewCell", bundle: nil), forCellReuseIdentifier: "PaymentCell")
        let cell = self.tblPayment.dequeueReusableCell(withIdentifier: "PaymentCell") as! PaymentTableViewCell
        cell.lblTitle.text = arrPayment[indexPath.row] as? String
        
        if selectedIndex == indexPath.row {
            cell.btnSelected.isSelected = true
            strPaymentType = "\(cell.lblTitle.text ?? "")"
        }
        else {
            cell.btnSelected.isSelected = false
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        tblPayment.reloadData()
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
    
    func acceptCreditCards() -> Bool {
        return self.payPalConfig.acceptCreditCards
    }
    
    func setAcceptCreditCards(acceptCreditCards: Bool) {
        self.payPalConfig.acceptCreditCards = self.acceptCreditCards()
    }
    
    //Configure paypal and set Marchant Name
    
    func configurePaypal(strMarchantName:String) {
        // Set up payPalConfig
        payPalConfig.acceptCreditCards = false
        payPalConfig.merchantName = strMarchantName
        payPalConfig.merchantPrivacyPolicyURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        payPalConfig.merchantUserAgreementURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
        payPalConfig.languageOrLocale = Locale.preferredLanguages[0]
        payPalConfig.payPalShippingAddressOption = .payPal;
        print("PayPal iOS SDK Version: \(PayPalMobile.libraryVersion())")
    }
    
    //MARK:-
    //MARK:-PayPalPayment methods
    
    func beginPayPalPayment() {
        let arrItem = NSMutableArray()
        var dicItem = NSDictionary()
        
        for i in 0..<arrCart.count {
            dicItem = arrCart[i] as! NSDictionary
            arrItem.add(PayPalItem(name: "\(dicItem.value(forKey: NAME) ?? "")", withQuantity: 1, withPrice: NSDecimalNumber(string: "\(dicItem.value(forKey: PRICE) ?? "")"), withCurrency: "USD", withSku: ""))
        }
        
        let items = arrItem
        let subtotal = PayPalItem.totalPrice(forItems: items as! [Any])
        
        // Optional: include payment details
        let shipping = NSDecimalNumber(string: "0.00")
        let tax = NSDecimalNumber(string: "0.00")
        let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: shipping, withTax: tax)
        
        let total = subtotal.adding(shipping).adding(tax)
        
        let payment = PayPalPayment(amount: total, currencyCode: "USD", shortDescription: "Grunth", intent: .sale)
        
        payment.items = items as? [Any]
        payment.paymentDetails = paymentDetails
        
        if (payment.processable) {
            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
            present(paymentViewController!, animated: true, completion: nil)
        }
        else {
            print("Payment not processalbe: \(payment)")
        }
    }
    
    //MARK:-
    //MARK:-PayPalPaymentDelegate methods
    
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        print("PayPal Payment Cancelled")
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        print("PayPal Payment Success !")
        paymentViewController.dismiss(animated: true, completion: { () -> Void in
            // send completed confirmaion to your server
            print("Here is your proof of payment:\n\n\(completedPayment.confirmation)\n\nSend this to your server for confirmation and fulfillment.")
            
            self.saveTransactionAPI()
        })
    }
    
    
    // MARK: Future Payments
    
    @IBAction func authorizeFuturePaymentsAction(_ sender: AnyObject) {
        let futurePaymentViewController = PayPalFuturePaymentViewController(configuration: payPalConfig, delegate: self)
        present(futurePaymentViewController!, animated: true, completion: nil)
    }
    
    func payPalFuturePaymentDidCancel(_ futurePaymentViewController: PayPalFuturePaymentViewController) {
        print("PayPal Future Payment Authorization Canceled")
        futurePaymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalFuturePaymentViewController(_ futurePaymentViewController: PayPalFuturePaymentViewController, didAuthorizeFuturePayment futurePaymentAuthorization: [AnyHashable: Any]) {
        print("PayPal Future Payment Authorization Success!")
        // send authorization to your server to get refresh token.
        futurePaymentViewController.dismiss(animated: true, completion: { () -> Void in
        })
    }
    
    // PayPalProfileSharingDelegate
    
    func userDidCancel(_ profileSharingViewController: PayPalProfileSharingViewController) {
        print("PayPal Profile Sharing Authorization Canceled")
        profileSharingViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalProfileSharingViewController(_ profileSharingViewController: PayPalProfileSharingViewController, userDidLogInWithAuthorization profileSharingAuthorization: [AnyHashable: Any]) {
        print("PayPal Profile Sharing Authorization Success!")
        
        // send authorization to your server
        
        profileSharingViewController.dismiss(animated: true, completion: { () -> Void in
        })
        
    }
    
    //MARK:-
    //MARK:- Paytm payment
    
    func beginPaytmPayment() {
    
        let type :ServerType = .eServerTypeStaging
        let order = PGOrder(orderID: "", customerID: "", amount: "", eMail: "", mobile: "")
        order.params = ["MID": cs.MID,
                        "ORDER_ID": cs.ORDER_ID,
                        "CUST_ID": cs.CUST_ID,
                        "MOBILE_NO": cs.MOBILE_NO,
                        "EMAIL": cs.EMAIL,
                        "CHANNEL_ID": cs.CHANNEL_ID,
                        "WEBSITE": cs.WEBSITE,
                        "TXN_AMOUNT": cs.TXN_AMOUNT,
                        "INDUSTRY_TYPE_ID": cs.INDUSTRY_TYPE_ID,
                        "CHECKSUMHASH": cs.CHECKSUMHASH,
                        "CALLBACK_URL": cs.CALLBACK_URL]
        
        var txnController = PGTransactionViewController()
        txnController =  txnController.initTransaction(for: order) as! PGTransactionViewController
        txnController.title = "Paytm Payments"
        txnController.setLoggingEnabled(true)
        if(type != ServerType.eServerTypeNone) {
            txnController.serverType = type;
        } else {
            return
        }
        txnController.merchant = PGMerchantConfiguration.defaultConfiguration()
        txnController.delegate = self
        navigationController?.pushViewController(txnController, animated: true)
    }
    
    //this function triggers when transaction gets finished
    func didFinishedResponse(_ controller: PGTransactionViewController, response responseString: String) {
        let msg : String = responseString
        var titlemsg : String = ""
        if let data = responseString.data(using: String.Encoding.utf8) {
            do {
                if let jsonresponse = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] , jsonresponse.count > 0{
                    titlemsg = jsonresponse["STATUS"] as? String ?? ""
                }
            } catch {
                titlemsg = "Something went wrong"
            }
        }
        let actionSheetController: UIAlertController = UIAlertController(title: titlemsg , message: msg, preferredStyle: .alert)
        let cancelAction : UIAlertAction = UIAlertAction(title: "OK", style: .cancel) {
            action -> Void in
            if titlemsg == "Something went wrong" {
                controller.navigationController?.popViewController(animated: true)
            }
            else {
                self.saveTransactionAPI()
            }
        }
        actionSheetController.addAction(cancelAction)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    //this function triggers when transaction gets cancelled
    func didCancelTrasaction(_ controller : PGTransactionViewController) {
        controller.navigationController?.popViewController(animated: true)
    }
    
    //Called when a required parameter is missing.
    func errorMisssingParameter(_ controller : PGTransactionViewController, error : NSError?) {
        THelper.toast(error?.localizedFailureReason, vc: self)
        controller.navigationController?.popViewController(animated: true)
    }

    
//        MARK:-
//        MARK:- UIButton Clicked Events
    
    @IBAction func btnContinue_Clicked(_ sender: Any) {
        if selectedIndex != -1 {
            self.generateChecksumAPI()
        }
        else {
            THelper.toast("Please select payment option", vc: self)
        }
    }
    
    @IBAction func btnWihsList_Clicked(_ sender: Any) {
        getWishlistAPI()
        vwPopUpBackground.isHidden = false
        vwPopUpWishlist.isHidden = false
    }
    
    @IBAction func btnBack_Clicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnClosePopup_Clicked(_ sender: Any) {
        vwPopUpBackground.isHidden = true
        vwPopUpWishlist.isHidden = true
    }
    
    @objc func btnMoveToCart_Clicked(_ sender: UIButton) {
        let dicWishlist: NSDictionary = arrWishlist[sender.tag] as! NSDictionary
        addToCartAPI(strBookId: "\(dicWishlist.value(forKey: BOOK_ID) ?? "")")
    }
    
    //MARK:-
    //MARK:- API calling
    
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
    
    func generateChecksumAPI() {
        THelper.ShowProgress(vc: self)
        let param = ["TXN_AMOUNT":strTotalPriceAmount,
                     "EMAIL" : "\(TPreferences.readString(EMAIL) ?? "")",
            "MOBILE_NO" : "\(TPreferences.readString(CONTACT_NUMBER) ?? "")"
            ] as [String : Any]
        print(param)
        
        let Auth_header = [ "Authorization" : "Bearer \(TPreferences.readString(API_TOKEN)!)"]
        
        Alamofire.request(TPreferences.getCommonURL(GENERATE_CHECK_SUM)!,method: .post, parameters: param, encoding: JSONEncoding.default,headers: Auth_header).responseJSON { (response:DataResponse<Any>) in
            switch(response.result) {
            case .success( _):
                THelper.hideProgress(vc: self)
                if let data = response.result.value{
                    print(data)
                    let dic: NSDictionary = data as! NSDictionary
                    let dicData: NSDictionary = dic.value(forKey: "data") as! NSDictionary
                    let dicOrderData: NSDictionary = dicData.value(forKey: "order_data") as! NSDictionary
                    let dicChecksumData: NSDictionary = dicData.value(forKey: "checksum_data") as! NSDictionary
                    
                    self.cs.MID = "\(dicOrderData.value(forKey: "MID") ?? "")"
                    self.cs.ORDER_ID = "\(dicOrderData.value(forKey: "ORDER_ID") ?? "")"
                    self.cs.CUST_ID = "\(dicOrderData.value(forKey: "CUST_ID") ?? "")"
                    self.cs.MOBILE_NO = "\(dicOrderData.value(forKey: "MOBILE_NO") ?? "")"
                    self.cs.EMAIL = "\(dicOrderData.value(forKey: "EMAIL") ?? "")"
                    self.cs.CHANNEL_ID = "\(dicOrderData.value(forKey: "CHANNEL_ID") ?? "")"
                    self.cs.WEBSITE = "\(dicOrderData.value(forKey: "WEBSITE") ?? "")"
                    self.cs.TXN_AMOUNT = "\(dicOrderData.value(forKey: "TXN_AMOUNT") ?? "")"
                    self.cs.INDUSTRY_TYPE_ID = "\(dicOrderData.value(forKey: "INDUSTRY_TYPE_ID") ?? "")"
                    self.cs.CHECKSUMHASH = "\(dicChecksumData.value(forKey: "CHECKSUMHASH") ?? "")"
                    self.cs.CALLBACK_URL = "\(dicOrderData.value(forKey: "CALLBACK_URL") ?? "")"
                    
                    if self.strPaymentType == "Paytm" {
                        self.beginPaytmPayment()
                    }
                    else if self.strPaymentType == "Paypal" {
                        self.beginPayPalPayment()
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
    
    func saveTransactionAPI() {
        THelper.ShowProgress(vc: self)
        
        let transactionDetails = ["CHECKSUMHASH" : self.cs.CHECKSUMHASH,
                                  "BANK_NAME" : "",
                                  "ORDER_ID": self.cs.ORDER_ID,
                                  "TXN_AMOUNT" : self.cs.TXN_AMOUNT,
                                  "TXN_DATE" : "",
                                  "MID" : self.cs.MID,
                                  "TXN_ID" : "PAYID-LWSFHGI85900150V6628070S",
                                  "PAYMENT_MODE" : strPaymentType,
                                  "CURRENCY" : "USD",
                                  "BANK_TXN_ID" : "",
                                  "GATEWAY_NAME" : "",
                                  "RESP_MSG" : "approved",
                                  "STATUS" : "approved"
            ] as [String : Any]
        
        var dicCart = NSDictionary()
        var data = [String : Any]()
        let arrData = NSMutableArray()
        
        for i in 0..<self.arrCart.count {
            dicCart = self.arrCart[i] as! NSDictionary
            data = ["book_id" : "\(dicCart.value(forKey: BOOK_ID) ?? "")",
                    "discount" : "\(dicCart.value(forKey: DISCOUNT) ?? "")"]
            arrData.add(data)
        }
        
        let orderDetails = ["user_id" :self.cs.CUST_ID,
                            "is_hard_copy" :"",
                            "gstnumber" :"",
                            "total_amount" :self.cs.TXN_AMOUNT,
                            "price" :self.cs.TXN_AMOUNT,
                            "discount" :"0.00",
                            "shipping_cost" :"0.00",
                            "quantity" :"1",
                            "cash_on_delivery" :"",
                            "payment_type" :strPaymentType,
                            "other_detail" : arrData
        ] as [String : Any]
        
        let jsonTransactionDetails = try? JSONSerialization.data(withJSONObject:transactionDetails)
        let jsonOrderDetails = try? JSONSerialization.data(withJSONObject:orderDetails)
        let mode = Data(self.strPaymentType.utf8)
        let status = Data("1".utf8)
        
        let headers: HTTPHeaders = ["Authorization" : "Bearer \(TPreferences.readString(API_TOKEN)!)"]
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(jsonTransactionDetails!, withName: "transactionDetails")
            multipartFormData.append(jsonOrderDetails!, withName: "orderDetails")
            multipartFormData.append(mode, withName: "mode")
            multipartFormData.append(status, withName: "status")
        
        }, to: TPreferences.getCommonURL(SAVE_TRANSACTION)!, method: .post, headers: headers) { (result) in
            switch result{
            case .success(let upload, _, _):
                THelper.hideProgress(vc: self)
                upload.responseJSON { response in
                    if response.error != nil{
                        self.getCartAPI()
                    } else {
                        print(response.value ?? "")
                        self.getCartAPI()
                    }
                }
            case .failure(let error):
                THelper.hideProgress(vc: self)
                print("Error in upload: \(error.localizedDescription)")
            }
        }
    }
    
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
                    
                    let vc = HomeViewController(nibName: "HomeViewController", bundle: nil)
                    AppDelegate.getDelegate()?.navigationController = TNavigationViewController(rootViewController: vc)
                    AppDelegate.getDelegate()?.navigationController.isNavigationBarHidden = true
                    if let aController = AppDelegate.getDelegate()?.navigationController {
                        self.frostedViewController.contentViewController = aController
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
