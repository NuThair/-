//
//  MasterProgramList.swift
//  OBQI
//
//  Created by t.o on 2017/01/26.
//  Copyright © 2017年 System. All rights reserved.
//


import UIKit

class DetailMenuDiseaseSelect: UITableViewController {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()

    let mySections = ["選択傷病名"]

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

        // 選択された傷病名のインデックス初期化
        appDelegate.SelectedDiseaseIndex = nil

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
        return appDelegate.MenuParamsTmp.Disease.count
    }

    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "MyCell")
        let index = (indexPath as NSIndexPath).row

        // 傷病名
        guard let disease = appDelegate.MenuParamsTmp.Disease[index] else {
            return cell
        }
        cell.textLabel?.text =  "\(disease.ICD10!)：\(disease.MainName!)"

        // 修飾語
        guard let modifiers = appDelegate.MenuParamsTmp.Disease[index]?.Modifiers else {
            return cell
        }

        var mdfText = ""
        // 接頭語
        let preMdf = modifiers.filter{ $0?.MdfyKbn == AppConst.ModifierKbn.PREFIX.rawValue }
        if preMdf.count > 0 {
            mdfText = "\(mdfText)\(AppConst.ModifierKbnText[AppConst.ModifierKbn.PREFIX.rawValue])：\((preMdf.map{ ($0?.MdfyName)! }).joined(separator: ","))　"
        }

        // 接尾語
        let sufMdf = modifiers.filter{ $0?.MdfyKbn == AppConst.ModifierKbn.SUFFIX.rawValue }
        if sufMdf.count > 0 {
            mdfText = "\(mdfText)\(AppConst.ModifierKbnText[AppConst.ModifierKbn.SUFFIX.rawValue])：\((sufMdf.map{ ($0?.MdfyName)! }).joined(separator: ","))　"
        }
        cell.detailTextLabel?.text = mdfText

        return cell

    }

    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = (indexPath as NSIndexPath).row

        // 選択された傷病名のインデックスを格納
        appDelegate.SelectedDiseaseIndex = index

        // 画面遷移
        self.performSegue(withIdentifier: "SegueDetailMenuDiseaseDetail", sender: self)

    }

    // セル 削除
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "削除"
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
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

                        self.appDelegate.MenuParamsTmp.Disease.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                })
            )

            AppCommon.alertAnyAction(controller: self, title: "確認", message: "削除してもよろしいでしょうか？", actionList: actionList)
        }
    }

    /*
     検索画面へ遷移
     */
    @IBAction func ClickAddDisease(_ sender: AnyObject) {
        performSegue(withIdentifier: "SegueDetailMenuDiseaseSearch", sender: self)
    }
}
