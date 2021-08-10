//
//  DetailKarteSOAPComfirmation.swift
//  OBQI
//
//  Created by t.o on 2017/05/31.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class DetailKarteSOAPCooperation: UITableViewController {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    let karteCommon = KarteCommon()

    var mySections = [
        AppConst.KarteKbnName[AppConst.KarteKbn.SUBJECT]?.Short,
        AppConst.KarteKbnName[AppConst.KarteKbn.OBJECT]?.Short,
        AppConst.KarteKbnName[AppConst.KarteKbn.ASSESSMENT]?.Short,
        AppConst.KarteKbnName[AppConst.KarteKbn.PLAN]?.Short
    ]

    var myItems: [AppConst.KarteKbn: String] = [
        AppConst.KarteKbn.SUBJECT: "",
        AppConst.KarteKbn.OBJECT: "",
        AppConst.KarteKbn.ASSESSMENT: "",
        AppConst.KarteKbn.PLAN: "",
        ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")

        // DataSourceの設定をする.
        self.tableView.dataSource = self

        // Delegateを設定する.
        self.tableView.delegate = self

        // セルの高さ設定
        self.tableView.estimatedRowHeight = 90
        self.tableView.rowHeight = UITableView.automaticDimension

        // データがない行の罫線を削除
        self.tableView.tableFooterView = UIView()
        
        // SOAPデータ初期化
        initSOAP()
    }

    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // SOAデータ整形
        myItems.merge(contentsOf: (appDelegate.KarteSOA?.formatCurrentSelectedDataForDisplay())!)
        // Pデータ整形
        myItems[AppConst.KarteKbn.PLAN] = (appDelegate.KartePlan?.formatCurrentSelectedDataForDisplay())!

        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /*
     セクションの数を返す.
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return mySections.count
    }

    /*
     セクションのタイトルを返す.
     */
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return mySections[section]
    }

    /*
     テーブルに表示する配列の総数を返す.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = (indexPath as NSIndexPath).section

        // セクションからSOAP区分を導出
        let karteKbn = karteCommon.getKarteKbn(section+1)

        // SOA用に選択された区分をセット
        appDelegate.KarteSOA?.targetKarteKbn = karteKbn

        switch karteKbn {
        case .PLAN: // P
            performSegue(withIdentifier: "SegueDetailKartePlanSelect", sender: self)
        default: // SOA
            performSegue(withIdentifier: "SegueDetailKarteSOASelect", sender: self)
        }
    }
    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MyCell")
        let section = (indexPath as NSIndexPath).section

        // 改行を許可する
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = myItems[karteCommon.getKarteKbn(section+1)]

        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator

        return cell
    }

    // 連携ボタンクリック
    @IBAction func clickCooperation(_ sender: UIBarButtonItem) {
        // アラートアクションの設定
        var actionList = [(title: String , style: UIAlertAction.Style,action: (UIAlertAction) -> Void)]()

        // キャンセルアクション
        actionList.append(
            (
                title: "キャンセル",
                style: UIAlertAction.Style.cancel,
                action: {
                    (action: UIAlertAction!) -> Void in
                    print("Cancel")
            })
        )

        // OKアクション
        actionList.append(
            (
                title: "OK",
                style: UIAlertAction.Style.default,
                action: {
                    (action: UIAlertAction!) -> Void in
                    print("OK")

                    // 連携ファイル作成事前準備
                    let shopID = String(self.appDelegate.LoginInfo!["ShopID"].asInt!)
                    let customerID = self.appDelegate.SelectedCustomer!["CustomerID"].asString!
                    let receptionID = self.appDelegate.SelectedReception?["ReceptionID"].asInt!

                    var params: [String: AnyObject] = ["ReceptionID": receptionID as AnyObject]

                    // SOA
                    params.merge(contentsOf: (self.appDelegate.KarteSOA?.formatCurrentSelectedDataForAPI())!)
                    // P
                    params.merge(contentsOf: (self.appDelegate.KartePlan?.formatCurrentSelectedDataForAPI())!)

                    // 連携ファイル作成
                    let url = "\(AppConst.URLPrefix)link/PutSOAPCSV/\(shopID)/\(customerID)"
                    _ = self.appCommon.putSynchronous(url, params: params)

                    // 再描画
                    self.viewWillAppear(true)
            })
        )

        AppCommon.alertAnyAction(controller: self, title: "確認", message: "連携しますか？", actionList: actionList)
    }

    /*
     SOAPデータ初期化
     */
    func initSOAP() {
        let receptionID = appDelegate.SelectedReception?["ReceptionID"].asInt!
        let assID = appDelegate.SelectedReception?["AssID"].asInt!
        let customerID = appDelegate.SelectedCustomer!["CustomerID"].asString!

        var url = ""
        var res:(result: String?, errCode: String?) = (result: nil, errCode: nil)

        // SOAP連携履歴ヘッダー取得
        url = "\(AppConst.URLPrefix)ic/GetSOAPHistoryHeaderList/\(receptionID!)"
        res = appCommon.getSynchronous(url)

        if res.result! != "null" && AppCommon.isNilOrEmpty(res.errCode) {
            let SOAPHistoryHeaderListJSON = JSON(string: res.result!) // JSON読み込み
            if SOAPHistoryHeaderListJSON.length != 0 {
                // 日付降順でソート
                appDelegate.SOAPHistoryHeaderList = SOAPHistoryHeaderListJSON.map{ AppConst.SOAPHistoryHeaderFormat(
                    SOAPHistoryHeaderID: $0.1["SOAPHistoryHeaderID"].asInt,
                    ReceptionID: $0.1["ReceptionID"].asInt,
                    SUpdateKbn: $0.1["SUpdateKbn"].asString,
                    OUpdateKbn: $0.1["OUpdateKbn"].asString,
                    AUpdateKbn: $0.1["AUpdateKbn"].asString,
                    PUpdateKbn: $0.1["PUpdateKbn"].asString,
                    UpdateDateTime: $0.1["UpdateDateTime"].asDate,
                    CreateDateTime: $0.1["CreateDateTime"].asDate)
                    }.sorted{$0.SOAPHistoryHeaderID! > $1.SOAPHistoryHeaderID!}
            }
        }

        let lastSOAPHistoryHeader = appDelegate.SOAPHistoryHeaderList.first ?? nil

        // SOA最終履歴データ取得
        url = "\(AppConst.URLPrefix)ic/GetLastSOAHistory/\(String(receptionID!))"
        res = appCommon.getSynchronous(url)

        var lastSOAHistoryJSON:JSON? = nil
        if res.result! != "null" && AppCommon.isNilOrEmpty(res.errCode) {
            lastSOAHistoryJSON = JSON(string: res.result!) // JSON読み込み
        }

        // SOA初期化
        appDelegate.KarteSOA = KarteSOAClass(assIDInt: assID, lastSOAPHistoryHeader: lastSOAPHistoryHeader, targetHistoryDetail: lastSOAHistoryJSON,
                                             mstAssessmentGroup: appDelegate.MstAssessmentGroupList, mstAssessmentSubGroup: appDelegate.MstAssessmentSubGroupList, mstAssessment: appDelegate.MstAssessmentList, mstAssImageParts: appDelegate.MstAssImagePartsList)


        // P最終履歴データ取得
        url = "\(AppConst.URLPrefix)ic/GetLastPHistory/\(String(receptionID!))"
        res = appCommon.getSynchronous(url)

        var lastPHistoryJSON:JSON? = nil
        if res.result! != "null" && AppCommon.isNilOrEmpty(res.errCode) {
            lastPHistoryJSON = JSON(string: res.result!) // JSON読み込み
        }

        // P初期化
        appDelegate.KartePlan = KartePlanClass(customerID: customerID, lastSOAPHistoryHeader: lastSOAPHistoryHeader, targetHistoryDetail: lastPHistoryJSON,
                                               mstMenu: appDelegate.MstMenu, mstBusinessLogSubHD: appDelegate.MstBusinessLogSubHDList)
    }
}
