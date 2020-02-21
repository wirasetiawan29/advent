//
//  SplashViewController.swift
//  Granth

import UIKit

class SplashViewController: UIViewController {
    
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
        self.timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.updateView), userInfo: nil, repeats: true)
    }
    
    //MARK:-
    //MARK:- UpdateView Method
    
    @objc func updateView(){
        timer.invalidate()
        let tabBarController = UITabBarController()
        let tabViewController1 = HomeViewController(nibName: "HomeViewController", bundle: nil)
        let tabViewController2 = RenunganListViewController(nibName: "RenunganListViewController", bundle: nil)
        let tabViewController3 = SiwonListViewController(nibName: "SiwonListViewController", bundle: nil)
        let controllers = [tabViewController1, tabViewController2, tabViewController3]
        tabBarController.viewControllers = controllers

        tabViewController1.tabBarItem = UITabBarItem(title: "Buku", image: UIImage(named: "iconAgenda"), tag: 1)
        tabViewController2.tabBarItem = UITabBarItem(title: "Renungan", image:UIImage(named: "iconText"), tag:2)
        tabViewController3.tabBarItem = UITabBarItem(title: "Lagu Sion", image:UIImage(named: "iconMusic"), tag:3)
        self.navigationController?.pushViewController(tabBarController, animated: true)

//        let vc = HomeViewController(nibName: "HomeViewController", bundle: nil)
//        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension UITabBar {
   override open func sizeThatFits(_ size: CGSize) -> CGSize {
        super.sizeThatFits(size)
        guard let window = UIApplication.shared.keyWindow else {
            return super.sizeThatFits(size)
        }
        var sizeThatFits = super.sizeThatFits(size)
    if #available(iOS 11.0, *) {
        sizeThatFits.height = window.safeAreaInsets.bottom + 50
    } else {
        // Fallback on earlier versions
    }
        return sizeThatFits
    }
}
