//
//  DetailBLogSchema.swift
//  OBQI
//
//  Created by t.o on 2017/03/16.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class DetailBLogSchema: SchemaBaseController {
    let bLogCommon = BLogCommon()

    // 初回ロードされた時
    override func viewDidLoad() {
        print("viewDidLoad")

        // Status Barの高さを取得をする.
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let navBarHeight = self.navigationController?.navigationBar.frame.size.height
        let navBarWidth = self.navigationController?.navigationBar.frame.size.width
        let barHeight = statusBarHeight + navBarHeight!

        // 描画領域設定
        super.plotArea = CGRect(x: 0, y: barHeight, width: navBarWidth!, height: self.view.frame.height - barHeight)

        super.viewDidLoad()
    }

    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillApper")

        // 選択データの設定
        super.selectedData = appDelegate.MstBusinessLogSubHDList?
            .filter{
                $0.1["BLogGroupID"].asInt! == appDelegate.SelectedBLogSub.BLogGroupID
                && $0.1["BLogSubGroupID"].asInt! == appDelegate.SelectedBLogSub.BLogSubGroupID
            }
            .first.map{ $0.1 }
        super.selectedGroupID = appDelegate.SelectedBLogSub.BLogGroupID
        super.selectedSubGroupID = appDelegate.SelectedBLogSub.BLogSubGroupID

        super.viewWillAppear(animated)
    }
}

// 抽象メソッドの実装
extension DetailBLogSchema: SchemaProtocol {
    /*
     選択されたパーツに紐づくデータを取得
     */
    func getSelectedSchemaData(groupID: Int, subGroupID: Int, imgPartsNo: Int) -> JSON? {
        var ret:JSON?

        // ImgPartsNoに複数紐づいている可能性を考慮
        let selectedMstBusinessLogDTList = appDelegate.MstBusinessLogDTList?
            .filter{
                $0.1["BLogGroupID"].asInt! == groupID
                && $0.1["BLogSubGroupID"].asInt! == subGroupID
                && $0.1["ImgPartsNo"].asInt! == imgPartsNo
            }

        // Photoがある場合は優先
        let photoItem = selectedMstBusinessLogDTList?.filter{ $0.1["BLogInputKB"].asString! == AppConst.InputKB.PHOTO.rawValue }

        if photoItem?.count == 0 {
            ret = selectedMstBusinessLogDTList?.first.map{ $0.1 }

        } else {
            ret = photoItem?.first.map{ $0.1 }
        }

        return ret
    }
    /*
     パーツが登録済みかどうか判定
     */
    func checkSelected(groupID: Int, subGroupID: Int, imgPartsNo: Int) -> Bool {
        // trnBLogDTListが空なら一致なし確定
        guard let trnBLogDTList = appDelegate.trnBLogDTList else {
            return false
        }

        // ImgPartsNoに複数紐づいている可能性を考慮
        let itemIDList = appDelegate.MstBusinessLogDTList?
            .filter{
                $0.1["BLogGroupID"].asInt! == groupID
                    && $0.1["BLogSubGroupID"].asInt! == subGroupID
                    && $0.1["ImgPartsNo"].asInt! == imgPartsNo
            }
            .map{ $0.1["BLogItemID"].asInt! }

        return trnBLogDTList.contains{ (itemIDList?.contains($0.1["BLogItemID"].asInt!))! }
    }

    /************************ シェーマパーツ選択時 ***********************/
    /*
     次の画面へ遷移
     */
    func moveNextView(selectedSchemaData: JSON?) {
        // 選択されたBLogDTをセット
        appDelegate.SelectedBLogDT = AppConst.BLogDTFormat(
            BLogGroupID: selectedSchemaData?["BLogGroupID"].asInt!,
            BLogSubGroupID: selectedSchemaData?["BLogSubGroupID"].asInt!,
            BLogItemID: selectedSchemaData?["BLogItemID"].asInt!
        )

        // シェーマ情報セット
        appDelegate.SelectedBLogImgPartsNo = selectedSchemaData?["ImgPartsNo"].asInt!

        // 入力区分が写真の場合はカメラロールを経由(通常はカメラ無し)
        if selectedSchemaData?["BLogInputKB"].asString! == AppConst.InputKB.PHOTO.rawValue {
            performSegue(withIdentifier: "SegueDetailBLogPhoto",sender: self)
        } else {
            performSegue(withIdentifier: "SegueDetailBLogList",sender: self)
        }
    }

    /*
     シェーマを登録
     */
    func saveItem(selectedSchemaData: JSON?) {
        // 最初の選択肢を取得
        let choices = selectedSchemaData?["BLogChoices"].asString!
        let firstChoice = choices?.substring(to: (choices?.firstIndex(of: ","))!)
        let ansArray = [firstChoice!]

        let customerID = Int(appDelegate.SelectedCustomer!["CustomerID"].asString!)

        let selectedBLog = AppConst.BLogDTFormat(
            BLogGroupID: selectedSchemaData?["BLogGroupID"].asInt!,
            BLogSubGroupID: selectedSchemaData?["BLogSubGroupID"].asInt!,
            BLogItemID: selectedSchemaData?["BLogItemID"].asInt!
        )

        // データ保存
        bLogCommon.saveBLog(customerID, selectedBLog: selectedBLog, ansArray: ansArray, controller: self)
    }
    /*
     シェーマを削除
     */
    func deleteItem(selectedSchemaData: JSON?) {
        // 未登録状態なら削除の必要なし
        if appDelegate.trnBLogSubHD == nil {
            return
        }

        let customerID = Int(appDelegate.SelectedCustomer!["CustomerID"].asString!)
        let selectedBLog = AppConst.BLogDTFormat(
            BLogGroupID: selectedSchemaData?["BLogGroupID"].asInt!,
            BLogSubGroupID: selectedSchemaData?["BLogSubGroupID"].asInt!,
            BLogItemID: selectedSchemaData?["BLogItemID"].asInt!
        )

        let bLogSeqNo = appDelegate.trnBLogSubHD?["BLogSEQNO"].asInt!

        let res = bLogCommon.delBLog(customerID, selectedBLog: selectedBLog, bLogSeqNo: bLogSeqNo)

        if !AppCommon.isNilOrEmpty(res.errCode) {
            AppCommon.alertMessage(controller: self, title: "エラー(\(res.errCode!))", message: "削除に失敗しました。")
        }
    }
    /*
     シェーマを全削除
     */
    func deleteItemAll() {
        // 未登録状態なら削除の必要なし
        if appDelegate.trnBLogDTList == nil {
            return
        }

        // 登録されているアイテムを全て削除
        appDelegate.trnBLogDTList?.forEach{
            deleteItem(selectedSchemaData: $0.1)
        }
    }

    /************************ シェーマパーツ選択時 ***********************/
}
