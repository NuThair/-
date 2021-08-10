//
//  ModalBLogCamera.swift
//  OBQI
//
//  Created by t.o on 2017/03/22.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class ModalBLogCamera: CameraBaseController {
    let bLogCommon = BLogCommon()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}


// 抽象メソッドの実装
extension ModalBLogCamera: CameraProtocol {
    /*
     画像を保存
     */
    func savePhoto(fileString: String) -> Bool {
        let customerID = Int(super.appDelegate.SelectedCustomer!["CustomerID"].asString!)
        let bLogGroupID = appDelegate.SelectedBLogDT.BLogGroupID!
        let bLogSubGroupID = appDelegate.SelectedBLogDT.BLogSubGroupID!

        // trn情報がない場合、新規登録
        var bLogSeqNo:Int?
        var treatmentDateTime:String?

        let isCreate = appDelegate.trnBLogSubHD == nil
        if isCreate {
            treatmentDateTime = appDelegate.inputTreatmentDateTime!
        } else {
            bLogSeqNo = appDelegate.trnBLogSubHD?["BLogSEQNO"].asInt!
        }

        let res = bLogCommon.regPhoto(customerID, selectedBLog: appDelegate.SelectedBLogDT, fileString: fileString, bLogSeqNo: bLogSeqNo, treatmentDateTime: treatmentDateTime)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            AppCommon.alertMessage(controller: self, title: "エラー(\(res.errCode!))", message: "写真の登録に失敗しました。")
            return false
        }

        // 新規登録の場合はHDをセット
        if !AppCommon.isNilOrEmpty(res.result) && isCreate {
            // BLogSubHD一覧取得
            let resSubHD = bLogCommon.getBLogSubHDList(customerID, bLogGroupID: bLogGroupID, bLogSubGroupID: bLogSubGroupID)

            if !AppCommon.isNilOrEmpty(resSubHD.result) {
                let trnBLogSubHDJson = JSON(string: resSubHD.result!).map{ $0.1 } // JSON読み込み
                appDelegate.trnBLogSubHD = trnBLogSubHDJson.last
            }
        }

        // BLogDT一覧取得
        let resDT = bLogCommon.getBLogDTList(customerID, bLogGroupID: bLogGroupID, bLogSubGroupID: bLogSubGroupID, bLogSeqNo: appDelegate.trnBLogSubHD?["BLogSEQNO"].asInt!)
        
        if !AppCommon.isNilOrEmpty(resDT.result) {
            appDelegate.trnBLogDTList = JSON(string: resDT.result!) // JSON読み込み
        }

        // 変更フラグ
        appDelegate.BLogisChanged = true

        // Post Notification（送信）
        let center = NotificationCenter.default
        center.post(name: appDelegate.BLogNotificationName, object: nil)

        return true
    }
}
