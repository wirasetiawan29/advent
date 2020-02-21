//
//  RenunganListViewController.swift
//  Granth
//
//  Created by wira on 2/17/20.
//  Copyright © 2020 Goldenmace-ios. All rights reserved.
//

import UIKit
import Alamofire
import GoogleMobileAds
import Speech
import UIImageColors

class RenunganListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, GADBannerViewDelegate, SFSpeechRecognizerDelegate {

    @IBOutlet weak var constraintHeaderTop: NSLayoutConstraint!
    @IBOutlet weak var lblTotalCartItem: UILabel!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var vwSearch: UIView!
    @IBOutlet weak var vwHeader: UIView!
    @IBOutlet weak var vwBackground: UIView!
    @IBOutlet weak var cvNewestBooks: UICollectionView!
    @IBOutlet weak var btnMic: UIButton!

    var arrSlider = NSArray()
    var arrBookCategories = NSArray()
    var categoriesBook = [BookCategoryModel]()
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


    //MARK:- SetUpObject.

    func setUpObject() {
        if #available(iOS 11.0, *) {

        } else {
            constraintHeaderTop.constant = UIApplication.shared.statusBarFrame.size.height
        }

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

        categoriesBook.append(BookCategoryModel.init(bookId: 1, imageBackground: "renunganPagi", name: "Renungan Pagi"))
        categoriesBook.append(BookCategoryModel.init(bookId: 2, imageBackground: "renunganSabat", name: "Sekolah Sabat"))
        self.cvNewestBooks.reloadData()

        self.vwSearch.layer.cornerRadius = 5.0
        self.vwSearch.layer.shadowColor = UIColor(hexString: VIEWALLCOLOR, alpha: 0.5).cgColor
        self.vwSearch.layer.shadowOpacity = 1.0
        self.vwSearch.layer.shadowRadius = 1.0
        self.vwSearch.layer.shadowOffset = .zero

        THelper.setHeaderShadow(view: vwHeader)

        self.btnMenu.addTarget(self.navigationController, action:#selector(showMenu) , for: .touchUpInside)

        automaticallyAdjustsScrollViewInsets = false
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveNotification(_:)), name: NSNotification.Name("Cart_item"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveNotification(_:)), name: NSNotification.Name("REMOVE_TOTAL"), object: nil)

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap( _:)))
        vwBackground.addGestureRecognizer(tap)

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

    //MARK:-
    //MARK:- UITapGestureRecognizer.

    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        vwBackground.isHidden = true
        audioEngine.stop()
        request?.endAudio()
        btnMic.isEnabled = true
    }

    //MARK:-
    //MARK:- Collectionview Delegate Methods.

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 16))
        return headerView.bounds.size
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return categoriesBook.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        self.cvNewestBooks.register(UINib(nibName: "DashboardItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DashboardCell")
        let cell = cvNewestBooks.dequeueReusableCell(withReuseIdentifier: "DashboardCell", for: indexPath) as! DashboardItemCollectionViewCell

        let categoryModel: BookCategoryModel = categoriesBook[indexPath.item]
        cell.lblBookName.text = categoryModel.name

        THelper.setImage(img: cell.imgBookCover, url: URL(string: categoryModel.imageBackground)!, placeholderImage: categoryModel.imageBackground)
        let colors = UIImage(named: categoryModel.imageBackground)!.getColors()
        cell.backgroundGradient.backgroundColor = colors?.background
        THelper.setShadow(view: cell)
        return cell;
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = ViewAllViewController(nibName: "ViewAllViewController", bundle: nil)
        vc.StrHeader = LanguageLocal.myLocalizedString(key: "TOP_SEARCH_BOOKS")
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:self.view.bounds.width-20, height: self.view.bounds.width/2 - 20)
    }

    //MARK:-
    //MARK:- ScrollView method.

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        let pageWidth = cvSlider.frame.size.width
//        pageControl.currentPage = Int(cvSlider.contentOffset.x / pageWidth)
    }

    //MARK:-
    //MARK:- Other Methods

    func startTimer() {
        _ =  Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.scrollAutomatically), userInfo: nil, repeats: true)
    }

    @objc func scrollAutomatically(_ timer1: Timer) {
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



    @IBAction func btnMic_Clicked(_ sender: Any) {
        vwBackground.isHidden = false
        if audioEngine.isRunning {
            audioEngine.stop()
            request?.endAudio()
            btnMic.isEnabled = false
        } else {
            startRecording()
        }
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

                    self.arrBookCategories = dicData.value(forKey: CATEGORY_BOOK) as! NSArray
                    self.arrPopularBooks = dicData.value(forKey: POPULAR_BOOK) as! NSArray
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
