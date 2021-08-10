//
//  DetailEpisodeReasonInput.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/12/01.
//  Copyright © 2016年 System. All rights reserved.
//

import UIKit

class DetailEpisodeReasonInput: UIViewController {
    @IBOutlet weak var textInput: UITextField!
    //@IBOutlet weak var labelError: UILabel!
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    var episodeJson : JSON!
    var firstValue : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 入力情報の取得
        if appDelegate.EpisodeStatusChangeMode == AppConst.EpisodeChangeMode.RESTART.rawValue {
            if !AppCommon.isNilOrEmpty(appDelegate.EpisodeRestartReason) {
                firstValue = appDelegate.EpisodeRestartReason!
            } else {
                firstValue = ""
            }
        } else if appDelegate.EpisodeStatusChangeMode == AppConst.EpisodeChangeMode.END.rawValue {
            if !AppCommon.isNilOrEmpty(appDelegate.EpisodeEndReason) {
                firstValue = appDelegate.EpisodeEndReason!
            } else {
                firstValue = ""
            }
        } else {
            firstValue = ""
        }
        textInput.text = firstValue
        
        textInput.becomeFirstResponder()
    }
    
    @IBAction func clickClear(_ sender: AnyObject) {
        textInput.text = ""
    }
    /*
     戻る
     値が変更されていたら更新する
     */
    override func viewWillDisappear(_ animated: Bool) {
        if textInput.text != firstValue {
            // 変更されているのでフラグを更新する
            appDelegate.ChangeEpisodeStatus = true
        }
        // 変更値の保存変更
        if appDelegate.EpisodeStatusChangeMode == AppConst.EpisodeChangeMode.RESTART.rawValue {
            appDelegate.EpisodeRestartReason = textInput.text
        } else if appDelegate.EpisodeStatusChangeMode == AppConst.EpisodeChangeMode.END.rawValue {
            appDelegate.EpisodeEndReason = textInput.text
        }
        
        super.viewWillDisappear(animated)
    }
    
}
