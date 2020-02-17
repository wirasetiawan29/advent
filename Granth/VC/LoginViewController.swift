//
//  LoginViewController.swift
//  Granth

import UIKit
import Alamofire
import GoogleSignIn
class LoginViewController: UIViewController {

//        MARK:-
//        MARK:- Outlets.
    
    @IBOutlet weak var vwBackground: UIView!
    @IBOutlet weak var vwLogin: UIView!
    
    @IBOutlet weak var vwEmail: UIView!
    @IBOutlet weak var vwPassword: UIView!
    @IBOutlet weak var btnSignin: UIButton!
    
    @IBOutlet weak var googleButton: GIDSignInButton!
    @IBOutlet weak var imgRemberMe: UIImageView!
    @IBOutlet weak var btnRember: UIButton!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassWord: UITextField!
    
//        MARK:-
//        MARK:- View Life Cycles.
    override func viewDidLoad() {
        super.viewDidLoad()

        self.SetUpObject()
        self.setupGoogleButtons()
        self.setupGoogleSignIn()

    }
    
//        MARK:-
//        MARK:- SetUpObject Methods.
    
    func SetUpObject() {
        vwBackground.clipsToBounds = true
        vwBackground.layer.cornerRadius = 30
        
        if #available(iOS 11.0, *) {
            vwBackground.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        } else {
            // Fallback on earlier versions
            
        }
        self.imgRemberMe.image = UIImage(named: "icocheckbox")
        self.imgRemberMe = THelper.setTintColor(self.imgRemberMe, tintColor: UIColor.primaryColor())
        
        
        vwEmail.layer.borderColor = UIColor.lightGray.cgColor
        vwEmail.layer.borderWidth = 1.0
        vwPassword.layer.borderColor = UIColor.lightGray.cgColor
        vwPassword.layer.borderWidth = 1.0
        
        vwLogin.layer.cornerRadius = 5.0
        vwEmail.layer.cornerRadius = 5.0
        vwPassword.layer.cornerRadius = 5.0
        btnSignin.layer.cornerRadius = 5.0
        
        //apply shadow
        
        vwLogin.layer.shadowColor = UIColor.black.cgColor
        vwLogin.layer.shadowOpacity = 0.5
        vwLogin.layer.shadowOffset = CGSize(width: 0, height: 0)
        vwLogin.layer.shadowRadius = 2
        
