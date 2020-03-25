//
//  SiwonListViewController.swift
//  Granth
//
//  Created by wira on 2/19/20.
//  Copyright © 2020 Goldenmace-ios. All rights reserved.
//

import UIKit

class SiwonListViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var articleListVM: SiwonListViewModel!

    @IBOutlet weak var buttonMenu: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblTotalCartItem: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupUI()
    }

    func setupData() {
        self.loadingIndicator.startAnimating()
        THelper.setHeaderShadow(view: headerView)
        let url = URL(string: "https://next.json-generator.com/api/json/get/41hAo9H7d")!
        Webservice().getSiwons(url: url) { articles in

            if let articles = articles {
                self.articleListVM = SiwonListViewModel(siwons: articles)

                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    self.tableView.reloadData()
                }
            }
        }
    }

    func setupUI() {
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        } else {

        }

        if TPreferences.readBoolean(IS_LOGINING) {
            self.lblTotalCartItem.isHidden = false
            self.lblTotalCartItem.layer.cornerRadius = self.lblTotalCartItem.layer.frame.height / 2
            self.lblTotalCartItem.text = TPreferences.readString(CART_TOTAL_ITEM)
            if self.lblTotalCartItem.text == "" {
                self.lblTotalCartItem.isHidden = true
            }else {
                self.lblTotalCartItem.isHidden = false
            }
        }else {
            self.lblTotalCartItem.isHidden = true
        }


        self.buttonMenu.addTarget(self.navigationController, action:#selector(showMenu) , for: .touchUpInside)

        tableView.register(UINib(nibName: "SiwonTableViewCell", bundle: nil), forCellReuseIdentifier: "SiwonTableViewCell")

    }

    @objc func showMenu() {
        let vc = SideBarMenuViewController(nibName: "SideBarMenuViewController", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc func receiveNotification(_ notification: Notification?) {
        if let aNotification = notification {
            print("\(aNotification)")
        }
        if TPreferences.readBoolean(IS_LOGINING) {
            self.lblTotalCartItem.isHidden = false
            self.lblTotalCartItem.text = TPreferences.readString(CART_TOTAL_ITEM)
        }else {
            self.lblTotalCartItem.isHidden = true
        }
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        return self.articleListVM == nil ? 0 : self.articleListVM.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.articleListVM.numberOfRowInSection(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SiwonTableViewCell", for:indexPath) as? SiwonTableViewCell else {
            fatalError("SiwonTableViewCell not found")
        }

        let articleVM = self.articleListVM.articleAtIndex(indexPath.row)
        cell.titleLabel.text = articleVM.title
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let articleVM = self.articleListVM.articleAtIndex(indexPath.row)

        let vc = WebViewViewController()
        vc.model = articleVM

        self.navigationController?.pushViewController(vc, animated: true)
    }

    //MARK: action function
    @IBAction func btnCart_Clicked(_ sender: Any) {
        if TPreferences.readBoolean(IS_LOGINING) {
            let vc = AddToCartViewController(nibName: "AddToCartViewController", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            let vc = LoginViewController(nibName: "LoginViewController", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    @IBAction func btnSearch_Clicked(_ sender: Any) {
        let vc = SearchViewController(nibName: "SearchViewController", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }


}
