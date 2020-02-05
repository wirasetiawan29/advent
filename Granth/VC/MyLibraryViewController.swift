//
//  MyLibraryViewController.swift
//  Granth

import UIKit
import CoreData
import Alamofire
import FolioReaderKit
import GoogleMobileAds

class MyLibraryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, GADBannerViewDelegate {
    
    //        MARK:-
    //        MARK:- Outlets
    
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var cvLibrary: UICollectionView!
    @IBOutlet weak var constraintHeightArea: NSLayoutConstraint!
    @IBOutlet weak var lblTotalCartItem: UILabel!
    @IBOutlet weak var vwNoRecord: UIView!
    
    @IBOutlet weak var vwBanner: UIView!
    @IBOutlet weak var constraintVwBannerHeight: NSLayoutConstraint!
    
    var window: UIWindow?
    var item :[Any] = []
    var dict = NSMutableDictionary()
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    
    var bannerView: GADBannerView!
    
    //        MARK:-
    //        MARK:- UIView Life Cycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.SetUpObject()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    //        MARK:-
    //        MARK:- SetUpObject Method.
    
    func SetUpObject() {
        if #available(iOS 11.0, *) {
            
        } else {
            self.constraintHeightArea.constant = UIApplication.shared.statusBarFrame.size.height
        }
        self.lblHeader.text = LanguageLocal.myLocalizedString(key: "MY_LIBRARY")
        if TPreferences.readBoolean(IS_LOGINING) {
            self.lblTotalCartItem.isHidden = false
            self.lblTotalCartItem.layer.cornerRadius = self.lblTotalCartItem.layer.frame.height / 2
            self.lblTotalCartItem.text = TPreferences.readString(CART_TOTAL_ITEM)
        }else {
            self.lblTotalCartItem.isHidden = true
        }
//        self.getLibarayAPI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveNotification(_:)), name: NSNotification.Name("Cart_item"), object: nil)
        
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
            vwNoRecord.isHidden = true
            cvLibrary.isHidden = false
        }
        else {
            vwNoRecord.isHidden = false
            cvLibrary.isHidden = true
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
        return item.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        self.cvLibrary.register(UINib(nibName: "HomeBooksCollectionCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        let cell = cvLibrary.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! HomeBooksCollectionCell
        
        cell.imgBookCover.layer.cornerRadius = 5.0
        cell.lblBookPrice.isHidden = true
        
        let dicLibrary = item[indexPath.item] as! NSManagedObject
        cell.lblBookName.text = "\(dicLibrary.value(forKey: NAME) ?? "")"
        THelper.setImage(img: cell.imgBookCover, url: URL(string: "\(dicLibrary.value(forKey: FRONT_COVER) ?? "")")!, placeholderImage: PLACEHOLDERIMAGE)
        
        THelper.setShadow(view: cell)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (cvLibrary.frame.width - 24) / 2, height: 240)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dicLibrary = item[indexPath.item] as! NSManagedObject
        let strFilePath = "\(dicLibrary.value(forKey: "file_path") ?? "")"
        let strFileFormat = "\(dicLibrary.value(forKey: FORMAT) ?? "")"
        let url: URL = URL(string: strFilePath)!
        
        if strFileFormat == "pdf" {
            let PDFVC = PDFViewController(nibName: "PDFViewController", bundle: nil)
            PDFVC.localPDFURL = url
            self.navigationController?.pushViewController(PDFVC, animated: true)
        }
        else if strFileFormat == "epub" {
            openEPub(strPath: strFilePath)
        }
    }
    
    
    //        MARK:-
    //        MARK:- Other Methods..
    
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
    
    func openEPub(strPath: String) {
        let config = FolioReaderConfig()
//        let bookPath = Bundle.main.path(forResource: "For the Love of Rescue Dogs - Tom Colvin", ofType: "epub")
        let folioReader = FolioReader()
        folioReader.presentReader(parentViewController: self, withEpubPath: strPath, andConfig: config)
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
    
    func getLibarayAPI() {
        THelper.ShowProgress(vc: self)
        let Auth_header = [ "Authorization" : "Bearer \(TPreferences.readString(API_TOKEN)!)"]
        
        Alamofire.request(TPreferences.getCommonURL(USER_PURCHASE_BOOK)!,method: .get, parameters: nil, encoding: JSONEncoding.default,headers: Auth_header).responseJSON { (response:DataResponse<Any>) in
            switch(response.result) {
            case .success( _):
                THelper.hideProgress(vc: self)
                if let data = response.result.value{
                    print(data)
                    var dicData = NSDictionary()
                    dicData = data as! NSDictionary
                    THelper.toast("\(dicData.value(forKey: MESSAGE) ?? "")", vc: self)
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
