//
//  SideBarMenuViewController.swift
//  Granth

import UIKit
import FCAlertView
import StoreKit

class SideBarMenuViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, FCAlertViewDelegate {
   
    //MARK:-
    //MARK:- Outlet
    
    @IBOutlet weak var constraintHeaderTop: NSLayoutConstraint!
    
    @IBOutlet weak var tblSideMenu: UITableView!
    
    @IBOutlet weak var imgProfile: UIImageView!
    
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    
    @IBOutlet weak var ConstraintSideMenuHeight: NSLayoutConstraint!
    //MARK:-
    //MARK:- variables
    
    let arrSection: NSArray = ["","SETTINGS","APP"]
    let arrSec: NSArray = ["","APP"]
    let arrSection0: NSArray = ["DASHBOARD","MY_LIBRARY","MY_CART"]
    let arrSec0: NSArray = ["DASHBOARD"]
    let arrSection1: NSArray = ["WISHLIST","TRANSCATION_HISTORY","CHANGE_PASSWORD","LOGOUT"]
    let arrSection2: NSArray = ["SHARE_APP","RATE_APP","PRIVACY_POLICY","TERM_AND_CONDITION","FEEDBACK","INFO"]
    
    let arrImageSection0: NSArray = ["icoHome","icoLibrary","icoCart"]
    let arrImageSection1: NSArray = ["icoBookmark","icoHistory","icoKey","icoLogout"]
    let arrImageSection2: NSArray = ["icoShare", "icoStarOutline", "icoLock", "icoLock", "icoFeedBack", "icoInfo"]
    
    
    //MARK:-
    //MARK:- View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.setUpObject()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setUpObject()
    }
    
    //MARK:-
    //MARK:- SetUpObject Method.
    
    func setUpObject() {
        if #available(iOS 11.0, *) {
            
        } else {
            constraintHeaderTop.constant = UIApplication.shared.statusBarFrame.size.height
        }
        
        if IPAD {
            self.imgProfile.layer.cornerRadius = 140 / 2
        }else {
            self.imgProfile.layer.cornerRadius =  self.imgProfile.layer.frame.size.height / 2
        }
        
        if TPreferences.readBoolean(IS_LOGINING) {
            self.imgProfile.isHidden = false
            self.lblEmail.isHidden = false
            if IPAD {
                self.imgProfile.layer.cornerRadius = 140 / 2
            }else {
                self.imgProfile.layer.cornerRadius =  self.imgProfile.layer.frame.size.height / 2
            }
            self.lblUserName.text = TPreferences.readString(USERNAME)
            self.lblEmail.text = TPreferences.readString(EMAIL)
            if TPreferences.readString(IMAGE) == "" {
                imgProfile.image = UIImage(named: "icoProfile1")
            }
            else {
                THelper.setImage(img: imgProfile, url: URL(string: "\(TPreferences.readString(IMAGE) ?? "")")!, placeholderImage: "icoProfile1")
            }
        }
        else {
            self.imgProfile.isHidden = true
            self.lblEmail.isHidden = true
            self.lblUserName.text = LanguageLocal.myLocalizedString(key: "LOGIN")
        }
        tblSideMenu.reloadData()
    }
    
    //MARK:-
    //MARK:- UITableView Delegate and Data Source Methods.
    func numberOfSections(in tableView: UITableView) -> Int {
       if TPreferences.readBoolean(IS_LOGINING) {
            return arrSection.count
       } else {
            return arrSec.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if TPreferences.readBoolean(IS_LOGINING) {
            let totalCell = arrSection0.count + arrSection1.count + arrSection2.count
            if IPAD {
                self.ConstraintSideMenuHeight.constant = CGFloat((totalCell * 60) + 80)
            }else {
                self.ConstraintSideMenuHeight.constant = CGFloat((totalCell * 50 ) + 60)
            }
            if section == 0 {
                return arrSection0.count
            }else if section == 1 {
                return arrSection1.count
            }else if section == 2 {
                return arrSection2.count
            }else {
                return 0
            }
        } else  {
            let totalCell = arrSection0.count + arrSection1.count
            if IPAD {
                self.ConstraintSideMenuHeight.constant = CGFloat((totalCell * 60) + 80)
            }else {
                self.ConstraintSideMenuHeight.constant = CGFloat((totalCell * 50 ) + 60)
            }
            if section == 0 {
                return arrSec0.count
            }else if section == 1 {
                return arrSection2.count
            } else {
                return 0
            }
        }
       
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if TPreferences.readBoolean(IS_LOGINING) {
            if section == 0 {
                return 0
            }else if section == 1 {
                if IPAD {
                    return 40
                }else {
                    return 30
                }
            }else if section == 2 {
                if IPAD {
                    return 40
                }else {
                    return 30
                }
            }else {
                if IPAD {
                    return 40
                }else {
                    return 30
                }
            }
        }else {
            if section == 0 {
                return 0
            }else if section == 1 {
                if IPAD {
                    return 40
                }else {
                    return 30
                }
            }else {
                if IPAD {
                    return 40
                }else {
                    return 30
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if IPAD {
            return 60
        }else {
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.tblSideMenu.register(UINib(nibName: "SideBarTableViewCell", bundle: nil), forCellReuseIdentifier: "SideCell")
        let cell = self.tblSideMenu.dequeueReusableCell(withIdentifier: "SideCell") as! SideBarTableViewCell
        cell.selectionStyle = .none
        if TPreferences.readBoolean(IS_LOGINING) {
            if indexPath.section == 0 {
                cell.lblLine.isHidden = true
                cell.lblTitle.text = LanguageLocal.myLocalizedString(key: "\(arrSection0[indexPath.row])")
                cell.imgIcon.image = UIImage(named: "\(arrImageSection0[indexPath.row])")
            }else if indexPath.section == 1 {
                if indexPath.row == 0 {
                    cell.lblLine.isHidden = false
                }else {
                    cell.lblLine.isHidden = true
                }
                cell.lblTitle.text = LanguageLocal.myLocalizedString(key: "\(arrSection1[indexPath.row])")
                cell.imgIcon.image = UIImage(named: "\(arrImageSection1[indexPath.row])")
            }else {
                if indexPath.row == 0 {
                    cell.lblLine.isHidden = false
                }else {
                    cell.lblLine.isHidden = true
                }
                cell.lblTitle.text = LanguageLocal.myLocalizedString(key: "\(arrSection2[indexPath.row])")
                cell.imgIcon.image = UIImage(named: "\(arrImageSection2[indexPath.row])")
            }
            
        }else {
            if indexPath.section == 0 {
                cell.lblLine.isHidden = true
                cell.lblTitle.text = LanguageLocal.myLocalizedString(key: "\(arrSection0[indexPath.row])")
                cell.imgIcon.image = UIImage(named: "\(arrImageSection0[0])")
            }else {
                if indexPath.row == 0 {
                    cell.lblLine.isHidden = false
                }else {
                    cell.lblLine.isHidden = true
                }
                cell.lblTitle.text = LanguageLocal.myLocalizedString(key: "\(arrSection2[indexPath.row])")
                cell.imgIcon.image = UIImage(named: "\(arrImageSection2[indexPath.row])")
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if TPreferences.readBoolean(IS_LOGINING) {
            if indexPath.section == 0 {
                if indexPath.row == 0 {
//                    let vc = HomeViewController(nibName: "HomeViewController", bundle: nil)
                    AppDelegate.getDelegate()?.navigationController.popViewController(animated: true)
                    frostedViewController?.hideMenuViewController()
                }
                else if indexPath.row == 1 {
                    let vc = MyLibraryViewController(nibName: "MyLibraryViewController", bundle: nil)
                    AppDelegate.getDelegate()?.navigationController.pushViewController(vc, animated: true)
                    frostedViewController?.hideMenuViewController()
                    
                }else if indexPath.row == 2 {
                    let vc = AddToCartViewController(nibName: "AddToCartViewController", bundle: nil)
                    AppDelegate.getDelegate()?.navigationController.pushViewController(vc, animated: true)
                    frostedViewController?.hideMenuViewController()
                }
            }
            else if indexPath.section == 1 {
                if indexPath.row == 0 {
                    let vc = WishListViewController(nibName: "WishListViewController", bundle: nil)
                    AppDelegate.getDelegate()?.navigationController.pushViewController(vc, animated: true)
                    frostedViewController?.hideMenuViewController()
                }else if indexPath.row == 1 {
                    let vc = TransactionHistoryViewController(nibName: "TransactionHistoryViewController", bundle: nil)
                    AppDelegate.getDelegate()?.navigationController.pushViewController(vc, animated: true)
                    frostedViewController?.hideMenuViewController()
                }else if indexPath.row == 2 {
                    let vc = ChangePasswordViewController(nibName: "ChangePasswordViewController", bundle: nil)
                    AppDelegate.getDelegate()?.navigationController.pushViewController(vc, animated: true)
                    frostedViewController?.hideMenuViewController()
                }else if indexPath.row == 3 {
                    frostedViewController?.hideMenuViewController()
                    THelper.displayAlert(self, title: "Confirmation", message: "Are you sure you want to logout.", tag: 101, firstButton: "Cancel", doneButton: "OK")
                }
            }
            else if indexPath.section == 2 {
                if indexPath.row == 0 {
                    frostedViewController?.hideMenuViewController()
                    let text = ""
                    let textToShare = [ text ]
                    
                    let home = HomeViewController()
                    let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                    activityViewController.popoverPresentationController?.sourceView = home.view // so that iPads won't crash
                    activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
                    present(activityViewController, animated: true, completion: nil)
                    
                }else if indexPath.row == 1 {
                    frostedViewController?.hideMenuViewController()
                    if #available(iOS 10.3, *) {
                        SKStoreReviewController.requestReview()
                    } else {
                        // Fallback on earlier versions
                    }
                    
                }else if indexPath.row == 2 {
                    frostedViewController?.hideMenuViewController()
                    guard let url = URL(string: "https://www.google.com") else { return }
                    UIApplication.shared.open(url)
                }else if indexPath.row == 3 {
                    frostedViewController?.hideMenuViewController()
                    guard let url = URL(string: "https://www.google.com") else { return }
                    UIApplication.shared.open(url)
                }else if indexPath.row == 4 {
                    let vc = FeedbackViewController(nibName: "FeedbackViewController", bundle: nil)
                    AppDelegate.getDelegate()?.navigationController.pushViewController(vc, animated: true)
                    frostedViewController?.hideMenuViewController()
                }else if indexPath.row == 5 {
                    let vc = AboutViewController(nibName: "AboutViewController", bundle: nil)
                    AppDelegate.getDelegate()?.navigationController.pushViewController(vc, animated: true)
                    frostedViewController?.hideMenuViewController()
                }
            }

        }else {
            if indexPath.section == 0 {
                if indexPath.row == 0 {
//                    let vc = HomeViewController(nibName: "HomeViewController", bundle: nil)
//                    AppDelegate.getDelegate()?.navigationController.pushViewController(vc, animated: true)
                    AppDelegate.getDelegate()?.navigationController.popViewController(animated: true)
                    frostedViewController?.hideMenuViewController()
                }
            }
            else if indexPath.section == 1 {
                if indexPath.row == 0 {
                    
                }else if indexPath.row == 1 {
                    
                }else if indexPath.row == 2 {
                   
                }else if indexPath.row == 3 {
                   
                }else if indexPath.row == 4 {
                    let vc = FeedbackViewController(nibName: "FeedbackViewController", bundle: nil)
                    AppDelegate.getDelegate()?.navigationController.pushViewController(vc, animated: true)
                    frostedViewController?.hideMenuViewController()
                }else if indexPath.row == 5 {
                    let vc = AboutViewController(nibName: "AboutViewController", bundle: nil)
                    AppDelegate.getDelegate()?.navigationController.pushViewController(vc, animated: true)
                    frostedViewController?.hideMenuViewController()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if TPreferences.readBoolean(IS_LOGINING) {
            if section == 0 {
                return ""
            }else {
                return LanguageLocal.myLocalizedString(key: "\(arrSection[section])")
            }
        }else {
            if section == 0 {
                return ""
            }else {
                return LanguageLocal.myLocalizedString(key: "\(arrSec[section])")
            }
        }
       
    }
    
    //MARK: -
    //MARK: - fcAlertDoneButtonClicked
    
    func fcAlertDoneButtonClicked(_ alertView: FCAlertView?) {
        if alertView?.tag == 101 {
           print("Logout")
            TPreferences.writeBoolean(IS_LOGINING, value: false)
             NotificationCenter.default.post(name: NSNotification.Name("REMOVE_TOTAL"), object: self, userInfo: ["flag":"1"])
            AppDelegate.getDelegate()?.navigationController.popViewController(animated: true)
        }
    }
    
    //MARK:-
    //MARK:- UIButton Action Methods
    
    @IBAction func btnProfile_Clicked(_ sender: Any) {
        if TPreferences.readBoolean(IS_LOGINING) {
            let vc = EditProfileViewController(nibName: "EditProfileViewController", bundle: nil)
            AppDelegate.getDelegate()?.navigationController.pushViewController(vc, animated: true)
            frostedViewController?.hideMenuViewController()
        }else {
            let vc = LoginViewController(nibName: "LoginViewController", bundle: nil)
            AppDelegate.getDelegate()?.navigationController.pushViewController(vc, animated: true)
            frostedViewController?.hideMenuViewController()
        }
    }

}
