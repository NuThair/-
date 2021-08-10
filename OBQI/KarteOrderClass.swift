//
//  KarteOrderClass.swift
//  OBQI
//
//  Created by t.o on 2017/05/31.
//  Copyright © 2017年 System. All rights reserved.
//


import UIKit

class KarteOrderClass {
    let appCommon = AppCommon()

    // マスタ
    var mstBusinessLogDT: JSON?
    var mstBssImageParts: JSON?
    var mstOrderRelation: JSON?

    // 対象の患者ID
    var targetCustomerID: String?

    // 選択可能データ
    var selectableHDData: AppConst.KarteBLogSubHDParamsFormat?
    var selectableDTData: [AppConst.KarteBLogDTParamsFormat] = []
    // 最終連携データ
    var lastSelectedData: [AppConst.KarteBLogDTParamsFormat] = []
    // 選択中データ
    var currentSelectedData: [AppConst.KarteBLogDTParamsFormat] = []
    // 履歴データ
    var lastHistoryData: JSON?


    /*
     初期化
     */
    init(customerID: String?, bLogSubHDJSON: JSON?, lastHistoryData: JSON?,
         mstBusinessLogDT: JSON?, mstBssImageParts: JSON?, mstOrderRelation: JSON?) {
        // プロパティの初期化
        self.targetCustomerID = customerID
        self.lastHistoryData = lastHistoryData

        self.mstBusinessLogDT = mstBusinessLogDT
        self.mstBssImageParts = mstBssImageParts
        self.mstOrderRelation = mstOrderRelation

        // 必要な値がセットされているか確認
        if !checkProperties() {
            return
        }
        

        // 選択可能データHD設定
        _ = self.setSelectableHDData(bLogSubHDJSON)
        // 最終連携データ設定
        _ = self.setLastSelectedData()

        // 初期選択状態の設定
        self.setInitialSelectedData()
    }

    /*
     必須プロパティのチェック
     */
    private func checkProperties() -> Bool {
        // 初期化時に値が入らない場合はエラー
        if self.mstBusinessLogDT == nil
            || self.mstBssImageParts == nil
            || self.mstOrderRelation == nil
        {
            return false
        }

        return true
    }

    /*
     選択可能データHD設定
     */
    func setSelectableHDData(_ bLogSubHDJSON: JSON?) -> Bool {
        if bLogSubHDJSON == nil || (bLogSubHDJSON?.length)! > 0 {
            self.selectableHDData = AppConst.KarteBLogSubHDParamsFormat(
                BLogGroupID:        bLogSubHDJSON?["BLogGroupID"].asInt!,
                BLogSubGroupID:     bLogSubHDJSON?["BLogSubGroupID"].asInt!,
                BLogSEQNO:          bLogSubHDJSON?["BLogSEQNO"].asInt!,
                TreatmentDateTIme:  bLogSubHDJSON?["TreatmentDateTime"].asDate!
            )
        }

        // BLogDT取得
        // エラーが発生したら処理終了
        if !self.setSelectableDTData(self.selectableHDData!) {
            return false
        }

        return true
    }

