//
//  DetailManText.swift
//  SkinFloraME
//
//  Created by ToyamaYoshimasa on 2015/01/26.
//  Copyright (c) 2015年 OrangeAct. All rights reserved.
//

import UIKit

class DetailManText: OutcomeViewController, UIAlertViewDelegate {
    var isNext = false
    var isReAnswer = false
    var outcomeItemGroup:[[JSON]] = []
    let outcomeCommon = OutcomeCommon()
    let assCommon = AssCommon()
    let appCommon = AppCommon()
    
    @IBOutlet weak var labelItemName: UILabel!
    @IBOutlet weak var textField: UITextField!

    @IBOutlet weak var middleEndButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // アウトカム結果一覧から遷移した場合はボタン非表示
        if isReAnswer {
            nextButton.setTitle("変更を確定して一覧へ戻る", for: UIControl.State.normal)
            middleEndButton.isHidden = true
            navigationItem.hidesBackButton = true

            textField.text =  outcomeItemGroup[appDelegate.SelectedSatisfactionNo!][0]["OutcomeChoicesAsr"].asString!
        }

        // 戻るボタン非表示
        //self.navigationController!.setNavigationBarHidden(true, animated: true)
        
        // 問題文設定
        let itemName = MstOutcome["OutcomeItemName"].asString!
        labelItemName.text = itemName
        
    }
    /*
    戻る
    */
    override func viewWillDisappear(_ animated: Bool) {
        if !isNext && appDelegate.SelectedSatisfactionNo > 0 {
            appDelegate.SelectedSatisfactionNo = appDelegate.SelectedSatisfactionNo - 1
        }
        isNext = false
        super.viewWillDisappear(animated)
    }

    
    @IBAction func clickNext(_ sender: AnyObject) {
        isNext = true
        // 入力されている値を取得する
        if !AppCommon.isNilOrEmpty(textField.text) {
            let array : [AnyObject] = [textField.text! as AnyObject]
            let episodeID = appDelegate.SelectedOutcom?["EpisodeID"].asInt
            let outcomeID = appDelegate.SelectedOutcom?["OutcomeID"].asInt

            // アウトカム結果一覧から遷移した場合は一覧画面から戻る
            if isReAnswer {
                outcomeCommon.saveAnswer(MstOutcome, episodeID : episodeID, outcomeID : outcomeID, ansArray: array as [AnyObject])
                _ = navigationController?.popViewController(animated: true)
            } else {
                outcomeCommon.goNext(self, mst: MstOutcome, episodeID : episodeID, outcomeID : outcomeID, ansArray: array as [AnyObject])
            }
        } else {
            AppCommon.alertMessage(controller: self, title: "エラー", message: "回答を入力してください。")
        }
    }

    @IBAction func clickEnd(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "確認", message: "途中終了しますか？", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "いいえ", style: .default, handler:{(action: UIAlertAction!) -> Void in
            print("pushed Cancel Button")
        })
        alertController.addAction(cancelAction)
        let okAction = UIAlertAction(title: "はい", style: .default, handler:{(action: UIAlertAction!) -> Void in
            let nex : AnyObject! = self.storyboard?.instantiateViewController(withIdentifier: "ManEnd")
            self.show(nex as! UIViewController, sender: UIView())
        })

        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }

    @IBAction func tapScreen(_ sender: AnyObject) {
        self.view.endEditing(true);
    }
}
