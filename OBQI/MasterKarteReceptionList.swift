//
//  File.swift
//  OBQI
//
//  Created by t.o on 2017/04/25.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class MasterKarteReceptionList: UITableViewController {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()

    var myItems: [JSON?] = []

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
            myItems = receptionJson.map{ $0.1 }
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
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "MyCell")
        let index = (indexPath as NSIndexPath).row

        if let receptionDateString = myItems[index]?["ReceptionDate"].asString {
            // yyyymmdd -> yyyy/mm/ddに変換
            cell.textLabel?.text = receptionDateString.replacingOccurrences(of: "([0-9]{4})([0-9]{2})([0-9]{2})", with: "$1/$2/$3", options: .regularExpression, range: receptionDateString.range(of: receptionDateString))
            cell.detailTextLabel?.text = "来院回数：\((myItems[index]?["VisitingTimes"].asString)!), 診療科コード：\((myItems[index]?["ClinicalCode"].asString)!)"
        }

        return cell
    }


    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = (indexPath as NSIndexPath).row

        // 選択された受付
        appDelegate.SelectedReception = myItems[index]

        // 選択された受付に紐づくアセスメント
        let assID = String(describing: (myItems[index]?["AssID"].asInt)!)
        let url = "\(AppConst.URLPrefix)assessment/GetInputAssessmentList/\(assID)"
        let res = appCommon.getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }
        appDelegate.RelatedAssessment = JSON(string: res.result!).map{ $0.1 }

        performSegue(withIdentifier: "SegueDetailKarteMenuList", sender: self)
    }
}
