//
//  MasterBLogMenuList.swift
//  OBQI
//
//  Created by t.o on 2017/03/13.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class MasterBLogMenuList: UITableViewController {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()

    var selectedMenuHDJson:JSON?
    var selectedMenuHDList = [JSON]()

    var showCompFlg = false
    override func viewDidLoad() {
        super.viewDidLoad()

        // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")

        // DataSourceの設定をする.
        self.tableView.dataSource = self

        // Delegateを設定する.
        self.tableView.delegate = self

        // リフレッシュコントロールを設定する。
        self.tableView.refreshControl = AppCommon.getRefreshControl(self, action: #selector(self.refreshTable), for: UIControl.Event.valueChanged)
    }

    //テーブルビュー引っ張り時の呼び出しメソッド
    @objc func refreshTable(){

        //テーブルを再読み込みする。
        self.viewWillAppear(false)

        //読込中の表示を消す。
        self.tableView.refreshControl?.endRefreshing()
    }

    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillApper")

        // 介入計画ヘッダ一覧取得
        let customerID = appDelegate.SelectedCustomer!["CustomerID"].asString!
        let url = "\(AppConst.URLPrefix)menu/GetSelectedMenuHD/\(customerID)"
        let res = appCommon.getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }
        selectedMenuHDJson = JSON(string: res.result!) // JSON読み込み

        // 表示するリストの制御
        selectedMenuHDList = setMenuList(menuJson: selectedMenuHDJson, showCompFlg: showCompFlg)

        // テーブル内容再描画
        self.tableView?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /*
     テーブルに表示する配列の総数を返す.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedMenuHDList.count
    }

    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MyCell")
        let index = (indexPath as NSIndexPath).row

        let menuSetName = selectedMenuHDList[index]["MenuSetName"].asString!
        let createDateTime = AppCommon.getDateFormat(date: selectedMenuHDList[index]["CreateDateTime"].asDate, format: "yyyy/MM/dd HH:mm:ss")!
        let criteriaAssID = selectedMenuHDList[index]["CriteriaAssID"].asInt!

        cell.textLabel?.text = "\(menuSetName)"
        cell.detailTextLabel?.text = "作成日：\(createDateTime) 基準AssID：\(criteriaAssID)"

        return cell
    }


    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = (indexPath as NSIndexPath).row

        // 選択データの保持
        let selectedMenuHD = selectedMenuHDList[index]

        // ヘッダ
        let menuHD = AppConst.MenuHDParamsFormat(
            MenuSetName:            selectedMenuHD["MenuSetName"].asString!,
            MenuStatus:             selectedMenuHD["MenuStatus"].asString!,
            CustomerID:             selectedMenuHD["CustomerID"].asInt!,
            MenuSetStaffID:         selectedMenuHD["MenuSetStaffID"].asString!,
            MenuSetStaffName:       nil,
            MenuSetStaffNameKana:   nil,
            CriteriaAssID:          selectedMenuHD["CriteriaAssID"].asInt!,
            MenuGroupID:            selectedMenuHD["MenuGroupID"].asInt!,
            MenuOrderNo:            selectedMenuHD["MenuOrderNo"].asInt!,
            UpdateDateTime:         AppCommon.getDateFormat(date: selectedMenuHD["UpdateDateTime"].asDate, format: "yyyy/MM/dd HH:mm:ss")!,
            CreateDateTime:         AppCommon.getDateFormat(date: selectedMenuHD["CreateDateTime"].asDate, format: "yyyy/MM/dd HH:mm:ss")!
        )
        // エピソード
        let episode = AppConst.EpisodeParamsFormat(
            EpisodeID:      selectedMenuHD["EpisodeID"].asInt!,
            EpisodeName:    nil
        )
        appDelegate.MenuParams = AppConst.MenuParamsFormat(
            MenuHD: menuHD,
            Episode: episode,
            MenuDT: [],
            Program: [],
            Disease: []
        )

        let splitViewController = self.splitViewController
        AppCommon.changeDetailView(sb: UIStoryboard(name: "BLog", bundle: nil), sv: splitViewController, storyBoardID: "BLogDetailStartView")

        performSegue(withIdentifier: "SegueMasterBLogSubGroupList", sender: self)
    }

    /*
     表示するリストの切り替え
     */
    @IBAction func switchList(_ sender: UISwitch) {
        selectedMenuHDList = setMenuList(menuJson: selectedMenuHDJson, showCompFlg: sender.isOn)

        self.tableView.reloadData()
    }

    /*
     計画外実施
     */
    @IBAction func clickUnplandeMenu(_ sender: AnyObject) {
        // パラメータ初期化
        self.appDelegate.MenuParams = AppConst.MenuParamsFormat()
        self.performSegue(withIdentifier: "SegueMasterBLogSubGroupList", sender: self)
    }

    /*
     表示するリストの設定
     */
    private func setMenuList(menuJson: JSON?, showCompFlg: Bool) -> [JSON] {
        self.showCompFlg = showCompFlg

        var menuList = [JSON]()
        if menuJson == nil || menuJson?.length == 0 {
            return menuList
        }

        if showCompFlg { // 確定,完了
            menuList = (menuJson?.filter{ $0.1["MenuStatus"].asString! == AppConst.MenuStatus.DETERMINE.rawValue || $0.1["MenuStatus"].asString! == AppConst.MenuStatus.COMP.rawValue }.map{ $0.1 })!

        } else { // 確定
            menuList = (menuJson?.filter{ $0.1["MenuStatus"].asString! == AppConst.MenuStatus.DETERMINE.rawValue }.map{ $0.1 })!
        }

        return menuList
    }
    
}
