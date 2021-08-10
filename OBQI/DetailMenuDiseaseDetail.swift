//
//  MasterProgramList.swift
//  OBQI
//
//  Created by t.o on 2017/01/26.
//  Copyright © 2017年 System. All rights reserved.
//


import UIKit

class DetailMenuDiseaseDetail: UITableViewController {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()

    let mySections = ["選択傷病名", "選択修飾語"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")

        // DataSourceの設定をする.
        self.tableView.dataSource = self

        // Delegateを設定する.
        self.tableView.delegate = self
    }

    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillApper")

        // 選択された修飾語のインデックス初期化
        appDelegate.SelectedModifierIndex = nil

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
        switch section {
        case 0: // 傷病名
            return 1

        case 1: // 修飾語名
            guard let modifiers = appDelegate.MenuParamsTmp.Disease[appDelegate.SelectedDiseaseIndex!]?.Modifiers else {
                return 1
            }
            return modifiers.count + 1

        default:
            return 0
        }
    }

    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "MyCell")
        let section = (indexPath as NSIndexPath).section
        let index = (indexPath as NSIndexPath).row

        guard let disease = appDelegate.MenuParamsTmp.Disease[appDelegate.SelectedDiseaseIndex!] else {
            return cell
        }

        switch section {
        case 0: // 傷病名
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text =  "選択傷病名\nICD10"
            cell.detailTextLabel?.numberOfLines = 0
            cell.detailTextLabel?.text =  "\(disease.MainName!)\n\(disease.ICD10!)"

        case 1: // 修飾語名
            if index == 0 { // 先頭は追加ボタン
                cell.textLabel?.text = "修飾語を追加する"
                cell.textLabel?.textColor = UIColor.blue

            } else {
                guard let modifier = disease.Modifiers[index - 1] else {
                    return cell
                }
                cell.textLabel?.text = modifier.MdfyName
                cell.detailTextLabel?.text = AppConst.ModifierKbnText[modifier.MdfyKbn!]
            }

        default: break
        }

        // 右側に矢印
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        return cell
    }

    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = (indexPath as NSIndexPath).section
        let index = (indexPath as NSIndexPath).row

        switch section {
        case 0: // 傷病名
            // 画面遷移
            self.performSegue(withIdentifier: "SegueDetailMenuDiseaseSearch", sender: self)

        case 1: // 修飾語名
            if index > 0 { // 先頭は追加ボタン
                // 選択された傷病名のインデックスを格納
                appDelegate.SelectedModifierIndex = index - 1
            }

            self.performSegue(withIdentifier: "SegueDetailMenuModifierSearch", sender: self)

        default: break
        }
    }

    // セル 削除
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let section = (indexPath as NSIndexPath).section

        // 削除は修飾語の追加ボタン以外
        if section == 1 && indexPath.row > 0{
            return true
        }

        return false
    }
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "削除"
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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

                        _ = self.appDelegate.MenuParamsTmp.Disease[self.appDelegate.SelectedDiseaseIndex!]?.Modifiers.remove(at: (indexPath.row - 1))
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                })
            )

            AppCommon.alertAnyAction(controller: self, title: "確認", message: "削除してもよろしいでしょうか？", actionList: actionList)
        }
    }
}
