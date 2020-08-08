//
//  RegisterViewController.swift
//  Granth

import UIKit
import Alamofire

class RegisterViewController: UIViewController {

//        MARK:-
//        MARK:- Outlets.
    
    @IBOutlet weak var vwBackground: UIView!
    @IBOutlet weak var vwLogin: UIView!
    @IBOutlet weak var vwName: UIView!
    @IBOutlet weak var vwUsername: UIView!
    @IBOutlet weak var vwEmail: UIView!
    @IBOutlet weak var vwPassword: UIView!
    @IBOutlet weak var vwConfirmPassword: UIView!
    @IBOutlet weak var vwMobileNo: UIView!
    
    @IBOutlet weak var btnContinue: UIButton!
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtReEnterPassword: UITextField!
    @IBOutlet weak var txtPhoneNo: UITextField!
    @IBOutlet weak var constraintHeaderTop: NSLayoutConstraint!
    
    //        MARK:-
//        MARK:- View Life Cycles.

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.SetUpObject()
    }
    
//        MARK:-
//        MARK:- SetUpObject Methods.
    
    func SetUpObject() {
        if #available(iOS 11.0, *) {

        } else {
            constraintHeaderTop.constant = UIApplication.shared.statusBarFrame.size.height
        }
        vwBackground.clipsToBounds = true
        vwBackground.layer.cornerRadius = 30
        
        if #available(iOS 11.0, *) {
            vwBackground.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        } else {
            // Fallback on earlier versions
        }
        
        vwLogin.layer.cornerRadius = 5.0
        vwName.layer.cornerRadius = 5.0
        vwUsername.layer.cornerRadius = 5.0
        vwEmail.layer.cornerRadius = 5.0
        vwPassword.layer.cornerRadius = 5.0
        vwConfirmPassword.layer.cornerRadius = 5.0
        vwMobileNo.layer.cornerRadius = 5.0
        btnContinue.layer.cornerRadius = 5.0
        
        vwName.layer.borderColor = UIColor.lightGray.cgColor
        vwName.layer.borderWidth = 1.0
        vwUsername.layer.borderColor = UIColor.lightGray.cgColor
        vwUsername.layer.borderWidth = 1.0
        vwEmail.layer.borderColor = UIColor.lightGray.cgColor
        vwEmail.layer.borderWidth = 1.0
        vwPassword.layer.borderColor = UIColor.lightGray.cgColor
        vwPassword.layer.borderWidth = 1.0
        vwConfirmPassword.layer.borderColor = UIColor.lightGray.cgColor
        vwConfirmPassword.layer.borderWidth = 1.0
        vwMobileNo.layer.borderColor = UIColor.lightGray.cgColor
        vwMobileNo.layer.borderWidth = 1.0
        
        vwLogin.layer.shadowColor = UIColor.black.cgColor
        vwLogin.layer.shadowOpacity = 0.5
        vwLogin.layer.shadowOffset = CGSize(width: 0, height: 0)
        vwLogin.layer.shadowRadius = 2
    }
    
//        MARK:-
//        MARK:- UIButton Clicked Events
    
    @IBAction func btnContinue_clicked(_ sender: Any) {
        if self.txtName.text?.count != 0 {
            if TValidation.isAlphaNumeric(withDotAndSpace: self.txtName.text) {
                if TValidation.isAlphaNumeric(withDotAndSpace: self.txtUserName.text) {
                    if TValidation.isValidEmail(self.txtEmail.text) {
                        if TValidation.isAlphaNumeric(self.txtPassword.text) {
                            if self.txtPassword.text == self.txtReEnterPassword.text {
                                if TValidation.isNumericOnly(self.txtPhoneNo.text){
                                    self.signUpAPI()
                                }else {
                                    print("Enter Valid  Phone Number")
                                }
                            }else {
                                print("Enter Valid  Re-password")
                            }
                        }else {
                            print("Enter Valid password")
                        }
                    }else {
                        print("The email must be a valid email address.")
                    }
                }else {
                    print("The username field is required.")
                }
            }else {
                print("The name format is invalid.")
            }
        }else {
            THelper.toast("both Field are required", vc: self)
        }
    }
    
    
    @IBAction func btnBack_Clicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:-
    //MARK:- API Calling..
    
    func signUpAPI() {
        THelper.ShowProgress(vc: self)
        
        let param = ["id":"-1",
                     "username": self.txtUserName.text ?? "",
                     "name": self.txtName.text ?? "",
                     "email": self.txtEmail.text ?? "",
                     "password": self.txtPassword.text ?? "",
                     "contact_number": self.txtPhoneNo.text ?? ""
            ] as [String : Any]
        Alamofire.request(TPreferences.getCommonURL(REGISTER)!,method: .post, parameters: param, encoding: JSONEncoding.default,headers: nil).responseJSON { (response:DataResponse<Any>) in
            switch(response.result) {
            case .success( _):
                THelper.hideProgress(vc: self)
                if let data = response.result.value{
                    print(data)
                    var dicData = NSDictionary()
                    dicData = data as! NSDictionary
                    let dicTemp:NSDictionary = dicData.value(forKey: "data") as! NSDictionary
                    print(dicTemp)
                    
                    TPreferences.writeString(API_TOKEN, value: dicTemp.value(forKey: API_TOKEN) as? String)
                    TPreferences.writeString(USERNAME, value: dicTemp.value(forKey: USERNAME) as? String)
                    TPreferences.writeString(NAME, value: dicTemp.value(forKey: NAME) as? String)
                    TPreferences.writeString(CONTACT_NUMBER, value: dicTemp.value(forKey: CONTACT_NUMBER) as? String)
                    TPreferences.writeString(EMAIL, value: dicTemp.value(forKey: EMAIL) as? String)
                
                    self.navigationController?.popViewController(animated: true)
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
