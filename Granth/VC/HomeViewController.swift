//
//  HomeViewController.swift
//  Granth

import UIKit
import Alamofire
import GoogleMobileAds
import Speech

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, GADBannerViewDelegate, SFSpeechRecognizerDelegate {
    
    @IBOutlet weak var constraintHeaderTop: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightSlider: NSLayoutConstraint!
    @IBOutlet weak var constraintCategoryList: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightNewestBooks: NSLayoutConstraint!
    @IBOutlet weak var costraintHeightPopularBooks: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightRecommanded: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightTopSelling: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightAuthors: NSLayoutConstraint!
    
    @IBOutlet weak var lblTotalCartItem: UILabel!
    @IBOutlet weak var lblSpeach: UILabel!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var btnMenu: UIButton!
    
    @IBOutlet weak var vwSearch: UIView!
    @IBOutlet weak var vwHeader: UIView!
    @IBOutlet weak var vwBackground: UIView!
    @IBOutlet weak var vwSpeach: UIView!
    
    @IBOutlet weak var cvSlider: UICollectionView!
    @IBOutlet weak var cvCategory: UICollectionView!
    @IBOutlet weak var cvNewestBooks: UICollectionView!
    @IBOutlet weak var cvPopularBooks: UICollectionView!
    @IBOutlet weak var cvRecommendedBooks: UICollectionView!
    @IBOutlet weak var cvTopSellingBooks: UICollectionView!
    @IBOutlet weak var cvAuthors: UICollectionView!

    @IBOutlet weak var btnTopNewestViewAll: UIButton!
    @IBOutlet weak var btnPopularViewAll: UIButton!
    @IBOutlet weak var btnRecommandViewAll: UIButton!
    @IBOutlet weak var btnTopSellingViewAll: UIButton!
    @IBOutlet weak var btnBestAuthorViewAll: UIButton!
    @IBOutlet weak var btnMic: UIButton!
    
    @IBOutlet weak var vwBanner: UIView!
    @IBOutlet weak var constraintVwBannerHeight: NSLayoutConstraint!
    
    var arrSlider = NSArray()
    var arrBookCategories = NSArray()
    var arrNewestBooks = NSArray()
    var arrPopularBooks = NSArray()
    var arrRecommendadBooks = NSArray()
    var arrTopSellingBooks = NSArray()
    var arrBestAuthors = NSArray()
    var arrConfiguration = NSArray()
    let arrColor = ["FA4352", "34B5C8", "FED76D", "0C5A93", "3CA69B"]
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    var request: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    var strSearch = String()
    
    var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpObject()
    }
    
    //MARK:-
    //MARK:- SetUpObject.
    
    func setUpObject() {
        if #available(iOS 11.0, *) {
            
        } else {
            constraintHeaderTop.constant = UIApplication.shared.statusBarFrame.size.height
        }
        self.btnTopNewestViewAll.setTitle(LanguageLocal.myLocalizedString(key: "VIEW_ALL"), for: .normal)
        self.btnPopularViewAll.setTitle(LanguageLocal.myLocalizedString(key: "VIEW_ALL"), for: .normal)
        self.btnRecommandViewAll.setTitle(LanguageLocal.myLocalizedString(key: "VIEW_ALL"), for: .normal)
        self.btnTopSellingViewAll.setTitle(LanguageLocal.myLocalizedString(key: "VIEW_ALL"), for: .normal)
        self.btnBestAuthorViewAll.setTitle(LanguageLocal.myLocalizedString(key: "VIEW_ALL"), for: .normal)
        
        if TPreferences.readBoolean(IS_LOGINING) {
            self.lblTotalCartItem.isHidden = false
            self.lblTotalCartItem.layer.cornerRadius = self.lblTotalCartItem.layer.frame.height / 2
            self.lblTotalCartItem.text = TPreferences.readString(CART_TOTAL_ITEM)
            if self.lblTotalCartItem.text == "" {
                self.lblTotalCartItem.isHidden = true
            }else {
                self.lblTotalCartItem.isHidden = false
            }
        }else {
            self.lblTotalCartItem.isHidden = true
        }
        getDashboardDetailsAPI()
        
        self.vwSearch.layer.cornerRadius = 5.0
        self.vwSearch.layer.shadowColor = UIColor(hexString: VIEWALLCOLOR, alpha: 0.5).cgColor
        self.vwSearch.layer.shadowOpacity = 1.0
        self.vwSearch.layer.shadowRadius = 1.0
        self.vwSearch.layer.shadowOffset = .zero
        
        THelper.setHeaderShadow(view: vwHeader)
        
        self.btnMenu.addTarget(self.navigationController, action:#selector(showMenu) , for: .touchUpInside)
        
        let layout = cvSlider.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.itemSize = cvSlider.frame.size
        if let layout = layout {
            cvSlider.collectionViewLayout = layout
        }
        automaticallyAdjustsScrollViewInsets = false
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveNotification(_:)), name: NSNotification.Name("Cart_item"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveNotification(_:)), name: NSNotification.Name("REMOVE_TOTAL"), object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap( _:)))
        vwBackground.addGestureRecognizer(tap)
        
        vwSpeach.layer.cornerRadius = 5.0
        vwSpeach.layer.masksToBounds = true
        
        btnMic.isEnabled = false
        speechRecognizer!.delegate = self
        SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
            var isButtonEnabled = false
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.btnMic.isEnabled = isButtonEnabled
            }
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
    //MARK:- UITapGestureRecognizer.
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        vwBackground.isHidden = true
        vwSpeach.isHidden = true
        
        audioEngine.stop()
        request?.endAudio()
        btnMic.isEnabled = true
    }
    
    //MARK:-
    //MARK:- Collectionview Delegate Methods.
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == cvSlider {
            self.startTimer()
            return arrSlider.count
        }
        else if collectionView == cvCategory {
            return arrBookCategories.count
        }
        else if collectionView == cvNewestBooks {
            return arrNewestBooks.count
        }
        else if collectionView == cvPopularBooks {
            return arrPopularBooks.count
        }
        else if collectionView == cvRecommendedBooks {
            return arrRecommendadBooks.count
        }
        else if collectionView == cvTopSellingBooks {
            return arrTopSellingBooks.count
        }
        else {
            return arrBestAuthors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == cvSlider {
            self.cvSlider.register(UINib(nibName: "SliderCollectionCell", bundle: nil), forCellWithReuseIdentifier: "SliderCell")
            let cell = cvSlider.dequeueReusableCell(withReuseIdentifier: "SliderCell", for: indexPath) as! SliderCollectionCell
            
            let dicSlider: NSDictionary = arrSlider[indexPath.item] as! NSDictionary
            self.pageControl.numberOfPages = arrSlider.count
            self.pageControl.currentPageIndicatorTintColor = UIColor.primaryColor()
            THelper.setImage(img: cell.imgSlider, url: URL(string: "\(dicSlider.value(forKey: SLIDE_IMAGE) ?? "")")!, placeholderImage: PLACEHOLDERIMAGE)
            
            return cell;
        }
        else if collectionView == cvCategory {
            self.cvCategory.register(UINib(nibName: "BookCategoryCollectionCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCell")
            let cell = cvCategory.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! BookCategoryCollectionCell
            
            cell.lblCategory.layer.cornerRadius = 5.0
            cell.lblCategory.layer.borderWidth = 0.5
//            cell.lblCategory.layer.borderColor = UIColor(hexString: arrColor[indexPath.item]).cgColor
            cell.lblCategory.layer.masksToBounds = true
            
            let dicBookCategories: NSDictionary = arrBookCategories[indexPath.item] as! NSDictionary
            cell.lblCategory.text = "\(dicBookCategories.value(forKey: NAME) ?? "")"
            cell.lblCategory.text = cell.lblCategory.text! .uppercased()
            
            cell.lblCategory.textColor = UIColor(hexString: arrColor[indexPath.item])
            
            return cell;
        }
        else if collectionView == cvNewestBooks {
            self.cvNewestBooks.register(UINib(nibName: "HomeBooksCollectionCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
            let cell = cvNewestBooks.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! HomeBooksCollectionCell
            
            let dicNewBooks: NSDictionary = arrNewestBooks[indexPath.item] as! NSDictionary
            
            THelper.setImage(img: cell.imgBookCover, url: URL(string: "\(dicNewBooks.value(forKey: FRONT_COVER) ?? "")")!, placeholderImage: PLACEHOLDERIMAGE)
            
            cell.lblBookName.text = "\(dicNewBooks.value(forKey: NAME) ?? "")"
            cell.lblBookPrice.text = "\(PRICE_SIGN) \(dicNewBooks.value(forKey: PRICE) ?? "")"
            
            THelper.setShadow(view: cell)
            return cell;
        }
        else if collectionView == cvPopularBooks {
            self.cvPopularBooks.register(UINib(nibName: "HomeBooksCollectionCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
            let cell = cvPopularBooks.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! HomeBooksCollectionCell
            
            let dicPopularBooks: NSDictionary = arrPopularBooks[indexPath.item] as! NSDictionary
            
            THelper.setImage(img: cell.imgBookCover, url: URL(string: "\(dicPopularBooks.value(forKey: FRONT_COVER) ?? "")")!, placeholderImage: PLACEHOLDERIMAGE)
            
            cell.lblBookName.text = "\(dicPopularBooks.value(forKey: NAME) ?? "")"
            cell.lblBookPrice.text = "\(PRICE_SIGN) \(dicPopularBooks.value(forKey: PRICE) ?? "")"
            
            THelper.setShadow(view: cell)
            return cell;
        }
        else if collectionView == cvRecommendedBooks {
            self.cvRecommendedBooks.register(UINib(nibName: "HomeBooksCollectionCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
            let cell = cvRecommendedBooks.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! HomeBooksCollectionCell
            
            let dicRecommendadBooks: NSDictionary = arrRecommendadBooks[indexPath.item] as! NSDictionary
            
            THelper.setImage(img: cell.imgBookCover, url: URL(string: "\(dicRecommendadBooks.value(forKey: FRONT_COVER) ?? "")")!, placeholderImage: PLACEHOLDERIMAGE)
            
            cell.lblBookName.text = "\(dicRecommendadBooks.value(forKey: NAME) ?? "")"
            cell.lblBookPrice.text = "\(PRICE_SIGN) \(dicRecommendadBooks.value(forKey: PRICE) ?? "")"
            
            THelper.setShadow(view: cell)
            return cell;
        }
        else if collectionView == cvTopSellingBooks {
            self.cvTopSellingBooks.register(UINib(nibName: "HomeBooksCollectionCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
            let cell = cvTopSellingBooks.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! HomeBooksCollectionCell
            
            let dicTopSellingBooks: NSDictionary = arrTopSellingBooks[indexPath.item] as! NSDictionary
            
            THelper.setImage(img: cell.imgBookCover, url: URL(string: "\(dicTopSellingBooks.value(forKey: FRONT_COVER) ?? "")")!, placeholderImage: PLACEHOLDERIMAGE)
            
            cell.lblBookName.text = "\(dicTopSellingBooks.value(forKey: NAME) ?? "")"
            cell.lblBookPrice.text = "\(PRICE_SIGN) \(dicTopSellingBooks.value(forKey: PRICE) ?? "")"
            
            THelper.setShadow(view: cell)
            return cell;
        }
        else {
            self.cvAuthors.register(UINib(nibName: "HomeAuthorsCollectionCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
            let cell = cvAuthors.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! HomeAuthorsCollectionCell
            
            let dicBestAuthors: NSDictionary = arrBestAuthors[indexPath.item] as! NSDictionary
            
            THelper.setImage(img: cell.imgAuthorProfile, url: URL(string: "\(dicBestAuthors.value(forKey: IMAGE) ?? "")")!, placeholderImage: PLACEHOLDERIMAGE)
            
            cell.lblAuthorName.text = "\(dicBestAuthors.value(forKey: NAME) ?? "")"
            
            return cell;
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == cvSlider {
        }
        else if collectionView == cvCategory {
            let dicBookCategories: NSDictionary = arrBookCategories[indexPath.item] as! NSDictionary
            let vc = ViewAllViewController(nibName: "ViewAllViewController", bundle: nil)
            vc.strCat_id = "\(dicBookCategories.value(forKey: CATEGORY_ID) ?? "")"
            vc.StrHeader = "\(dicBookCategories.value(forKey: NAME) ?? "")"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if collectionView == cvNewestBooks {
            let dicNewestBooks: NSDictionary = arrNewestBooks[indexPath.item] as! NSDictionary
            let vc = BookDetailViewController(nibName: "BookDetailViewController", bundle: nil)
            vc.strBookId = "\(dicNewestBooks.value(forKey: BOOK_ID) ?? "")"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if collectionView == cvPopularBooks {
            let dicPopularBooks: NSDictionary = arrPopularBooks[indexPath.item] as! NSDictionary
            let vc = BookDetailViewController(nibName: "BookDetailViewController", bundle: nil)
            vc.strBookId = "\(dicPopularBooks.value(forKey: BOOK_ID) ?? "")"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if collectionView == cvRecommendedBooks {
            let dicRecommendedBooks: NSDictionary = arrRecommendadBooks[indexPath.item] as! NSDictionary
            let vc = BookDetailViewController(nibName: "BookDetailViewController", bundle: nil)
            vc.strBookId = "\(dicRecommendedBooks.value(forKey: BOOK_ID) ?? "")"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if collectionView == cvTopSellingBooks {
            let dicTopSellingBooks: NSDictionary = arrTopSellingBooks[indexPath.item] as! NSDictionary
            let vc = BookDetailViewController(nibName: "BookDetailViewController", bundle: nil)
            vc.strBookId = "\(dicTopSellingBooks.value(forKey: BOOK_ID) ?? "")"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if collectionView == cvAuthors {
            let dicBestAuthors: NSDictionary = arrBestAuthors[indexPath.item] as! NSDictionary
            let vc = AuthorDetailViewController(nibName: "AuthorDetailViewController", bundle: nil)
            vc.AuthorName = "\(dicBestAuthors.value(forKey: NAME) ?? "")"
            vc.AuthorImage = "\(dicBestAuthors.value(forKey: IMAGE) ?? "")"
            vc.dicAuthorDetail = dicBestAuthors
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == cvSlider {
            return CGSize(width:cvSlider.frame.width , height: cvSlider.frame.height)
        }
        else if collectionView == cvCategory {
            let label = UILabel(frame: CGRect.zero)
            let dicBookCategories: NSDictionary = arrBookCategories[indexPath.item] as! NSDictionary
            label.text = "\(dicBookCategories.value(forKey: NAME) ?? "")"
            label.sizeToFit()
            
            return CGSize(width: label.intrinsicContentSize.width + 60, height: 50)
        }
        else if collectionView == cvAuthors {
            return CGSize(width:100 , height: 130)
        }
        else {
            return CGSize(width:150 , height: 240)
        }
    }
    
    //MARK:-
    //MARK:- ScrollView method.
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = cvSlider.frame.size.width
        pageControl.currentPage = Int(cvSlider.contentOffset.x / pageWidth)
    }
    
    //MARK:-
    //MARK:- Other Methods
    
    func startTimer() {
        _ =  Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.scrollAutomatically), userInfo: nil, repeats: true)
    }
    
    @objc func scrollAutomatically(_ timer1: Timer) {
        
        if let coll  = cvSlider {
            for cell in coll.visibleCells {
                let indexPath: IndexPath? = coll.indexPath(for: cell)
                if ((indexPath?.row)! < arrSlider.count - 1){
                    let indexPath1: IndexPath?
                    indexPath1 = IndexPath.init(row: (indexPath?.row)! + 1, section: (indexPath?.section)!)
                    pageControl.currentPage = indexPath1!.item
                    coll.scrollToItem(at: indexPath1!, at: .right, animated: true)
                }
                else{
                    let indexPath1: IndexPath?
                    indexPath1 = IndexPath.init(row: 0, section: (indexPath?.section)!)
                    pageControl.currentPage = indexPath1!.item
                    coll.scrollToItem(at: indexPath1!, at: .left, animated: true)
                }
                
            }
        }
    }
    
    @objc func showMenu() {
        let vc = SideBarMenuViewController(nibName: "SideBarMenuViewController", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func receiveNotification(_ notification: Notification?) {
        if let aNotification = notification {
            print("\(aNotification)")
        }
        if TPreferences.readBoolean(IS_LOGINING) {
            self.lblTotalCartItem.isHidden = false
            self.lblTotalCartItem.text = TPreferences.readString(CART_TOTAL_ITEM)
        }else {
            self.lblTotalCartItem.isHidden = true
        }
    }
    
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        request = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        let recognitionRequest = request
        recognitionRequest?.shouldReportPartialResults = true
        recognitionTask = speechRecognizer!.recognitionTask(with: recognitionRequest!, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                self.lblSpeach.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.request = nil
                self.recognitionTask = nil
                
                self.btnMic.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.request?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        lblSpeach.text = "Say something, I'm listening!"
        
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            btnMic.isEnabled = true
        } else {
            btnMic.isEnabled = false
        }
    }
    
    //MARK:-
    //MARK:- UIButton Action Methods
    
    @IBAction func btnCart_Clicked(_ sender: Any) {
        if TPreferences.readBoolean(IS_LOGINING) {
            let vc = AddToCartViewController(nibName: "AddToCartViewController", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            let vc = LoginViewController(nibName: "LoginViewController", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnSearch_Clicked(_ sender: Any) {
        let vc = SearchViewController(nibName: "SearchViewController", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnViewAllNewestBooks_Clicked(_ sender: Any) {
        let vc = ViewAllViewController(nibName: "ViewAllViewController", bundle: nil)
        vc.StrHeader = LanguageLocal.myLocalizedString(key: "TOP_SEARCH_BOOKS")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnViewAllPopularBooks_Clicked(_ sender: Any) {
        let vc = ViewAllViewController(nibName: "ViewAllViewController", bundle: nil)
        vc.StrHeader = LanguageLocal.myLocalizedString(key: "POPULAR_BOOKS")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnViewAllRecommended_Clicked(_ sender: Any) {
        let vc = ViewAllViewController(nibName: "ViewAllViewController", bundle: nil)
        vc.StrHeader = LanguageLocal.myLocalizedString(key: "RECOMMANDED_BOOKS")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnViewAllTopSelling_Clicked(_ sender: Any) {
        let vc = ViewAllViewController(nibName: "ViewAllViewController", bundle: nil)
        vc.StrHeader = LanguageLocal.myLocalizedString(key: "TOP_SELLING_BOOKS")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnViewAllAuthor_Clicked(_ sender: Any) {
        let vc = AutorsListViewController(nibName: "AutorsListViewController", bundle: nil)
        vc.StrHeader = LanguageLocal.myLocalizedString(key: "BEST_AUTHORS")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnMic_Clicked(_ sender: Any) {
        vwBackground.isHidden = false
        vwSpeach.isHidden = false
        
        if audioEngine.isRunning {
            audioEngine.stop()
            request?.endAudio()
            btnMic.isEnabled = false
        } else {
            startRecording()
        }
    }
    
    @IBAction func btnSpeachSearch_Clicked(_ sender: Any) {
        self.vwBackground.isHidden = true
        self.vwSpeach.isHidden = true
        
        audioEngine.stop()
        request?.endAudio()
        btnMic.isEnabled = true
        
        let vc = SearchViewController(nibName: "SearchViewController", bundle: nil)
        if self.lblSpeach.text == "Say something, I'm listening!" {
            vc.strSearch = ""
        }
        else {
            vc.strSearch = "\(self.lblSpeach.text ?? "")"
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK:-
    //MARK:- API Calling
    
    func getDashboardDetailsAPI() {
        THelper.ShowProgress(vc: self)
        
        Alamofire.request(TPreferences.getCommonURL(DASHBOARD_DETAIL)!,method: .get, parameters: nil, encoding: JSONEncoding.default,headers: nil).responseJSON { (response:DataResponse<Any>) in
            switch(response.result) {
            case .success( _):
                THelper.hideProgress(vc: self)
                if let data = response.result.value{
                    print(data)
                    var dicData = NSDictionary()
                    dicData = data as! NSDictionary
                    print(dicData)
                    self.arrSlider = dicData.value(forKey: SLIDER) as! NSArray

                    if self.arrSlider.count != 0 {
                        if IPAD {
                            self.constraintHeightSlider.constant = 300
                        }
                        else {
                            self.constraintHeightSlider.constant = 240
                        }
                    }else {
                        self.constraintHeightSlider.constant = 0
                    }
                    
                    self.cvSlider.reloadData()
                    
                    self.arrBookCategories = dicData.value(forKey: CATEGORY_BOOK) as! NSArray
                    
                    if self.arrBookCategories.count != 0 {
                        self.constraintCategoryList.constant = 50
                    }else {
                        self.constraintCategoryList.constant = 0
                    }
                    
                    self.cvCategory.reloadData()
                    
                    self.arrNewestBooks = dicData.value(forKey: TOP_SEARCH_BOOK) as! NSArray
                    
                    if self.arrNewestBooks.count != 0 {
                        self.constraintHeightNewestBooks.constant = 250
                        self.btnTopNewestViewAll.isHidden = false
                    }else {
                        self.constraintHeightNewestBooks.constant = 0
                        self.btnTopNewestViewAll.isHidden = true
                    }
                    
                    self.cvNewestBooks.reloadData()
                    
                    self.arrPopularBooks = dicData.value(forKey: POPULAR_BOOK) as! NSArray
                    
                    if self.arrPopularBooks.count != 0 {
                        self.costraintHeightPopularBooks.constant = 250
                        self.btnPopularViewAll.isHidden = false
                    }else {
                        self.costraintHeightPopularBooks.constant = 0
                        self.btnPopularViewAll.isHidden = true
                    }
                    
                    self.cvPopularBooks.reloadData()
                    
                    self.arrRecommendadBooks = dicData.value(forKey: RECOMMENDED_BOOK) as! NSArray
                    
                    if self.arrRecommendadBooks.count != 0 {
                        self.constraintHeightRecommanded.constant = 250
                        self.btnRecommandViewAll.isHidden = false
                    }else {
                        self.constraintHeightRecommanded.constant = 0
                        self.btnRecommandViewAll.isHidden = true
                    }
                    
                    self.cvRecommendedBooks.reloadData()
                    
                    self.arrTopSellingBooks = dicData.value(forKey: TOP_SELL_BOOK) as! NSArray
                    
                    if self.arrTopSellingBooks.count != 0 {
                        self.constraintHeightTopSelling.constant = 250
                        self.btnTopSellingViewAll.isHidden = false
                    }else {
                        self.constraintHeightTopSelling.constant = 0
                        self.btnTopSellingViewAll.isHidden = true
                    }
                    
                    self.cvTopSellingBooks.reloadData()
                    
                    self.arrBestAuthors = dicData.value(forKey: TOP_AUTHOR) as! NSArray
                    
                    if self.arrBestAuthors.count != 0 {
                        self.constraintHeightAuthors.constant = 150
                        self.btnBestAuthorViewAll.isHidden = false
                    }else {
                        self.constraintHeightAuthors.constant = 0
                        self.btnBestAuthorViewAll.isHidden = true
                    }
                    
                    self.arrConfiguration = dicData.value(forKey: CONFIGURATION) as! NSArray
                    var dicConfiguration = NSDictionary()
                    for i in 0..<self.arrConfiguration.count {
                        dicConfiguration = self.arrConfiguration[i] as! NSDictionary
                        if "\(dicConfiguration.value(forKey: KEY) ?? "")" == "\(PAYPAL_CLIENT_ID)" {
                            TPreferences.writeString(PAYPAL_CLIENT_ID, value: "\(dicConfiguration.value(forKey: VALUE) ?? "")")
                        }
                    }
                    
                    for i in 0..<self.arrConfiguration.count {
                        dicConfiguration = self.arrConfiguration[i] as! NSDictionary
                        if "\(dicConfiguration.value(forKey: KEY) ?? "")" == "\(PAYTM_MERCHANT_ID)" {
                            TPreferences.writeBoolean(PAYTM, value: true)
                            break
                        }
                        else {
                            TPreferences.writeBoolean(PAYTM, value: false)
                        }
                    }
                    
                    self.cvAuthors.reloadData()
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
