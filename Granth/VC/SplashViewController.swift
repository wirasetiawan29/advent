//
//  SplashViewController.swift
//  Granth

import UIKit

class SplashViewController: UIViewController {
    
    //MARK:-
    //MARK:- Outlet
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    
    @IBOutlet weak var icoLogo: UIImageView!
    
    //MARK:-
    //MARK:- Variables
    
    var timer: Timer!
    
    
    //MARK:-
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpObject()
    }
    
    //MARK:-
    //MARK:- SetUpObject Method

    func setUpObject() {
        self.lblTitle.text = LanguageLocal.myLocalizedString(key: "GRANTH")
        self.lblSubTitle.text = LanguageLocal.myLocalizedString(key:"WELCOME_MSG")
        self.timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.updateView), userInfo: nil, repeats: true)
        
        icoLogo.layer.cornerRadius = 10.0
        icoLogo.layer.masksToBounds = true
    }
    
    //MARK:-
    //MARK:- UpdateView Method
    
    @objc func updateView(){
        timer.invalidate()
        let vc = HomeViewController(nibName: "HomeViewController", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
