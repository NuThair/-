//
//  DetailMenuList.swift
//  OBQI
//
//  Created by t.o on 2017/01/27.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class DetailMenuAssessmentComparison: UITableViewController {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()

    let mySections = ["介入計画基本情報", "比較対象アセスメント"]
    var myItems:[[(title:String?, value:String?)]] = []

    // 比較アセスメント区分
    var SelectedTargetAss1:Int?
    var SelectedTargetAss2:Int?
    var MenuReportKbn:AppConst.MenuReportKbn?

    // 表示用アセスメントID
    var FirstAssID:String?
    var LatestAssID:String?

    // 選択中の比較対象
    var currentTarget:Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")

        // DataSourceの設定をする.
        self.tableView.dataSource = self

        // Delegateを設定する.
        self.tableView.delegate = self

        // 表示用に初回と最新のAssIDを取得
        let customerID = appDelegate.SelectedCustomer!["CustomerID"].asString!
        let menuGroupID = appDelegate.MenuParams.MenuHD.MenuGroupID!

        let url = "\(AppConst.URLPrefix)report/GetHikakuReportAssIDs/\(customerID)/\(menuGroupID)/1/4"
        let res = appCommon.getSynchronous(url)
        if AppCommon.isNilOrEmpty(res.errCode) {
            let assIDsJson = JSON(string: res.result!) // JSON読み込み

            FirstAssID = assIDsJson["Source"]["AssID"].asString
            LatestAssID = assIDsJson["Target"]["AssID"].asString
        }
    }

    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillApper")

        // 介入計画基本情報
        let menuBaseInfo:[(title:String?, value:String?)] = [
            (title: "介入計画名称", value: appDelegate.MenuParams.MenuHD.MenuSetName),
            (title: "臨床プログラム", value: (appDelegate.MenuParams.Program.map{ $0!.MenuName! }).joined(separator: ", ")),
            (title: "最新作成日", value: AppCommon.isNilOrEmpty(appDelegate.MenuParams.MenuHD.UpdateDateTime) ? appDelegate.MenuParams.MenuHD.CreateDateTime : appDelegate.MenuParams.MenuHD.UpdateDateTime),
            (title: "最新作成時対象AssID", value: String(describing: appDelegate.MenuParams.MenuHD.CriteriaAssID!)),
            (title: "初回作成時対象AssID", value: FirstAssID),
            (title: "最新AssID", value: LatestAssID),
            (title: "担当者", value: appDelegate.MenuParams.MenuHD.MenuSetStaffNameKana)
        ]
        // 比較対象アセスメント
        var comparisonAss:[(title:String?, value:String?)] = [
            (title: "比較対象1", value: ""),
            (title: "比較対象2", value: "")
        ]

        // 選択したアセスメント区分を設定
        if SelectedTargetAss1 != nil {
            comparisonAss[0].value = AppConst.ComparisonAssKbnText[SelectedTargetAss1!]
        }
        if SelectedTargetAss2 != nil {
            comparisonAss[1].value = AppConst.ComparisonAssKbnText[SelectedTargetAss2!]
        }

        myItems = []
        myItems.append(menuBaseInfo)
        myItems.append(comparisonAss)

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
       return myItems[section].count
    }

    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "MyCell")

        let section = (indexPath as NSIndexPath).section
        let index = (indexPath as NSIndexPath).row

        cell.textLabel?.text = myItems[section][index].title
        cell.detailTextLabel?.text = myItems[section][index].value

        // 選択しても色を変えない
        cell.selectionStyle = UITableViewCell.SelectionStyle.none

        // 比較アセスメントは画面遷移をする
        if section == 1 {
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        }

        return cell
    }

    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = (indexPath as NSIndexPath).section
        let index = (indexPath as NSIndexPath).row

        // 比較アセスメントは画面遷移をする
        if section == 1 {
            currentTarget = index
            performSegue(withIdentifier: "SegueDetailMenuAssessmentSelect", sender: self)
        }
    }


    /*
     比較レポート表示
     */
    @IBAction func clickOutputReport(_ sender: Any) {
        if !checkSelectedAssesment() {
            return
        }
        MenuReportKbn = AppConst.MenuReportKbn.ASSESSMENT

        performSegue(withIdentifier: "SegueModalMenuAssessmentReport", sender: self)
    }
    /*
     比較アウトカム表示
     */
    @IBAction func clickOutputOutCome(_ sender: Any) {
        if !checkSelectedAssesment() {
            return
        }
        MenuReportKbn = AppConst.MenuReportKbn.OUTCOME

        performSegue(withIdentifier: "SegueModalMenuAssessmentReport", sender: self)
    }

    /*
     画面遷移時
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // レポート出力に必要な情報をセット
        if segue.identifier == "SegueModalMenuAssessmentReport" {
            let modalMenuAssessmentReport = segue.destination as! ModalMenuAssessmentReport
            modalMenuAssessmentReport.SelectedTargetAss1 = SelectedTargetAss1
            modalMenuAssessmentReport.SelectedTargetAss2 = SelectedTargetAss2
            modalMenuAssessmentReport.MenuReportKbn = MenuReportKbn
        }
    }

    // 比較アセスメント選択確認
    private func checkSelectedAssesment() -> Bool {
        // 必須項目チェック
        if SelectedTargetAss1 == nil {
            AppCommon.alertMessage(controller: self, title: "エラー", message: "比較対象1を選択してください。")
            return false
        }
        if SelectedTargetAss2 == nil {
            AppCommon.alertMessage(controller: self, title: "エラー", message: "比較対象2を選択してください。")
            return false
        }
        if SelectedTargetAss1 == SelectedTargetAss2 {
            AppCommon.alertMessage(controller: self, title: "エラー", message: "比較対象は別々のものを選択してください。")
            return false
        }

        // 比較対象Assの存在確認
        let customerID = appDelegate.SelectedCustomer!["CustomerID"].asString!
        let menuGroupID = appDelegate.MenuParams.MenuHD.MenuGroupID!
        let sourceReportKbn = AppConst.ComparisonAssKbn[SelectedTargetAss1!]
        let targetReportKbn = AppConst.ComparisonAssKbn[SelectedTargetAss2!]

        let url = "\(AppConst.URLPrefix)report/GetHikakuReportAssIDs/\(customerID)/\(menuGroupID)/\(sourceReportKbn)/\(targetReportKbn)"
        let res = appCommon.getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return false
        }
        let assIDsJson = JSON(string: res.result!) // JSON読み込み
        if AppCommon.isNilOrEmpty(assIDsJson["Source"]["AssID"].asString) {
            AppCommon.alertMessage(controller: self, title: "エラー", message: "比較対象1に該当するアセスメントが存在しませんでした。")
            return false
        }
        if AppCommon.isNilOrEmpty(assIDsJson["Target"]["AssID"].asString) {
            AppCommon.alertMessage(controller: self, title: "エラー", message: "比較対象2に該当するアセスメントが存在しませんでした。")
            return false
        }

        return true
    }
}


