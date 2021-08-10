//
//  KartePlanClass.swift
//  OBQI
//
//  Created by t.o on 2017/05/31.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class KartePlanClass {
    let appCommon = AppCommon()

    // マスタ
    var mstMenu: JSON?
    var mstBusinessLogSubHD: JSON?

    // 対象の患者ID
    var targetCustomerID: String?
    // 対象の最終連携区分
    var targetHistory: AppConst.SOAPHistoryHeaderFormat?
    // 対象の最終連携詳細データ
    var targetHistoryDetail: JSON?

    // 選択可能データ
    var selectableHDData: [AppConst.KarteMenuHDParamsFormat] = []
    var selectableDTData: [AppConst.KarteMenuDTParamsFormat] = []
    // 最終連携データ
    var lastSelectedData: [AppConst.KarteMenuDTParamsFormat] = []
    // 選択中データ
    var currentSelectedData: [AppConst.KarteMenuDTParamsFormat] = []
    // 新規追加データ
    var newSelectedData: [AppConst.KarteMenuDTParamsFormat] = []



    /*
     初期化
     */
    init(customerID: String?, lastSOAPHistoryHeader: AppConst.SOAPHistoryHeaderFormat?, targetHistoryDetail: JSON?,
        mstMenu: JSON?, mstBusinessLogSubHD: JSON?) {
        // プロパティの初期化
        self.targetCustomerID = customerID

        self.targetHistory = lastSOAPHistoryHeader // 未連携時はnil
        self.targetHistoryDetail = targetHistoryDetail // 未連携時はnil

        self.mstMenu = mstMenu
        self.mstBusinessLogSubHD = mstBusinessLogSubHD

        // 必要な値がセットされているか確認
        if !checkProperties() {
            return
        }

        // 選択可能データHD設定
        _ = self.setSelectableHDData()
        // 最終連携データ設定
        _ = self.setLastSelectedData()

        // 初期選択状態の設定
        let updateKbn = targetHistory.map{ $0.PUpdateKbn } ?? nil
        self.setInitialSelectedData(updateKbn)
    }

    /*
     必須プロパティのチェック
     */
    private func checkProperties() -> Bool {
        // 初期化時に値が入らない場合はエラー
        if self.targetCustomerID == nil
            || self.mstMenu == nil
            || self.mstBusinessLogSubHD == nil
        {
            return false
        }

        return true
    }

    /*
     選択可能データHD設定
     */
    func setSelectableHDData() -> Bool {
        // 介入計画HD一覧取得
        let url = "\(AppConst.URLPrefix)menu/GetSelectedMenuHD/\(self.targetCustomerID!)"
        let res = appCommon.getSynchronous(url)

        if !AppCommon.isNilOrEmpty(res.errCode) {
            return false
        }

        let selectedMenuHDJSON = JSON(string: res.result!)

        if selectedMenuHDJSON.length == 0 {
            return false
        }

        self.selectableHDData = selectedMenuHDJSON.map{ AppConst.KarteMenuHDParamsFormat(
            MenuSetName:    $0.1["MenuSetName"].asString!,
            MenuStatus:     $0.1["MenuStatus"].asString!,
            CustomerID:     $0.1["CustomerID"].asInt!,
            CriteriaAssID:  $0.1["CriteriaAssID"].asInt!,
            MenuGroupID:    $0.1["MenuGroupID"].asInt!,
            MenuOrderNo:    $0.1["MenuOrderNo"].asInt!,
            CreateDateTime: AppCommon.getDateFormat(date: $0.1["CreateDateTime"].asDate, format: "yyyy/MM/dd HH:mm:ss")!,
            MenuInfoList:   $0.1["MenuInfoList"].map{ (menuInfoList) -> AppConst.ProgramParamsFormat in
                                return AppConst.ProgramParamsFormat( MenuID: menuInfoList.1["MenuID"].asInt!, MenuName: "") },
            MnameInfoList:  []
            ) }

        return true
    }

    /*
     選択可能データDT設定
     */
    func setSelectableDTData(_ menuGroupID: Int) -> Bool {
        // 介入計画DT一覧取得
        let menuGroupIDString = String(describing: menuGroupID)
        let url = "\(AppConst.URLPrefix)menu/GetSelectedMenuDT/\(menuGroupIDString)"
        let res = appCommon.getSynchronous(url)

        if !AppCommon.isNilOrEmpty(res.errCode) {
            return false
        }

        let selectedMenuDTJSON = JSON(string: res.result!)

        if selectedMenuDTJSON.length == 0 {
            return false
        }

        self.selectableDTData = selectedMenuDTJSON.map{ AppConst.KarteMenuDTParamsFormat(
            MenuGroupID:        $0.1["MenuGroupID"].asInt!,
            Day:                $0.1["Day"].asInt!,
            BLogGroupID:        $0.1["BLogGroupID"].asInt!,
            BLogSubGroupID:     $0.1["BLogSubGroupID"].asInt!,
            OrderNo:            $0.1["OrderNo"].asInt!
            ) }

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
        self.lastSelectedData = (self.targetHistoryDetail?.map{ AppConst.KarteMenuDTParamsFormat(
            MenuGroupID:    $0.1["MenuGroupID"].asInt!,
            Day:            $0.1["Day"].asInt!,
            BLogGroupID:    $0.1["BLogGroupID"].asInt!,
            BLogSubGroupID: $0.1["BLogSubGroupID"].asInt!,
            OrderNo:        $0.1["OrderNo"].asInt!
            ) })!

        return true
    }

    /*
     初期選択状態の設定
     */
    func setInitialSelectedData(_ updateKbn: String?) {
        // 前回連携データがある場合はそちらを優先
        if !AppCommon.isNilOrEmpty(updateKbn) {
            self.currentSelectedData = self.lastSelectedData
        }
    }


    /*
     表示用データフォーマッター
     */
    func formatCurrentSelectedDataForDisplay() -> String {
        var formatedString = ""
        // MenuGroup毎に分ける
        let allMenuGroupIDList = self.currentSelectedData.map{ $0.MenuGroupID! }
        let menuGroupIDList = (NSOrderedSet(array: allMenuGroupIDList).array as! [Int]).sorted(by: <)


        var textArray:[String] = []
        menuGroupIDList.forEach{ (menuGroupID) -> Void in
            var text = ""

            let selectedMenuHDInfo = self.selectableHDData.filter{ $0.MenuGroupID == menuGroupID }.first

            // 計画名
            let menuSetName = selectedMenuHDInfo?.MenuSetName!

            // 臨床プログラム名
            let programNames = selectedMenuHDInfo?.MenuInfoList.map{ (menuInfo) -> String in
                return (self.mstMenu?.filter{ $0.1["MenuID"].asInt! == menuInfo.MenuID! }.map{ $0.1["MenuName"].asString! }.first)!
                }.joined(separator: ",")

            // DT取得
           // let DTInfoList = self.currentSelectedData.filter{ $0.MenuGroupID == menuGroupID }.sorted{ $0.0.OrderNo! < $0.1.OrderNo! }
            let DTInfoList = self.currentSelectedData.filter{ $0.MenuGroupID == menuGroupID }.sorted{ $0.OrderNo! < $1.OrderNo! }

            // 詳細に含まれるDayをユニーク化
            let allDays = DTInfoList.map{
                $0.Day!
            }
            let orderedDays = (NSOrderedSet(array: allDays).array as! [Int]).sorted(by: <)
            var menuDTs = ""
            orderedDays.forEach{ (day) -> Void in
                // 回数取得
                menuDTs = "\(menuDTs)\n\(day)回目"
                // 名称取得
                let menuDTNames = DTInfoList
                    .filter{ $0.Day == day }
                    .map{ (DTInfo) -> String in
                        return (self.mstBusinessLogSubHD?
                            .filter{ $0.1["BLogGroupID"].asInt == DTInfo.BLogGroupID && $0.1["BLogSubGroupID"].asInt == DTInfo.BLogSubGroupID }
                            .map{ $0.1["BLogSubGroupName"].asString! }.first)!
                    }
                    .joined(separator: "\n\(AppConst.IndentWidth.Space2.rawValue)")
                menuDTs = "\(menuDTs)\n\(AppConst.IndentWidth.Space2.rawValue)\(menuDTNames)"
            }

            text = "【計画名】 \(menuSetName!)\n【臨床プログラム】 \(programNames!)\(menuDTs)"

            textArray.append(text)
        }
        formatedString = textArray.joined(separator: "\n\n")

        return formatedString
    }

    /*
     連携用データフォーマッター
     */
    func formatCurrentSelectedDataForAPI() -> [String: AnyObject] {
        var params: [String: AnyObject] = [:]

        let sendSOAPList = self.currentSelectedData.map{ [
            "MenuGroupID":      $0.MenuGroupID as AnyObject,
            "Day":              $0.Day as AnyObject,
            "BLogGroupID":      $0.BLogGroupID as AnyObject,
            "BLogSubGroupID":   $0.BLogSubGroupID as AnyObject,
            "OrderNo":          $0.OrderNo as AnyObject
            ] } 

        params[(AppConst.KarteKbnName[AppConst.KarteKbn.PLAN]?.Full)!] = sendSOAPList as AnyObject

        return params
    }
    
    /*
     エラーチェック
     */
    func validate() -> Bool {
        return true
    }
}
