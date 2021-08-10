//
//  MasterKarteTreatmentList.swift
//  OBQI
//
//  Created by t.o on 2017/06/29.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class MasterKarteTreatmentList: UITableViewController {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()

    var myItems: [String] = []
    var trnBLogSubHDList: [JSON?] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")

        // DataSourceの設定をする.
        self.tableView.dataSource = self

        // Delegateを設定する.
        self.tableView.delegate = self

        // 介入結果情報取得
        let customerID = appDelegate.SelectedCustomer!["CustomerID"].asString!
        let url = "\(AppConst.URLPrefix)business/GetBusinessLogSubHDListAll/\(customerID)"
        let res = appCommon.getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }

        let trnBLogSubHDListJson = JSON(string: res.result!) // JSON読み込み
        if trnBLogSubHDListJson.length > 0 {
            trnBLogSubHDList = trnBLogSubHDListJson.map{ $0.1 }
            myItems = trnBLogSubHDList
                .map{ AppCommon.getDateFormat(date: $0?["TreatmentDateTime"].asDate!, format: "yyyy/MM/dd")! }
               // .reduce([], { $0.0.contains($0.1) ? $0.0: $0.0 + [$0.1] }) Err
                .sorted(by: >)
        }
    }

    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MyCell")
        let index = (indexPath as NSIndexPath).row

        cell.textLabel?.text = myItems[index]

        return cell
    }


    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = (indexPath as NSIndexPath).row

        // 同一日のBLogSubHDを取得
        appDelegate.SelectedSameDayBLogSubHDList = trnBLogSubHDList
            .filter{ AppCommon.getDateFormat(date: $0?["TreatmentDateTime"].asDate!, format: "yyyy/MM/dd")! == myItems[index] }
            .map{ $0 }

        performSegue(withIdentifier: "SegueDetailKarteOrderCooperation", sender: self)
    }
}
