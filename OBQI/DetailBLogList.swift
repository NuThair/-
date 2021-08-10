//
//  DetailBLogList.swift
//  OBQI
//
//  Created by t.o on 2017/03/15.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class DetailBLogList: UITableViewController {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    let bLogCommon = BLogCommon()

    var selectedBLogDTList:[JSON?] = []

    // 内部ネットワークかどうか
    var isInside = false

    @IBOutlet weak var myNaviBar: UINavigationItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!

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

        // 変更フラグ
        appDelegate.BLogisChanged = false

        // シェーマから遷移した場合は削除ボタン押下不可
        if appDelegate.SelectedBLogImgPartsNo != nil {
            deleteButton.isEnabled = false
        }
    }

    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillApper")

        isInside = appCommon.isInside()

        // シェーマ経由且つ、遷移先から戻った際に変更があった場合
        if appDelegate.SelectedBLogImgPartsNo != nil && appDelegate.BLogisChanged {
            // シェーマ区分に応じて処理分岐
            let selectedSchemaKBString = appDelegate.MstBusinessLogSubHDList?
                .filter{ $0.1["BLogGroupID"].asInt! == appDelegate.SelectedBLogSub.BLogGroupID && $0.1["BLogSubGroupID"].asInt! == appDelegate.SelectedBLogSub.BLogSubGroupID }
                .first.map{ $0.1["SchemaKB"].asString! }
            let selectedSchemaKB = AppConst.SchemaKB(rawValue: selectedSchemaKBString!)

            // 択一選択の場合は選択されたパーツ以外の情報を削除
            // 実際にシェーマから一覧画面への遷移が発生し得るのは「SINGLE」のみ
            switch selectedSchemaKB! {
            case .SINGLE, .SINGLE_REQUIRE_PHOTO, .ONLY_SCHEMA_PHOTO_SINGLE_REQUIRE_PHOTO:
                // 選択中のアイテム以外は全削除
                deleteAllDT(ignoreItem: appDelegate.SelectedBLogDT.BLogItemID)

                // BLogDT一覧取得
                let customerID = Int(appDelegate.SelectedCustomer!["CustomerID"].asString!)
                let bLogGroupID = appDelegate.trnBLogSubHD?["BLogGroupID"].asInt!
                let bLogSubGroupID = appDelegate.trnBLogSubHD?["BLogSubGroupID"].asInt!
                let bLogSeqNo = appDelegate.trnBLogSubHD?["BLogSEQNO"].asInt!

                let resDT = bLogCommon.getBLogDTList(customerID, bLogGroupID: bLogGroupID, bLogSubGroupID: bLogSubGroupID, bLogSeqNo: bLogSeqNo)

                if !AppCommon.isNilOrEmpty(resDT.result) {
                    appDelegate.trnBLogDTList = JSON(string: resDT.result!) // JSON読み込み
                }

                break

            default: break
            }

            // フラグを戻す
            appDelegate.BLogisChanged = false
        }

        // DTマスタの取得
        selectedBLogDTList = (appDelegate.MstBusinessLogDTList?
            .filter{
                $0.1["BLogGroupID"].asInt! == appDelegate.SelectedBLogSub.BLogGroupID
                && $0.1["BLogSubGroupID"].asInt! == appDelegate.SelectedBLogSub.BLogSubGroupID
                && (appDelegate.SelectedBLogImgPartsNo == nil || $0.1["ImgPartsNo"].asInt! == appDelegate.SelectedBLogImgPartsNo)
            }
            .map{ $0.1 })!

        // テーブル内容再描画
        self.tableView?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /*
     戻る
     */
    override func viewWillDisappear(_ animated: Bool) {
    }

    /*
     テーブルに表示する配列の総数を返す.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedBLogDTList.count + 1
    }

    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "MyCell")
        let index = (indexPath as NSIndexPath).row

        if index == 0 { // 実施日付
            cell.textLabel?.text = "実施日付"
            cell.detailTextLabel?.text = appDelegate.inputTreatmentDateTime

            // 新規の場合は変更可
            if appDelegate.trnBLogSubHD == nil {
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator

            } else {
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
            }

        } else {
            cell.textLabel?.text = selectedBLogDTList[index - 1]?["BLogItemName"].asString!

            // privateFlgが立っている項目は外部から編集不可
            if !isInside && self.selectedBLogDTList[index - 1]?["PrivateFlg"].asString! == AppConst.Flag.ON.rawValue {
                cell.accessoryType = UITableViewCell.AccessoryType.none
                cell.selectionStyle = UITableViewCell.SelectionStyle.none

            } else {
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            }

            // BLogDTマスタ取得
            let bLogGroupID = selectedBLogDTList[index - 1]!["BLogGroupID"].asInt!
            let bLogSubGroupID = selectedBLogDTList[index - 1]!["BLogSubGroupID"].asInt!
            let bLogItemID = selectedBLogDTList[index - 1]!["BLogItemID"].asInt!

            let mstBLogDT = appDelegate.MstBusinessLogDTList?
                .filter{
                    $0.1["BLogGroupID"].asInt! == bLogGroupID
                    && $0.1["BLogSubGroupID"].asInt! == bLogSubGroupID
                    && $0.1["BLogItemID"].asInt! == bLogItemID
                }.first.map{ $0.1 }

            let trnBLogDT = appDelegate.trnBLogDTList?
                .filter{
                    $0.1["BLogGroupID"].asInt! == bLogGroupID
                    && $0.1["BLogSubGroupID"].asInt! == bLogSubGroupID
                    && $0.1["BLogItemID"].asInt! == bLogItemID
                }.map{ $0.1 }

            var detailText = ""
            // 写真ありの場合は、有無のみ表示
            if mstBLogDT?["BLogInputKB"].asString! == AppConst.InputKB.PHOTO.rawValue
                || mstBLogDT?["BLogInputKB"].asString! == AppConst.InputKB.VIDEO.rawValue {
                if trnBLogDT != nil && (trnBLogDT?.count)! > 0 {
                    detailText = "有り"
                }

                // シェーマ経由の場合は表示のみ
                if appDelegate.SelectedBLogImgPartsNo != nil {
                    cell.accessoryType = UITableViewCell.AccessoryType.none
                    cell.selectionStyle = UITableViewCell.SelectionStyle.none
                }

            } else {
                // 回答は複数の可能性がある
                var asr = ""
                if trnBLogDT != nil && (trnBLogDT?.count)! > 0 {
                    asr = (trnBLogDT?.map{ $0["BLogChoicesAsr"].asString! }.joined(separator: ","))!
                }

                // 単位
                let unit = appDelegate.MstBusinessLogDTList?
                    .filter{
                        $0.1["BLogGroupID"].asInt! == bLogGroupID
                        && $0.1["BLogSubGroupID"].asInt! == bLogSubGroupID
                        && $0.1["BLogItemID"].asInt! == bLogItemID
                    }
                    .first.map{ $0.1["BLogUnit"].asString! }

                detailText = asr
                if !AppCommon.isNilOrEmpty(unit) {
                    detailText += "(\(unit!))"
                }
            }

            cell.detailTextLabel?.text = detailText
        }

        return cell
    }


    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = (indexPath as NSIndexPath).row

        if index == 0 { // 実施日付
            // 登録済みの場合は変更不可
            if appDelegate.trnBLogSubHD != nil {
                return
            }
            performSegue(withIdentifier: "SegueDetailInputTreatmentDateTime", sender: self)

        } else {
            // 選択されたマスタを取得
            guard let selectedBLogDT = selectedBLogDTList[index - 1] else {
                return
            }

            // 選択されたBLogDTをセット
            appDelegate.SelectedBLogDT = AppConst.BLogDTFormat(
                BLogGroupID: selectedBLogDT["BLogGroupID"].asInt!,
                BLogSubGroupID: selectedBLogDT["BLogSubGroupID"].asInt!,
                BLogItemID: selectedBLogDT["BLogItemID"].asInt!
            )

            // privateFlgが立っている項目は外部から編集不可
            if !isInside && self.selectedBLogDTList[index - 1]?["PrivateFlg"].asString! == AppConst.Flag.ON.rawValue {
                return
            }

            let inputKb = AppConst.InputKB(rawValue: (selectedBLogDTList[index - 1]?["BLogInputKB"].asString!)!)
            switch inputKb! {
            case .SINGLE:
                // 回答群を取得
                let answerList = selectedBLogDT["BLogChoices"].asString!.components(separatedBy: ",")

                // 二択以下の場合は遷移しないでその場で変更
                if answerList.count <= 2 {
                    // 現在値を設定
                    let selectedTrnBLogDT = appDelegate.trnBLogDTList?
                        .filter{
                            $0.1["BLogGroupID"].asInt! == appDelegate.SelectedBLogDT.BLogGroupID
                                && $0.1["BLogSubGroupID"].asInt! == appDelegate.SelectedBLogDT.BLogSubGroupID
                                && $0.1["BLogItemID"].asInt! == appDelegate.SelectedBLogDT.BLogItemID
                    }
                    var currentValue = ""
                    if selectedTrnBLogDT != nil && selectedTrnBLogDT!.count > 0 {
                        currentValue = selectedTrnBLogDT!.first.map{ $0.1["BLogChoicesAsr"].asString! }!
                    }

                    // インデックスを取得
                    let answerIndex = answerList.firstIndex(of: currentValue)
                    // 値を設定
                    if answerIndex == nil { // 未回答の場合は最初の選択肢
                        currentValue = answerList[0]

                    } else if answerIndex == (answerList.count - 1){ // 一周した場合は未回答に戻る
                        currentValue = ""

                    } else { // 次の値を取得
                        currentValue = answerList[answerIndex! + 1]
                    }

                    var ansArray:[String] = []
                    if !AppCommon.isNilOrEmpty(currentValue) {
                        ansArray = [currentValue]
                    }

                    let customerID = Int(appDelegate.SelectedCustomer!["CustomerID"].asString!)

                    // 保存のために必要なデータを生成
                    let selectedBLog = AppConst.BLogDTFormat(
                        BLogGroupID: appDelegate.SelectedBLogDT.BLogGroupID!,
                        BLogSubGroupID: appDelegate.SelectedBLogDT.BLogSubGroupID!,
                        BLogItemID: appDelegate.SelectedBLogDT.BLogItemID!
                    )
                    
                    // データ保存
                    bLogCommon.saveBLog(customerID, selectedBLog: selectedBLog, ansArray: ansArray, controller: self)
                    
                    // 変更フラグ
                    appDelegate.BLogisChanged = true

                    // 再表示
                    viewWillAppear(true)

                } else {
                    // 遷移
                    performSegue(withIdentifier: "SegueDetailSelectSingle",sender: self)
                }

                break

            case .MULTI:
                performSegue(withIdentifier: "SegueDetailSelectMulti",sender: self)
                break

            case .BIRTHDAY: // yyyy/mm/dd
                performSegue(withIdentifier: "SegueDetailDate",sender: self)
                break

            case .DATETIME: // yyyy/mm/dd H:i:s
                performSegue(withIdentifier: "SegueDetailDateTime",sender: self)
                break

            case .INPUT:
                performSegue(withIdentifier: "SegueDetailInputText",sender: self)
                break

            case .INPUT_AREA:
                performSegue(withIdentifier: "SegueDetailInputTextArea",sender: self)
                break

            case .PHOTO:
                // シェーマ経由の場合は表示のみ
                if appDelegate.SelectedBLogImgPartsNo != nil {
                    return
                }
                performSegue(withIdentifier: "SegueDetailPhoto",sender: self)
                break

            case .BARCODE:
                performSegue(withIdentifier: "SegueDetailBarcode",sender: self)
                break

            case .DRUG:
                performSegue(withIdentifier: "SegueDetailDrug",sender: self)
                break

            case .BUI:
                performSegue(withIdentifier: "SegueDetailBui",sender: self)
                break

            default: break
            }
        }
    }


    /*
     DTを一括削除
     */
    @IBAction func clickDelete(_ sender: Any) {
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
                    print("Delete All")

                    // 登録されているアイテムを全て削除
                    self.deleteAllDT()

                    // 初期化
                    self.appDelegate.trnBLogDTList = nil
                    
                    // 再描画
                    self.viewWillAppear(true)
            })
        )
        
        AppCommon.alertAnyAction(controller: self, title: "確認", message: "実施指示内容を削除しますか？", actionList: actionList)
    }

    func deleteAllDT(ignoreItem: Int? = nil){
        // 未登録状態なら削除の必要なし
        if appDelegate.trnBLogDTList == nil {
            return
        }

        let customerID = Int(appDelegate.SelectedCustomer!["CustomerID"].asString!)

        appDelegate.trnBLogDTList?.forEach{
            // 選択中パーツは削除しない
            if ignoreItem != nil && $0.1["BLogItemID"].asInt! == ignoreItem! {
                return
            }

            let selectedBLog = AppConst.BLogDTFormat(
                BLogGroupID: $0.1["BLogGroupID"].asInt!,
                BLogSubGroupID: $0.1["BLogSubGroupID"].asInt!,
                BLogItemID: $0.1["BLogItemID"].asInt!
            )

            let bLogSeqNo = appDelegate.trnBLogSubHD?["BLogSEQNO"].asInt!

            let res = bLogCommon.delBLog(customerID, selectedBLog: selectedBLog, bLogSeqNo: bLogSeqNo)

            if !AppCommon.isNilOrEmpty(res.errCode) {
                AppCommon.alertMessage(controller: self, title: "エラー(\(res.errCode!))", message: "削除に失敗しました。")
            }
        }
    }
}
