//
//  DetailICSelect.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/12/06.
//  Copyright © 2016年 System. All rights reserved.
//

import UIKit

class DetailICSelect: UITableViewController {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    var selectedIndex : Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
        // DataSourceの設定をする.
        self.tableView.dataSource = self
        
        // Delegateを設定する.
        self.tableView.delegate = self
    }
    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillApper")
    }
    
    /*
     セクションの数を返す.
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /*
     セクションのタイトルを返す.
     */
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "追加するインフォームド・コンセントの種別を選択してください。"
    }
    
    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = (indexPath as NSIndexPath).row
    }
    /*
     テーブルに表示する配列の総数を返す.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (appDelegate.MstInformedConsentList?.length)!
    }
    
    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "MyCell")
        cell.textLabel?.text = "\((appDelegate.MstInformedConsentList?[(indexPath as NSIndexPath).row]["ICName"].asString)!)"
        //var value : String!
        //let index = (indexPath as NSIndexPath).row
        //cell.detailTextLabel?.text = value
        return cell
    }
    
    @IBAction func clickAddIC(_ sender: Any) {
        if selectedIndex == nil {
            AppCommon.alertMessage(controller: self, title: "エラー", message: "追加するインフォームド・コンセントの種別を選択してください。")
            return
        } else {
            // ICを保存
            let icid = appDelegate.MstInformedConsentList?[selectedIndex!]["ICID"].asInt
            let url = "\(AppConst.URLPrefix)ic/PostInformedConsent/\(appDelegate.SelectedEpisodeID!)/\(icid!)"
            let params: [String: AnyObject] = [:]
            let appCommon = AppCommon()
            let res = appCommon.postSynchronous(url, params: params)
            if !AppCommon.isNilOrEmpty(res.errCode) {
                AppCommon.alertMessage(controller: self, title: "エラー(\(res.errCode!))", message: "登録に失敗しました。")
            } else {
                appDelegate.ChangeIC = true
                // 戻る
                self.navigationController!.popViewController(animated: true)
            }
        }
    }
}
