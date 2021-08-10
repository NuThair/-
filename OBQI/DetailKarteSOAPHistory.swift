//
//  DetailKarteSOAPHistory.swift
//  OBQI
//
//  Created by t.o on 2017/05/26.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class DetailKarteSOAPHistory: UITableViewController {

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

        // 選択不可
        self.tableView.allowsSelection = false

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
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MyCell")
        let section = (indexPath as NSIndexPath).section

        // 改行を許可する
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = myItems[karteCommon.getKarteKbn(section+1)]

        return cell
    }

    /*
     SOAPデータ初期化
     */
    func initSOAP() {
        // アセスメントの取得
        let receptionID = appDelegate.SelectedKarteHistory?["ReceptionID"].asInt
        let customerID = appDelegate.SelectedCustomer!["CustomerID"].asString!

        var url = ""
        var res:(result: String?, errCode: String?) = (result: nil, errCode: nil)


        // 受付情報取得
        var assID: Int = 0
        url = "\(AppConst.URLPrefix)customer/GetReceptionList/\(customerID)"
        res = appCommon.getSynchronous(url)
        if res.result! != "null" && AppCommon.isNilOrEmpty(res.errCode) {
            let receptionJson = JSON(string: res.result!) // JSON読み込み
            if receptionJson.length != 0 {
                assID = receptionJson.filter{ $0.1["ReceptionID"].asInt == receptionID }.map{ $0.1["AssID"].asInt! }.first!
            }
        }

        // SOAP連携履歴ヘッダー取得
        url = "\(AppConst.URLPrefix)ic/GetSOAPHistoryHeaderList/\(receptionID!)"
        res = appCommon.getSynchronous(url)

        if res.result! != "null" && AppCommon.isNilOrEmpty(res.errCode) {
            let SOAPHistoryHeaderListJSON = JSON(string: res.result!) // JSON読み込み
            if SOAPHistoryHeaderListJSON.length != 0 {
                // 対象の履歴のみ抽出
                appDelegate.SOAPHistoryHeaderList = SOAPHistoryHeaderListJSON
                    .filter{ $0.1["SOAPHistoryHeaderID"].asInt == $0.1["SOAPHistoryHeaderID"].asInt }
                    .map{ AppConst.SOAPHistoryHeaderFormat(
                        SOAPHistoryHeaderID: $0.1["SOAPHistoryHeaderID"].asInt,
                        ReceptionID: $0.1["ReceptionID"].asInt,
                        SUpdateKbn: $0.1["SUpdateKbn"].asString,
                        OUpdateKbn: $0.1["OUpdateKbn"].asString,
                        AUpdateKbn: $0.1["AUpdateKbn"].asString,
                        PUpdateKbn: $0.1["PUpdateKbn"].asString,
                        UpdateDateTime: $0.1["UpdateDateTime"].asDate,
                        CreateDateTime: $0.1["CreateDateTime"].asDate)
                }
            }
        }

        let SOAPHistoryHeader = appDelegate.SOAPHistoryHeaderList.first ?? nil

        // SOA履歴データ取得
        url = "\(AppConst.URLPrefix)ic/GetSOAHistoryByID/\(String(describing: (appDelegate.SelectedKarteHistory?["HistoryID"].asInt)!))"
        res = appCommon.getSynchronous(url)

        var SOAHistoryJSON:JSON? = nil
        if res.result! != "null" && AppCommon.isNilOrEmpty(res.errCode) {
            SOAHistoryJSON = JSON(string: res.result!) // JSON読み込み
        }

        // SOA初期化
        appDelegate.KarteSOA = KarteSOAClass(assIDInt: assID, lastSOAPHistoryHeader: SOAPHistoryHeader, targetHistoryDetail: SOAHistoryJSON,
                                             mstAssessmentGroup: appDelegate.MstAssessmentGroupList, mstAssessmentSubGroup: appDelegate.MstAssessmentSubGroupList, mstAssessment: appDelegate.MstAssessmentList, mstAssImageParts: appDelegate.MstAssImagePartsList)


        // P履歴データ取得
        url = "\(AppConst.URLPrefix)ic/GetPHistoryByID/\(String(describing: (appDelegate.SelectedKarteHistory?["HistoryID"].asInt)!))"
        res = appCommon.getSynchronous(url)

        var PHistoryJSON:JSON? = nil
        if res.result! != "null" && AppCommon.isNilOrEmpty(res.errCode) {
            PHistoryJSON = JSON(string: res.result!) // JSON読み込み
        }

        // P初期化
        appDelegate.KartePlan = KartePlanClass(customerID: customerID, lastSOAPHistoryHeader: SOAPHistoryHeader, targetHistoryDetail: PHistoryJSON,
                                               mstMenu: appDelegate.MstMenu, mstBusinessLogSubHD: appDelegate.MstBusinessLogSubHDList)
    }
}
