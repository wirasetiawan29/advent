//
//  WebViewViewController.swift
//  Granth
//
//  Created by wira on 2/19/20.
//  Copyright © 2020 Goldenmace-ios. All rights reserved.
//

import UIKit
import WebKit

class WebViewViewController: UIViewController, UITextViewDelegate {
    var model:SiwonViewModel?

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        THelper.setHeaderShadow(view: headerView)
        titleLabel.text = model?.title ?? ""
        textView.text = model?.desc.htmlToString ?? ""
    }

    @IBAction func onClickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
