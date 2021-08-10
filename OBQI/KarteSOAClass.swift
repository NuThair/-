//
//  KarteSOAClass.swift
//  OBQI
//
//  Created by t.o on 2017/05/31.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class KarteSOAClass {
    let appCommon = AppCommon()

    // マスタ
    var mstAssessmentGroup: JSON?
    var mstAssessmentSubGroup: JSON?
    var mstAssessment: JSON?
    var mstAssImageParts: JSON?

    // 対象のアセスメントID
    var targetAssID: Int?
    // 対象の最終連携区分
    var targetHistory: AppConst.SOAPHistoryHeaderFormat?
    // 対象の最終連携詳細データ
    var targetHistoryDetail: JSON?
    // 対象の区分
    var targetKarteKbn: AppConst.KarteKbn?

    // 選択可能データ
    var selectableData: [AppConst.KarteKbn:[AppConst.KarteAssDTFormat]] = [
        AppConst.KarteKbn.SUBJECT: [],
        AppConst.KarteKbn.OBJECT: [],
        AppConst.KarteKbn.ASSESSMENT: [],
        ]
    // 最終連携データ
    var lastSelectedData: [AppConst.KarteKbn:[AppConst.KarteAssDTFormat]] = [
        AppConst.KarteKbn.SUBJECT: [],
        AppConst.KarteKbn.OBJECT: [],
        AppConst.KarteKbn.ASSESSMENT: [],
        ]
    // 選択中データ
    var currentSelectedData: [AppConst.KarteKbn:[AppConst.KarteAssDTFormat]] = [
        AppConst.KarteKbn.SUBJECT: [],
        AppConst.KarteKbn.OBJECT: [],
        AppConst.KarteKbn.ASSESSMENT: [],
        ]



    /*
     初期化
     */
    init(assIDInt: Int?, lastSOAPHistoryHeader: AppConst.SOAPHistoryHeaderFormat?, targetHistoryDetail: JSON?,
        mstAssessmentGroup: JSON?, mstAssessmentSubGroup: JSON?, mstAssessment: JSON?, mstAssImageParts: JSON?) {
        // プロパティの初期化
        self.targetAssID = assIDInt

        self.targetHistory = lastSOAPHistoryHeader // 未連携時はnil
        self.targetHistoryDetail = targetHistoryDetail // 未連携時はnil

        self.mstAssessmentGroup = mstAssessmentGroup
        self.mstAssessmentSubGroup = mstAssessmentSubGroup
        self.mstAssessment = mstAssessment
        self.mstAssImageParts = mstAssImageParts

        // 必要な値がセットされているか確認
        if !checkProperties() {
            return
        }

        // 選択可能データ設定
        _ = self.setSelectableData()
        // 最終連携データ設定
        _ = self.setLastSelectedData()

        // 初期選択状態の設定
        var updateKbn: String? = nil

        updateKbn = targetHistory.map{ $0.SUpdateKbn } ?? nil
        self.setInitialSelectedData(AppConst.KarteKbn.SUBJECT, updateKbn)

        updateKbn = targetHistory.map{ $0.OUpdateKbn } ?? nil
        self.setInitialSelectedData(AppConst.KarteKbn.OBJECT, updateKbn)

        updateKbn = targetHistory.map{ $0.AUpdateKbn } ?? nil
        self.setInitialSelectedData(AppConst.KarteKbn.ASSESSMENT, updateKbn)
    }

    /*
     必須プロパティのチェック
     */
    private func checkProperties() -> Bool {
        // 初期化時に値が入らない場合はエラー
        if self.targetAssID == nil
            || self.mstAssessmentGroup == nil
            || self.mstAssessmentSubGroup == nil
            || self.mstAssessment == nil
            || self.mstAssImageParts == nil
        {
            return false
        }

        return true
    }

    /*
     選択可能データ設定
     */
    func setSelectableData() -> Bool {
        // 選択された受付に紐づくアセスメント
        let assIDString = String(describing: self.targetAssID!)
        let url = "\(AppConst.URLPrefix)assessment/GetInputAssessmentList/\(assIDString)"
        let res = appCommon.getSynchronous(url)

        if !AppCommon.isNilOrEmpty(res.errCode) {
            return false
        }

        let inputAssessmentListJSON = JSON(string: res.result!)

        if inputAssessmentListJSON.length == 0 {
            return false
        }

        // 各区分毎にデータを設定
        inputAssessmentListJSON.map{ $0.1 }.forEach { assData in
            let assMenuGroupID = assData["AssMenuGroupID"].asInt!
            let assMenuSubGroupID = assData["AssMenuSubGroupID"].asInt!
            let assItemID = assData["AssItemID"].asInt!

            // 各項目のカルテ区分を判定
            let inputKarteKbn = self.mstAssessment?.filter {
                $0.1["AssMenuGroupID"].asInt! == assMenuGroupID
                    && $0.1["AssMenuSubGroupID"].asInt! == assMenuSubGroupID
                    && $0.1["AssItemID"].asInt! == assItemID
                }
                .map{ $0.1["UpdateKarteKbn"].asString! }
                .first

            // それぞれの区分毎にデータを格納
            var karteKbn:AppConst.KarteKbn?
            switch AppConst.KarteKbn(rawValue: inputKarteKbn!)! {
            case AppConst.KarteKbn.SUBJECT:
                karteKbn = AppConst.KarteKbn.SUBJECT
                break

            case AppConst.KarteKbn.OBJECT:
                karteKbn = AppConst.KarteKbn.OBJECT
                break

            case AppConst.KarteKbn.ASSESSMENT:
                karteKbn = AppConst.KarteKbn.ASSESSMENT
                break

            default: break
            }

            selectableData[karteKbn!]?.append(AppConst.KarteAssDTFormat(
                AssID: assData["AssID"].asInt!,
                AssMenuGroupID: assData["AssMenuGroupID"].asInt!,
                AssMenuSubGroupID: assData["AssMenuSubGroupID"].asInt!,
                AssItemID: assData["AssItemID"].asInt!,
                SEQNO: assData["SEQNO"].asInt!,
                AssChoicesAsr: assData["AssChoicesAsr"].asString!,
                TakeoverFlg: assData["TakeoverFlg"].asString!
            ))
        }

        return true
    }

    /*
     最終連携データ設定
     */
    func setLastSelectedData() -> Bool {
        if self.targetHistoryDetail?.length == 0 {
            return false
        }
        // 各区分毎にデータを設定
        self.targetHistoryDetail?.map{ $0.1 }.forEach { assData in
            // 各項目のカルテ区分を判定
            let inputKarteKbn = assData["SOAPKbn"].asString!

            // それぞれの区分毎にデータを格納
            var karteKbn:AppConst.KarteKbn?
            switch AppConst.KarteKbn(rawValue: inputKarteKbn)! {
            case AppConst.KarteKbn.SUBJECT:
                karteKbn = AppConst.KarteKbn.SUBJECT
                break

            case AppConst.KarteKbn.OBJECT:
                karteKbn = AppConst.KarteKbn.OBJECT
                break

            case AppConst.KarteKbn.ASSESSMENT:
                karteKbn = AppConst.KarteKbn.ASSESSMENT
                break

            default: break
            }

            self.lastSelectedData[karteKbn!]?.append(AppConst.KarteAssDTFormat(
                AssID: nil,
                AssMenuGroupID: assData["AssMenuGroupID"].asInt!,
                AssMenuSubGroupID: assData["AssMenuSubGroupID"].asInt!,
                AssItemID: assData["AssItemID"].asInt!,
                SEQNO: nil,
                AssChoicesAsr: nil,
                TakeoverFlg: nil
            ))
        }

        return true
    }

    /*
     初期選択状態の設定
     */
    func setInitialSelectedData(_ karteKbn: AppConst.KarteKbn, _ updateKbn: String?) {
        // takeoverを除いた選択可能データを全てセット
        self.currentSelectedData[karteKbn] = self.selectableData[karteKbn]?.filter{ $0.TakeoverFlg! == AppConst.Flag.OFF.rawValue }

        // 前回連携データがある場合はそちらを優先
        if !AppCommon.isNilOrEmpty(updateKbn) {
            self.currentSelectedData[karteKbn] = self.lastSelectedData[karteKbn]
        }
    }


    /*
     表示用データフォーマッター
     */
    func formatCurrentSelectedDataForDisplay() -> [AppConst.KarteKbn: String] {
        // データを表示用に整形
        var formatedStringList: [AppConst.KarteKbn: String] = [
            AppConst.KarteKbn.SUBJECT: "",
            AppConst.KarteKbn.OBJECT: "",
            AppConst.KarteKbn.ASSESSMENT: "",
        ]
        self.currentSelectedData.forEach { karteKbn, kbnDataList in
            // データをグループ毎にまとめる
            var groupDataList:[(
                AssMenuGroupID: Int,
                AssMenuSubGroupID: Int,
                Text: String
                )] = []

            kbnDataList.forEach { kbnData in
                // 既にグループ別に分類されているか判定
                let existIndex = groupDataList.enumerated()
                    .filter{
                        $1.AssMenuGroupID == kbnData.AssMenuGroupID
                            && $1.AssMenuSubGroupID == kbnData.AssMenuSubGroupID
                    }
                    .map{ $0.offset }
                    .first

                // 回答
                var asr = (self.selectableData[karteKbn]?.filter{
                    $0.AssMenuGroupID == kbnData.AssMenuGroupID
                        && $0.AssMenuSubGroupID == kbnData.AssMenuSubGroupID
                        && $0.AssItemID == kbnData.AssItemID
                    }
                    .map{ $0.AssChoicesAsr! }.first!)!

                // マスタから単位や部位を取得
                let mst = self.mstAssessment?.filter{
                    $0.1["AssMenuGroupID"].asInt! == kbnData.AssMenuGroupID
                        && $0.1["AssMenuSubGroupID"].asInt! == kbnData.AssMenuSubGroupID
                        && $0.1["AssItemID"].asInt! == kbnData.AssItemID
                    }.map{ $0.1 }.first
                let mstImgPartsNo = mst?["ImgPartsNo"].asInt
                let mstAssInputKB = mst?["AssInputKB"].asString!


                var text = mst?["AssAbbreviatedName"].asString!

                // ImagePartsがある場合は部位名として取得する
                let parts = self.mstAssImageParts?.filter{
                    $0.1["ImgPartsNo"].asInt! == mstImgPartsNo
                    }.map{ $0.1 }.first

                if parts != nil && (parts?.length)! > 0 {
                    text = "【\(parts!["ImgPartsName"].asString!)】 \(text!)"
                }

                // 単位
                var unitStr : String! = ""
                let unit = mst?["AssUnit"].asString
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

                // グループが存在していない場合
                if existIndex == nil
                {
                    // グループ
                    let groupName = self.mstAssessmentGroup?
                        .filter{ $0.1["AssMenuGroupID"].asInt! == kbnData.AssMenuGroupID }
                        .first.map{ $0.1["AssMenuGroupName"].asString! }
                    // サブグループ
                    let subGroupName = self.mstAssessmentSubGroup?
                        .filter{ $0.1["AssMenuGroupID"].asInt! == kbnData.AssMenuGroupID && $0.1["AssMenuSubGroupID"].asInt! == kbnData.AssMenuSubGroupID }
                        .first.map{ $0.1["AssMenuSubGroupName"].asString! }

                    let groupData = (
                        AssMenuGroupID: kbnData.AssMenuGroupID,
                        AssMenuSubGroupID: kbnData.AssMenuSubGroupID,
                        Text: "\(groupName!)\n\(AppConst.IndentWidth.Space2.rawValue)\(subGroupName!)\n\(AppConst.IndentWidth.Space4.rawValue)\(text!): \(asr)"
                    )

                    groupDataList.append(groupData as! (AssMenuGroupID: Int, AssMenuSubGroupID: Int, Text: String))

                }

                    // 既にグループが存在している場合
                else
                {
                    groupDataList[existIndex!].Text = groupDataList[existIndex!].Text + "\n\(AppConst.IndentWidth.Space4.rawValue)\(text!): \(asr)"
                }
            }
            
            // データを表示用に整形する
            formatedStringList[karteKbn] = groupDataList.map{ $0.Text }.joined(separator: "\n\n")
        }

        return formatedStringList
    }

    /*
     連携用データフォーマッター
     */
    func formatCurrentSelectedDataForAPI() -> [String: AnyObject] {
        var params: [String: AnyObject] = [:]
        var karteKbn: AppConst.KarteKbn?

        // S
        karteKbn = AppConst.KarteKbn.SUBJECT
        params[(AppConst.KarteKbnName[karteKbn!]?.Full)!] = self.formatCurrentSelectedDataForAPIIndivisual(karteKbn!) as AnyObject

        // O
        karteKbn = AppConst.KarteKbn.OBJECT
        params[(AppConst.KarteKbnName[karteKbn!]?.Full)!] = self.formatCurrentSelectedDataForAPIIndivisual(karteKbn!) as AnyObject

        // A
        karteKbn = AppConst.KarteKbn.ASSESSMENT
        params[(AppConst.KarteKbnName[karteKbn!]?.Full)!] = self.formatCurrentSelectedDataForAPIIndivisual(karteKbn!) as AnyObject

        return params
    }

    /*
     連携用データフォーマッター 個別
     */
    func formatCurrentSelectedDataForAPIIndivisual(_ karteKbn: AppConst.KarteKbn) -> [[String: AnyObject]] {
        var sendSOAPList: [[String: AnyObject]] = []

        if self.currentSelectedData[karteKbn] != nil {
            sendSOAPList = self.currentSelectedData[karteKbn]?.map{ [
                "AssMenuGroupID":       $0.AssMenuGroupID as AnyObject,
                "AssMenuSubGroupID":    $0.AssMenuSubGroupID as AnyObject,
                "AssItemID":            $0.AssItemID as AnyObject
                ] } ?? []
        }

        return sendSOAPList
    }

    /*
     エラーチェック
     */
    func validate() -> Bool {
        return true
    }
}
