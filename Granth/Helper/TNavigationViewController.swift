//
//  TNavigationViewController.swift

import UIKit

class TNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.panGestureRecognized(_:))))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func showMenu() {
        // Dismiss keyboard (optional)
        //
        view.endEditing(true)
        frostedViewController.view.endEditing(true)
        // Present the view controller
        //
        frostedViewController.presentMenuViewController()
    }
    
    func hideMenu() {
        frostedViewController.hideMenuViewController()
    }
    
    // MARK: - Gesture recognizer
    @objc func panGestureRecognized(_ sender: UIPanGestureRecognizer?) {
        // Dismiss keyboard (optional)
        //
        view.endEditing(true)
        frostedViewController.view.endEditing(true)
        // Present the view controller
        //
        frostedViewController.panGestureRecognized(sender)
    }
}
