//
//  BookDetailViewController.swift
//  Granth

import UIKit
import Cosmos
import Alamofire
import CoreData
import FCAlertView
import GoogleMobileAds
import UIImageColors

class BookDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FCAlertViewDelegate, GADBannerViewDelegate {

    @IBOutlet weak var constraintHeaderTop: NSLayoutConstraint!
    @IBOutlet weak var constraintLblDescriptionHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintTblReviewHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintYourReviewHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintViewAllHeight: NSLayoutConstraint!
    
    @IBOutlet weak var imgBookCover: UIImageView!
    @IBOutlet weak var imgAuthor: UIImageView!
    @IBOutlet weak var imgCartBookCover: UIImageView!
    
    @IBOutlet weak var lblBookName: UILabel!
//    @IBOutlet weak var lblAuthorName: UILabel!
//    @IBOutlet weak var lblReview: UILabel!
//    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblBookAuthorName: UILabel!
    @IBOutlet weak var lblCartBookName: UILabel!
    @IBOutlet weak var lblCartBookPrice: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblCommentDate: UILabel!
    @IBOutlet weak var lblComment: UILabel!
    
    @IBOutlet weak var lblTotalCartItem: UILabel!
    
//    @IBOutlet weak var vwStar: CosmosView!
    @IBOutlet weak var vwPopup: UIView!
    @IBOutlet weak var vwPopRateBook: UIView!
    @IBOutlet weak var vwRating: CosmosView!
    @IBOutlet weak var vwYouReviewStar: CosmosView!
    @IBOutlet weak var VwYourReview: UIView!
    @IBOutlet weak var vwPopCart: UIView!
    @IBOutlet weak var vwHeader: UIView!
    
    @IBOutlet weak var scrollContainerView: UIScrollView!
    @IBOutlet weak var bookHeaderContainerView: UIView!
    @IBOutlet weak var vwViewAll: UIView!
    @IBOutlet weak var txtVwDescription: UITextView!
    
    @IBOutlet weak var btnReadMore: UIButton!
    @IBOutlet weak var btnWishlist: UIButton!
    @IBOutlet weak var btnWriteReview: UIButton!

    @IBOutlet weak var btnBuyNow: UIButton!
    @IBOutlet weak var tblReview: UITableView!
    
    @IBOutlet weak var cvBooksByAuthor: UICollectionView!
    @IBOutlet weak var cvLikeBooks: UICollectionView!
    
    @IBOutlet weak var vwBanner: UIView!
    @IBOutlet weak var constraintVwBannerHeight: NSLayoutConstraint!
    
    var strBookId = String()
    var arrBookDetail = NSArray()
    var arrAuthorDetail = NSArray()
    var arrauthorBookList = NSArray()
    var arrRecommendedBook = NSArray()
    var arrBookRatingData = NSArray()
    var isWishlist = Int()
    var dicReviewData = NSDictionary()
    var rating_id = String()
    let nscontext = ((UIApplication.shared.delegate) as! AppDelegate).persistentContainer.viewContext
    var isPurchase = Int()
    var price = Int()
    
