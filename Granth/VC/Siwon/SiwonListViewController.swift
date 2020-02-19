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

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupUI()
    }

    func setupData() {
        THelper.setHeaderShadow(view: headerView)
        let url = URL(string: "https://next.json-generator.com/api/json/get/41hAo9H7d")!
        Webservice().getSiwons(url: url) { articles in

            if let articles = articles {
                self.articleListVM = SiwonListViewModel(siwons: articles)

                DispatchQueue.main.async {
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

        tableView.register(UINib(nibName: "SiwonTableViewCell", bundle: nil), forCellReuseIdentifier: "SiwonTableViewCell")

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
//        cell.descLabel.text = articleVM.desc
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let articleVM = self.articleListVM.articleAtIndex(indexPath.row)

        let vc = WebViewViewController()
        vc.model = articleVM

        self.navigationController?.pushViewController(vc, animated: true)
    }

}
