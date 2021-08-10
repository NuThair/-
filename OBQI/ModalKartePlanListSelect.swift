//
//  File3.swift
//  OBQI
//
//  Created by t.o on 2017/04/25.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class ModalKartePlanListSelect: UITableViewController {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()

    var selectedMenuHDList = [JSON]()

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

        // 現在選択中の値を設定
        appDelegate.KartePlan?.newSelectedData = (appDelegate.KartePlan?.currentSelectedData)!
    }

    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // テーブル内容再描画
        self.tableView?.reloadData()
    }

    /*
     テーブルに表示する配列の総数を返す.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let selectableHDData = appDelegate.KartePlan?.selectableHDData else {
            return 0
        }
        return selectableHDData.count
    }

    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "MyCell")
        let index = (indexPath as NSIndexPath).row

        let menuSetName = (appDelegate.KartePlan?.selectableHDData[index].MenuSetName)!
        let createDateTime = (appDelegate.KartePlan?.selectableHDData[index].CreateDateTime)!
        let menuStatus = (appDelegate.KartePlan?.selectableHDData[index].MenuStatus)!

        cell.textLabel?.text = "\(menuSetName)"
        cell.detailTextLabel?.text = "作成日：\(createDateTime) ステータス：\(AppConst.MenuStatusName[Int(menuStatus)!])"

        // 追加画面から戻った場合は追加されたメニューを選択済みにする
        let menuGroupID = appDelegate.KartePlan?.selectableHDData[index].MenuGroupID!
        let selectedCount = appDelegate.KartePlan?.newSelectedData.filter{ $0.MenuGroupID == menuGroupID }.map{ $0 }.count
        if  selectedCount! > 0 {
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        }

        // 追加済みなら選択不可
        let addedCount = appDelegate.KartePlan?.currentSelectedData.filter{ $0.MenuGroupID == menuGroupID }.map{ $0 }.count
        if  addedCount! > 0 {
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.backgroundColor = UIColor.disabled()
        }

        return cell
    }


    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let index = (indexPath as NSIndexPath).row

        // 追加済みなら選択不可
        let menuGroupID = appDelegate.KartePlan?.selectableHDData[index].MenuGroupID!
        let addedCount = appDelegate.KartePlan?.currentSelectedData.filter{ $0.MenuGroupID == menuGroupID }.map{ $0 }.count
        if  addedCount! > 0 {
            return nil
        }

        return indexPath
    }
    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = (indexPath as NSIndexPath).row

        // 次の画面で選択可能なDTを設定
        let menuGroupID = appDelegate.KartePlan?.selectableHDData[index].MenuGroupID!
        _ = appDelegate.KartePlan?.setSelectableDTData(menuGroupID!)

        performSegue(withIdentifier: "SegueDetailKartePlanDTSelect", sender: self)
    }


    /*
     確定
     */
    @IBAction func ClickConfirm(_ sender: Any) {
        // 追加が一つもない場合アラート
        if appDelegate.KartePlan?.newSelectedData.count == 0 {
            AppCommon.alertMessage(controller: self, title: "エラー", message: "追加する介入計画を選択してください。")
            return
        }

        // 連携対象リストに追加
        appDelegate.KartePlan?.currentSelectedData = (appDelegate.KartePlan?.currentSelectedData)! + (appDelegate.KartePlan?.newSelectedData)!

        // 閉じる
        self.dismiss(animated: true, completion: nil)

        // 親コントローラ
        let parentSplitView = self.presentingViewController as! UISplitViewController
        let parentNavi = parentSplitView.viewControllers[1] as! UINavigationController
        let parentView = parentNavi.topViewController as! DetailKarteSelectPlan

        // 親コントローラ再描画
        parentView.viewWillAppear(false)
    }

    /*
     モーダル閉じる
     */
    @IBAction func ClickCancel(_ sender: Any) {
        // 閉じる
        self.dismiss(animated: true, completion: nil)
    }
}
