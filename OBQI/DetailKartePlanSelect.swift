//
//  File2.swift
//  OBQI
//
//  Created by t.o on 2017/04/25.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class DetailKarteSelectPlan: UITableViewController {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()

    var currentSelectedMenuGroupIDList: [Int] = []

    @IBOutlet weak var myNaviBar: UINavigationItem!

    override func viewDidLoad() {
        // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")

        // DataSourceの設定をする.
        self.tableView.dataSource = self

        // Delegateを設定する.
        self.tableView.delegate = self

        // タイトル設定
        myNaviBar.title = AppConst.KarteKbnName[AppConst.KarteKbn.PLAN]?.Full

        super.viewDidLoad()
    }

    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let allMenuGroupIDList = appDelegate.KartePlan?.currentSelectedData.map{ $0.MenuGroupID! }
        currentSelectedMenuGroupIDList = (NSOrderedSet(array: allMenuGroupIDList!).array as! [Int]).sorted(by: <)

        self.tableView.reloadData()
    }

    /*
     テーブルに表示する配列の総数を返す.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentSelectedMenuGroupIDList.count
    }
    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MyCell")
        let index = (indexPath as NSIndexPath).row

        cell.textLabel?.text = appDelegate.KartePlan?.selectableHDData.filter{ $0.MenuGroupID == currentSelectedMenuGroupIDList[index] }.map{ $0.MenuSetName }.first ?? ""

        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        
        return cell
    }

    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = (indexPath as NSIndexPath).row

        // 次の画面で選択可能なDTを設定
        _ = appDelegate.KartePlan?.setSelectableDTData(currentSelectedMenuGroupIDList[index])

        performSegue(withIdentifier: "SegueDetailKartePlanDTSelect", sender: self)
    }

    // セル 削除
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "削除"
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let index = (indexPath as NSIndexPath).row

        if  editingStyle == .delete {
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
                        print("Delete")

                        //　削除しないリスト
                        let keepList = self.appDelegate.KartePlan?.currentSelectedData.filter{ $0.MenuGroupID! != self.currentSelectedMenuGroupIDList[index] }

                        if keepList == nil {
                            // 削除しないリストがnilの場合はから配列を挿入
                            self.appDelegate.KartePlan?.currentSelectedData = []

                        } else {
                            // 削除しないリストでselectableHDDataを上書き(削除対象を除外する)
                            self.appDelegate.KartePlan?.currentSelectedData = keepList!
                        }


                        self.viewWillAppear(false)
                })
            )

            AppCommon.alertAnyAction(controller: self, title: "確認", message: "削除してもよろしいでしょうか？", actionList: actionList)
        }
    }

    @IBAction func ClickAdd(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "SegueModalKartePlanList", sender: self)
    }
}