    /*
     選択可能データDT設定
     */
    func setSelectableDTData(_ SelectableOrderHD: AppConst.KarteBLogSubHDParamsFormat) -> Bool {
        // BLogDT取得
        let url = "\(AppConst.URLPrefix)business/GetBusinessLogDTList/\(self.targetCustomerID!)/\(SelectableOrderHD.BLogGroupID!)/\(SelectableOrderHD.BLogSubGroupID!)/\(SelectableOrderHD.BLogSEQNO!)"
        let res = appCommon.getSynchronous(url)

        if !AppCommon.isNilOrEmpty(res.errCode) {
            return false
        }

        let bLogDTListJSON = JSON(string: res.result!)

        if bLogDTListJSON.length == 0 {
            return false
        }

        // 出力定義に登録されている項目だけ選択可能
        bLogDTListJSON.forEach{ (bLogDT) -> Void in
            let isDefined = mstOrderRelation?.filter{ $0.1["BLogGroupID"].asInt == bLogDT.1["BLogGroupID"].asInt
                && $0.1["BLogSubGroupID"].asInt == bLogDT.1["BLogSubGroupID"].asInt
                && $0.1["BLogItemID"].asInt == bLogDT.1["BLogItemID"].asInt
                }
                .map{ $0.1 }

            if isDefined != nil && (isDefined?.count)! > 0 {
                self.selectableDTData.append(AppConst.KarteBLogDTParamsFormat(
                    BLogGroupID: bLogDT.1["BLogGroupID"].asInt!,
                    BLogSubGroupID: bLogDT.1["BLogSubGroupID"].asInt!,
                    BLogSEQNO: bLogDT.1["BLogSEQNO"].asInt!,
                    BLogItemID: bLogDT.1["BLogItemID"].asInt!,
                    SEQNO: bLogDT.1["SEQNO"].asInt!,
                    BLogChoicesAsr: bLogDT.1["BLogChoicesAsr"].asString!))
            }
        }

        // SEQNOよりもItemID優先で並べ替える
       // self.selectableDTData = self.selectableDTData.sorted{ $0.0.BLogItemID! < $0.1.BLogItemID! }
        self.selectableDTData = self.selectableDTData.sorted{ $0.BLogItemID! < $1.BLogItemID! }
        return true
    }

    /*
     最終連携データ設定
     */
    func setLastSelectedData() -> Bool {
        // 履歴データなし
        if self.lastHistoryData?["R_HistoryList"].asArray == nil {
            return false
        }

        // 対象のレシピ取得
        self.lastHistoryData?["R_HistoryList"].forEach{ (R_History) -> Void in
            // ステータスが削除の場合はデータがあっても選択しない
            if R_History.1["R_History"]["OrderRecipeStatus"].asString! == AppConst.UpdateKbnStatus.DELETE.rawValue {
                return
            }

            // レシピに紐づくBLogDTデータを設定
            R_History.1["R_BLogHistoryList"].forEach{ (R_BLogHistoryList) -> Void in
                let trnBLogDTList = convertToCurrentTrnValue(R_BLogHistoryList.1)

                if trnBLogDTList != nil {
                    self.lastSelectedData.append(trnBLogDTList!)
                }
            }

            // 対象の明細取得
            R_History.1["M_HistoryList"].forEach{ (M_History) -> Void in
                // ステータスが削除の場合はデータがあっても選択しない
                if M_History.1["M_History"]["OrderDetailStatus"].asString! == AppConst.UpdateKbnStatus.DELETE.rawValue {
                    return
                }

                M_History.1["M_BLogHistoryList"].forEach{ (M_BLogHistoryList) -> Void in
                    let trnBLogDTList = convertToCurrentTrnValue(M_BLogHistoryList.1)

                    if trnBLogDTList != nil {
                        self.lastSelectedData.append(trnBLogDTList!)
                    }
                }
            }
        }

        return true
    }

    // 最終連携データを現在の値に変換
    func convertToCurrentTrnValue(_ bLogHistoryList: JSON) -> AppConst.KarteBLogDTParamsFormat? {
        let matchDT = self.selectableDTData.filter {
                $0.BLogGroupID == bLogHistoryList["BLogGroupID"].asInt!
                && $0.BLogSubGroupID == bLogHistoryList["BLogSubGroupID"].asInt!
                && $0.BLogSEQNO == bLogHistoryList["BLogSEQNO"].asInt!
                && $0.BLogItemID == bLogHistoryList["BLogItemID"].asInt!
                && $0.SEQNO == bLogHistoryList["SEQNO"].asInt!
            }
            .map{ $0 }
            .first

        if matchDT == nil {
            return nil
        }

        let bLogDTParams = AppConst.KarteBLogDTParamsFormat(
            BLogGroupID: matchDT?.BLogGroupID,
            BLogSubGroupID: matchDT?.BLogSubGroupID,
            BLogSEQNO: matchDT?.BLogSEQNO,
            BLogItemID: matchDT?.BLogItemID,
            SEQNO: matchDT?.SEQNO,
            BLogChoicesAsr: matchDT?.BLogChoicesAsr)

        return bLogDTParams
    }

