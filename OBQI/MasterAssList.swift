//
//  MasterAssList.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/10/27.
//  Copyright © 2016年 System. All rights reserved.
//

import UIKit

class MasterAssList: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    // Tableで使用する配列を定義する.
    var assessmentList: [JSON] = []
    var fromKarteList: [JSON] = []

    // 表示するテーブルビュー
    var myTableView: UITableView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TableViewの生成( status barの高さ分ずらして表示 ).
        myTableView = UITableView(frame: CGRect(x: 0, y: appDelegate.barHeight!, width: appDelegate.tabBarWidth!, height: appDelegate.availableViewHeight!), style: UITableView.Style.plain)
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
        print("viewWillApper")
        
        loadAssList()
    }
    func loadAssList() {
        // assessment取得
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        let shopID = appDelegate.LoginInfo?["ShopID"].asInt
        let sShopID = String(shopID!)
        let customerID = appDelegate.SelectedCustomer!["CustomerID"].asString!

        var url = ""
        var res:(result: String?, errCode: String?)

        url = "\(AppConst.URLPrefix)assessment/GetCustomerAssessmentList/\(sShopID)/\(customerID)"
        res = appCommon.getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }
        let assessmentJson = JSON(string: res.result!) // JSON読み込み
        if assessmentJson.length == 0 {
            assessmentList = []
        } else {
            assessmentList = []
            for i in 0 ..< assessmentJson.length {
                let json : JSON? = assessmentJson[i]
                assessmentList.append(json!)
            }
            // 日付降順に並べる
            assessmentList = assessmentList.sorted{ $0["AssDate"].asString! > $1["AssDate"].asString! }.map{ $0 }
        }

        if assessmentList.count > 0 {
            // 受付情報取得
            url = "\(AppConst.URLPrefix)customer/GetReceptionList/\(customerID)"
            res = appCommon.getSynchronous(url)
            if !AppCommon.isNilOrEmpty(res.errCode) {
                return
            }

            let receptionJson = JSON(string: res.result!) // JSON読み込み
            if receptionJson.length > 0 {
                fromKarteList = receptionJson.map{ $0.1 }
            }
        }
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
        // 選択されたアセスメントIDを保存する
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        appDelegate.SelectedAssAssID = assessmentList[(indexPath as NSIndexPath).row]["AssID"].asInt!
        appDelegate.SelectedBssAssID = assessmentList[(indexPath as NSIndexPath).row]["AssID"].asInt!
        // 左側を変更
        performSegue(withIdentifier: "SegueAssessmentMenu",sender: self)
    }
    
    /*
     テーブルに表示する配列の総数を返す.
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assessmentList.count
    }
    
    /*
     Cellに値を設定する.
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "MyCell")
        var dateStr = assessmentList[(indexPath as NSIndexPath).row]["AssDate"].asString!
        dateStr = dateStr.replacingOccurrences(of: "T", with: " ", options: [], range: nil)
        dateStr = dateStr.replacingOccurrences(of: "Z", with: "", options: [], range: nil)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: dateStr)
        
        let myDateFormatter: DateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        let mySelectedDate: NSString = myDateFormatter.string(from: date!) as NSString
        
        cell.textLabel?.text = "\(mySelectedDate)"

        let assID = assessmentList[(indexPath as NSIndexPath).row]["AssID"].asInt!

        // 受付があるか確認
        let recepitonData = fromKarteList.filter{ $0["AssID"].asInt! == assID }.first
        if recepitonData != nil {
            cell.backgroundColor = UIColor.good()

            let visitingTimes = recepitonData?["VisitingTimes"].asString
            let clinicalCode = recepitonData?["ClinicalCode"].asString
            cell.detailTextLabel?.text = "来院回数：\(visitingTimes!), 診療科コード：\(clinicalCode!)"
        }

        return cell
        
    }
    /*
     新規アセスメント追加
     */
    @IBAction func ClickAddNew(_ sender: AnyObject) {
       
        let alertController = UIAlertController(title: "確認", message: "新規アセスメントを作成しますか？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "作成", style: UIAlertAction.Style.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("作成 Button")
            let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
            let customerID = appDelegate.SelectedCustomer!["CustomerID"].asString!
            let shopID = appDelegate.LoginInfo?["ShopID"].asInt
            let sShopID = String(shopID!)
            
            // 最後のアセスメントIDを引き継ぎ元にする。
            var nothing : String!
            if self.assessmentList.count > 0 {
                nothing = String(self.assessmentList[0]["AssID"].asInt!)
            } else {
                nothing = "|".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            }
            //customer?loginSessionKey={0}&staffid={1}&createdate={2}
            let url = "\(AppConst.URLPrefix)assessment/putregassessment/\(nothing!)/\(sShopID)/\(customerID)/"
            
            let res = self.appCommon.putSynchronous(url, params: [:])
            if !AppCommon.isNilOrEmpty(res.errCode) {
                AppCommon.alertMessage(controller: self, title: "エラー", message: "情報を更新できませんでした\nインターネット接続を確認して下さい。")
            }
            // リスト更新
            self.loadAssList()
            self.myTableView?.reloadData()
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
}
