//
//  AutorsListViewController.swift
//  Granth

import UIKit
import Alamofire
import GoogleMobileAds

class AutorsListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, GADBannerViewDelegate  {
    
    //MARK:-
    //MARK:- Outlet
    @IBOutlet weak var lblAuthorHeader: UILabel!
    @IBOutlet weak var cvAuthorList: UICollectionView!
    
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var vwNoRecord: UIView!
    @IBOutlet weak var vwBanner: UIView!
    
    @IBOutlet weak var constraintVwBannerHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintHeaderTop: NSLayoutConstraint!
    
    //MARK:-
    //MARK:- Variables
    
    var StrHeader = String()
    var dicAuthors = NSDictionary()
    var arrAuthorList = NSArray()
    
    var bannerView: GADBannerView!
    
    //MARK:-
    //MARK:- View Life Cycle..
    
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
        self.lblAuthorHeader.text = StrHeader
        getAuthorListDetailsAPI()
        
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
        return arrAuthorList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        self.cvAuthorList.register(UINib(nibName: "AuthorCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AuthorCell")
        let cell = self.cvAuthorList.dequeueReusableCell(withReuseIdentifier: "AuthorCell", for: indexPath) as! AuthorCollectionViewCell
        let dicAuthor: NSDictionary = arrAuthorList[indexPath.row] as! NSDictionary
         THelper.setImage(img: cell.ImgAuthors, url: URL(string: "\(dicAuthor.value(forKey: IMAGE) ?? "")")!, placeholderImage: PLACEHOLDERIMAGE)
        cell.lblAuthorName.text = "\(dicAuthor.value(forKey: NAME) ?? "")"
        cell.ImgAuthors.layer.cornerRadius = cell.ImgAuthors.layer.frame.height / 2
        cell.ImgAuthors.layer.borderColor = UIColor.primaryTextColor().cgColor
        cell.ImgAuthors.layer.borderWidth = 1.0
        cell.vwMain.layer.cornerRadius = 10.0
        cell.vwMain.layer.shadowOpacity = 0.5
        cell.vwMain.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.vwMain.layer.shadowRadius = 2.0
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if IPAD {
            return CGSize(width: (cvAuthorList.frame.width / 2) - 16, height: 200)
        }else {
            return CGSize(width: (cvAuthorList.frame.width / 2) - 16, height: 150)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dicAuthor: NSDictionary = arrAuthorList[indexPath.row] as! NSDictionary
        let vc = AuthorDetailViewController(nibName: "AuthorDetailViewController", bundle: nil)
        vc.dicAuthorDetail = dicAuthor
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK:-
    //MARK:- UIButton Clicked Events..
    
    @IBAction func btnSearch_clicked(_ sender: Any) {
        let vc = SearchViewController(nibName: "SearchViewController", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnBack_Clicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK:-
    //MARK:- API Calling..
    
    func getAuthorListDetailsAPI() {
        THelper.ShowProgress(vc: self)
        
        Alamofire.request(TPreferences.getCommonURL(AUTHOR_LIST)!,method: .get, parameters: nil, encoding: JSONEncoding.default,headers: nil).responseJSON { (response:DataResponse<Any>) in
            switch(response.result) {
            case .success( _):
                THelper.hideProgress(vc: self)
                if let data = response.result.value{
                    print(data)
                    var dicData = NSDictionary()
                    dicData = data as! NSDictionary
                    print(dicData)
                    self.dicAuthors = dicData
                    var arrTemp = NSArray()
                    arrTemp = self.dicAuthors.allValues as NSArray
                    self.arrAuthorList = arrTemp[0] as! NSArray
                    if self.arrAuthorList.count == 0 {
                        self.cvAuthorList.isHidden = true
                        self.vwNoRecord.isHidden = false
                    }else {
                        self.cvAuthorList.isHidden = false
                        self.vwNoRecord.isHidden = true
                    }
                    self.cvAuthorList.reloadData()
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