    var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Setupobject()
    }

    //MARK:- SetUpObject
    func Setupobject() {
        if #available(iOS 11.0, *) {
            
        } else {
            constraintHeaderTop.constant = UIApplication.shared.statusBarFrame.size.height
        }
        getBookDetailsAPI(strBookId: strBookId)
                
        vwRating.settings.fillMode = .precise
        vwPopRateBook.layer.shadowColor = UIColor.black.cgColor
        vwPopRateBook.layer.shadowOpacity = 0.8
        vwPopRateBook.layer.shadowRadius = 1.0
        vwPopRateBook.layer.shadowOffset = CGSize(width: 0.0 , height: 1.0)
        vwPopRateBook.layer.masksToBounds = false
        
        THelper.setHeaderShadow(view: vwHeader)
        
        if TPreferences.readBoolean(IS_LOGINING) {
            self.lblTotalCartItem.isHidden = false
            self.lblTotalCartItem.layer.cornerRadius = self.lblTotalCartItem.layer.frame.height / 2
            self.lblTotalCartItem.text = TPreferences.readString(CART_TOTAL_ITEM)
            self.btnWriteReview.isHidden = false
        }else {
            self.lblTotalCartItem.isHidden = true
            self.btnWriteReview.isHidden = true
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveNotification(_:)), name: NSNotification.Name("Cart_item"), object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap( _:)))
        vwPopup.addGestureRecognizer(tap)
        
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
        vwPopup.isHidden = true
        vwPopCart.isHidden = true
        vwPopRateBook.isHidden = true
    }
    
    func Setupvalue() {
        let dicBookDetail: NSDictionary = arrBookDetail[0] as! NSDictionary
        lblBookName.text = "\(dicBookDetail.value(forKey: NAME) ?? "")"
        lblDescription.text = "\(dicBookDetail.value(forKey: DESCRIPTION) ?? "")"
        THelper.setImage(img: imgBookCover, url: URL(string: "\(dicBookDetail.value(forKey: FRONT_COVER) ?? "")")!, placeholderImage: PLACEHOLDERIMAGE)
        
        let dicAuthorDetail: NSDictionary = arrAuthorDetail[0] as! NSDictionary
        lblBookAuthorName.text = "\(dicAuthorDetail.value(forKey: NAME) ?? "")"
        THelper.setImage(img: imgAuthor, url: URL(string: "\(dicAuthorDetail.value(forKey: IMAGE) ?? "")")!, placeholderImage: PLACEHOLDERIMAGE)

        imgBookCover.image!.getColors { colors in
            self.scrollContainerView.backgroundColor = colors?.background
               self.bookHeaderContainerView.backgroundColor = colors?.background
               self.lblBookName.textColor = colors?.primary
                 self.lblDescription.textColor = colors?.detail
             }
    }
    
    //MARK:-
    //MARK:- UITableview Delegate & Data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrBookRatingData.count > 3 {
            constraintTblReviewHeight.constant = CGFloat(3 * 85)
            self.vwViewAll.isHidden = false
            constraintViewAllHeight.constant = 50
            return 3
        }else {
            constraintTblReviewHeight.constant = CGFloat(arrBookRatingData.count * 85)
            self.vwViewAll.isHidden = true
            constraintViewAllHeight.constant = 0
            return arrBookRatingData.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tblReview.register(UINib(nibName: "TopReviewsTableCell", bundle: nil), forCellReuseIdentifier: "ReviewCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! TopReviewsTableCell
        
        let dicBookRating: NSDictionary = arrBookRatingData[indexPath.row] as! NSDictionary
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
    //MARK:- Collectionview Delegate Methods.
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == cvBooksByAuthor {
            return arrauthorBookList.count
        }
        else {
            return arrRecommendedBook.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == cvBooksByAuthor {
            cvBooksByAuthor.register(UINib(nibName: "AuthorBooksCollectionCell", bundle: nil), forCellWithReuseIdentifier: "AuthorBookCell")
            let cell = cvBooksByAuthor.dequeueReusableCell(withReuseIdentifier: "AuthorBookCell", for: indexPath) as! AuthorBooksCollectionCell
            
            let dicAuthorBookList: NSDictionary = arrauthorBookList[indexPath.item] as! NSDictionary
            cell.lblBookName.text = "\(dicAuthorBookList.value(forKey: NAME) ?? "")"
            cell.lblBookPrice.text = "\(PRICE_SIGN) \(dicAuthorBookList.value(forKey: PRICE) ?? "")"
            cell.lblDescription.text = "\(dicAuthorBookList.value(forKey: DESCRIPTION) ?? "")"
            THelper.setImage(img: cell.imgBookCover, url: URL(string: "\(dicAuthorBookList.value(forKey: FRONT_COVER) ?? "")")!, placeholderImage: PLACEHOLDERIMAGE)
            
            return cell;
        }
        else {
            cvLikeBooks.register(UINib(nibName: "HomeBooksCollectionCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
            let cell = cvLikeBooks.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! HomeBooksCollectionCell
            
            let dicNewBooks: NSDictionary = arrRecommendedBook[indexPath.item] as! NSDictionary
            
            THelper.setImage(img: cell.imgBookCover, url: URL(string: "\(dicNewBooks.value(forKey: FRONT_COVER) ?? "")")!, placeholderImage: PLACEHOLDERIMAGE)
            
            cell.lblBookName.text = "\(dicNewBooks.value(forKey: NAME) ?? "")"
            cell.lblBookPrice.text = "\(PRICE_SIGN) \(dicNewBooks.value(forKey: PRICE) ?? "")"
            
            THelper.setShadow(view: cell)
            return cell;
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = BookDetailViewController(nibName: "BookDetailViewController", bundle: nil)
        if collectionView == cvBooksByAuthor {
            let dicAuthorBookList: NSDictionary = arrauthorBookList[indexPath.item] as! NSDictionary
            vc.strBookId = "\(dicAuthorBookList.value(forKey: BOOK_ID) ?? "")"
        }else {
            let dicNewBooks: NSDictionary = arrRecommendedBook[indexPath.item] as! NSDictionary
            vc.strBookId = "\(dicNewBooks.value(forKey: BOOK_ID) ?? "")"
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == cvBooksByAuthor {
            if IPAD {
                return CGSize(width:cvBooksByAuthor.frame.width / 2, height: cvBooksByAuthor.frame.height - 24)
            }else {
                return CGSize(width:cvBooksByAuthor.frame.width - 32 , height: cvBooksByAuthor.frame.height - 24)
            }
        }
        else {
            return CGSize(width:150 , height: 240)
        }
        
    }
    
    //        MARK:-
    //        MARK:- Other Methods..
    
    @objc func receiveNotification(_ notification: Notification?) {
        if let aNotification = notification {
            print("\(aNotification)")
        }
        self.lblTotalCartItem.text = TPreferences.readString(CART_TOTAL_ITEM)
    }
    
    func retriveData() {
        var item :[Any] = []
        var dictItem = NSManagedObject()
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        var flag = Int()
        
        let context = appdelegate.persistentContainer.viewContext
        var locations = [LocalLibrary]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LocalLibrary")
        fetchRequest.returnsObjectsAsFaults = false
        locations = try! context.fetch(fetchRequest) as! [LocalLibrary]
        
        for location in locations
        {
            item.append(location)
        }
        
        if item.count > 0 {
            for i in 0..<item.count {
                dictItem = item[i] as! NSManagedObject
                if "\(dictItem.value(forKey: BOOK_ID) ?? "")" == strBookId {
                    flag = 1
                    break
                }
                else {
                    flag = 2
                }
            }
        }
        else {
            let dicBookDetail: NSDictionary = arrBookDetail[0] as! NSDictionary
            savePdf(urlString: "\(dicBookDetail.value(forKey: FILE_SAMPLE_PATH) ?? "")", bookId: "\(dicBookDetail.value(forKey: BOOK_ID) ?? "")", cover: "\(dicBookDetail.value(forKey: FRONT_COVER) ?? "")", bookName: "\(dicBookDetail.value(forKey: NAME) ?? "")", format: "\(dicBookDetail.value(forKey: FORMAT) ?? "")" )
        }
        
        if flag == 1 {
            let url: URL = URL(string: "\(dictItem.value(forKey: "file_path") ?? "")")!
            let PDFVC = PDFViewController(nibName: "PDFViewController", bundle: nil)
            PDFVC.localPDFURL = url
            self.navigationController?.pushViewController(PDFVC, animated: true)
        }
        else if flag == 2 {
            let dicBookDetail: NSDictionary = arrBookDetail[0] as! NSDictionary
            savePdf(urlString: "\(dicBookDetail.value(forKey: FILE_SAMPLE_PATH) ?? "")", bookId: "\(dicBookDetail.value(forKey: BOOK_ID) ?? "")", cover: "\(dicBookDetail.value(forKey: FRONT_COVER) ?? "")", bookName: "\(dicBookDetail.value(forKey: NAME) ?? "")", format: "\(dicBookDetail.value(forKey: FORMAT) ?? "")" )
        }
    }
    
    
    //MARK:-
    //MARK:- UIButton Action Method
    
    @IBAction func btnBack_Clicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnMore_Clicked(_ sender: Any) {
        
        let alert = UIAlertController(title: "Choose Options", message: "", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: { action in
            THelper.displayAlert(self, title: "Confirmation", message: "Are you sure you want to Delete.", tag: 101, firstButton: "Cancel", doneButton: "OK")
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = CGRect(x: (SCREEN_SIZE.width / 2) - 150, y: SCREEN_SIZE.height, width: 300, height: 300)
        alert.popoverPresentationController?.permittedArrowDirections = .down
        present(alert, animated: true)
    }
    
    @IBAction func btnShare_Clicked(_ sender: Any) {
//        let text = "\(lblBookName.text ?? "") \(lblAuthorName.text ?? "")"
        
//        let textToShare = [ text ]
//        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
//        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
//        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
//        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func btnWishlist_Clicked(_ sender: Any) {
        if TPreferences.readBoolean(IS_LOGINING) {
            addToWishlistAPI(strBookId: strBookId)
        }else {
            let vc = LoginViewController(nibName: "LoginViewController", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnCart_Clicked(_ sender: Any) {
        if TPreferences.readBoolean(IS_LOGINING) {
            let vc = AddToCartViewController(nibName: "AddToCartViewController", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            let vc = LoginViewController(nibName: "LoginViewController", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnReadMore_Clicked(_ sender: Any) {
        btnReadMore.isSelected = !btnReadMore.isSelected
        if btnReadMore.isSelected {
            lblDescription.sizeToFit()
            constraintLblDescriptionHeight.constant = lblDescription.frame.height
            btnReadMore.setTitle("Read less", for: .normal)
        }
        else {
            constraintLblDescriptionHeight.constant = 80
            btnReadMore.setTitle("Read more", for: .normal)
        }
    }
    
    @IBAction func btnWriteReview_Clicked(_ sender: Any) {
        vwPopup.isHidden = false
        vwPopRateBook.isHidden = false
    }
    
    @IBAction func btnDownloadSample_Clicked(_ sender: Any) {
        retriveData()
    }
    
    @IBAction func btnBuyNow_Clicked(_ sender: Any) {
        let dicBookDetail: NSDictionary = arrBookDetail[0] as! NSDictionary
        if isPurchase == 1 || price == 0 {
            retriveData()
        }else {
            vwPopup.isHidden = false
            vwPopCart.isHidden = false
            
            lblCartBookName.text = "\(dicBookDetail.value(forKey: NAME) ?? "")"
            lblCartBookPrice.text = "\(PRICE_SIGN)\(dicBookDetail.value(forKey: PRICE) ?? "")"
            THelper.setImage(img: imgCartBookCover, url: URL(string: "\(dicBookDetail.value(forKey: FRONT_COVER) ?? "")")!, placeholderImage: PLACEHOLDERIMAGE)
        }
    }
    
    @IBAction func btnCancel_Clicked(_ sender: Any) {
        vwPopup.isHidden = true
        vwPopRateBook.isHidden = true
        vwRating.rating = 0
    }
    
    @IBAction func btnPost_Clicked(_ sender: Any) {
        vwPopup.isHidden = true
        vwPopRateBook.isHidden = true
        
        if txtVwDescription.text != "Describe your experience" {
            if txtVwDescription.text.count > 0 {
                addBookRatingAPI(strId: "\(TPreferences.readString(USER_ID) ?? "")", strBookId: strBookId, strRating: "\(vwRating.rating)", strReview: txtVwDescription.text)
            }
            else {
                THelper.toast("Describe your experience", vc: self)
            }
        }
        else {
            THelper.toast("Describe your experience", vc: self)
        }
        
        vwRating.rating = 0
        txtVwDescription.text = "Describe your experience"
    }
    
    @IBAction func btnCheckout_Clicked(_ sender: Any) {
        if TPreferences.readBoolean(IS_LOGINING) {
            addToCartAPI(strBookId: strBookId)
            vwPopup.isHidden = true
            vwPopCart.isHidden = true
            let vc = AddToCartViewController(nibName: "AddToCartViewController", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            let vc = LoginViewController(nibName: "LoginViewController", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnAddToCart_Clicked(_ sender: Any) {
        if TPreferences.readBoolean(IS_LOGINING) {
            addToCartAPI(strBookId: strBookId)
            vwPopup.isHidden = true
            vwPopCart.isHidden = true
        }else {
            let vc = LoginViewController(nibName: "LoginViewController", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnClosePopup_Clicked(_ sender: Any) {
        vwPopup.isHidden = true
        vwPopCart.isHidden = true
    }
    
    @IBAction func btnAuthor_Clicked(_ sender: Any) {
        let dicAuthorDetail: NSDictionary = arrAuthorDetail[0] as! NSDictionary
        let vc = AuthorDetailViewController(nibName: "AuthorDetailViewController", bundle: nil)
        vc.AuthorName = "\(dicAuthorDetail.value(forKey: NAME) ?? "")"
        vc.AuthorImage = "\(dicAuthorDetail.value(forKey: IMAGE) ?? "")"
        vc.dicAuthorDetail = dicAuthorDetail
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnReview_Clicked(_ sender: Any) {
        let vc = ReViewViewController(nibName: "ReViewViewController", bundle: nil)
        vc.strBookId = self.strBookId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func btnReviewRatting_Clicked(_ sender: Any) {
        vwPopup.isHidden = false
        vwPopRateBook.isHidden = false
        vwRating.rating = self.dicReviewData.value(forKey: RATING) as! Double
        txtVwDescription.text = self.dicReviewData.value(forKey: REVIEW) as? String
    }
    
    
    @IBAction func btnViewAllComment_Clicked(_ sender: Any) {
        let vc = ReViewViewController(nibName: "ReViewViewController", bundle: nil)
        vc.strBookId = self.strBookId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func savePdf(urlString:String, bookId:String, cover:String, bookName:String, format:String) {
        THelper.toast("Download started", vc: self)
        
        DispatchQueue.global(qos: .background).async {
            let url = URL(string: urlString)
            if url != nil {
                let pdfData = try? Data.init(contentsOf: url!)
                let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
                let pdfNameFromUrl:String = "Granth-\(bookId).pdf"
                let actualPath = resourceDocPath.appendingPathComponent(pdfNameFromUrl)
                do {
                    try pdfData?.write(to: actualPath, options: .atomic)
//                    THelper.toast("pdf successfully saved!", vc: self)
                    
                    let library = NSEntityDescription.insertNewObject(forEntityName: "LocalLibrary", into: self.nscontext)
                    library.setValue("\(actualPath)", forKey: "file_path")
                    library.setValue("\(bookId)", forKey: BOOK_ID)
                    library.setValue("\(cover)", forKey: FRONT_COVER)
                    library.setValue("\(bookName)", forKey: NAME)
                    library.setValue("\(format)", forKey: FORMAT)
                    
                    let pdfData = try? Data.init(contentsOf: URL(string: urlString)!)
                    
                    library.setValue(pdfData, forKey: "path_data")
                    
                    do {
                        try self.nscontext.save()
                    }
                    catch {}
                } catch {
                }
            }
            else {
            }
        }
    }
    
    //MARK: -
    //MARK: - fcAlertDoneButtonClicked
    
    func fcAlertDoneButtonClicked(_ alertView: FCAlertView?) {
        if alertView?.tag == 101 {
            print("Delete")
            print(self.rating_id)
            self.DeleteRatingAPI(Rating_id: self.rating_id)
        }
    }
    
    
    //MARK:-
    //MARK:- API Calling
    
    func getBookDetailsAPI(strBookId: String) {
        THelper.ShowProgress(vc: self)
        let param = ["book_id":strBookId,
                     "user_id":"\(TPreferences.readString(USER_ID) ?? "")"
        ]
        
        Alamofire.request(TPreferences.getCommonURL(BOOK_DETAIL)!,method: .post, parameters: param, encoding: JSONEncoding.default,headers: nil).responseJSON { (response:DataResponse<Any>) in
            switch(response.result) {
            case .success( _):
                THelper.hideProgress(vc: self)
                if let data = response.result.value{
                    print(data)
                    var dicData = NSDictionary()
                    dicData = data as! NSDictionary
                    print(dicData)
                    self.arrBookDetail = dicData.value(forKey: SINGLE_BOOK_DETAIL) as! NSArray
                    let dic: NSDictionary = self.arrBookDetail[0] as! NSDictionary
                    self.isPurchase = dic.value(forKey: IS_PURCHASE) as! Int
                    self.price = dic.value(forKey: PRICE) as! Int
                    
                    if self.isPurchase == 1 || self.price == 0 {
                        self.btnBuyNow.setTitle(LanguageLocal.myLocalizedString(key: "READ"), for: .normal)
                    }else {
                        self.btnBuyNow.setTitle(LanguageLocal.myLocalizedString(key: "BUY_NOW"), for: .normal)
                    }
                    
                    self.isWishlist = dic.value(forKey: IS_WISHLIST) as! Int
                    if self.isWishlist == 1 {
                        self.isWishlist = 0
                        self.btnWishlist.setImage(UIImage(named: "icoBookmarkSelected"), for: .normal)
                    }
                    else {
                        self.isWishlist = 1
                        self.btnWishlist.setImage(UIImage(named: "icoBookmark"), for: .normal)
                    }
                    
                    if TValidation.isDictionary(dicData.value(forKey: USER_REVIEW_DATA)) {
                        self.dicReviewData = dicData.value(forKey: USER_REVIEW_DATA) as! NSDictionary
                        print(self.dicReviewData)
                        self.VwYourReview.isHidden = false
                        self.constraintYourReviewHeight.constant = 160
                        self.lblUserName.text = TPreferences.readString(NAME) ?? ""
                        self.lblCommentDate.text = self.dicReviewData.value(forKey: CREATED_AT) as? String
                        self.lblComment.text = self.dicReviewData.value(forKey: REVIEW) as? String
                        self.vwYouReviewStar.rating = self.dicReviewData.value(forKey: RATING) as! Double
                        self.rating_id = "\(self.dicReviewData.value(forKey: RATING_ID) ?? "")"
                        print(self.rating_id)
                        self.btnWriteReview.isHidden = true
                    }else {
                        self.VwYourReview.isHidden = true
                        self.btnWriteReview.isHidden = false
                        self.constraintYourReviewHeight.constant = 0
                    }
                    
                    self.arrAuthorDetail = dicData.value(forKey: AUTHOR_DETAIL) as! NSArray
                    self.arrauthorBookList = dicData.value(forKey: AUTHOR_BOOK_LIST) as! NSArray
                    self.cvBooksByAuthor.reloadData()
                    
                    self.arrRecommendedBook = dicData.value(forKey: RECOMMENDED_BOOK) as! NSArray
                    self.cvLikeBooks.reloadData()
                    
                    self.arrBookRatingData = dicData.value(forKey: BOOK_RATING_DATA) as! NSArray
                    self.tblReview.reloadData()
                    
                    self.Setupvalue()
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
    
    func addBookRatingAPI(strId: String, strBookId: String, strRating: String, strReview: String) {
        THelper.ShowProgress(vc: self)
        let Auth_header = [ "Authorization" : "Bearer \(TPreferences.readString(API_TOKEN)!)"]
        print(Auth_header)
        
        let param = [ID:strId,
                     BOOK_ID:strBookId,
                     RATING:strRating,
                     REVIEW:strReview
            ] as [String : Any]
        print(param)
        
        Alamofire.request(TPreferences.getCommonURL(ADD_BOOK_RATING)!,method: .post, parameters: param, encoding: JSONEncoding.default,headers: Auth_header).responseJSON { (response:DataResponse<Any>) in
            switch(response.result) {
            case .success( _):
                THelper.hideProgress(vc: self)
                if let data = response.result.value{
                    print(data)
                    var dicData = NSDictionary()
                    dicData = data as! NSDictionary
                    print(dicData)
                    THelper.toast("\(dicData.value(forKey: MESSAGE) ?? "")", vc: self)
                    self.getBookDetailsAPI(strBookId: self.strBookId)
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
                    self.lblTotalCartItem.text = TPreferences.readString(CART_TOTAL_ITEM)
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
    
    func addToWishlistAPI(strBookId: String) {
        THelper.ShowProgress(vc: self)
        let param = [BOOK_ID:strBookId,
                     IS_WISHLIST:self.isWishlist
            ] as [String : Any]
        print(param)
        
        let Auth_header = [ "Authorization" : "Bearer \(TPreferences.readString(API_TOKEN)!)"]
        
        Alamofire.request(TPreferences.getCommonURL(ADD_REMOVE_WISHLIST_BOOK)!,method: .post, parameters: param, encoding: JSONEncoding.default,headers: Auth_header).responseJSON { (response:DataResponse<Any>) in
            switch(response.result) {
            case .success( _):
                THelper.hideProgress(vc: self)
                if let data = response.result.value{
                    print(data)
                    var dicData = NSDictionary()
                    dicData = data as! NSDictionary
                    THelper.toast("\(dicData.value(forKey: MESSAGE) ?? "")", vc: self)
                    if self.isWishlist == 1 {
                        self.isWishlist = 0
                        self.btnWishlist.setImage(UIImage(named: "icoBookmarkSelected"), for: .normal)
                    }
                    else {
                        self.isWishlist = 1
                        self.btnWishlist.setImage(UIImage(named: "icoBookmark"), for: .normal)
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
    
    func DeleteRatingAPI(Rating_id: String) {
        THelper.ShowProgress(vc: self)
        let param = [ID: Rating_id] as [String : Any]
        let Auth_header = [ "Authorization" : "Bearer \(TPreferences.readString(API_TOKEN)!)"]
        
        Alamofire.request(TPreferences.getCommonURL(DELETE_BOOK_RATING)!,method: .post, parameters: param, encoding: JSONEncoding.default,headers: Auth_header).responseJSON { (response:DataResponse<Any>) in
            switch(response.result) {
            case .success( _):
                THelper.hideProgress(vc: self)
                if let data = response.result.value{
                    print(data)
                    var dicData = NSDictionary()
                    dicData = data as! NSDictionary
                    THelper.toast("\(dicData.value(forKey: MESSAGE) ?? "")", vc: self)
                    self.tblReview.reloadData()
                    self.constraintYourReviewHeight.constant = 0
                    self.getBookDetailsAPI(strBookId: self.strBookId)
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