    /*
     初期選択状態の設定
     */
    func setInitialSelectedData() {
        // 削除連携の場合はどちらにも当てはまらず、未選択の状態で表示される
        if self.lastHistoryData?["H_History"].asDictionary == nil { // 未連携の場合選択可能データをセット
            self.currentSelectedData = self.selectableDTData
        }
        else if self.lastSelectedData.count > 0 { // 前回連携データがある場合はそちらを優先
            self.currentSelectedData = self.lastSelectedData
        }
    }


    /*
     表示用データフォーマッター
     */
    func formatCurrentSelectedDataForDisplay() -> String {
        var formatedString = ""

        var textArray:[String] = []
        self.currentSelectedData.forEach{ (selectedBLogDT) -> Void in
            // 回答
            var asr = selectedBLogDT.BLogChoicesAsr!

            // マスタから単位や部位を取得
            let mst = self.mstBusinessLogDT?.filter{
                $0.1["BLogGroupID"].asInt! == selectedBLogDT.BLogGroupID
                    && $0.1["BLogSubGroupID"].asInt! == selectedBLogDT.BLogSubGroupID
                    && $0.1["BLogItemID"].asInt! == selectedBLogDT.BLogItemID
                }.map{ $0.1 }.first
            let mstImgPartsNo = mst?["ImgPartsNo"].asInt
            let mstAssInputKB = mst?["BLogInputKB"].asString!


            var text = mst?["BLogAbbreviatedName"].asString!

            // ImagePartsがある場合は部位名として取得する
            let parts = self.mstBssImageParts?.filter{
                $0.1["ImgPartsNo"].asInt! == mstImgPartsNo
                }.map{ $0.1 }.first

            if parts != nil && (parts?.length)! > 0 {
                text = "【\(parts!["ImgPartsName"].asString!)】 \(text!)"
            }

            // 単位
            var unitStr : String! = ""
            let unit = mst?["BLogUnit"].asString
            if !AppCommon.isNilOrEmpty(unit) {
                unitStr = " (\(unit!))"
            }

            // 回答内容
            // 画像の場合
            if mstAssInputKB == AppConst.InputKB.PHOTO.rawValue
                || mstAssInputKB == AppConst.InputKB.VIDEO.rawValue
            {
                asr = "有り"
            }

            // 画像以外の場合
            else
            {
                asr = asr + unitStr
            }

            textArray.append("\(text!): \(asr)")
        }
        formatedString = textArray.joined(separator: "\n")
        
        return formatedString
    }

