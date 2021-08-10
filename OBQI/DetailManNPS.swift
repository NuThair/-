//
//  DetailManNPS.swift
//  SkinFloraME
//
//  Created by ToyamaYoshimasa on 2015/01/26.
//  Copyright (c) 2015年 OrangeAct. All rights reserved.
//


import UIKit

class DetailManNPS: OutcomeViewController, UIAlertViewDelegate {
    var isNext = false
    var isReAnswer = false
    var outcomeItemGroup:[[JSON]] = []
    let outcomeCommon = OutcomeCommon()
    let assCommon = AssCommon()
    let appCommon = AppCommon()
    
    @IBOutlet weak var labelNPS: UILabel!
    @IBOutlet weak var sliderNPS: UISlider!
    @IBOutlet weak var labelItemName: UILabel!

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var middleEndButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // アウトカム結果一覧から遷移した場合はボタン非表示
        if isReAnswer {
            nextButton.setTitle("変更を確定して一覧へ戻る", for: UIControl.State.normal)
            middleEndButton.isHidden = true
            navigationItem.hidesBackButton = true

            // 初期値
            let defaultValue = Float(outcomeItemGroup[appDelegate.SelectedSatisfactionNo][0]["OutcomeChoicesAsr"].asString!)!
            sliderNPS.value = defaultValue / 10
            labelNPS.text = "お勧め度：\(getLevel())"
        }

        // 問題文設定
        let itemName = MstOutcome["OutcomeItemName"].asString!
        labelItemName.text = itemName
        
        // ラベルに初期値を設定する
        changeSlider(sliderNPS)
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
    
    @IBAction func changeSlider(_ sender: UISlider) {
        let level = getLevel()
        labelNPS.text = "お勧め度：\(level)"
    }

    
    @IBAction func clickNext(_ sender: AnyObject) {
        isNext = true

        let level = getLevel()

        let array : [Any] = [String(describing: level)]
        let episodeID = appDelegate.SelectedOutcom?["EpisodeID"].asInt
        let outcomeID = appDelegate.SelectedOutcom?["OutcomeID"].asInt

        // アウトカム結果一覧から遷移した場合は一覧画面へ戻る
        if isReAnswer {
            outcomeCommon.saveAnswer(MstOutcome, episodeID : episodeID, outcomeID : outcomeID, ansArray: array as [AnyObject])
            _ = navigationController?.popViewController(animated: true)
        } else {
            outcomeCommon.goNext(self, mst: MstOutcome, episodeID : episodeID, outcomeID : outcomeID, ansArray: array as [AnyObject])
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

    func getLevel() -> Int {
        let roundValue = appCommon.ponvireRound(Double(sliderNPS.value), figures: 1)
        return Int(roundValue * 10)
    }
}
