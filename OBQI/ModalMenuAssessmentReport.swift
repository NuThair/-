//
//  DetailMenuAssessmentReport.swift
//  OBQI
//
//  Created by t.o on 2017/02/09.
//  Copyright © 2017年 System. All rights reserved.
//


import UIKit
import WebKit

class ModalMenuAssessmentReport: UIViewController, WKNavigationDelegate, WKUIDelegate {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()

    var myIndiator: UIActivityIndicatorView!

    // 比較アセスメント区分
    var SelectedTargetAss1:Int?
    var SelectedTargetAss2:Int?
    var MenuReportKbn:AppConst.MenuReportKbn?

    @IBOutlet weak var naviTitle: UINavigationItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        // ページ読み込み中に表示させるインジケータを生成.
        myIndiator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        myIndiator.center = self.view.center
        myIndiator.hidesWhenStopped = true
        myIndiator.style = UIActivityIndicatorView.Style.gray

        // URLReqestを生成.
        let customerID = appDelegate.SelectedCustomer!["CustomerID"].asString!
        let menuGroupId = appDelegate.MenuParams.MenuHD.MenuGroupID!

        var apiName:String?
        switch MenuReportKbn! {
        case AppConst.MenuReportKbn.ASSESSMENT:
            apiName = "GetHikakuReport"
            naviTitle.title = "比較レポート"
        case AppConst.MenuReportKbn.OUTCOME:
            apiName = "GetOutcomeHikakuReport"
            naviTitle.title = "比較アウトカム"
        }

        let url = "\(AppConst.URLPrefix)report/\(apiName!)/\(customerID)/\(menuGroupId)/\(AppConst.ComparisonAssKbn[SelectedTargetAss1!])/\(AppConst.ComparisonAssKbn[SelectedTargetAss2!])"
        let req = appCommon.createApiURL(url, AppConst.MethodType.GET)

        // PDFを開くためのWebViewを生成.
        let barHeight = 64 as CGFloat
        let webView = WKWebView(frame: CGRect(x: 0, y: barHeight, width: self.view.frame.width, height: self.view.frame.height - barHeight))
        webView.navigationDelegate = self
        webView.layer.position = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/2 + barHeight/2)

        // WebViewのLoad開始.
        webView.load(req as URLRequest)

        // viewにWebViewを追加.
        self.view.addSubview(webView)

        print(1)
    }

    /*
     インジケータのアニメーション開始.
     */
    func startAnimation() {
        // NetworkActivityIndicatorを表示.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        // UIACtivityIndicatorを表示.
        if !myIndiator.isAnimating {
            myIndiator.startAnimating()
        }

        // viewにインジケータを追加.
        self.view.addSubview(myIndiator)
    }

    /*
     インジケータのアニメーション終了.
     */
    func stopAnimation() {
        // NetworkActivityIndicatorを非表示.
        UIApplication.shared.isNetworkActivityIndicatorVisible = false

        // UIACtivityIndicatorを非表示.
        if myIndiator.isAnimating {
            myIndiator.stopAnimating()
        }
    }

    /*
     WebViewのloadが開始された時に呼ばれるメソッド.
     */
    func webView(_ webView: WKWebView, didStartProvisionalNavigation: WKNavigation!) {
        print("load started")

        startAnimation()
    }

    /*
     WebViewのloadが終了した時に呼ばれるメソッド.
     */
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("load finished")
        
        stopAnimation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /*
     画面を閉じる.
     */
    @IBAction func clickClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
