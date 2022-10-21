//
//  XSWebViewController.swift
//  xspace
//
//  Created by Lendo on 2022/8/11.
//  Copyright © 2022 星舰. All rights reserved.
//

import UIKit
import WebKit

class XSWebViewController: UIViewController {

    var url:String = ""
    var webView: WKWebView?

    override func viewDidLoad() {
        super.viewDidLoad()
        commonBackground()
        
        webView = WKWebView(frame: UIScreen.main.bounds)
        view.addSubview(webView!)
        webView!.backgroundColor = .clear
        whiteNavBar()
        webView?.snp.makeConstraints({ make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(StatusBarHeight + 44)
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webView!.load(URLRequest(url: URL(string:url)!))
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
