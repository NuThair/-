//
//  detailPerformedList.swift
//  OBQI
//
//  Created by t.o on 2017/03/15.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class DetailPerformedList: UITableViewController {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    let bLogCommon = BLogCommon()

    var selectedPerformedDateList:[JSON?] = []

    @IBOutlet weak var myNaviBar: UINavigationItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")

        // DataSourceの設定をする.
        self.tableView.dataSource = self

        // Delegateを設定する.
        self.tableView.delegate = self

        myNaviBar.title = appDelegate.MstBusinessLogSubHDList?
            .filter{ $0.1["BLogGroupID"].asInt! == appDelegate.SelectedBLogSub.BLogGroupID && $0.1["BLogSubGroupID"].asInt! == appDelegate.SelectedBLogSub.BLogSubGroupID }
            .first.map{ $0.1["BLogSubGroupName"].asString! }
    }

    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillApper")

        // BLogSubHD一覧取得
        let customerID = Int(appDelegate.SelectedCustomer!["CustomerID"].asString!)
        let bLogGroupID = appDelegate.SelectedBLogSub.BLogGroupID!
        let bLogSubGroupID = appDelegate.SelectedBLogSub.BLogSubGroupID!

        let res = bLogCommon.getBLogSubHDList(customerID, bLogGroupID: bLogGroupID, bLogSubGroupID: bLogSubGroupID)

        selectedPerformedDateList = []
        if !AppCommon.isNilOrEmpty(res.result) {
            selectedPerformedDateList = JSON(string: res.result!).map{ $0.1 } // JSON読み込み
        }

        // テーブル内容再描画
       self.tableView?.reloadData()

        // 初期化
        appDelegate.SelectedBLogImgPartsNo = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /*
     テーブルに表示する配列の総数を返す.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedPerformedDateList.count
    }

    // セル 削除
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "削除"
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let index = (indexPath as NSIndexPath).row

        if editingStyle == UITableViewCell.EditingStyle.delete {
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

                        let customerID = self.selectedPerformedDateList[index]!["CustomerID"].asInt!
                        let bLogGroupID = self.selectedPerformedDateList[index]!["BLogGroupID"].asInt!
                        let bLogSubGroupID = self.selectedPerformedDateList[index]!["BLogSubGroupID"].asInt!
                        let bLogSeqNo = self.selectedPerformedDateList[index]!["BLogSEQNO"].asInt!

                        // オーダー連携済みだった場合は削除できない。ただし削除済みを除く
                        var url = "\(AppConst.URLPrefix)ic/GetLastOrderHistory/\(customerID)/\(bLogGroupID)/\(bLogSubGroupID)/\(bLogSeqNo)"
                        let res = self.appCommon.getSynchronous(url)

                        if !AppCommon.isNilOrEmpty(res.errCode) {
                            AppCommon.alertMessage(controller: self, title: "エラー(\(res.errCode!))", message: "削除に失敗しました。")
                            return
                        }

                        let lastHistoryJSON = JSON(string: res.result!)

                        if lastHistoryJSON.length == 0 {
                            AppCommon.alertMessage(controller: self, title: "エラー", message: "削除に失敗しました。")
                            return
                        }

                        if lastHistoryJSON["H_History"].asDictionary != nil
                            && lastHistoryJSON["H_History"]["OrderStatus"].asString! != AppConst.UpdateKbnStatus.DELETE.rawValue {
                            AppCommon.alertMessage(controller: self, title: "エラー", message: "オーダー連携済みのため削除できませんでした。")
                            return
                        }

                        // HD削除
                        url = "\(AppConst.URLPrefix)business/DeleteBusinessLogSubHD/\(customerID)/\(bLogGroupID)/\(bLogSubGroupID)/\(bLogSeqNo)"
                        _ = self.appCommon.deleteSynchronous(url, params: [:])

                        // Post Notification（送信）
                        let center = NotificationCenter.default
                        center.post(name: self.appDelegate.BLogNotificationName, object: nil)

                        // 再描画
                        self.viewWillAppear(true)
                })
            )
            
            AppCommon.alertAnyAction(controller: self, title: "確認", message: "本当に削除しますか？", actionList: actionList)
        }
    }

    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MyCell")
        let index = (indexPath as NSIndexPath).row


        let TreatmentDateTime = AppCommon.getDateFormat(date: selectedPerformedDateList[index]?["TreatmentDateTime"].asDate, format: "yyyy/MM/dd HH:mm")!
        cell.textLabel?.text = "\(TreatmentDateTime) 実施内容"
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator

        return cell
    }


    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = (indexPath as NSIndexPath).row

        // 選択されたtrnBLogSubHDをセット
        appDelegate.trnBLogSubHD = selectedPerformedDateList[index]

        // 選択されたtrnBLogSubHDに紐づくtrnBLogDTListをセット
        let customerID = selectedPerformedDateList[index]!["CustomerID"].asInt!
        let bLogGroupID = selectedPerformedDateList[index]!["BLogGroupID"].asInt!
        let bLogSubGroupID = selectedPerformedDateList[index]!["BLogSubGroupID"].asInt!
        let bLogSeqNo = selectedPerformedDateList[index]!["BLogSEQNO"].asInt!

        let res = bLogCommon.getBLogDTList(customerID, bLogGroupID: bLogGroupID, bLogSubGroupID: bLogSubGroupID, bLogSeqNo: bLogSeqNo)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }
        appDelegate.trnBLogDTList = JSON(string: res.result!)

        // 実施日付
        appDelegate.inputTreatmentDateTime = AppCommon.getDateFormat(date: selectedPerformedDateList[index]!["TreatmentDateTime"].asDate!, format: "yyyy/MM/dd HH:mm")

        moveNext()
    }


    /*
     新規ボタン押下
     */
    @IBAction func clickNew(_ sender: Any) {
        // 初期化
        appDelegate.trnBLogSubHD = nil
        appDelegate.trnBLogDTList = nil
        appDelegate.inputTreatmentDateTime = AppCommon.getDateFormat(date: Date(), format: "yyyy/MM/dd HH:mm")

        moveNext()
    }

    /*
     シェーマの有無により遷移先振り分け
     */
    private func moveNext() {
        // シェーマの有無判定
        let schemaKB = appDelegate.MstBusinessLogSubHDList?
            .filter{ $0.1["BLogGroupID"].asInt! == appDelegate.SelectedBLogSub.BLogGroupID! && $0.1["BLogSubGroupID"].asInt! == appDelegate.SelectedBLogSub.BLogSubGroupID }
            .first.map{ $0.1["SchemaKB"].asString! }

        if schemaKB == AppConst.SchemaKB.NO_SCHEMA.rawValue { // シェーマ無し
            performSegue(withIdentifier: "SegueDetailBLogList", sender: self)

        } else {  // シェーマ有り
            performSegue(withIdentifier: "SegueDetailSchema", sender: self)
        }
    }
}
