//
//  MasterEpisodeList.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/11/22.
//  Copyright © 2016年 System. All rights reserved.
//

import UIKit

class MasterEpisodeList: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    // Tableで使用する配列を定義する.
    var episodeList: [JSON] = []
    
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
        // Episode取得
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        let customerID = appDelegate.SelectedCustomer!["CustomerID"].asString!
        
        let url = "\(AppConst.URLPrefix)episode/GetCustomerEpisodeList/\(customerID)"
        let res = appCommon.getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }
        let episodeJson = JSON(string: res.result!) // JSON読み込み
        if episodeJson.length == 0 {
            episodeList = []
        } else {
            episodeList = []
            for i in 0 ..< episodeJson.length {
                let json : JSON? = episodeJson[i]
                episodeList.append(json!)
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
        appDelegate.SelectedEpisodeID = episodeList[(indexPath as NSIndexPath).row]["EpisodeID"].asInt!
        
        // 詳細を変更
        AppCommon.changeDetailView(sb: storyboard!, sv: splitViewController!, storyBoardID: "EpisodeNavigationController")
    }
    
    /*
     テーブルに表示する配列の総数を返す.
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodeList.count
    }
    
    /*
     Cellに値を設定する.
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MyCell")
        
        var episodeName = episodeList[(indexPath as NSIndexPath).row]["EpisodeName"].asString!
        if episodeName == "" {
            episodeName = "名称未設定"
        }
        cell.textLabel?.text = "\(episodeName)"
        
        return cell
        
    }
    /*
     新規アセスメント追加
     */
    @IBAction func ClickAddNew(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "確認", message: "新規エピソードを作成しますか？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "作成", style: UIAlertAction.Style.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("作成 Button")
            let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
            let customerID = appDelegate.SelectedCustomer!["CustomerID"].asString!
            let shopID = appDelegate.LoginInfo?["ShopID"].asInt
            let sShopID = String(shopID!)
            
            let url = "\(AppConst.URLPrefix)episode/postNewEpisode/"
            
            let params: [String: AnyObject] = [
                "ShopID": sShopID as AnyObject,
                "CustomerID": customerID as AnyObject,
                "EpisodeName": "" as AnyObject,
                "EpisodeText": "" as AnyObject
                ]
            let res = self.appCommon.postSynchronous(url, params: params)
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