        if TPreferences.readBoolean(REMEMBER) == false {
            self.txtEmail.text = ""
            self.txtPassWord.text = ""
             self.imgRemberMe.image = UIImage(named: "icocheckbox")
            self.imgRemberMe = THelper.setTintColor(self.imgRemberMe, tintColor: UIColor.primaryColor())
        }else {
            self.txtEmail.text = TPreferences.readString(EMAIL)
            self.txtPassWord.text = TPreferences.readString(PASSWORD)
             self.imgRemberMe.image = UIImage(named: "icoCheck-1")
            self.imgRemberMe = THelper.setTintColor(self.imgRemberMe, tintColor: UIColor.primaryColor())
        }
        
    }

    func setupGoogleSignIn() {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        NotificationCenter.default.addObserver(self,
                selector: #selector(LoginViewController.receiveToggleAuthUINotification(_:)),
                name: NSNotification.Name(rawValue: "ToggleAuthUINotification"),
                object: nil)
        toggleAuthUI()
    }

    func toggleAuthUI() {
         if let _ = GIDSignIn.sharedInstance()?.currentUser?.authentication {
             self.txtEmail.text = TPreferences.readString(EMAIL)
             self.txtPassWord.text = TPreferences.readString(PASSWORD)
             self.imgRemberMe.image = UIImage(named: "icoUncheck")
             self.imgRemberMe = THelper.setTintColor(self.imgRemberMe, tintColor: UIColor.primaryColor())
             self.btnRember.isSelected = true

               TPreferences.writeBoolean(REMEMBER, value: true)

            let email = GIDSignIn.sharedInstance()?.currentUser.profile.email
            let name = GIDSignIn.sharedInstance()?.currentUser.profile.name
            let userId = GIDSignIn.sharedInstance()?.currentUser.userID
            let token = GIDSignIn.sharedInstance()?.currentUser.authentication.idToken


               TPreferences.writeString(EMAIL, value: email)
               TPreferences.writeString(API_TOKEN, value: token)
               TPreferences.writeString(NAME, value: name)
               TPreferences.writeString(USER_ID, value: userId)
               print(TPreferences.readString(USER_ID) ?? "")
               let tabBarController = UITabBarController()
               let tabViewController1 = HomeViewController(nibName: "HomeViewController", bundle: nil)
               let tabViewController2 = RenunganListViewController(nibName: "RenunganListViewController", bundle: nil)
               let tabViewController3 = HomeViewController(nibName: "HomeViewController", bundle: nil)
               let controllers = [tabViewController1, tabViewController2, tabViewController3]
               tabBarController.viewControllers = controllers

               tabViewController1.tabBarItem = UITabBarItem(title: "Buku", image: UIImage(named: "iconAgenda"), tag: 1)
               tabViewController2.tabBarItem = UITabBarItem(title: "Renungan", image:UIImage(named: "iconText"), tag:2)
               tabViewController3.tabBarItem = UITabBarItem(title: "Lagu Sion", image:UIImage(named: "iconMusic"), tag:3)

               TPreferences.writeBoolean(IS_LOGINING, value: true)
               self.navigationController?.pushViewController(tabBarController, animated: true)

         }
       }

    deinit {
         NotificationCenter.default.removeObserver(self,
             name: NSNotification.Name(rawValue: "ToggleAuthUINotification"),
             object: nil)
       }

       @objc func receiveToggleAuthUINotification(_ notification: NSNotification) {
         if notification.name.rawValue == "ToggleAuthUINotification" {
           self.toggleAuthUI()
           if notification.userInfo != nil {
             guard let userInfo = notification.userInfo as? [String:String] else { return }
//             self.titleLabel.text = userInfo["statusText"]!
//               saveUser(self.titleLabel.text)
           }
         }
       }

    fileprivate func setupGoogleButtons() {

              GIDSignIn.sharedInstance()?.delegate = self
          }
    
    //        MARK:-
    //        MARK:- UIButton Clicked Events
    
    
    @IBAction func btnBack_Clicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func btnRemeber_Clicked(_ sender: Any) {
        if btnRember.isSelected == false {
            self.btnRember.isSelected = true
            self.imgRemberMe.image = UIImage(named: "icocheckbox")
            self.imgRemberMe = THelper.setTintColor(self.imgRemberMe, tintColor: UIColor.primaryColor())
        }else {
            
            self.btnRember.isSelected = false
            self.imgRemberMe.image = UIImage(named: "icoCheck-1")
            self.imgRemberMe = THelper.setTintColor(self.imgRemberMe, tintColor: UIColor.primaryColor())
        }
    }
    
    
    @IBAction func btnSignclick(_ sender: Any) {
        if txtEmail.text!.count > 0 {
            if txtPassWord.text!.count > 0 {
                LoginAPI()
            }else {
                THelper.toast("Please Enter password", vc: self)
            }
        }
        else {
            THelper.toast("Please Enter Email", vc: self)
        }
    }
    
    @IBAction func btnCreateaccount(_ sender: Any) {
        let vc = RegisterViewController(nibName: "RegisterViewController", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnForgotpassword(_ sender: Any) {
        let vc = ForgotPasswordViewController(nibName: "ForgotPasswordViewController", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK:-
    //MARK:- API Calling..
    
    func LoginAPI() {
        THelper.ShowProgress(vc: self)
    
        let param = ["email":txtEmail.text ?? "",
                     "password":txtPassWord.text ?? "",
                     "device_id": TPreferences.readString(UDID) ?? "",
                     "registeration_id": "-1"
                    ] as [String : Any]
        
        Alamofire.request(TPreferences.getCommonURL(LOGIN)!,method: .post, parameters: param, encoding: JSONEncoding.default,headers: nil).responseJSON { (response:DataResponse<Any>) in
            switch(response.result) {
            case .success( _):
                THelper.hideProgress(vc: self)
                if let data = response.result.value{
                    print(data)
                    var dicData = NSDictionary()
                    dicData = data as! NSDictionary
                    print(dicData)
                    
                    if dicData.value(forKey: "data") != nil {
                        let dicLogin: NSDictionary = dicData.value(forKey: "data") as! NSDictionary
                        
                        if self.btnRember.isSelected == false {
                            self.txtEmail.text = ""
                            self.txtPassWord.text = ""
                            self.imgRemberMe.image = UIImage(named: "icoUncheck")
                            self.imgRemberMe = THelper.setTintColor(self.imgRemberMe, tintColor: UIColor.primaryColor())
                            self.btnRember.isSelected = false
                        }else {
                            self.txtEmail.text = TPreferences.readString(EMAIL)
                            self.txtPassWord.text = TPreferences.readString(PASSWORD)
                            self.imgRemberMe.image = UIImage(named: "icoUncheck")
                            self.imgRemberMe = THelper.setTintColor(self.imgRemberMe, tintColor: UIColor.primaryColor())
                            self.btnRember.isSelected = true
                        }
                        
                        TPreferences.writeBoolean(REMEMBER, value: true)
                        
                        TPreferences.writeString(EMAIL, value: dicLogin.value(forKey: EMAIL) as? String)
                        TPreferences.writeString(PASSWORD, value: self.txtPassWord.text)
                        TPreferences.writeString(USERNAME, value: dicLogin.value(forKey: USERNAME)as? String)
                        TPreferences.writeString(API_TOKEN, value: dicLogin.value(forKey: API_TOKEN)as? String)
                        TPreferences.writeString(CONTACT_NUMBER, value: dicLogin.value(forKey: CONTACT_NUMBER)as? String)
                        TPreferences.writeString(NAME, value: dicLogin.value(forKey: NAME)as? String)
                        TPreferences.writeString(USER_ID, value: "\(dicLogin.value(forKey: ID) ?? "")")
                        print(TPreferences.readString(USER_ID) ?? "")
                        let tabBarController = UITabBarController()
                        let tabViewController1 = HomeViewController(nibName: "HomeViewController", bundle: nil)
                        let tabViewController2 = RenunganListViewController(nibName: "RenunganListViewController", bundle: nil)
                        let tabViewController3 = HomeViewController(nibName: "HomeViewController", bundle: nil)
                        let controllers = [tabViewController1, tabViewController2, tabViewController3]
                        tabBarController.viewControllers = controllers

                        tabViewController1.tabBarItem = UITabBarItem(title: "Buku", image: UIImage(named: "iconAgenda"), tag: 1)
                        tabViewController2.tabBarItem = UITabBarItem(title: "Renungan", image:UIImage(named: "iconText"), tag:2)
                        tabViewController3.tabBarItem = UITabBarItem(title: "Lagu Sion", image:UIImage(named: "iconMusic"), tag:3)

                        TPreferences.writeBoolean(IS_LOGINING, value: true)
                        self.navigationController?.pushViewController(tabBarController, animated: true)
//                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    else {
                        
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

extension LoginViewController : GIDSignInDelegate {
    //MARK: delegate
       func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
           if let _ = signIn.currentUser?.authentication {
               let homeViewController = HomeViewController()
                    let navController = UINavigationController(rootViewController: homeViewController)
                    navController.isNavigationBarHidden = true
                    UIApplication.shared.keyWindow?.rootViewController = navController
           } else {
               print("error")
           }
       }

}
