//
//  XSMemberViewController.swift
//  xspace
//
//  Created by Lendo on 2022/8/2.
//  Copyright © 2022 星舰. All rights reserved.
//

import UIKit
import WebKit
import StoreKit

//沙盒验证地址
let url_receipt_sandbox = "https://sandbox.itunes.apple.com/verifyReceipt"
//生产环境验证地址
let url_receipt_itunes = "https://buy.itunes.apple.com/verifyReceipt"

enum PayEnvironment: Int {
    case sandbox = 21007 , production
    case nothing = 0
}

struct ProductOrder {
    var ordderID: String? = ""
    var transaction: SKPaymentTransaction
    var recript: String
}

var state: PayEnvironment = .production

class XSMemberViewController: UIViewController, WKScriptMessageHandler {
    deinit {
        self.webView.configuration.userContentController.removeScriptMessageHandler(forName: "gotoPay")
        print("XSMemberViewController 释放!!!")
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "gotoPay" {
            print(message.body)
//            showHub()
            if currentUser == nil {
                oneKeyLogin.getPhoneNumber(currentVC: self)
                return
            }else {
                
            }
        }
    }

    var order: ProductOrder? = nil
    var webView = WKWebView()
    override func viewDidLoad() {
        super.viewDidLoad()
        commonBackground()
        
        
        let config = WKWebViewConfiguration()
        config.userContentController = WKUserContentController()
        config.userContentController.add(self, name: "gotoPay")
        config.preferences = WKPreferences()
        config.preferences.javaScriptCanOpenWindowsAutomatically=true
        config.preferences.javaScriptEnabled = true
        webView = WKWebView(frame: CGRect.zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        webView.isHidden = true
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        webView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        webView.backgroundColor = .clear
        webView.load(URLRequest(url: URL(string: kHttpBaseURL + "/pay")!))
    
//        webView.load(URLRequest(url: URL(string: "http://192.168.50.81:8080" + "/pay")!))
//        webView.load(URLRequest(url: URL(string: "https://321tto.ga/roctet/Payment")!))
        

        if #available(iOS 11.0, *) {
            self.webView.scrollView.contentInsetAdjustmentBehavior = .never
        }else{
            self.automaticallyAdjustsScrollViewInsets = false
        }
        whiteNavBar()
        showHub()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //根据内购种类加参数
    func buy(string:String){
        //判断是否允许内购
        if SKPaymentQueue.canMakePayments() {
            let nsset:NSSet = NSSet.init(array: [string])
            let request = SKProductsRequest.init(productIdentifiers: nsset as! Set<String>)
            request.delegate = self
            request.start()
        }else{
            print("can not canMakePayments")
        }
    }
    
    func noticeService() {
        
    }
    
}

extension XSMemberViewController : WKNavigationDelegate {
    // 页面开始加载时调用
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.webView.evaluateJavaScript("document.body.style.backgroundColor=\"#0E2240\"", completionHandler: nil)

    }
    
    // 当内容开始返回时调用
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!){

    }
    
    // 页面加载完成之后调用
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){

        self.webView.isHidden = false
        hubHide()
//        let userName = UserDefaults.standard.string(forKey: "USERNAME")! as String
//        var vipName = "暂未开通会员"
//        if ISVIP() {
//            vipName = GETEXPIRETIME() + " 到期"
//        }
//
        var content = ""

        if currentUser == nil {
            content = "getUserinfoData('未登录','您还没有登录，请先登录。')"
        }else {
            if currentUser?.isVip == "1" {
                content = "getUserinfoData('\(currentUser!.userName)','您的会员身份将于\(timeStampToDateString(time: currentUser!.exprieTime))失效，续费畅享会员权益')"
            }else {
                content = "getUserinfoData('\(currentUser!.userName)','您的还不是会员，请您先购买会员。')"

            }
        }
        self.webView.evaluateJavaScript(content) { data, error in

        }
//        let userName = QWUserDefault
        
//        if self.str == "Help & Feedback" {
//            DDLog(message: "getBaseParams('\(USERID())')")
//            self.web.evaluateJavaScript("getBaseParams('\(USERID())')") { (result, err) in
//                  print(result ?? "", err ?? "")
//            }
//        }
    }
    
    // 页面加载失败时调用
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error){

        hubHide()
    }
}

extension XSMemberViewController: SKPaymentTransactionObserver {
    //MARK:购买结果 监听回调
    func paymentQueue(_ queue: SKPaymentQueue,updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for tran in transactions {
            switch tran.transactionState {
            case .purchased:
                print("交易完成")
                SKPaymentQueue.default().finishTransaction(tran)
                self.verifyTransactionResult(transaction: tran) //验证凭证
                
                var arr = UserDefaults.standard.object(forKey: "payment") as? Array<Any> ?? []
                arr.append(transactions)
                UserDefaults.standard.set(arr, forKey: "payment")
                break
            case .purchasing:
                print("商品添加进列表")
                break
            case .restored:
                showMessage(message: "已经购买过该商品")
                SKPaymentQueue.default().finishTransaction(tran)
                break
            case .failed, .deferred:
                showMessage(message: "支付失败")
                SKPaymentQueue.default().finishTransaction(tran)
                break
            default:
                break
            }
        }
    }
    
