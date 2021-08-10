//
//  DetailKarteOrderList.swift
//  OBQI
//
//  Created by t.o on 2017/05/26.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class DetailKarteOrderCooperation: UITableViewController {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    let karteCommon = KarteCommon()

    var mySections: [String] =  []

    var myItems: [String] = []

    // 選択中オーダークラス
    var selectingIndex = 0

    // 選択済みセクション
    var selectedSectionList: [Int] = []
    
    // 最新受付情報
    var lastReceptionJSON: JSON?

    @IBOutlet weak var myNaviBar: UINavigationItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")

        // DataSourceの設定をする.
        self.tableView.dataSource = self

        // Delegateを設定する.
        self.tableView.delegate = self

        // 複数選択可
        self.tableView.allowsMultipleSelection = true

        // セルの高さ設定
        self.tableView.estimatedRowHeight = 90
        self.tableView.rowHeight = UITableView.automaticDimension

        // 編集モード中もタップを許可する
        self.tableView.allowsSelectionDuringEditing = true

        // データがない行の罫線を削除
        self.tableView.tableFooterView = UIView()

        // オーダー初期化
        initOrder()
    }

    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tableView.reloadData()
    }


    /*
     セクションの数を返す.
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return appDelegate.KarteOrderList.count
    }

    /*
     セクション設定
     */
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let frame: CGRect = tableView.frame
        let headerView: UIView = UIButton(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        headerView.backgroundColor = UIColor.defaultSectionBackGround()

        let label = UILabel(frame: CGRect(x: 8, y: 0, width: frame.size.width, height: 80));
        label.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
        label.numberOfLines = 0
        label.text = "\(mySections[section])"
        if appDelegate.KarteOrderList[section]?.selectableHDData != nil {
            let bLogGroupID = appDelegate.KarteOrderList[section]?.selectableHDData?.BLogGroupID!
            let bLogSubGroupID = appDelegate.KarteOrderList[section]?.selectableHDData?.BLogSubGroupID!
            var groupName =  appDelegate.MstBusinessLogHDList?.filter{ $0.1["BLogGroupID"].asInt! == bLogGroupID }.first.map{ $0.1["BLogGroupName"].asString! }
            var subGroupName = appDelegate.MstBusinessLogSubHDList?.filter{ $0.1["BLogGroupID"].asInt! == bLogGroupID && $0.1["BLogSubGroupID"].asInt! == bLogSubGroupID }.first.map{ $0.1["BLogSubGroupName"].asString! }
            if groupName == nil {
                groupName = "削除済み"
            }
            if subGroupName == nil {
                subGroupName = "削除済み"
            }
            label.text = "\(label.text!)\n【メニュー】\(groupName!)\n【サブメニュー】\(subGroupName!)"
        }
        headerView.addSubview(label)

        return headerView
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
        cell.textLabel?.text = appDelegate.KarteOrderList[section]?.formatCurrentSelectedDataForDisplay()

        // 選択モード
        if self.myNaviBar.leftBarButtonItem?.tag == 0
        {
            if self.selectedSectionList.contains(section) {
                // チェックマークをつける
                cell.isSelected = true
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
                self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
        }

        // 編集モード
        else
        {
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        }

        return cell
    }

    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let section = (indexPath as NSIndexPath).section

        // 選択モード
        if self.myNaviBar.leftBarButtonItem?.tag == 0
        {
            cell?.accessoryType = UITableViewCell.AccessoryType.checkmark

            // 選択済みセクション
            selectedSectionList.append(section)
        }

        // 編集モード
        else
        {
            self.selectingIndex = section

            self.performSegue(withIdentifier: "SegueDetailKarteOrderSelect", sender: self)
        }
    }
    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let section = (indexPath as NSIndexPath).section

        // 選択モード
        if self.myNaviBar.leftBarButtonItem?.tag == 0
        {
            cell?.accessoryType = UITableViewCell.AccessoryType.none

            // 選択済みセクション
            let selectedSectionIndex = selectedSectionList.index(of: section)
            selectedSectionList.remove(at: selectedSectionIndex!)
        }
    }

    // セル 削除
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // 削除は許可しない
        return false
    }

    /*
     画面遷移時
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // オーダー選択に必要な情報をセット
        if segue.identifier == "SegueDetailKarteOrderSelect" {
            let detailKarteOrderSelect = segue.destination as! DetailKarteOrderSelect
            detailKarteOrderSelect.selectingIndex = self.selectingIndex
        }
    }

    // 編集モード切り替え
    @IBAction func toggleEditMode(_ sender: UIBarButtonItem) {
        // tagによってモード切り替え
        if sender.tag == 0 {
            // 編集モード on
            sender.tag = 1
            self.tableView.isEditing = true

            sender.tintColor = UIColor.red
            sender.title = "選択モードにする"

            // 選択状態を解除して矢印を付与する
            for i in 0..<tableView.numberOfSections {
                for j in 0..<tableView.numberOfRows(inSection: i) {
                    let ints: [Int] = [i, j]
                    let indexPath = IndexPath(indexes: ints)
                    let cell: UITableViewCell? = tableView.cellForRow(at: indexPath)

                    tableView.deselectRow(at: indexPath, animated: false)
                    cell?.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                }
            }

        } else {
            // 編集モード off
            sender.tag = 0
            self.tableView.isEditing = false

            sender.tintColor = self.view.tintColor
            sender.title = "編集モードにする"

            // 矢印を取り除いて選択状態を再現する
            for i in 0..<tableView.numberOfSections {
                for j in 0..<tableView.numberOfRows(inSection: i) {
                    let ints: [Int] = [i, j]
                    let indexPath = IndexPath(indexes: ints)
                    let cell: UITableViewCell? = tableView.cellForRow(at: indexPath)

                    cell?.accessoryType = UITableViewCell.AccessoryType.none

                    if self.selectedSectionList.contains(i) {
                        cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
                        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                    }
                }
            }
        }
    }

    // 連携ボタンクリック
    @IBAction func clickCooperation(_ sender: UIBarButtonItem) {
        // エラーチェック 対象なし
        if selectedSectionList.count == 0 {
            AppCommon.alertMessage(controller: self, title: "エラー", message: "連携対象を選択してください")
            return
        }

        // 連携対象データをOBQIOrderNo毎に振り分け
        var orderList: [(OBQIOrderNo: Int, ReceptionID: Int, IsChange: Bool, OrderKbn: String, KarteDataList: [KarteOrderClass])] = []
        self.selectedSectionList.forEach { (selectedIndex) -> Void in
            // 新規の場合は0
            var orderNo = 0
            // 新規の場合は最新
            var receptionID = self.lastReceptionJSON?["ReceptionID"].asInt!
            // 当該セクションの情報を取得する
            let bLogGroupID = appDelegate.KarteOrderList[selectedIndex]?.selectableHDData?.BLogGroupID!
            let bLogSubGroupID = appDelegate.KarteOrderList[selectedIndex]?.selectableHDData?.BLogSubGroupID!

            // 履歴データがある場合
            if self.appDelegate.KarteOrderList[selectedIndex]?.lastHistoryData?["H_History"].asDictionary != nil {
                // 最終連携時のNoを使用
                let orderNoString = (self.appDelegate.KarteOrderList[selectedIndex]?.lastHistoryData?["H_History"]["OBQIOrderNo"].asString!)!
                orderNo = Int(orderNoString)!
                receptionID = self.appDelegate.KarteOrderList[selectedIndex]?.lastHistoryData?["H_History"]["ReceptionID"].asInt!
            }
            // オーダー区分を取得する
            let orderKbnList = appDelegate.MstOrderRelation?.filter{
                $0.1["BLogGroupID"].asInt == bLogGroupID
                && $0.1["BLogSubGroupID"].asInt == bLogSubGroupID
                }
                .map{ $0.1["OrderKbn"].asString! }
            var orderKbn = ""
            if orderKbnList != nil && (orderKbnList?.count)! > 0 {
                orderKbn = (orderKbnList?.first)!
            }
            
            
            // リストになければ追加
            if (orderList.filter{ $0.OBQIOrderNo == orderNo && $0.OrderKbn == orderKbn }.count) == 0 {
                orderList.append((OBQIOrderNo: orderNo, ReceptionID: receptionID!, IsChange: false, OrderKbn: orderKbn, KarteDataList: []))
            }

            // OBQIOrderNoグループのインデックス取得
            let orderListIndex = orderList.enumerated().filter{ $0.element.OBQIOrderNo == orderNo && $0.element.OrderKbn == orderKbn }.map{ $0.offset }.first!

            // データの追加
            orderList[orderListIndex].KarteDataList.append(self.appDelegate.KarteOrderList[selectedIndex]!)
        }

        // エラーチェック オーダー単位
        orderList.forEach {
            var order = $0

            order.KarteDataList.forEach { (KarteData) -> Void in
                // 未連携且つDT未選択の場合
                if !(KarteData.validateDTSelect()) {
                    AppCommon.alertMessage(controller: self, title: "エラー", message: "詳細が選択されていないデータが含まれています")
                    return
                }

                // 必須チェック
                if !(KarteData.validateRequired()) {
                    AppCommon.alertMessage(controller: self, title: "エラー", message: "必須項目が選択されていないデータが含まれています")
                    return
                }

                // 変更を含む
                if (KarteData.validateChanged()) {
                    order.IsChange = true
                }
            }

            // falseが一件でも含まれていればエラー
            if !order.IsChange {
                AppCommon.alertMessage(controller: self, title: "エラー", message: "最終連携から変更がないデータが含まれています")
                return
            }
        }

        // アラートアクションの設定
        var actionList = [(title: String , style: UIAlertAction.Style ,action: (UIAlertAction) -> Void)]()

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

                    // OBQIOrderNoが分かれている場合は別リクエストにする
                    orderList.forEach { (order) -> Void in
                        // 選択された連携対象からorderNoに合致する分を取得
                        var orderBLogSubHDInfoList: [AnyObject] = []
                        order.KarteDataList.forEach {
                            orderBLogSubHDInfoList.append($0.formatCurrentSelectedDataForAPI() as AnyObject)
                        }

                        let params: [String: AnyObject] = [
                            "OBQIOrderNo": order.OBQIOrderNo as AnyObject,
                            "ReceptionID": order.ReceptionID as AnyObject,
                            "OrderBLogSubHDInfoList": orderBLogSubHDInfoList as AnyObject,
                        ]

                        // 連携ファイル作成
                        let url = "\(AppConst.URLPrefix)link/PutOrderCSV/\(shopID)/\(customerID)"
                        _ = self.appCommon.putSynchronous(url, params: params)
                    }

                    // オーダー初期化
                    self.initOrder()

                    // 再描画
                    self.viewWillAppear(true)
            })
        )
        
        AppCommon.alertAnyAction(controller: self, title: "確認", message: "連携しますか？", actionList: actionList)
    }

    /*
     オーダーデータ初期化
     */
    func initOrder() {
        self.lastReceptionJSON = appDelegate.KarteReceptionList.sorted{ ($0?["ReceptionID"].asInt!)! < ($1?["ReceptionID"].asInt!)! }.last!!
        let customerID = appDelegate.SelectedCustomer!["CustomerID"].asString!

        self.mySections = []
        appDelegate.KarteOrderList = []
        appDelegate.SelectedSameDayBLogSubHDList.forEach { (selectedSameDayBLogSubHD) -> Void in
            let treatmentDateString =  AppCommon.getDateFormat(date: selectedSameDayBLogSubHD?["TreatmentDateTime"].asDate, format: "yyyy/MM/dd HH:mm")!
            var sectionTitle = "実施日時: \(treatmentDateString)        最終連携日時: "

            // 履歴データの取得
            let bLogGroupID = (selectedSameDayBLogSubHD?["BLogGroupID"].asInt)!
            let bLogSubGroupID = (selectedSameDayBLogSubHD?["BLogSubGroupID"].asInt)!
            let bLogSEQNO = (selectedSameDayBLogSubHD?["BLogSEQNO"].asInt)!
            let url = "\(AppConst.URLPrefix)ic/GetLastOrderHistory/\(customerID)/\(bLogGroupID)/\(bLogSubGroupID)/\(bLogSEQNO)"
            let res = appCommon.getSynchronous(url)

            // 取得した履歴データを格納
            let orderHistoryJson = JSON(string: res.result!) // JSON読み込み

            // 履歴データを展開して、初期選択状態を生成
            // 受付日取得
            var receptionDate = self.lastReceptionJSON?["ReceptionDate"].asString!
            if(orderHistoryJson["H_History"].asDictionary != nil) {
                // 連携済みであれば連携当時の受付日
                let receptionID = orderHistoryJson["H_History"]["ReceptionID"].asInt!
                receptionDate = appDelegate.KarteReceptionList.filter{ $0?["ReceptionID"].asInt! == receptionID}.map{ ($0?["ReceptionDate"].asString!)! }.first

                let createDateTimeString =  AppCommon.getDateFormat(date: orderHistoryJson["H_History"]["CreateDateTime"].asDate, format: "yyyy/MM/dd HH:mm")!
                sectionTitle = "\(sectionTitle)\(createDateTimeString)"
            }
            // yyyymmdd -> yyyy-mm-ddに変換
            receptionDate = receptionDate?.replacingOccurrences(of: "([0-9]{4})([0-9]{2})([0-9]{2})", with: "$1-$2-$3", options: .regularExpression, range: receptionDate?.range(of: receptionDate!))

            // オーダー初期化
            appDelegate.KarteOrderList.append(
                KarteOrderClass(customerID: customerID
                              , bLogSubHDJSON: selectedSameDayBLogSubHD
                              , lastHistoryData: orderHistoryJson
                              , mstBusinessLogDT: appDelegate.MstBusinessLogDTList
                              , mstBssImageParts: appDelegate.MstBssImagePartsList
                              , mstOrderRelation: appDelegate.MstOrderRelation))
            
            // セクションタイトル
            mySections.append(sectionTitle)
        }
    }
}
