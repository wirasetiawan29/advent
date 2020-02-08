//
//  AuthorDetailViewController.swift
//  Granth

import UIKit
import Alamofire
import GoogleMobileAds
import UIImageColors

class AuthorDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, GADBannerViewDelegate {
    
    //MARK:-
    //MARK:- Outlet
    
    @IBOutlet weak var constraintHeaderTop: NSLayoutConstraint!
    
    @IBOutlet weak var imgAuthorProfile: UIImageView!
    @IBOutlet weak var headerBackground: UIView!
    
    @IBOutlet weak var lblAuthorName: UILabel!
    @IBOutlet weak var lblPublishBook: UILabel!
    @IBOutlet weak var lblTotalPublishBook: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblDesignation: UILabel!
    @IBOutlet weak var lblDesignationDetail: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblAddressDetail: UILabel!
    @IBOutlet weak var lblEduction: UILabel!
    @IBOutlet weak var lblEducationDetail: UILabel!
    
    @IBOutlet weak var btnReadMore: UIButton!
    @IBOutlet weak var ConstraintheightAuthorDetail: NSLayoutConstraint!
  
    @IBOutlet weak var ConstraintCvBookHeight: NSLayoutConstraint!
    @IBOutlet weak var VwEducation: UIView!
    
    @IBOutlet weak var vwBanner: UIView!
    @IBOutlet weak var constraintVwBannerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var cvBooks: UICollectionView!
    
    
    //MARK:-
    //MARK:- Outlets.
    
    var AuthorImage = String()
    var AuthorName = String()
    var dicAuthorDetail = NSDictionary()
    var AuthorID = String()
    var arrBooks = NSArray()
    var arrPage = NSArray()
    
    var bannerView: GADBannerView!
    
