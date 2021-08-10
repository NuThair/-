//
//  DetailKarteMenuList.swift
//  OBQI
//
//  Created by t.o on 2017/05/26.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class DetailKarteMenuList: UITableViewController {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    let karteCommon = KarteCommon()

    let myItems = ["SOAP"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")

        // DataSourceの設定をする.
        self.tableView.dataSource = self

        // Delegateを設定する.
        self.tableView.delegate = self


        // SOAPデータ初期化
        initSOAP()

        // オーダーデータ初期化
        initOrder()


        // NotificationCenterを使用して更新を監視
        let center = NotificationCenter.default
        // SOAP
        center.addObserver(self, selector: #selector(self.initSOAP), name: appDelegate.SOAPNotificationName, object: nil)
        // オーダー
        center.addObserver(self, selector: #selector(self.initOrder), name: appDelegate.OrderNotificationName, object: nil)
    }

    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
    }

    /*
     テーブルに表示する配列の総数を返す.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myItems.count
    }

    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "MyCell")
        let index = (indexPath as NSIndexPath).row

        cell.textLabel?.text = myItems[index]
        switch index {
        case 0: // SOAP
            var lastLinkDate: Date? = nil
            if appDelegate.SOAPHistoryHeaderList.count > 0 {
                lastLinkDate = appDelegate.SOAPHistoryHeaderList.first?.CreateDateTime
            }

            cell.detailTextLabel?.text = karteCommon.getLastLinkDateText(lastLinkDate)
            break

        case 1: // オーダー
            if appDelegate.SOAPHistoryHeaderList.count == 0 {
                break
            }

            cell.detailTextLabel?.text = karteCommon.getLastLinkDateText(nil)
            break

        default:
            break
        }

        // 矢印
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator

        return cell
    }

    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = (indexPath as NSIndexPath).row

        switch index {
        case 0: // SOAP
            performSegue(withIdentifier: "SegueDetailKarteSOAPCooperation", sender: self)
            break

        case 1: // オーダー
            performSegue(withIdentifier: "SegueDetailKarteOrderCooperation", sender: self)
            break

        case 2: // 連携履歴
            performSegue(withIdentifier: "SegueDetailKarteHistoryList", sender: self)
            break

        default:
            break
        }
    }

    /*
     SOAPデータ初期化
     */
    func initSOAP() {
        let receptionID = appDelegate.SelectedReception?["ReceptionID"].asInt!
        let assID = appDelegate.SelectedReception?["AssID"].asInt!
        let customerID = appDelegate.SelectedCustomer!["CustomerID"].asString!

        // SOAP連携履歴ヘッダー取得
        let url = "\(AppConst.URLPrefix)ic/GetSOAPHistoryHeaderList/\(receptionID!)"
        let res = appCommon.getSynchronous(url)

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
                }.sorted{ $0.0.SOAPHistoryHeaderID! > $0.1.SOAPHistoryHeaderID! }
            }
        }

        let lastSOAPHistoryHeader = appDelegate.SOAPHistoryHeaderList.first ?? nil

        // SOA初期化
        appDelegate.KarteSOA = KarteSOAClass(receptionID: receptionID, assIDInt: assID, lastSOAPHistoryHeader: lastSOAPHistoryHeader,
            mstAssessmentGroup: appDelegate.MstAssessmentGroupList, mstAssessmentSubGroup: appDelegate.MstAssessmentSubGroupList, mstAssessment: appDelegate.MstAssessmentList, mstAssImageParts: appDelegate.MstAssImagePartsList)

        // P初期化
        appDelegate.KartePlan = KartePlanClass(receptionID: receptionID, customerID: customerID, lastSOAPHistoryHeader: lastSOAPHistoryHeader,
            mstMenu: appDelegate.MstMenu, mstBusinessLogSubHD: appDelegate.MstBusinessLogSubHDList)
    }

    /*
     オーダーデータ初期化
     */
    func initOrder() {
        let customerID = appDelegate.SelectedCustomer!["CustomerID"].asString!
        // yyyymmdd -> yyyy-mmddに変換
        var receptionDate = appDelegate.SelectedReception?["ReceptionDate"].asString!
        receptionDate = receptionDate?.replacingOccurrences(of: "([0-9]{4})([0-9]{2})([0-9]{2})", with: "$1-$2-$3", options: .regularExpression, range: receptionDate?.range(of: receptionDate!))


        // オーダー連携履歴ヘッダー取得

        // オーダー初期化
        appDelegate.KarteOrder = KarteOrderClass(customerID: customerID, receptionDate: receptionDate)
    }
}
