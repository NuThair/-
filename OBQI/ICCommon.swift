//
//  ICCommon.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/12/14.
//  Copyright © 2016年 System. All rights reserved.
//

import UIKit

class ICCommon {
    let appCommon = AppCommon()
    
    // IC名の取得
    static func getICIDName(icid : Int!) -> String! {
        if icid == nil {
            return ""
        } else {
            let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
            let array = appDelegate.MstInformedConsentList?.enumerated().filter{ $0.element.1["ICID"].asInt == icid }.map{ $0.element.1 }
            if array?.count == 0 {
                    return ""
            } else {
                return array?.first!["ICName"].asString
            }
        }
    }
    // IC情報の取得
    static func getICInfo(episodeID : Int!, icID : Int!, seqNo : Int!) -> JSON {
        let url = "\(AppConst.URLPrefix)ic/GetInformedConsent/\(episodeID!)/\(icID!)/\(seqNo!)"
        let appCommon = AppCommon()
        let res = appCommon.getSynchronous(url)
        return JSON(string: res.result!) // JSON読み込み
    }

    // 対象アセスメントの写真を取得する
    func getICPhotoFileList(episodeID : Int!, icID : Int!, seqNo : Int!) -> JSON? {
        let url = "\(AppConst.URLPrefix)ic/GetICPhotoFileList/\(episodeID!)/\(icID!)/\(seqNo!)"
        let res = appCommon.getSynchronous(url)

        if !AppCommon.isNilOrEmpty(res.errCode) || AppCommon.isNilOrEmpty(res.result) {
            return nil
        }

        return JSON(string: res.result!) // JSON読み込み
    }

    // IC画像全件削除
    func deleleICPhotoFile(episodeID : Int!, icID : Int!, seqNo : Int!) -> (result: String?, errCode: String?) {
        return deleleICPhotoFile(episodeID : episodeID, icID : icID, seqNo : seqNo, photoSeqNo : nil)
    }
    // IC画像削除
    func deleleICPhotoFile(episodeID : Int!, icID : Int!, seqNo : Int!, photoSeqNo : Int!) -> (result: String?, errCode: String?) {
        var url = "\(AppConst.URLPrefix)ic/DeleteICPhotoFile/\(episodeID!)/\(icID!)/\(seqNo!)"
        if photoSeqNo != nil {
            url += "/\(photoSeqNo!)"
        }

        return appCommon.deleteSynchronous(url, params: [:])
    }
}
