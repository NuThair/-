//
//  DetailMenuList.swift
//  OBQI
//
//  Created by t.o on 2017/01/27.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class DetailMenuSetStaffSelect: UITableViewController {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()

    var shopStaffList: [JSON] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")

        // DataSourceの設定をする.
        self.tableView.dataSource = self

        // Delegateを設定する.
        self.tableView.delegate = self

        // スタッフ一覧取得
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        let shopID = appDelegate.SelectedCustomer!["ShopID"].asInt!

        let url = "\(AppConst.URLPrefix)staff/GetShopStaffList/\(shopID)"
        let res = appCommon.getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }

        let shopStaffJson = JSON(string: res.result!) // JSON読み込み
        if shopStaffJson.length == 0 {
            shopStaffList = []
        } else {
            shopStaffList = []
            for i in 0 ..< shopStaffJson.length {
                let json : JSON? = shopStaffJson[i]
                shopStaffList.append(json!)
            }
        }
    }

    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillApper")
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /*
     テーブルに表示する配列の総数を返す.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shopStaffList.count
    }

    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "MyCell")

        let staffID = shopStaffList[(indexPath as NSIndexPath).row]["StaffID"].asString!
        let staffLastNameKana = shopStaffList[(indexPath as NSIndexPath).row]["StaffLastNameKana"].asString!
        let staffFirstNameKana = shopStaffList[(indexPath as NSIndexPath).row]["StaffFirstNameKana"].asString!
        let createDateTime = AppCommon.getDateFormat(date: shopStaffList[(indexPath as NSIndexPath).row]["CreateDateTime"].asDate, format: "yyyy/MM/dd HH:mm:ss")!

        cell.textLabel?.text = "\(staffLastNameKana) \(staffFirstNameKana)"
        cell.detailTextLabel?.text = "作成日：\(createDateTime) StaffID：\(staffID)"

        // 選択済み
        if staffID == appDelegate.MenuParamsTmp.MenuHD.MenuSetStaffID {
            // チェックマークをつける
            cell.isSelected = true
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }

        return cell
    }

    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let index = (indexPath as NSIndexPath).row

        appDelegate.MenuParamsTmp.MenuHD.MenuSetStaffID = shopStaffList[index]["StaffID"].asString!
        appDelegate.MenuParamsTmp.MenuHD.MenuSetStaffName = "\(shopStaffList[index]["StaffLastName"].asString!) \(shopStaffList[index]["StaffFirstName"].asString!)"
        appDelegate.MenuParamsTmp.MenuHD.MenuSetStaffNameKana = "\(shopStaffList[index]["StaffLastNameKana"].asString!) \(shopStaffList[index]["StaffFirstNameKana"].asString!)"

        // チェックマークをつける
        cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
    }
    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)

        cell?.accessoryType = UITableViewCell.AccessoryType.none
    }

}
