//
//  MasterPatient.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/10/20.
//  Copyright © 2016年 System. All rights reserved.
//


import UIKit

class MasterPatient: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    let appCommon = AppCommon()
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    // Tableで使用する配列を定義する.
    var customerInfoItems: [JSON?] = []
    var searchCustomerInfoItems: [JSON?] = []
    var todayReceptionList: [JSON?] = []
    
    // 表示するテーブルビュー
    var myTableView: UITableView? = nil
    var mySearchBar: UISearchBar!
    
    @IBOutlet weak var receptionSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if appDelegate.IsFirst {
            appDelegate.IsFirst = false
            
            // 各サイズの取得
            appDelegate.statusBarHeight = 0
            appDelegate.navBarHeight = 0
            appDelegate.navBarWidth = self.navigationController!.navigationBar.frame.size.width
            appDelegate.tabBarHeight = self.tabBarController!.tabBar.frame.size.height
            appDelegate.tabBarWidth = self.tabBarController!.tabBar.frame.width
            appDelegate.availableViewHeight = self.view.frame.size.height-appDelegate.statusBarHeight!-appDelegate.navBarHeight!-appDelegate.tabBarHeight!
            appDelegate.detailNavBarWidth = self.view.frame.size.width - appDelegate.navBarWidth!
            appDelegate.availableDetailViewHeight = self.view.frame.size.height-appDelegate.statusBarHeight!-appDelegate.navBarHeight!
            appDelegate.barHeight = appDelegate.statusBarHeight! + appDelegate.navBarHeight!
            
            self.tabBarController!.selectedIndex = 1
        }

        let switchHeight: CGFloat = 40
        
        
        // 検索バーを作成する.
        mySearchBar = UISearchBar()
        mySearchBar.delegate = self
        //mySearchBar.frame = CGRectMake(0, barHeight, tabBarWidth!, 60)
        mySearchBar.frame = CGRect(x: 0, y: (UIApplication.shared.statusBarFrame.height + self.navigationController!.navigationBar.frame.size.height) + switchHeight , width: appDelegate.tabBarWidth!, height: 60)
        
        // ブックマークボタンを無効にする.
        mySearchBar.showsBookmarkButton = false
        // バースタイルをDefaultに設定する.
        mySearchBar.searchBarStyle = UISearchBar.Style.minimal
        // 説明文を設定する.
        mySearchBar.placeholder = "IDまたは名前（カナ）を入力してください"
        // 検索結果表示ボタンは非表示にする.
        mySearchBar.showsSearchResultsButton = false
        // 検索バーをViewに追加する.
        self.view.addSubview(mySearchBar)
        let height = self.view.frame.size.height-UIApplication.shared.statusBarFrame.height-self.navigationController!.navigationBar.frame.size.height-appDelegate.tabBarHeight!
        myTableView = UITableView(frame: CGRect(x: 0, y: (UIApplication.shared.statusBarFrame.height + self.navigationController!.navigationBar.frame.size.height) + mySearchBar.frame.height + switchHeight, width: appDelegate.tabBarWidth!, height: height - mySearchBar.frame.height - switchHeight), style: UITableView.Style.plain)
        // Cell名の登録をおこなう.
        myTableView!.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        // DataSourceの設定をする.
        myTableView!.dataSource = self
        // Delegateを設定する.
        myTableView!.delegate = self
        // Viewに追加する.
        self.view.addSubview(myTableView!)

        // リフレッシュコントロールを設定する。
        myTableView?.refreshControl = AppCommon.getRefreshControl(self, action: #selector(self.refreshTable), for: UIControl.Event.valueChanged)
    }

    //テーブルビュー引っ張り時の呼び出しメソッド
    @objc func refreshTable(){

        //テーブルを再読み込みする。
        self.viewWillAppear(false)
        myTableView?.reloadData()

        //読込中の表示を消す。
        myTableView?.refreshControl?.endRefreshing()
    }
    
    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // カスタマー取得
        loadCustomer()
        searchCustomer()
        
        // 詳細切り替え
        AppCommon.changeDetailView(sb: storyboard!, sv: splitViewController!, storyBoardID: "PatientListNavigationController")
    }
    
    /*
     テキストが変更される毎に呼ばれる
     */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("searchBar")
        
        searchCustomer()
    }
    
    
    /*
     Searchボタンが押された時に呼ばれる
     */
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarSearchButtonClicked")
        self.view.endEditing(true)
    }
    
    // カスタマー取得
    func loadCustomer() {
        //let loginSessionKey = appDelegate.LoginInfo!["LoginSessionKey"].asString!
        let shopID = String(appDelegate.LoginInfo!["ShopID"].asInt!)

        var url = ""
        var res:(result: String?, errCode: String?)

        // カスタマー取得
        let str = "|".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        url = "\(AppConst.URLPrefix)customer/GetCustomer/\(shopID)/\(str)/\(str)/\(str)"
        res = appCommon.getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }
        
        let customerJson = JSON(string: res.result!) // JSON読み込み
        if customerJson["allCount"].asInt == 0 {
            customerInfoItems = []
        } else {
            customerInfoItems = []
            for i in 0 ..< customerJson["customerList"].length {
                let json : JSON? = customerJson["customerList"][i]
                customerInfoItems.append(json)
            }
        }

        if customerInfoItems.count > 0 {
            // 当日受付日取得
            url = "\(AppConst.URLPrefix)customer/GetReceptionListToday"
            res = appCommon.getSynchronous(url)
            if !AppCommon.isNilOrEmpty(res.errCode) {
                return
            }

            let receptionJson = JSON(string: res.result!) // JSON読み込み
            if receptionJson.length > 0 {
                todayReceptionList = receptionJson.map{ $0.1 }
            }

            // スイッチによって表示対象切り替え
            if !receptionSwitch.isOn {
                var matchCustomerInfoItems: [JSON?] = []

                // 受付あり以外を除外
                customerInfoItems.forEach{
                    let customerID = $0?["CustomerID"].asString!

                    let hasReception = todayReceptionList.filter{ ($0?["CustomerID"].asInt!)! == Int(customerID!)!}
                    if hasReception.count > 0 {
                        matchCustomerInfoItems.append($0)
                    }
                }

                customerInfoItems = matchCustomerInfoItems
            }
        }
    }
    // カスタマー絞り込み
    func searchCustomer() {
        let text = mySearchBar.text
        if AppCommon.isNilOrEmpty(text) {
            searchCustomerInfoItems = customerInfoItems
        } else {
            let separators = CharacterSet(charactersIn: " 　") // 半角と全角のスペース
            let words = text!.components(separatedBy: separators)
            searchCustomerInfoItems = [] // 初期化
            
            
            for i in 0 ..< customerInfoItems.count {
                let customer = customerInfoItems[i]!
                let tmpCustomerID = customer["CustomerID"].asString
                let tmpName = customer["CsmName"].asString
                let customerID : NSString = AppCommon.isNilOrEmpty(tmpCustomerID) ? "" : tmpCustomerID! as NSString
                let name : NSString = AppCommon.isNilOrEmpty(tmpName) ? "" : tmpName! as NSString
                
                
                var isMatch = true
                for j in 0 ..< words.count {
                    let word = words[j]
                    if AppCommon.isNilOrEmpty(word) {
                        continue
                    }
                    let locCustomerID = customerID.range(of: word).location
                    let locName = name.range(of: word).location
                    // 全部一致していない場合は不一致
                    if locCustomerID == NSNotFound && locName == NSNotFound {
                        isMatch = false
                        break
                    }
                }
                // 一致している利用者情報のみ保存
                if isMatch {
                    searchCustomerInfoItems.append(customer)
                }
            }
        }
        myTableView?.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /*
     セクションの数を返す.
     */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /*
     Cellが選択された際に呼び出される.
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 選択されたカスタマーを保存
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        appDelegate.SelectedCustomer = searchCustomerInfoItems[(indexPath as NSIndexPath).row]
        // 遷移
        //performSegue(withIdentifier: "SegueAssList",sender: self)
        performSegue(withIdentifier: "SeguePatientMenu",sender: self)
    }
    
    /*
     テーブルに表示する配列の総数を返す.
    */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchCustomerInfoItems.count
    }
    
    /*
     Cellに値を設定する.
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) as UITableViewCell
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "MyCell")
        let customerID = searchCustomerInfoItems[(indexPath as NSIndexPath).row]!["CustomerID"].asString!
        var name = searchCustomerInfoItems[(indexPath as NSIndexPath).row]!["CsmName"].asString
        let createDateTime = searchCustomerInfoItems[(indexPath as NSIndexPath).row]!["CsmCreateDate"].asString
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let date = dateFormatter.date(from: createDateTime!)
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm" // 日付フォーマットの設定
        let dateStr = dateFormatter.string(from: date!)
        if name == "" {
            name = "名前未登録"
        }
        cell.textLabel?.text = "\(name!)"
        cell.detailTextLabel?.text = "利用者ID：\(customerID), 登録日時：\(dateStr)"

        let hasReception = todayReceptionList.filter{ $0?["CustomerID"].asInt! == Int(customerID)!}
        if hasReception.count > 0 {
            cell.backgroundColor = UIColor.good();
        }

        return cell
    }
    // 利用者追加
    @IBAction func ClickAddNew(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "確認", message: "新規利用者を追加しますか？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "追加", style: UIAlertAction.Style.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("pushed 追加 Button")
            
            let iStaffID : String! = self.appDelegate.LoginInfo?["UserID"].asString!
            
            let now = Date() // 現在日時の取得
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US") // ロケールの設定
            dateFormatter.dateFormat = "yyyyMMddHHmmss" // 日付フォーマットの設定
            var nowStr = dateFormatter.string(from: now)
            nowStr = nowStr.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            //customer?loginSessionKey={0}&staffid={1}&createdate={2}
            var url = "\(AppConst.URLPrefix)customer/postregcustomer/\(iStaffID!)"
            
            let res = self.appCommon.postSynchronous(url, params: [:])
            if AppCommon.isNilOrEmpty(res.errCode) {
                var customerID = res.result!
                customerID = customerID.replacingOccurrences(of: "\"", with: "", options: [], range: nil)
                print(customerID)
                
                // アセスメント追加
                let nothing : String! = "|".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                let now = Date() // 現在日時の取得
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyyMMddHHmmss" // 日付フォーマットの設定
                let shopID = self.appDelegate.LoginInfo?["ShopID"].asInt
                let sShopID = String(shopID!)
                var nowStr = dateFormatter.string(from: now)
                nowStr = nowStr.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                url = "\(AppConst.URLPrefix)assessment/putregassessment/\(nothing!)/\(sShopID)/\(customerID)"
                print(url)
                
                let res2 = self.appCommon.putSynchronous(url, params: [:])
                if !AppCommon.isNilOrEmpty(res2.errCode) {
                    AppCommon.alertMessage(controller: self, title: "エラー", message: "情報を更新できませんでした\nインターネット接続を確認して下さい。")
                }

                // リスト更新
                self.viewWillAppear(false)
            }
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("Cancel")
        })
        
        // addActionした順に左から右にボタンが配置
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)

    }

    /*
     表示するリストの切り替え
     */
    @IBAction func switchList(_ sender: UISwitch) {
        self.viewWillAppear(false)
    }
    
}
