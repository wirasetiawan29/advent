//
//  walkthroughViewController.swift
//  Granth

import UIKit

class walkthroughViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    //MARK:-
    //MARK:- Outlet
    @IBOutlet weak var cvWalkThrough: UICollectionView!
    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var constraintHeaderTop: NSLayoutConstraint!
    //MARK:-
    //MARK:- Variables.
    let arrTitle: NSArray = ["EBOOKS","BUY_BOOKS","READ_OFFLINE","RATE_REVIEW"]
    let arrSubTitle: NSArray = ["LOREM_TEXT","LOREM_TEXT","LOREM_TEXT","LOREM_TEXT"]
    let arrImages: NSArray = ["icoLogo","icoLogo","icoLogo","icoLogo"]
    var sectionNumber = 0
    var indexNumber = Int()

    //MARK:-
    //MARK:- View Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.SetuUpObject()
    }
    
    //MARK:-
    //MARK:- SetUpObject Method
    
    func SetuUpObject() {
        if #available(iOS 11.0, *) {
            
        } else {
            constraintHeaderTop.constant = UIApplication.shared.statusBarFrame.size.height
        }
        self.pageControl.numberOfPages = self.arrImages.count
        self.pageControl.currentPageIndicatorTintColor = UIColor.primaryColor()
        self.btnNext = THelper.setButtonTintColor(self.btnNext, imageName: "icoRightArrow", state: .normal, tintColor: UIColor.primaryColor())//icoCheck
        
        let layout = cvWalkThrough.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.itemSize = cvWalkThrough.frame.size
        if let layout = layout {
            cvWalkThrough.collectionViewLayout = layout
        }
        automaticallyAdjustsScrollViewInsets = false
    }
    
    //MARK:-
    //MARK:- CollectionView Delegate and DataSource Method
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        cvWalkThrough.register(UINib(nibName: "WalkthroughCollectionCell", bundle: nil), forCellWithReuseIdentifier: "WalkthroughCell")
        let cell = cvWalkThrough.dequeueReusableCell(withReuseIdentifier: "WalkthroughCell", for: indexPath) as! WalkthroughCollectionCell
        
        cell.lblTitle.text = LanguageLocal.myLocalizedString(key: "\(arrTitle[indexPath.item])")
        cell.lblSubTitle.text = LanguageLocal.myLocalizedString(key: "\(arrSubTitle[indexPath.item])")
        cell.imgWalkthrough.image = UIImage(named: arrImages[indexPath.item] as! String)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.cvWalkThrough.frame.width, height: self.cvWalkThrough.frame.height)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = cvWalkThrough.frame.size.width
        pageControl.currentPage = Int(cvWalkThrough.contentOffset.x / pageWidth)
        indexNumber = pageControl.currentPage
        if indexNumber == 3 {
            self.btnNext = THelper.setButtonTintColor(self.btnNext, imageName: "icoCheck", state: .normal, tintColor: UIColor.primaryColor())//icoCheck
        }
        else {
            self.btnNext = THelper.setButtonTintColor(self.btnNext, imageName: "icoRightArrow", state: .normal, tintColor: UIColor.primaryColor())
        }
    }
    
    
    //MARK:-
    //MARK:- UIButton Clicked Methods.
    
    @IBAction func btnSkip_Clicked(_ sender: Any) {
         TPreferences.writeBoolean(WALKTHROUGH, value: true)
//        let vc = HomeViewController(nibName: "HomeViewController", bundle: nil)
        let tabBarController = UITabBarController()
        let tabViewController1 = HomeViewController(nibName: "HomeViewController", bundle: nil)
        let tabViewController2 = HomeViewController(nibName: "HomeViewController", bundle: nil)
        let tabViewController3 = HomeViewController(nibName: "HomeViewController", bundle: nil)
        let controllers = [tabViewController1, tabViewController2, tabViewController3]
        tabBarController.viewControllers = controllers

        tabViewController1.tabBarItem = UITabBarItem(title: "Buku", image: UIImage(named: "iconAgenda"), tag: 1)
        tabViewController2.tabBarItem = UITabBarItem(title: "Renungan", image:UIImage(named: "iconText"), tag:2)
        tabViewController3.tabBarItem = UITabBarItem(title: "Lagu Sion", image:UIImage(named: "iconMusic"), tag:3)
        self.navigationController?.pushViewController(tabBarController, animated: true)
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnNext_Clicked(_ sender: Any) {
        let visibleItems: NSArray = self.cvWalkThrough.indexPathsForVisibleItems as NSArray
        let currentItem: IndexPath = visibleItems.object(at: 0) as! IndexPath
        let nextItem: IndexPath = IndexPath(item: currentItem.item + 1, section: 0)
        if nextItem.row < arrImages.count {
            self.cvWalkThrough.scrollToItem(at: nextItem, at: .left, animated: true)
            pageControl.currentPage = currentItem.item + 1
            
            if pageControl.currentPage == 3 {
                self.btnNext = THelper.setButtonTintColor(self.btnNext, imageName: "icoCheck", state: .normal, tintColor: UIColor.primaryColor())//icoCheck
            }
            else {
                self.btnNext = THelper.setButtonTintColor(self.btnNext, imageName: "icoRightArrow", state: .normal, tintColor: UIColor.primaryColor())
            }
            
            if pageControl.currentPage == 4 {
                TPreferences.writeBoolean(WALKTHROUGH, value: true)
                let vc = HomeViewController(nibName: "HomeViewController", bundle: nil)
                self.navigationController?.pushViewController(vc, animated: true)
            }else {
                
            }
        }else {
            TPreferences.writeBoolean(WALKTHROUGH, value: true)
            let vc = HomeViewController(nibName: "HomeViewController", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
