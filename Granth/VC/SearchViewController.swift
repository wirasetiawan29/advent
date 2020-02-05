//
//  SearchViewController.swift
//  Granth

import UIKit
import MultiSlider
import  Alamofire
import GoogleMobileAds

class SearchViewController: UIViewController, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, GADInterstitialDelegate {
    
    
    //MARK:-
    //MARK:- Outlet
    
    @IBOutlet weak var vwSlider: UIView!
    
    @IBOutlet weak var lblMin: UILabel!
    @IBOutlet weak var lblMax: UILabel!
    @IBOutlet weak var lblByPrice: UILabel!
    @IBOutlet weak var lblByRating: UILabel!
    
    @IBOutlet weak var vwBlur: UIView!
    @IBOutlet weak var vwRatting: UIView!
    @IBOutlet weak var vwHeader: UIView!
    
    @IBOutlet weak var cvBooks: UICollectionView!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnFilterList: UIButton!
    @IBOutlet weak var btnNil: UIButton!
    @IBOutlet weak var btn1Star: UIButton!
    @IBOutlet weak var btn2Star: UIButton!
    @IBOutlet weak var btn3Star: UIButton!
    @IBOutlet weak var btn4Star: UIButton!
    @IBOutlet weak var btn5Star: UIButton!
    
    @IBOutlet weak var txtSearch: UISearchBar!
    @IBOutlet weak var constraintHeightArea: NSLayoutConstraint!
    
    @IBOutlet weak var vwSearch: UIView!
    
    @IBOutlet weak var btn1StarImg: UIButton!
    @IBOutlet weak var btn2StarImg: UIButton!
    @IBOutlet weak var btn3StarImg: UIButton!
    @IBOutlet weak var btn4StarImg: UIButton!
    @IBOutlet weak var btn5StarImg: UIButton!
    
    @IBOutlet weak var vwNil: UIView!
    @IBOutlet weak var vw1Star: UIView!
    @IBOutlet weak var vw2Star: UIView!
    @IBOutlet weak var vw3Star: UIView!
    @IBOutlet weak var vw4Star: UIView!
    @IBOutlet weak var vw5Star: UIView!
    
    @IBOutlet weak var lbl1Star: UILabel!
    @IBOutlet weak var lbl2Star: UILabel!
    @IBOutlet weak var lbl3Star: UILabel!
    @IBOutlet weak var lbl4Star: UILabel!
    @IBOutlet weak var lbl5Star: UILabel!
    
    //MARK:-
    //MARK:- Variables
    let slider = MultiSlider()
    var timer = Timer()
    var arrBooks = NSArray()
    var strSearch = String()
    
    var interstitial: GADInterstitial!
    
    //MARK:-
    //MARK:- View Life Cycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.SetUpObject()
    }
    
    //MARK:-
    //MARK:- SetUpObject Method
    
    func SetUpObject() {
        if #available(iOS 11.0, *) {
            
        } else {
            self.constraintHeightArea.constant = UIApplication.shared.statusBarFrame.size.height
        }
        
        self.vwNil.layer.cornerRadius = 5.0
        self.vw1Star.layer.cornerRadius = 5.0
        self.vw2Star.layer.cornerRadius = 5.0
        self.vw3Star.layer.cornerRadius = 5.0
        self.vw4Star.layer.cornerRadius = 5.0
        self.vw5Star.layer.cornerRadius = 5.0
        
        self.vwSearch.layer.cornerRadius = 5.0
        self.vwSearch.layer.shadowColor = UIColor(hexString: VIEWALLCOLOR, alpha: 0.5).cgColor
        self.vwSearch.layer.shadowOpacity = 1.0
        self.vwSearch.layer.shadowRadius = 1.0
        self.vwSearch.layer.shadowOffset = .zero
        
        THelper.setHeaderShadow(view: vwHeader)
        
        self.lblByPrice.text = LanguageLocal.myLocalizedString(key: "BY_PRICE")
        self.lblByRating.text = LanguageLocal.myLocalizedString(key: "BY_RATING")
        self.btnCancel.setTitle(LanguageLocal.myLocalizedString(key: "CANCEL"), for: .normal)
        self.btnFilterList.setTitle(LanguageLocal.myLocalizedString(key: "FILTER_LIST"), for: .normal)
        
        if IPAD {
            self.slider.frame = CGRect(x: 32, y: 0, width: UIScreen.main.bounds.width - 64 , height: 40)
        }else {
            self.slider.frame = CGRect(x: 24, y: 0, width: vwSlider.frame.width - 48, height: 30)
        }
        
        slider.minimumValue = 0
        slider.maximumValue = 1000
        slider.value = [0, 1000]

        var imgTemp = UIImageView()
        imgTemp.image = UIImage(named: "icoDot")
        imgTemp = THelper.setTintColor(imgTemp, tintColor: UIColor.primaryColor())!

        slider.thumbImage = imgTemp.image
