//
//  AssCommon.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/11/17.
//  Copyright © 2016年 System. All rights reserved.
//

import UIKit

class AssCommon {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    
    init(){
        
    }
    // アセスメント状態更新。アセスメントヘッダーも取得する
    func postAssState() {
        let assID = appDelegate.SelectedAssAssID!
        let url = "\(AppConst.URLPrefix)assessment/PostAssessmentState/\(assID)"
        let params: [String: AnyObject] = [
            "assID": assID as AnyObject
        ]
        let res = appCommon.postSynchronous(url, params: params)
        if AppCommon.isNilOrEmpty(res.errCode) {
            appDelegate.SelectedAssHD = JSON(string: res.result!) // JSON読み込み
        }
    }
    // アセスメント項目更新
    func regAss(_ ansArray : [AnyObject], assessmentID : Int!, selectedAss : JSON!, isSync : Bool!) -> (result: String?, errCode: String?) {
        if appDelegate.SelectedAssHD!["AssRecordKB"].asString == AppConst.AssRecordKB.COMP.rawValue
        { // 完了している場合は更新しない
            return (result: nil, errCode: nil)
        }
        let url = "\(AppConst.URLPrefix)assessment/PostAssessmentInfo/true"
        
        var inputArray : [String] = []
        for ans in ansArray {
            inputArray.append(ans as! String)
        }
        let assMenuGroupID = selectedAss["AssMenuGroupID"].asInt!
        let assMenuSubGroupID = selectedAss["AssMenuSubGroupID"].asInt!
        let assItemID = selectedAss["AssItemID"].asInt!
        let params: [String: AnyObject] = [
            "assID": assessmentID as AnyObject,
            "assMenuGroupID": assMenuGroupID as AnyObject,
            "assMenuSubGroupID": assMenuSubGroupID as AnyObject,
            "assItemID": assItemID as AnyObject,
            "inputArray": inputArray as AnyObject,
            //"inputTypeArray": inputTypeArray
        ]
        /*
         request.HTTPMethod = "POST"
         request.addValue("application/json", forHTTPHeaderField: "Content-Type")
         request.addValue("application/json", forHTTPHeaderField: "Accept")
         request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: nil)
         */
        //if isSync == true { // 同期
            //var data = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)
            return appCommon.postSynchronous(url, params: params)
        //} else {
            // 時間かかるので非同期で実行
            //var connection: NSURLConnection = NSURLConnection(request: request, delegate: self)!
            //connection.start()
        //    appCommon.postUnSynchronous(url, params: params)
        //}
        
    }
    // アセスメント削除
    func delAss(_ assessmentID : Int!, selectedAss : JSON!, isSync : Bool!) -> (result: String?, errCode: String?) {
        return delAss(assessmentID, selectedAss: selectedAss, isSync: isSync, seqNo: nil)
    }
    func delAss(_ assessmentID : Int!, selectedAss : JSON!, isSync : Bool!, seqNo : Int?) -> (result: String?, errCode: String?) {
        if appDelegate.SelectedAssHD!["AssRecordKB"].asString == AppConst.AssRecordKB.COMP.rawValue
        { // 完了している場合は更新しない
            return (result: nil, errCode: nil)
        }
        let url = "\(AppConst.URLPrefix)assessment/PostAssessmentInfo/true"
        
        let assMenuGroupID = selectedAss["AssMenuGroupID"].asInt!
        let assMenuSubGroupID = selectedAss["AssMenuSubGroupID"].asInt!
        let assItemID = selectedAss["AssItemID"].asInt!
        // inputArrayをからで渡すと削除になる
        var params: [String: AnyObject] = [
            "AssID": assessmentID as AnyObject,
            "AssMenuGroupID": assMenuGroupID as AnyObject,
            "AssMenuSubGroupID": assMenuSubGroupID as AnyObject,
            "AssItemID": assItemID as AnyObject,
            ]
        if seqNo != nil {
            params.updateValue(String(seqNo!) as AnyObject, forKey: "SeqNo")
        }
        /*
         let request = NSMutableURLRequest(URL: NSURL(string: url)!)
         request.HTTPMethod = "POST"
         request.addValue("application/json", forHTTPHeaderField: "Content-Type")
         request.addValue("application/json", forHTTPHeaderField: "Accept")
         request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: nil)
         */
        //if isSync == true { // 同期
            //var data = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)
            return appCommon.postSynchronous(url, params: params)
        //} else {
            // 時間かかるので非同期で実行
            //var connection: NSURLConnection = NSURLConnection(request: request, delegate: self)!
            //connection.start()
        //    appCommon.postUnSynchronous(url, params: params)
        //}
    }
    // 入力されているアセスメントを取得する
    func getInputAssessmentList() -> JSON? {
        let assID = appDelegate.SelectedAssAssID!
        let url = "\(AppConst.URLPrefix)assessment/GetInputAssessmentList/\(assID)"
        let res = appCommon.getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return nil
        }
        return JSON(string: res.result!) // JSON読み込み
    }
    // 入力されているアセスメントを取得する
    func getSubGroupInputAssessmentList() -> JSON? {
        let assID = appDelegate.SelectedAssAssID!
        let assMenuGroupID = appDelegate.SelectedMstAssessmentSubGroup!["AssMenuGroupID"].asInt!
        let assMenuSubGroupID = appDelegate.SelectedMstAssessmentSubGroup!["AssMenuSubGroupID"].asInt!
        let url = "\(AppConst.URLPrefix)assessment/GetSubGroupInputAssessmentList/\(assID)/\(assMenuGroupID)/\(assMenuSubGroupID)"
        let res = appCommon.getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return nil
        }
        return JSON(string: res.result!) // JSON読み込み
    }
    // 入力されている基本情報アセスメントを取得する
    func getBasicSubGroupInputAssessmentList() -> JSON? {
        let assID = appDelegate.SelectedAssAssID!
        let assMenuGroupID = 1
        let assMenuSubGroupID = 1
        let url = "\(AppConst.URLPrefix)assessment/GetSubGroupInputAssessmentList/\(assID)/\(assMenuGroupID)/\(assMenuSubGroupID)"
        let res = appCommon.getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return nil
        }
        return JSON(string: res.result!) // JSON読み込み
    }
    // 入力されているアセスメントを取得する
    func getMenuGroupInputAssessmentList() -> JSON? {
        let assID = appDelegate.SelectedAssAssID!
        let assMenuGroupID = appDelegate.SelectedMstAssessmentGroup!["AssMenuGroupID"]!.asInt!
        let url = "\(AppConst.URLPrefix)assessment/GetMenuGroupInputAssessmentList/\(assID)/\(assMenuGroupID)"
        let res = appCommon.getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return nil
        }
        return JSON(string: res.result!) // JSON読み込み
    }
    // 対象アセスメントの写真を取得する
    func getPhotoAssessmentList() -> JSON? {
        let assID = appDelegate.SelectedAssAssID!
        let mstAssMenuGroupID = appDelegate.SelectedMstAssessmentItem!["AssMenuGroupID"].asInt!
        let mstAssMenuSubGroupID = appDelegate.SelectedMstAssessmentItem!["AssMenuSubGroupID"].asInt!
        let mstAssItemID = appDelegate.SelectedMstAssessmentItem!["AssItemID"].asInt!
        let customerID = appDelegate.SelectedCustomer!["CustomerID"].asString!
        let url = "\(AppConst.URLPrefix)assessment/GetPhotoAssessments/\(customerID)/\(assID)/\(mstAssMenuGroupID)/\(mstAssMenuSubGroupID)/\(mstAssItemID)"
        let res = appCommon.getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) || AppCommon.isNilOrEmpty(res.result) {
            return nil
        }
        return JSON(string: res.result!) // JSON読み込み
    }
    // 対象のアセスメントの入力を返す
    func getAssInput(_ inputAssList : JSON?, mstAssessment : JSON!) -> [JSON] {
        let mstAssMenuGroupID = mstAssessment["AssMenuGroupID"].asInt!
        let mstAssMenuSubGroupID = mstAssessment["AssMenuSubGroupID"].asInt!
        let mstAssItemID = mstAssessment["AssItemID"].asInt!
        
        var ret : [JSON] = []
        for i in 0 ..< inputAssList!.length {
            let ob = inputAssList![i]
            let inputAssMenuGroupID = ob["AssMenuGroupID"].asInt!
            let inputAssMenuSubGroupID = ob["AssMenuSubGroupID"].asInt!
            let inputAssItemID = ob["AssItemID"].asInt!
            
            if mstAssMenuGroupID == inputAssMenuGroupID
                && mstAssMenuSubGroupID == inputAssMenuSubGroupID
                && mstAssItemID == inputAssItemID {
                ret.append(ob)
                if mstAssessment["AssInputKB"].asString == AppConst.InputKB.SINGLE.rawValue {
                    break
                }
            }
        }
        return ret
    }
    
}
