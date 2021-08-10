//
//  DetailEpisodeTextInput.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/11/29.
//  Copyright © 2016年 System. All rights reserved.
//

import UIKit

class DetailEpisodeTextInput: UIViewController {
    @IBOutlet weak var textInput: UITextView!
    @IBOutlet weak var labelError: UILabel!
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    var episodeJson : JSON!
    var firstValue : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // エピソード情報の取得
        episodeJson = EpisodeCommon.getEpisodeInfo(selectedEipsodeID: appDelegate.SelectedEpisodeID)
        if !AppCommon.isNilOrEmpty(episodeJson["EpisodeText"].asString) {
            firstValue = episodeJson["EpisodeText"].asString!
        } else {
            firstValue = ""
        }
        textInput.text = firstValue
        
        // 角に丸みをつける.
        textInput.layer.masksToBounds = true
        // 丸みのサイズを設定する.
        textInput.layer.cornerRadius = 3.0
        // 枠線の太さを設定する.
        textInput.layer.borderWidth = 1
        // 枠線の色を黒に設定する.
        textInput.layer.borderColor = UIColor.gray.cgColor
        // 左詰めの設定をする.
        textInput.textAlignment = NSTextAlignment.left
        
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
        
        episodeCommon.regEpisodeText(episodeID: appDelegate.SelectedEpisodeID, text: textInput.text!)
        super.viewWillDisappear(animated)
    }
    
}
