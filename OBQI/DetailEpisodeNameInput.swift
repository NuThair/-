//
//  DetailEpisodeNameInput.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/11/28.
//  Copyright © 2016年 System. All rights reserved.
//

import UIKit

class DetailEpisodeNameInput: UIViewController {
    @IBOutlet weak var textInput: UITextField!
    @IBOutlet weak var labelError: UILabel!
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    var episodeJson : JSON!
    var firstValue : String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // エピソード情報の取得
        episodeJson = EpisodeCommon.getEpisodeInfo(selectedEipsodeID: appDelegate.SelectedEpisodeID)
        if !AppCommon.isNilOrEmpty(episodeJson["EpisodeName"].asString) {
            firstValue = episodeJson["EpisodeName"].asString!
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
        let episodeCommon = EpisodeCommon()
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        // 入力されている文字を取得する
        
         if textInput.text != firstValue {
            // 変更されているのでフラグを更新する
            appDelegate.ChangeEpisode = true
         }

        episodeCommon.regEpisodeName(episodeID: appDelegate.SelectedEpisodeID, text: textInput.text!)
        super.viewWillDisappear(animated)
    }

}
