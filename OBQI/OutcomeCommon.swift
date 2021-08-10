//
//  OutcomeCommon.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/12/19.
//  Copyright © 2016年 System. All rights reserved.
//
import UIKit

class OutcomeCommon {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()

    // アウトカムHD情報の取得
    static func getOutcomeHDInfo(episodeID : Int!, outcomeID : Int!) -> JSON {
        let url = "\(AppConst.URLPrefix)satisfaction/GetOutcomeHD/\(episodeID!)/\(outcomeID!)"
        let appCommon = AppCommon()
        let res = appCommon.getSynchronous(url)
        return JSON(string: res.result!) // JSON読み込み
    }

    // アウトカムDT情報の取得
    static func getOutcomeDTInfo(episodeID : Int!, outcomeID : Int!, outcomeKbn : Int!) -> JSON {
        let url = "\(AppConst.URLPrefix)satisfaction/GetOutcomeDT/\(episodeID!)/\(outcomeID!)/\(outcomeKbn!)"
        let appCommon = AppCommon()
        let res = appCommon.getSynchronous(url)
        return JSON(string: res.result!) // JSON読み込み
    }

    static func getRecordKbnString(recordKbn : String) -> String! {
        switch recordKbn {
        case AppConst.OutcomeRecordKB.MIJISSHI.rawValue:
            return "未実施"
        case AppConst.OutcomeRecordKB.JISSHIZUMI.rawValue:
            return "実施済み"
        case AppConst.OutcomeRecordKB.JISSHISHINAI.rawValue:
            return "実施しない"
        default:
            return ""
        }
    }

    func saveAnswer(_ mst : JSON!, episodeID : Int!, outcomeID : Int!, ansArray : [AnyObject], comment : String = "") {

        // 登録
        let outocomeItemID = mst["OutcomeItemID"].asInt!
        let commentInputFlg = mst["CommentInputFlg"].asString!

        let url = "\(AppConst.URLPrefix)satisfaction/PostSatisfaction"
        var inputArray : [String] = []

        for ans in ansArray {
            inputArray.append(ans as! String)
        }


        let params: [String: AnyObject] = [
            "EpisodeID": episodeID as AnyObject,
            "OutcomeID": outcomeID as AnyObject,
            "OutcomeItemID": outocomeItemID as AnyObject,
            "CommentInputFlg": commentInputFlg as AnyObject,
            "Comment": comment as AnyObject,
            "InputArray": inputArray as AnyObject
        ]

        // TODO エラーハンドリング
        _ = appCommon.postSynchronous(url, params: params)
    }

    func move(view : UIViewController) {
        // 区分毎に使用するアンケートを変更
        let outcomeKbn = (self.appDelegate.SelectedOutcomeKbn)!
        let outcomeListByKbn = appDelegate.MstOutcomeList?.enumerated().filter{ $0.element.1["OutcomeKbn"].asString == outcomeKbn }.map{ $0.element.1 }

        // 次の番号
        appDelegate.SelectedSatisfactionNo = appDelegate.SelectedSatisfactionNo + 1
        if (outcomeListByKbn?.count)! > appDelegate.SelectedSatisfactionNo {
            let outcome = outcomeListByKbn![appDelegate.SelectedSatisfactionNo]
            let inputKB = outcome["OutcomeInputKB"].asString!
            switch(inputKB) {
            case AppConst.InputKB.SINGLE.rawValue:
                let nex : AnyObject! = view.storyboard?.instantiateViewController(withIdentifier: "ManSingle")
                view.show(nex as! UIViewController, sender: view)
                break
            case AppConst.InputKB.MULTI.rawValue:
                let nex : AnyObject! = view.storyboard?.instantiateViewController(withIdentifier: "ManMulti")
                view.show(nex as! UIViewController, sender: view)
                break
            case AppConst.InputKB.INPUT.rawValue:
                let nex : AnyObject! = view.storyboard?.instantiateViewController(withIdentifier: "ManText")
                view.show(nex as! UIViewController, sender: view)
                break
            case AppConst.InputKB.NPS.rawValue:
                let nex : AnyObject! = view.storyboard?.instantiateViewController(withIdentifier: "ManNPS")
                view.show(nex as! UIViewController, sender: view)
                break
            default:
                let nex : AnyObject! = view.storyboard?.instantiateViewController(withIdentifier: "ManEnd")
                view.show(nex as! UIViewController, sender: view)
                break
            }
        } else { // 次がないので終了
            let nex : AnyObject! = view.storyboard?.instantiateViewController(withIdentifier: "ManEnd")
            view.show(nex as! UIViewController, sender: view)
        }
    }

    func goNext(_ view : UIViewController, mst : JSON!, episodeID : Int!, outcomeID : Int!, ansArray : [AnyObject], comment : String = "") {

        // 回答の保存
        saveAnswer(mst, episodeID : episodeID, outcomeID : outcomeID, ansArray : ansArray, comment : comment)

        // 次の画面へ
        move(view: view)
    }

}