//        slider.valueLabelFormatter.positivePrefix = "\(PRICE_SIGN)"
        slider.outerTrackColor = .lightGray
        slider.orientation = .horizontal
//        slider.valueLabelPosition = .top // .notAnAttribute = don't show labels
        slider.tintColor = ThemeManager.shared()?.color(forKey: "Primary_Default_Color") // color of track
        slider.trackWidth = 10
        slider.hasRoundTrackEnds = true

        vwSlider.addSubview(slider)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap( _:)))
        vwBlur.addGestureRecognizer(tap)
                
        if strSearch != "" {
            txtSearch.text = strSearch
            SearchBooksListAPI(searchText: strSearch as NSString)
        }
        
        interstitial = GADInterstitial(adUnitID: INTERSTITIAL_ID)
        let request = GADRequest()
        interstitial.load(request)
        interstitial.delegate = self
    }
    
    //MARK:-
    //MARK:- GADInterstitialDelegate
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        interstitial.present(fromRootViewController: self)
    }
    
    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    //MARK:-
    //MARK:- UITapGestureRecognizer.
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        vwBlur.isHidden = true
        vwRatting.isHidden = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if self.txtSearch.text!.count > 0  {
            SearchBooksListAPI(searchText: self.txtSearch!.text! as NSString)
            self.txtSearch.resignFirstResponder()
        }
        else {
            THelper.toast("Enter search text", vc: self)
            self.txtSearch.resignFirstResponder()
        }
    }
    
    //MARK:-
    //MARK:- UICollectionView Delegate and DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrBooks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        self.cvBooks.register(UINib(nibName: "SearchCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SearchCell")
        let cell = self.cvBooks.dequeueReusableCell(withReuseIdentifier: "SearchCell", for: indexPath) as! SearchCollectionViewCell
        let dicBookDetail:NSDictionary = self.arrBooks[indexPath.row] as! NSDictionary
        cell.lblBookName.text = "\(dicBookDetail.value(forKey: NAME) ?? "")"
        cell.lblAuthorName.text = "by \(dicBookDetail.value(forKey: AUTHOR_NAME) ?? "")"
        cell.lblBookPrice.text = "\(PRICE_SIGN)\(dicBookDetail.value(forKey: PRICE) ?? "")"
        cell.lblBookType.text = "\(dicBookDetail.value(forKey: CATEGORY_NAME) ?? "")"
        THelper.setImage(img: cell.imgBookimage, url: URL(string: "\(dicBookDetail.value(forKey: FRONT_COVER) ?? "")")!, placeholderImage: PLACEHOLDERIMAGE)
        THelper.setHeaderShadow(view: cell)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cvBooks.frame.width - 16, height: 120)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dicBookDetail:NSDictionary = self.arrBooks[indexPath.row] as! NSDictionary
        let vc = BookDetailViewController(nibName: "BookDetailViewController", bundle: nil)
        vc.strBookId = "\(dicBookDetail.value(forKey: BOOK_ID) ?? "")"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK:-
    //MARK:- UIbutton Clicked Events
    
    
    @IBAction func btnFilterList_clicked(_ sender: Any) {
        self.vwBlur.isHidden = true
        self.vwRatting.isHidden = true
    }
    
    @IBAction func btnCancel_Clicked(_ sender: Any) {
        self.vwBlur.isHidden = true
        self.vwRatting.isHidden = true
    }
    
    @IBAction func btnFilter_Clicked(_ sender: Any) {
        self.vwBlur.isHidden = false
        self.vwRatting.isHidden = false
    }
    
    @IBAction func btnBack_Clicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func btnNil_Clicked(_ sender: Any) {
        self.btnBackVwColor(SelectedvwName: vwNil, vw1Name: vw1Star, vw2Name: vw2Star, vw3Name: vw3Star, vw4Name: vw4Star, vw5Name: vw5Star)
        self.btnNil.setTitleColor(UIColor.white, for: .normal)
        self.lbl1Star.textColor = UIColor.lightGray
        self.lbl2Star.textColor = UIColor.lightGray
        self.lbl3Star.textColor = UIColor.lightGray
        self.lbl4Star.textColor = UIColor.lightGray
        self.lbl5Star.textColor = UIColor.lightGray
        self.btn1StarImg = THelper.setButtonTintColor(self.btn1StarImg, imageName: "icoStar", state: .normal, tintColor: UIColor.lightGray)
         self.btnImgTintColor(SelectedBtnName: btn1StarImg, btn2Name: btn2StarImg, btn3Name: btn3StarImg, btn4Name: btn4StarImg, btn5Name: btn5StarImg)
    }
    
    
    @IBAction func btn1Star_Clicked(_ sender: Any) {
        self.btnBackVwColor(SelectedvwName: vw1Star, vw1Name: vwNil, vw2Name: vw2Star, vw3Name: vw3Star, vw4Name: vw4Star, vw5Name: vw5Star)
        self.btnNil.setTitleColor(UIColor.primaryColor(), for: .normal)
        self.lbl1Star.textColor = UIColor.white
        self.lbl2Star.textColor = UIColor.lightGray
        self.lbl3Star.textColor = UIColor.lightGray
        self.lbl4Star.textColor = UIColor.lightGray
        self.lbl5Star.textColor = UIColor.lightGray
        self.btnImgTintColor(SelectedBtnName: btn1StarImg, btn2Name: btn2StarImg, btn3Name: btn3StarImg, btn4Name: btn4StarImg, btn5Name: btn5StarImg)
    }
    
    
    
    @IBAction func btn2Star_Clicked(_ sender: Any) {
        self.btnBackVwColor(SelectedvwName: vw2Star, vw1Name: vw1Star, vw2Name: vwNil, vw3Name: vw3Star, vw4Name: vw4Star, vw5Name: vw5Star)
        self.btnNil.setTitleColor(UIColor.primaryColor(), for: .normal)
        self.lbl2Star.textColor = UIColor.white
        self.lbl1Star.textColor = UIColor.lightGray
        self.lbl3Star.textColor = UIColor.lightGray
        self.lbl4Star.textColor = UIColor.lightGray
        self.lbl5Star.textColor = UIColor.lightGray
        self.btnImgTintColor(SelectedBtnName: btn2StarImg, btn2Name: btn1StarImg, btn3Name: btn3StarImg, btn4Name: btn4StarImg, btn5Name: btn5StarImg)
    }
    
    
    @IBAction func btn3Star_Clicked(_ sender: Any) {
        self.btnBackVwColor(SelectedvwName: vw3Star, vw1Name: vw1Star, vw2Name: vw2Star, vw3Name: vwNil, vw4Name: vw4Star, vw5Name: vw5Star)
        self.btnNil.setTitleColor(UIColor.primaryColor(), for: .normal)
        self.lbl3Star.textColor = UIColor.white
        self.lbl1Star.textColor = UIColor.lightGray
        self.lbl2Star.textColor = UIColor.lightGray
        self.lbl4Star.textColor = UIColor.lightGray
        self.lbl5Star.textColor = UIColor.lightGray
        self.btnImgTintColor(SelectedBtnName: btn3StarImg, btn2Name: btn1StarImg, btn3Name: btn2StarImg, btn4Name: btn4StarImg, btn5Name: btn5StarImg)
    }
    
    @IBAction func btn4Star_Clicked(_ sender: Any) {
        self.btnBackVwColor(SelectedvwName: vw4Star, vw1Name: vw1Star, vw2Name: vw2Star, vw3Name: vw3Star, vw4Name: vwNil, vw5Name: vw5Star)
        self.btnNil.setTitleColor(UIColor.primaryColor(), for: .normal)
        self.lbl4Star.textColor = UIColor.white
        self.lbl1Star.textColor = UIColor.lightGray
        self.lbl3Star.textColor = UIColor.lightGray
        self.lbl2Star.textColor = UIColor.lightGray
        self.lbl5Star.textColor = UIColor.lightGray
        self.btnImgTintColor(SelectedBtnName: btn4StarImg, btn2Name: btn1StarImg, btn3Name: btn3StarImg, btn4Name: btn2StarImg, btn5Name: btn5StarImg)
    }
    
    
    @IBAction func btn5Star_Clicked(_ sender: Any) {
        self.btnBackVwColor(SelectedvwName: vw5Star, vw1Name: vw1Star, vw2Name: vw2Star, vw3Name: vw3Star, vw4Name: vw4Star, vw5Name: vwNil)
        self.btnNil.setTitleColor(UIColor.primaryColor(), for: .normal)
        self.lbl5Star.textColor = UIColor.white
        self.lbl1Star.textColor = UIColor.lightGray
        self.lbl3Star.textColor = UIColor.lightGray
        self.lbl4Star.textColor = UIColor.lightGray
        self.lbl2Star.textColor = UIColor.lightGray
        self.btnImgTintColor(SelectedBtnName: btn5StarImg, btn2Name: btn1StarImg, btn3Name: btn3StarImg, btn4Name: btn4StarImg, btn5Name: btn2StarImg)
    }
    
    //MARK:-
    //MARK:- Other Methods..
    
    func btnBackVwColor(SelectedvwName: UIView,vw1Name: UIView,vw2Name: UIView,vw3Name: UIView,vw4Name: UIView,vw5Name: UIView) {
        
        SelectedvwName.backgroundColor = UIColor.primaryColor()
        vw1Name.backgroundColor = UIColor.white
        vw2Name.backgroundColor = UIColor.white
        vw3Name.backgroundColor = UIColor.white
        vw4Name.backgroundColor = UIColor.white
        vw5Name.backgroundColor = UIColor.white
    }
    
    func btnImgTintColor(SelectedBtnName: UIButton,btn2Name: UIButton,btn3Name: UIButton,btn4Name: UIButton,btn5Name: UIButton) {
        THelper.setButtonTintColor(SelectedBtnName, imageName: "icoStar", state: .normal, tintColor: UIColor.white)
        THelper.setButtonTintColor(btn2Name, imageName: "icoStar", state: .normal, tintColor: UIColor.lightGray)
        THelper.setButtonTintColor(btn3Name, imageName: "icoStar", state: .normal, tintColor: UIColor.lightGray)
        THelper.setButtonTintColor(btn4Name, imageName: "icoStar", state: .normal, tintColor: UIColor.lightGray)
        THelper.setButtonTintColor(btn5Name, imageName: "icoStar", state: .normal, tintColor: UIColor.lightGray)
    }
    
    //MARK:-
    //MARK:- API Calling.. https://iqonic.design/granth/api/book-list?search_text=a&page=1
    
    func SearchBooksListAPI(searchText: NSString) {
        THelper.ShowProgress(vc: self)
        let param = [SEARCH_TEXT: searchText,
                     PAGE: "1"
        ] as [String : Any]
        
        Alamofire.request(TPreferences.getCommonURL(BOOK_LIST)!,method: .get, parameters: param, encoding: JSONEncoding.default,headers: nil).responseJSON { (response:DataResponse<Any>) in
            switch(response.result) {
            case .success( _):
                THelper.hideProgress(vc: self)
                if let data = response.result.value{
                    print(data)
                    var dicData = NSDictionary()
                    dicData = data as! NSDictionary                    
                    self.arrBooks = dicData.value(forKey: "data") as! NSArray
                    print(self.arrBooks)
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