    /*
     連携用データフォーマッター
     */
    func formatCurrentSelectedDataForAPI() -> [String: AnyObject] {
        var orderSEQNO = 0
        if self.lastHistoryData?["R_HistoryList"].asArray != nil {
            // 対象のレシピ取得
            self.lastHistoryData?["R_HistoryList"].forEach{ (R_History) -> Void in
                // レシピに紐づくBLogDTデータを設定
                let R_BLogHistory = R_History.1["R_BLogHistoryList"]
                    .filter{ $0.1["BLogGroupID"].asInt == self.selectableHDData?.BLogGroupID
                        && $0.1["BLogSubGroupID"].asInt! == self.selectableHDData?.BLogSubGroupID
                        && $0.1["BLogSEQNO"].asInt! == self.selectableHDData?.BLogSEQNO }
                    .first

                if R_BLogHistory != nil {
                    orderSEQNO = (R_BLogHistory?.1["OrderSEQNO"].asInt!)!
                }
            }
        }

        // subHD情報
        var orderBLogSubHDInfo: [String: AnyObject] = [
            "OrderSEQNO": orderSEQNO as AnyObject,
            "BLogGroupID": self.selectableHDData?.BLogGroupID as AnyObject,
            "BLogSubGroupID": self.selectableHDData?.BLogSubGroupID as AnyObject,
            "BLogSEQNO": self.selectableHDData?.BLogSEQNO as AnyObject,
        ]

        //  DT情報リスト
        var orderBLogDTInfoList: [[String:AnyObject]] = []
        self.currentSelectedData.forEach { (current) -> Void in
            // 明細シーケンスは同じグループのうちのどれか一つにセットしてあればAPI側で判断してくれる
            var orderDetailSEQNO = 0
            if self.lastHistoryData?["R_HistoryList"].asArray != nil {
                // 対象のレシピ取得
                self.lastHistoryData?["R_HistoryList"].forEach{ (R_History) -> Void in
                    // 対象の明細取得
                    R_History.1["M_HistoryList"].forEach{ (M_History) -> Void in
                        let M_BLogHistory = M_History.1["M_BLogHistoryList"]
                            .filter{ $0.1["BLogGroupID"].asInt == current.BLogGroupID
                                && $0.1["BLogSubGroupID"].asInt! == current.BLogSubGroupID
                                && $0.1["BLogSEQNO"].asInt! == current.BLogSEQNO
                                && $0.1["BLogItemID"].asInt! == current.BLogItemID
                                && $0.1["SEQNO"].asInt! == current.SEQNO }
                            .first

                        if M_BLogHistory != nil {
                            orderDetailSEQNO = (M_BLogHistory?.1["OrderDetailSEQNO"].asInt!)!
                        }
                    }
                }
            }

            let orderBLogDTInfo: [String:AnyObject] = [
                "OrderDetailSEQNO": orderDetailSEQNO as AnyObject,
                "BLogItemID": current.BLogItemID as AnyObject,
                "SEQNO": current.SEQNO as AnyObject,
            ]

            orderBLogDTInfoList.append(orderBLogDTInfo)
        }

        // DTをセット
        orderBLogSubHDInfo["OrderBLogDTInfoList"] = orderBLogDTInfoList as AnyObject

        return orderBLogSubHDInfo
    }
    
    /*
     エラーチェック
     */
    // 選択チェック
    func validateDTSelect() -> Bool {
        // 未連携且つDT未選択の場合
        if self.lastHistoryData?["H_History"].asDictionary == nil && self.currentSelectedData.count == 0 {
            return false
        }

        return true
    }
    // 必須チェック
    func validateRequired() -> Bool {
        var isOK = true
        // 一つでも入力がなければエラー
        let requiredItemList = mstBusinessLogDT?.filter{ $0.1["BLogGroupID"].asInt == self.selectableHDData?.BLogGroupID
            && $0.1["BLogSubGroupID"].asInt == self.selectableHDData?.BLogSubGroupID
            && $0.1["BLogRequiredFlg"].asString! == AppConst.Flag.ON.rawValue
            }
            .map{ $0.1 }

        requiredItemList?.forEach{ (requiredItem) -> Void in
            let matchData = self.currentSelectedData.filter{ $0.BLogGroupID == requiredItem["BLogGroupID"].asInt
                && $0.BLogSubGroupID == requiredItem["BLogSubGroupID"].asInt
                && $0.BLogItemID == requiredItem["BLogItemID"].asInt
            }
            if matchData.count == 0 {
                isOK = false
                return
            }
        }

        return isOK
    }
    // 変更チェック
    func validateChanged() -> Bool {
        // 連携済み且つ値まで一致していた場合
        if self.lastHistoryData?["H_History"].asDictionary != nil {
            // 最終連携項目の数
            let lastCnt = self.lastSelectedData.count
            // 今回連携項目の数
            let currentCnt = self.currentSelectedData.count

            // 数が同じ
            if lastCnt == currentCnt {
                // 一致した項目の数
                var matchCnt = 0

                // 値の比較
                self.currentSelectedData.forEach { (current) -> Void in
                    let matchData = self.lastSelectedData.filter {
                        $0.BLogGroupID == current.BLogGroupID
                            && $0.BLogSubGroupID == current.BLogSubGroupID
                            && $0.BLogSEQNO == current.BLogSEQNO
                            && $0.BLogItemID == current.BLogItemID
                            && $0.SEQNO == current.SEQNO
                            && $0.BLogChoicesAsr == current.BLogChoicesAsr
                    }

                    if matchData.count > 0 {
                        matchCnt += 1
                    }
                }

                // 数が同じ
                if matchCnt == currentCnt {
                    return false
                }
            }
        }

        return true
    }
}
