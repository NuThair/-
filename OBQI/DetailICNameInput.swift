//
//  DetailICNameInput.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/12/14.
//  Copyright © 2016年 System. All rights reserved.
//

import UIKit

class DetailICNameInput: UIViewController {
    @IBOutlet weak var textInput: UITextField!
    //@IBOutlet weak var labelError: UILabel!
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    var episodeJson : JSON!
    var firstValue : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let episodeID = appDelegate.SelectedIC?["EpisodeID"].asInt
        let icID = appDelegate.SelectedIC?["ICID"].asInt
        let seqNo = appDelegate.SelectedIC?["SEQNO"].asInt
        
        appDelegate.SelectedIC = ICCommon.getICInfo(episodeID: episodeID!, icID: icID!, seqNo: seqNo!)

        firstValue = nil
        if let ICtext = appDelegate.SelectedIC?["ICText"].asString {
                firstValue = ICtext
        }
        textInput.text = firstValue
        
        textInput.becomeFirstResponder()
    }
    /*
     戻る
     値が変更されていたら更新する
     */
    override func viewWillDisappear(_ animated: Bool) {
        if textInput.text != firstValue {
            // 変更値の保存変更
            let episodeID = appDelegate.SelectedIC?["EpisodeID"].asInt
            let icID = appDelegate.SelectedIC?["ICID"].asInt
            let seqNo = appDelegate.SelectedIC?["SEQNO"].asInt
            
            let url = "\(AppConst.URLPrefix)ic/PutInformedConsent"
            let params: [String: AnyObject] = [
                "EpisodeID": episodeID as AnyObject,
                "ICID": icID as AnyObject,
                "SEQNO": seqNo as AnyObject,
                "ICText": textInput.text as AnyObject,
                ]
            let appCommon = AppCommon()
            let res = appCommon.putSynchronous(url, params: params)
            if !AppCommon.isNilOrEmpty(res.errCode) {
                AppCommon.alertMessage(controller: self, title: "エラー(\(res.errCode!))", message: "登録に失敗しました。")
            } else {
                // 変更されているのでフラグを更新する
                appDelegate.ChangeIC = true
            }
        }
        super.viewWillDisappear(animated)
    }
    
}
