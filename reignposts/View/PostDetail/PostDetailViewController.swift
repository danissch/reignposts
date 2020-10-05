//
//  PostDetailViewController.swift
//  reignposts
//
//  Created by Daniel Durán Schütz on 1/10/20.
//

import Foundation
import UIKit
import WebKit

class PostDetailViewController: UIViewController, WKUIDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    var url:URL?
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let myURL = self.url ?? URL(string:"http://www.apple.com")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }

    func setData(urlBrowser:URL){
        self.url = urlBrowser
    }
}
