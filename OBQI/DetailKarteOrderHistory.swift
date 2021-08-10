//
//  DetailKCOrderHistory.swift
//  OBQI
//
//  Created by t.o on 2017/05/26.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class DetailKarteOrderHistory: UITableViewController {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    let karteCommon = KarteCommon()

    var mySections: [String] =  []

    var myItems: [String] = []

    // 選択中オーダークラス
    var selectingIndex = 0

    // 選択済みセクション
    var selectedSectionList: [Int] = []

    @IBOutlet weak var myNaviBar: UINavigationItem!
    @IBOutlet weak var result: UILabel!

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

        // データがない行の罫線を削除
        self.tableView.tableFooterView = UIView()

        // 選択不可
        self.tableView.allowsSelection = false

        // 連携結果メッセージ表示
        let cooperationStatus = appDelegate.SelectedKarteHistory?["CooperationStatus"].asInt
        let errTxt = appDelegate.SelectedKarteHistory?["ErrTxt"].asString

        // ステータス判定
        var status = ""
        switch(AppConst.CooperationStatus(rawValue: cooperationStatus!)!) {
        case AppConst.CooperationStatus.SENT:
            status = "送信済"
            break
        case AppConst.CooperationStatus.SUCCESS:
            status = "連携済"
        case AppConst.CooperationStatus.ERROR:
            status = "連携エラー"
            break
        }

        result.text = "ステータス: \(status)\nメッセージ: \(errTxt ?? "")"

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
            let groupName =  appDelegate.MstBusinessLogHDList?.filter{ $0.1["BLogGroupID"].asInt! == bLogGroupID }.first.map{ $0.1["BLogGroupName"].asString! }
            let subGroupName = appDelegate.MstBusinessLogSubHDList?.filter{ $0.1["BLogGroupID"].asInt! == bLogGroupID && $0.1["BLogSubGroupID"].asInt! == bLogSubGroupID }.first.map{ $0.1["BLogSubGroupName"].asString! }
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

        return cell
    }

    /*
     オーダーデータ初期化
     */
    func initOrder() {
        let customerID = appDelegate.SelectedCustomer!["CustomerID"].asString!

        var url = ""
        var res:(result: String?, errCode: String?) = (result: nil, errCode: nil)


        // SOAP連携履歴ヘッダー取得
        url = "\(AppConst.URLPrefix)ic/GetOrderHistoryByID/\(String(describing: (appDelegate.SelectedKarteHistory?["HistoryID"].asInt)!))"
        res = appCommon.getSynchronous(url)

        var orderHistoryJson:JSON? = nil
        if res.result! != "null" && AppCommon.isNilOrEmpty(res.errCode) {
            orderHistoryJson = JSON(string: res.result!) // JSON読み込み
        }


        // 履歴データから必要なBLogSubHDの特定
        url = "\(AppConst.URLPrefix)business/GetBusinessLogSubHDListAll/\(customerID)"
        res = appCommon.getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }

        var trnBLogSubHDList: [JSON?] = []
        let trnBLogSubHDListJson = JSON(string: res.result!) // JSON読み込み
        if trnBLogSubHDListJson.length > 0 {
            orderHistoryJson?["H_BLogHistoryList"].forEach{ (orderHistory) -> Void in
                let trnBLogSubHD = trnBLogSubHDListJson
                    .filter{ $0.1["BLogGroupID"].asInt == orderHistory.1["BLogGroupID"].asInt
                        && $0.1["BLogSubGroupID"].asInt == orderHistory.1["BLogSubGroupID"].asInt
                        && $0.1["BLogSEQNO"].asInt == orderHistory.1["BLogSEQNO"].asInt
                    }
                    .map{ $0.1 }
                    .first

                if trnBLogSubHD != nil {
                    trnBLogSubHDList.append(trnBLogSubHD)
                }
            }
        }

        self.mySections = []
        appDelegate.KarteOrderList = []
        trnBLogSubHDList.forEach { (trnBLogSubHD) -> Void in
            let treatmentDateString =  AppCommon.getDateFormat(date: trnBLogSubHD?["TreatmentDateTime"].asDate, format: "yyyy/MM/dd HH:mm")!
            let sectionTitle = "実施日時: \(treatmentDateString)"

            // オーダー初期化
            appDelegate.KarteOrderList.append(KarteOrderClass(customerID: customerID, bLogSubHDJSON: trnBLogSubHD, lastHistoryData: orderHistoryJson,
                                                              mstBusinessLogDT: appDelegate.MstBusinessLogDTList, mstBssImageParts: appDelegate.MstBssImagePartsList, mstOrderRelation: appDelegate.MstOrderRelation))
            // セクションタイトル
            mySections.append(sectionTitle)
        }
    }
}
