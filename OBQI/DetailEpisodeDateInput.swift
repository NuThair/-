//
//  DetailEpisodeDateInput.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/12/01.
//  Copyright © 2016年 System. All rights reserved.
//

import UIKit

class DetailEpisodeDateInput: UIViewController {
    @IBOutlet weak var datePicker: UIDatePicker!

    //@IBOutlet weak var labelError: UILabel!
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    var episodeJson : JSON!
    var firstValue : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 入力情報の取得
        if appDelegate.EpisodeStatusChangeMode == AppConst.EpisodeChangeMode.RESTART.rawValue {
            if !AppCommon.isNilOrEmpty(appDelegate.EpisodeRestartDate) {
                firstValue = appDelegate.EpisodeRestartDate!
            } else {
                firstValue = ""
            }
        } else if appDelegate.EpisodeStatusChangeMode == AppConst.EpisodeChangeMode.END.rawValue {
            if !AppCommon.isNilOrEmpty(appDelegate.EpisodeEndDate) {
                firstValue = appDelegate.EpisodeEndDate!
            } else {
                firstValue = ""
            }
        } else {
            firstValue = ""
        }
        // 初期値設定
        if !AppCommon.isNilOrEmpty(firstValue) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
            let date = dateFormatter.date(from: firstValue!)
            datePicker.date = date!
        }
    }
    /*
     戻る
     値が変更されていたら更新する
     */
    override func viewWillDisappear(_ animated: Bool) {
        let myDateFormatter: DateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        let choice: NSString = myDateFormatter.string(from: datePicker.date) as NSString

        // 変更値の保存変更
        if appDelegate.EpisodeStatusChangeMode == AppConst.EpisodeChangeMode.RESTART.rawValue {
            appDelegate.EpisodeRestartDate = choice as String
        } else if appDelegate.EpisodeStatusChangeMode == AppConst.EpisodeChangeMode.END.rawValue {
            appDelegate.EpisodeEndDate = choice as String
        }
        
        super.viewWillDisappear(animated)
    }
    
}

