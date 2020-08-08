//
//  EditProfileViewController.swift
//  Granth

import UIKit
import Alamofire
import GoogleMobileAds

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GADInterstitialDelegate{

    @IBOutlet weak var constraintHeaderTop: NSLayoutConstraint!
    
    @IBOutlet weak var vwFullName: UIView!
    @IBOutlet weak var vwUserName: UIView!
    @IBOutlet weak var vwEmail: UIView!
    @IBOutlet weak var vwMobileNo: UIView!
    @IBOutlet weak var vwUserImage: UIView!
    
    @IBOutlet weak var btnChangeImage: UIButton!
    
    @IBOutlet weak var imgUser: UIImageView!
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    
    @IBOutlet weak var txtPhoneNo: UITextField!
    
    var interstitial: GADInterstitial!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.SetUpObject()
    }
    
    //MARK:-
    //MARK:- SetUpObject Methods.
    
    func SetUpObject() {
        if #available(iOS 11.0, *) {
            
        } else {
            constraintHeaderTop.constant = UIApplication.shared.statusBarFrame.size.height
        }
        
        if IPAD {
            imgUser.layer.cornerRadius = 120 / 2
            btnChangeImage.layer.cornerRadius = 40 / 2
        }else  {
            imgUser.layer.cornerRadius = imgUser.frame.height / 2
            btnChangeImage.layer.cornerRadius = btnChangeImage.frame.height / 2
        }
        
        vwFullName.layer.cornerRadius = 5.0
        vwUserName.layer.cornerRadius = 5.0
        vwEmail.layer.cornerRadius = 5.0
        vwMobileNo.layer.cornerRadius = 5.0
        imgUser.layer.borderColor = UIColor.gray.cgColor
        imgUser.layer.borderWidth = 1.0
        
        vwFullName.layer.borderColor = UIColor.lightGray.cgColor
        vwFullName.layer.borderWidth = 1.0
        vwUserName.layer.borderColor = UIColor.lightGray.cgColor
        vwUserName.layer.borderWidth = 1.0
        vwEmail.layer.borderColor = UIColor.lightGray.cgColor
        vwEmail.layer.borderWidth = 1.0
        vwMobileNo.layer.borderColor = UIColor.lightGray.cgColor
        vwMobileNo.layer.borderWidth = 1.0
        
        
        self.txtName.text = TPreferences.readString(NAME)
        self.txtUserName.text = TPreferences.readString(USERNAME)
        self.txtEmail.text = TPreferences.readString(EMAIL)
        self.txtPhoneNo.text = TPreferences.readString(CONTACT_NUMBER)
        
        if TPreferences.readString(IMAGE) == "" {
            imgUser.image = UIImage(named: "icoProfile1")
        }
        else {
            THelper.setImage(img: imgUser, url: URL(string: "\(TPreferences.readString(IMAGE) ?? "icoProfile1")")!, placeholderImage: "icoProfile1")
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
    //MARK:- UIImagePickerView Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let img = info[.originalImage] as? UIImage
        self.imgUser.image = img
        picker.dismiss(animated: true, completion: nil)
    }
    
    //MARK:-
    //MARK:- Other Methods
    
    func openCamera()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have permission to access gallery.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //        MARK:-
    //        MARK:- UIButton Clicked Events
    
    @IBAction func btnChangeImage_Click(_ sender: Any) {        
        let alert = UIAlertController(title: "Choose Options", message: "", preferredStyle: .actionSheet)
        let GalleryAction = UIAlertAction(title: "Gallery", style: .default, handler: { action in
            self.openGallery()
        })
        
        let CameraAction = UIAlertAction(title: "Camera", style: .default, handler: { action in
            self.openCamera()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(GalleryAction)
        alert.addAction(CameraAction)
        alert.addAction(cancelAction)
        
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = CGRect(x: (SCREEN_SIZE.width / 2) - 150, y: SCREEN_SIZE.height, width: 300, height: 300)
        alert.popoverPresentationController?.permittedArrowDirections = .down
        present(alert, animated: true)
    }
    
    
    @IBAction func btnSave_Clicked(_ sender: Any) {
        SaveUserProfileImageAPI()
    }
    
    @IBAction func btnBack_Clicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //        MARK:-
    //        MARK:- API Calling
    
    func SaveUserProfileImageAPI() {
        THelper.ShowProgress(vc: self)
        
        let image = imgUser.image
        let imgData = THelper.compressImageFromSize(image: image)
        print(imgData?.base64EncodedString() ?? "")
        
        let parameters = ["id": Int("\(TPreferences.readString(USER_ID) ?? "0")") ?? 0,
                          USERNAME: self.txtUserName.text ?? "",
                          NAME: self.txtName.text ?? "",
                          EMAIL: self.txtEmail.text ?? "",
                          CONTACT_NUMBER: self.txtPhoneNo.text ?? ""
            ] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject:parameters)
        
        print(parameters)
        print(THelper.setImageName() ?? "")
        
        let Auth_header = ["Authorization" : "Bearer \(TPreferences.readString(API_TOKEN)!)"]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in    
            multipartFormData.append(imgData!, withName: "image",fileName: THelper.setImageName()!, mimeType: "image/*")
            multipartFormData.append(jsonData!, withName: "user_detail")
            
        }, usingThreshold: UInt64.init(), to:TPreferences.getCommonURL(SAVE_USER_PROFILE)!, method: .post, headers: Auth_header)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    THelper.hideProgress(vc: self)
                    if let data = response.result.value{
                        let responseJson: NSDictionary = data as! NSDictionary
                        print(responseJson)
                        let dicData: NSDictionary = responseJson.value(forKey: "data") as! NSDictionary
                        
                        TPreferences.writeString(EMAIL, value: dicData.value(forKey: EMAIL) as? String)
                        TPreferences.writeString(USERNAME, value: dicData.value(forKey: USERNAME)as? String)
                        TPreferences.writeString(CONTACT_NUMBER, value: dicData.value(forKey: CONTACT_NUMBER)as? String)
                        TPreferences.writeString(NAME, value: dicData.value(forKey: NAME)as? String)
                        TPreferences.writeString(USER_ID, value: "\(dicData.value(forKey: ID) ?? "")")
                        TPreferences.writeString(IMAGE, value: "\(dicData.value(forKey: IMAGE) ?? "")")
                    }
                    else {
                        print(response.result.error ?? "Something went wrong")
                    }
                }
                break

            case .failure(let encodingError):
                 THelper.hideProgress(vc: self)
                print(encodingError)
            }
        }
    }
}
