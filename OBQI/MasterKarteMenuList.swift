//
//  MasterKarteMenuList.swift
//  OBQI
//
//  Created by t.o on 2017/06/29.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class MasterKarteMenuList: UITableViewController {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    let karteCommon = KarteCommon()

    let myItems = ["SOAP", "オーダー", "連携履歴"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")

        // DataSourceの設定をする.
        self.tableView.dataSource = self

        // Delegateを設定する.
        self.tableView.delegate = self

        // 受付情報取得
        let customerID = appDelegate.SelectedCustomer!["CustomerID"].asString!
        let url = "\(AppConst.URLPrefix)customer/GetReceptionList/\(customerID)"
        let res = appCommon.getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }

        let receptionJson = JSON(string: res.result!) // JSON読み込み
        if receptionJson.length > 0 {
            appDelegate.KarteReceptionList = receptionJson.map{ $0.1 }
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
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "MyCell")
        let index = (indexPath as NSIndexPath).row

        cell.textLabel?.text = myItems[index]

        // 矢印
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator

        return cell
    }

    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = (indexPath as NSIndexPath).row

        switch index {
        case 0: // SOAP
            performSegue(withIdentifier: "SegueMasterKarteReceptionList", sender: self)
            break

        case 1: // オーダー
            performSegue(withIdentifier: "SegueMasterKarteTreatmentList", sender: self)
            break

        case 2: // 連携履歴
            performSegue(withIdentifier: "SegueDetailKarteHistoryList", sender: self)
            break

        default:
            break
        }
    }
}