    //MARK:-
    //MARK:- View Life Cycle..
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.SetUpObject()
    }
    
    //MARK:-
    //MARK:- SetUpObject Methods..
    
    func SetUpObject()  {




        if #available(iOS 11.0, *) {
            
        } else {
            constraintHeaderTop.constant = UIApplication.shared.statusBarFrame.size.height
        }
        
        if IPAD {
             self.imgAuthorProfile.layer.cornerRadius = 100 / 2
        }else {
             self.imgAuthorProfile.layer.cornerRadius = self.imgAuthorProfile.layer.frame.height / 2
        }
        
        self.lblPublishBook.text = LanguageLocal.myLocalizedString(key: "PUBLISH_BOOK")
        self.ConstraintheightAuthorDetail.constant = 80
        print("\(dicAuthorDetail)")
         THelper.setImage(img: self.imgAuthorProfile, url: URL(string: "\(dicAuthorDetail.value(forKey: IMAGE) ?? "")")!, placeholderImage: PLACEHOLDERIMAGE)
        self.lblAuthorName.text = "\(dicAuthorDetail.value(forKey: NAME) ?? "")"
        self.lblDesignationDetail.text = "\(dicAuthorDetail.value(forKey: DESIGNATION) ?? "")"
        self.lblEducationDetail.text = "\(dicAuthorDetail.value(forKey: EDUCATION) ?? "")"
        self.lblAddressDetail.text =  "\(dicAuthorDetail.value(forKey: ADDRESS) ?? "")"
        self.lblDescription.text = "\(dicAuthorDetail.value(forKey: DESCRIPTION) ?? "")"
        self.AuthorID = "\(dicAuthorDetail.value(forKey: AUTHOR_ID) ?? "")"
        print(self.AuthorID)
        
        getAuthorBooksListAPI()
        self.imgAuthorProfile.image!.getColors { colors in
            self.headerBackground.backgroundColor = colors?.background
            self.lblAuthorName.textColor = colors?.primary
            self.lblPublishBook.textColor = colors?.secondary
            self.lblDescription.textColor = colors?.detail
            self.btnReadMore.titleLabel?.textColor = colors?.secondary
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
        if (self.arrBooks.count % 3 == 0) {
            self.ConstraintCvBookHeight.constant = CGFloat((self.arrBooks.count / 3)  * 250);
        }
        else {
            var count = 0
            count = self.arrBooks.count + 1
            if (count % 3 == 0) {
                self.ConstraintCvBookHeight.constant = CGFloat((count / 3) * 250)
            }
            else {
                count = self.arrBooks.count + 2;
                self.ConstraintCvBookHeight.constant = CGFloat((count / 3) * 250)
            }
        }
        return self.arrBooks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        self.cvBooks.register(UINib(nibName: "HomeBooksCollectionCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        let cell = self.cvBooks.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! HomeBooksCollectionCell
        let dicBookDetail:NSDictionary = self.arrBooks[indexPath.row] as! NSDictionary
        cell.lblBookName.text = "\(dicBookDetail.value(forKey: NAME) ?? "")"
        cell.lblBookPrice.text = "\(PRICE_SIGN) \(dicBookDetail.value(forKey: PRICE) ?? "")"
        THelper.setImage(img: cell.imgBookCover, url: URL(string: "\(dicBookDetail.value(forKey: FRONT_COVER) ?? "")")!, placeholderImage: PLACEHOLDERIMAGE)
        
        THelper.setShadow(view: cell)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if IPAD {
            return CGSize(width: (cvBooks.frame.width / 3) - 12, height: 240)
        }
        else {
            return CGSize(width: (cvBooks.frame.width / 2) - 12, height: 240)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dicBookDetail:NSDictionary = self.arrBooks[indexPath.row] as! NSDictionary
        let vc = BookDetailViewController(nibName: "BookDetailViewController", bundle: nil)
        vc.strBookId = "\(dicBookDetail.value(forKey: BOOK_ID) ?? "")"
        self.navigationController?.pushViewController(vc, animated: true)
    }

    //MARK:-
    //MARK:- UIButton Clicked Event..
    
    @IBAction func btnBack_Clicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func btnReadMoreORLess_Clicked(_ sender: Any) {
        btnReadMore.isSelected = !btnReadMore.isSelected
        if btnReadMore.isSelected {

            self.lblDesignationDetail.text = "\(dicAuthorDetail.value(forKey: DESIGNATION) ?? "")"
            self.lblEducationDetail.text = "\(dicAuthorDetail.value(forKey: EDUCATION) ?? "")"
            self.lblAddressDetail.text =  "\(dicAuthorDetail.value(forKey: ADDRESS) ?? "")"
            self.lblDescription.text = "\(dicAuthorDetail.value(forKey: DESCRIPTION) ?? "")"
            
            let size = THelper.rectForText(text: "\(self.lblDescription.text ?? "")", font: UIFont.systemFont(ofSize: 14), maxSize: CGSize(width: lblDescription.frame.width, height: 999))
            
            if lblDesignationDetail.text != "" {
                lblDesignation.text = "Designation"
            }
            else {
                lblDesignation.text = ""
            }
            
            if lblAddressDetail.text != "" {
                lblAddress.text = "Address"
            }
            else {
                lblAddress.text = ""
            }
            
            if lblEducationDetail.text != "" {
                lblEduction.text = "Education"
            }
            else {
                lblEduction.text = ""
            }
            
            self.ConstraintheightAuthorDetail.constant = size.height + CGFloat(30 * 3) + 60
            self.VwEducation.isHidden = false
            self.imgAuthorProfile.image!.getColors { colors in
                self.btnReadMore.titleLabel?.textColor = colors?.secondary
            }
            btnReadMore.setTitle("Read less", for: .normal)

        }else {
            self.ConstraintheightAuthorDetail.constant = 80
            self.VwEducation.isHidden = true
            self.imgAuthorProfile.image!.getColors { colors in
                self.btnReadMore.titleLabel?.textColor = colors?.secondary
            }
            btnReadMore.setTitle("Read more", for: .normal)
        }
    }
    
    
    //MARK:-
    //MARK:- API Calling..
    func getAuthorBooksListAPI() {
        THelper.ShowProgress(vc: self)
        let param = ["author_id":self.AuthorID]
        Alamofire.request(TPreferences.getCommonURL(BOOK_LIST)!,method: .get, parameters: param, encoding: JSONEncoding.default,headers: nil).responseJSON { (response:DataResponse<Any>) in
            switch(response.result) {
            case .success( _):
                THelper.hideProgress(vc: self)
                if let data = response.result.value{
                    print(data)
                    var dicData = NSDictionary()
                    dicData = data as! NSDictionary
                    print(dicData)
                    
                    self.arrBooks = dicData.value(forKey: "data") as! NSArray
                    print(self.arrBooks)
                    self.lblTotalPublishBook.text = "\(self.arrBooks.count)"
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
