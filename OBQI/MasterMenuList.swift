//
//  DetailMenuList.swift
//  OBQI
//
//  Created by t.o on 2017/01/27.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class MasterMenuList: UITableViewController {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()

    var selectedMenuHDList = [JSON]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")

        // DataSourceの設定をする.
        self.tableView.dataSource = self

        // Delegateを設定する.
        self.tableView.delegate = self

        // パラメータ初期化
        self.appDelegate.MenuParams = AppConst.MenuParamsFormat()
        self.appDelegate.MenuParamsTmp = AppConst.MenuParamsFormat()

        // リフレッシュコントロールを設定する。
        self.tableView.refreshControl = AppCommon.getRefreshControl(self, action: #selector(setter: refreshControl) , for: UIControl.Event.valueChanged)
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

        // api取得事前処理
        let customerID = appDelegate.SelectedCustomer!["CustomerID"].asString!

        var url:String
        var res:(result: String?, errCode: String?)

        // 介入計画ヘッダ一覧取得
        url = "\(AppConst.URLPrefix)menu/GetSelectedMenuHD/\(customerID)"
        res = appCommon.getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }
        let selectedMenuHDJson = JSON(string: res.result!) // JSON読み込み
        if selectedMenuHDJson.length == 0 {
            selectedMenuHDList = []
        } else {
            selectedMenuHDList = []
            for i in 0 ..< selectedMenuHDJson.length {
                let json : JSON? = selectedMenuHDJson[i]
                selectedMenuHDList.append(json!)
            }
        }

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
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "MyCell")
        let index = (indexPath as NSIndexPath).row

        let menuSetName = selectedMenuHDList[index]["MenuSetName"].asString!
        let createDateTime = AppCommon.getDateFormat(date: selectedMenuHDList[index]["CreateDateTime"].asDate, format: "yyyy/MM/dd HH:mm:ss")!
        let menuStatus = selectedMenuHDList[index]["MenuStatus"].asString!

        cell.textLabel?.text = "\(menuSetName)"
        cell.detailTextLabel?.text = "作成日：\(createDateTime) ステータス：\(AppConst.MenuStatusName[Int(menuStatus)!])"

        // 追加画面から戻った場合は追加されたメニューを選択済みにする
        let menuGroupID = selectedMenuHDList[index]["MenuGroupID"].asInt!
        if  appDelegate.MenuParams.MenuHD.MenuGroupID == menuGroupID {
            cell.isSelected = true
            self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            self.tableView(self.tableView, didSelectRowAt: indexPath)
        }

        return cell
    }


    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = (indexPath as NSIndexPath).row

        // 選択データの保持
        let selectedMenuHD = selectedMenuHDList[index]

        var url:String
        var res:(result: String?, errCode: String?)

        // スタッフ名取得
        url = "\(AppConst.URLPrefix)staff/GetShopStaff/\(selectedMenuHD["MenuSetStaffID"].asString!)"
        res = appCommon.getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }
        let staffJson = JSON(string: res.result!) // JSON読み込み

        // エピソード名取得
        url = "\(AppConst.URLPrefix)episode/GetEpisode/\(selectedMenuHD["EpisodeID"].asInt!)"
        res = appCommon.getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }
        var episodeDetailJson:JSON?
        if res.result != nil && res.result! != "null" {
            episodeDetailJson = JSON(string: res.result!) // JSON読み込み
        }

        // ヘッダ
        let menuHD = AppConst.MenuHDParamsFormat(
            MenuSetName:            selectedMenuHD["MenuSetName"].asString!,
            MenuStatus:             selectedMenuHD["MenuStatus"].asString!,
            CustomerID:             selectedMenuHD["CustomerID"].asInt!,
            MenuSetStaffID:         selectedMenuHD["MenuSetStaffID"].asString!,
            MenuSetStaffName:       "\(staffJson["StaffLastName"].asString!) \(staffJson["StaffFirstName"].asString!)",
            MenuSetStaffNameKana:   "\(staffJson["StaffLastNameKana"].asString!) \(staffJson["StaffFirstNameKana"].asString!)",
            CriteriaAssID:          selectedMenuHD["CriteriaAssID"].asInt!,
            MenuGroupID:            selectedMenuHD["MenuGroupID"].asInt!,
            MenuOrderNo:            selectedMenuHD["MenuOrderNo"].asInt!,
            UpdateDateTime:         AppCommon.getDateFormat(date: selectedMenuHD["UpdateDateTime"].asDate, format: "yyyy/MM/dd HH:mm:ss")!,
            CreateDateTime:         AppCommon.getDateFormat(date: selectedMenuHD["CreateDateTime"].asDate, format: "yyyy/MM/dd HH:mm:ss")!
        )

        // エピソード
        let episode = AppConst.EpisodeParamsFormat(
            EpisodeID:      selectedMenuHD["EpisodeID"].asInt!,
            EpisodeName:    episodeDetailJson?["EpisodeName"].asString ?? nil
        )

        // プログラム
        var programList:[AppConst.ProgramParamsFormat] = []

        selectedMenuHD["MenuInfoList"].forEach{ (menuInfo) -> Void in
            let menuInfo = AppConst.ProgramParamsFormat(
                MenuID:     menuInfo.1["MenuID"].asInt!,
                MenuName:   appDelegate.MstMenu?.filter{ menuInfo.1["MenuID"].asInt! == $0.1["MenuID"].asInt! }.first.map{ $0.1["MenuName"].asString! }
            )
            programList.append(menuInfo)
        }

        // 傷病と修飾語
        var diseaseList:[AppConst.DiseaseParamsFormat] = []

        selectedMenuHD["MnameInfoList"].forEach{ (mNameInfo) -> Void in
            var mnameInfo = AppConst.DiseaseParamsFormat(
                MainNumber:     mNameInfo.1["MainNumber"].asInt!,
                MainName:       mNameInfo.1["MainName"].asString!,
                MainNameKana:   appDelegate.MstNmain400?.filter{ mNameInfo.1["MainNumber"].asInt! == $0.1["MainNumber"].asInt! }.first.map{ $0.1["MainNameKana"].asString! },
                ICD10:          appDelegate.MstNmain400?.filter{ mNameInfo.1["MainNumber"].asInt! == $0.1["MainNumber"].asInt! }.first.map{ $0.1["ICD10"].asString! },
                Modifiers:      []
            )

            (mNameInfo.1["MdfyInfoList"] as JSON).forEach{ (mdfyInfo) -> Void in
                let mdfyInfo = AppConst.ModifierParamsFormat(
                    MdfyNumber:     mdfyInfo.1["MdfyNumber"].asInt!,
                    MdfyName:       appDelegate.MstMdfy400?.filter{ mdfyInfo.1["MdfyNumber"].asInt! == $0.1["MdfyNumber"].asInt! }.first.map{ $0.1["MdfyName"].asString! },
                    MdfyNameKana:   appDelegate.MstMdfy400?.filter{ mdfyInfo.1["MdfyNumber"].asInt! == $0.1["MdfyNumber"].asInt! }.first.map{ $0.1["MdfyNameKana"].asString! },
                    MdfyKbn:        mdfyInfo.1["MdfyKbn"].asInt!
                )
                mnameInfo.Modifiers.append(mdfyInfo)
            }

            diseaseList.append(mnameInfo)
        }

        appDelegate.MenuParams = AppConst.MenuParamsFormat(
            MenuHD: menuHD,
            Episode: episode,
            MenuDT: [],
            Program: programList,
            Disease: diseaseList
        )
        performSegue(withIdentifier: "SegueNavigationDetailMenuDetail", sender: self)
    }

    /*
     新規プログラム追加
     */
    @IBAction func clickAddNew(_ sender: AnyObject) {
        // セル選択状態の解除
        if let selectedCellRow = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectedCellRow, animated: true)
        }

        self.appDelegate.CurrentMenuEditMode = AppConst.Mode.CREATE
        self.appDelegate.MenuParamsTmp = AppConst.MenuParamsFormat()
        self.performSegue(withIdentifier: "SegueNavigationDetailMenuEdit", sender: self)
    }

}


