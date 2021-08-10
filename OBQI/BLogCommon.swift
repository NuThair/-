//
//  BLogCommon.swift
//  OBQI
//
//  Created by t.o on 2017/03/21.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class BLogCommon {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()

    // api通信共通
    func postBLog(_ params: [String: AnyObject]) -> (result: String?, errCode: String?) {
        // TODO 完了している場合は更新しない

        let url = "\(AppConst.URLPrefix)business/PostBusinessLog"

        return appCommon.postSynchronous(url, params: params)
    }

    // 実施内容登録
    func regBLog(_ customerID : Int!, selectedBLog : AppConst.BLogDTFormat!, ansArray : [String], bLogSeqNo: Int? = nil, treatmentDateTime: String? = nil) -> (result: String?, errCode: String?) {
        let bLogGroupID = selectedBLog.BLogGroupID!
        let bLogSubGroupID = selectedBLog.BLogSubGroupID!
        var params: [String: AnyObject] = [
            "CustomerID": customerID as AnyObject,
            "BLogGroupID": bLogGroupID as AnyObject,
            "BLogSubGroupID": bLogSubGroupID as AnyObject,
            "InputArray": ansArray as AnyObject,
        ]
        if selectedBLog.BLogItemID != nil { // HDのみ登録の場合nil
            params["BLogItemID"] = selectedBLog.BLogItemID! as AnyObject
        }
        if bLogSeqNo != nil {
            params["BLogSEQNO"] = bLogSeqNo! as AnyObject
        }
        if treatmentDateTime != nil {
            params["TreatmentDateTime"] = treatmentDateTime! as AnyObject
        }

        return postBLog(params)
    }

    // 実施内容削除
    func delBLog(_ customerID : Int!, selectedBLog : AppConst.BLogDTFormat!, bLogSeqNo: Int!, SeqNo: Int? = nil) -> (result: String?, errCode: String?) {
        let bLogGroupID = selectedBLog.BLogGroupID!
        let bLogSubGroupID = selectedBLog.BLogSubGroupID!
        let bLogItemID = selectedBLog.BLogItemID!
        var params: [String: AnyObject] = [
            "CustomerID": customerID as AnyObject,
            "BLogGroupID": bLogGroupID as AnyObject,
            "BLogSubGroupID": bLogSubGroupID as AnyObject,
            "BLogSEQNO": bLogSeqNo as AnyObject,
            "BLogItemID": bLogItemID as AnyObject,
            "InputArray": [] as AnyObject, // 空の配列で登録すると削除
        ]
        if SeqNo != nil {
            params["SeqNo"] = SeqNo as AnyObject
        }

        return postBLog(params)
    }

    // 画像登録
    func regPhoto(_ customerID : Int!, selectedBLog : AppConst.BLogDTFormat!, fileString: String!, bLogSeqNo: Int? = nil, treatmentDateTime: String? = nil) -> (result: String?, errCode: String?) {
        let bLogGroupID = selectedBLog.BLogGroupID!
        let bLogSubGroupID = selectedBLog.BLogSubGroupID!
        let bLogItemID = selectedBLog.BLogItemID!

        let url = "\(AppConst.URLPrefix)business/PostBssPhotoFile"

        var params: [String: AnyObject] = [
            "CustomerID": customerID as AnyObject,
            "BssMenuGroupID": bLogGroupID as AnyObject,
            "BssMenuSubGroupID": bLogSubGroupID as AnyObject,
            "ItemID": bLogItemID as AnyObject,
            "Extention": "jpg" as AnyObject,
            "FileData": fileString as AnyObject,
            ]
        if bLogSeqNo != nil {
            params["BLogSEQNO"] = bLogSeqNo! as AnyObject
        }
        if treatmentDateTime != nil {
            params["TreatmentDateTime"] = treatmentDateTime! as AnyObject
        }

        return appCommon.postSynchronous(url, params: params)
    }

    // 実施内容保存
    func saveBLog(_ customerID : Int!, selectedBLog : AppConst.BLogDTFormat!, ansArray : [String], controller: UIViewController) {
        // trn情報がない場合、新規登録
        var bLogSeqNo:Int?
        var treatmentDateTime:String?
        let isCreate = appDelegate.trnBLogSubHD == nil
        if isCreate {
            treatmentDateTime = appDelegate.inputTreatmentDateTime!
        } else {
            bLogSeqNo = appDelegate.trnBLogSubHD?["BLogSEQNO"].asInt!
        }

        let res = self.regBLog(customerID, selectedBLog: selectedBLog, ansArray: ansArray, bLogSeqNo: bLogSeqNo, treatmentDateTime: treatmentDateTime)

        if !AppCommon.isNilOrEmpty(res.errCode) {
            AppCommon.alertMessage(controller: controller, title: "エラー(\(res.errCode!))", message: "登録に失敗しました。")
        }

        // 新規登録の場合はHDをセット
        if !AppCommon.isNilOrEmpty(res.result) && isCreate {
            // BLogSubHD一覧取得
            let resSubHD = self.getBLogSubHDList(customerID, bLogGroupID: selectedBLog.BLogGroupID, bLogSubGroupID: selectedBLog.BLogSubGroupID)

            if !AppCommon.isNilOrEmpty(resSubHD.result) {
                let trnBLogSubHDJson = JSON(string: resSubHD.result!).map{ $0.1 } // JSON読み込み .. err
               // appDelegate.trnBLogSubHD = trnBLogSubHDJson.sorted{ $0.1["BLogSEQNO"].asInt! < $0.1["BLogSEQNO"].asInt! }.map { $0.1 }
                
            }
        }

        // BLogDT一覧取得
        let resDT = self.getBLogDTList(customerID, bLogGroupID: selectedBLog.BLogGroupID, bLogSubGroupID: selectedBLog.BLogSubGroupID, bLogSeqNo: appDelegate.trnBLogSubHD?["BLogSEQNO"].asInt!)

        if !AppCommon.isNilOrEmpty(resDT.result) {
            appDelegate.trnBLogDTList = JSON(string: resDT.result!) // JSON読み込み
        }

        // Post Notification（送信）
        let center = NotificationCenter.default
        center.post(name: appDelegate.BLogNotificationName, object: nil)
    }

    // BLogSubHDリスト取得
    func getBLogSubHDList(_ customerID : Int!, bLogGroupID : Int!, bLogSubGroupID : Int!) -> (result: String?, errCode: String?) {
        let url = "\(AppConst.URLPrefix)business/GetBusinessLogSubHDList/\(customerID!)/\(bLogGroupID!)/\(bLogSubGroupID!)"

        return appCommon.getSynchronous(url)
    }
    // BLogDTリスト取得
    func getBLogDTList(_ customerID : Int!, bLogGroupID : Int!, bLogSubGroupID : Int!, bLogSeqNo: Int!) -> (result: String?, errCode: String?) {
        let url = "\(AppConst.URLPrefix)business/GetBusinessLogDTList/\(customerID!)/\(bLogGroupID!)/\(bLogSubGroupID!)/\(bLogSeqNo!)"

        return appCommon.getSynchronous(url)
    }
}