    /*
     值得注意的是，新版中数据结构中的in_app字段，可能包含多个transaction的receipt。当完成transaction后，还没有成功调用读取过receipt的接口，那下一次读取recept时会把所有的都读取出来，从而出现多条数据。

     票据格式
     {
     environment = Sandbox;
     receipt =   {
     "adam_id" = 0;
     "app_item_id" = 0;
     "application_version" = 1;
     "bundle_id" = "com.coodezhang.test";
     "download_id" = 0;
     "in_app" =     (
     {
     "is_trial_period" = false;
     "original_purchase_date" = "2017-12-14 07:18:56 Etc/GMT";
     "original_purchase_date_ms" = 1513235936000;
     "original_purchase_date_pst" = "2017-12-13 23:18:56 America/Los_Angeles";
     "original_transaction_id" = 1000000359369424;
     "product_id" = "com.coodezhang.test_coins99M_Tier1";
     "purchase_date" = "2017-12-14 07:18:56 Etc/GMT";
     "purchase_date_ms" = 1513235936000;
     "purchase_date_pst" = "2017-12-13 23:18:56 America/Los_Angeles";
     quantity = 1;
     "transaction_id" = 1000000359369424;
     }
     ...... 可能存在多条
     );
     "original_application_version" = "1.0";
     "original_purchase_date" = "2013-08-01 07:00:00 Etc/GMT";
     "original_purchase_date_ms" = 1375340400000;
     "original_purchase_date_pst" = "2013-08-01 00:00:00 America/Los_Angeles";
     "receipt_creation_date" = "2017-12-14 07:18:56 Etc/GMT";
     "receipt_creation_date_ms" = 1513235936000;
     "receipt_creation_date_pst" = "2017-12-13 23:18:56 America/Los_Angeles";
     "receipt_type" = ProductionSandbox;
     "request_date" = "2017-12-14 07:19:23 Etc/GMT";
     "request_date_ms" = 1513235963829;
     "request_date_pst" = "2017-12-13 23:19:23 America/Los_Angeles";
     "version_external_identifier" = 0;
     };
     status = 0;
     }
     */
    
    //验证凭据，获取到苹果返回的交易凭据
    func verifyTransactionResult(transaction:SKPaymentTransaction){
        //从沙盒中获取到购买凭据
        let recepitUrl = Bundle.main.appStoreReceiptURL
        let recriptData = NSData.init(contentsOf: recepitUrl!)
        let base64Str = recriptData?.base64EncodedString(options: .endLineWithLineFeed)
        
        // 客户端本地验证
        let params = NSMutableDictionary()
        params["receipt-data"] = base64Str
        let body = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        var request = URLRequest.init(url: URL.init(string: state == .production ? url_receipt_itunes : url_receipt_sandbox)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 20)
        request.httpMethod = "POST"
        request.httpBody = body
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let dict = try! JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
            print(dict)
            SKPaymentQueue.default().finishTransaction(transaction)
            let status = dict["status"] as! Int
            switch(status){
            case 0:
                // MARK: - 需要通知服务端
//                self.resultBlock("购买成功")
//                UMAnalyticsSwift.event(eventId: "1003") 1个月
//                UMAnalyticsSwift.event(eventId: "1004") 3个月
//                UMAnalyticsSwift.event(eventId: "1005") 1年
                break
            case 21007:
                state = .sandbox
                self.verifyTransactionResult(transaction: transaction)
                break
            default:
//                self.resultBlock("验证失败")
                break
            }
            //移除监听
            SKPaymentQueue.default().remove(self)
        }
        task.resume()
    }
 
    func paymentQueue(_ queue: SKPaymentQueue,restoreCompletedTransactionsFailedWithError error: Error) {
        print(error)
    }
}

extension XSMemberViewController: SKProductsRequestDelegate {
    //收到的产品信息
    func productsRequest(_ request: SKProductsRequest,didReceive response: SKProductsResponse) {
        if response.products.count == 0 {
            print("没有商品")
            return
        }
        for product in response.products {
            let payment:SKPayment = SKPayment.init(product: product)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    func request(_ request: SKRequest,didFailWithError error: Error) {
        print("------------------错误-----------------\(error)")
        showMessage(message: "支付出现异常, 无法支付")
    }
    
    func requestDidFinish(_ request: SKRequest) {
        print("反馈信息结束----------\(request.description)")
    }
    
}
