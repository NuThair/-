//
//  DetailManSonota.swift
//  SkinFloraME
//
//  Created by ToyamaYoshimasa on 2015/02/26.
//  Copyright (c) 2015年 OrangeAct. All rights reserved.
//

import UIKit

class DetailManSonota: UIViewController, UIAlertViewDelegate {

    var isReAnswer = false
    var outcomeItemGroup:[[JSON]] = []
    var MstOutcome : JSON!
    var SelectArray : [AnyObject] = []
    let outcomeCommon = OutcomeCommon()
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)

    @IBOutlet weak var textViewComment: UITextView!

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var middleEndButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // アウトカム結果一覧から遷移した場合はボタン非表示
        if isReAnswer {
            nextButton.setTitle("変更を確定して一覧へ戻る", for: UIControl.State.normal)
            middleEndButton.isHidden = true

            textViewComment.text = outcomeItemGroup[appDelegate.SelectedSatisfactionNo!].filter{ $0["CommentInputFlg"].asString! == "1" }.first.map{ $0["OutcomeChoicesAsr"].asString! }
        }

        // Do any additional setup after loading the view.
        //textViewComment.frame.origin.y = 50
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func clickNext(_ sender: AnyObject) {

        let episodeID = appDelegate.SelectedOutcom?["EpisodeID"].asInt
        let outcomeID = appDelegate.SelectedOutcom?["OutcomeID"].asInt
        let comment = textViewComment.text

        // 入力されている値を取得する
        if !AppCommon.isNilOrEmpty(textViewComment.text) {
            // アウトカム結果一覧から遷移した場合は一覧画面から戻る
            if isReAnswer {
                outcomeCommon.saveAnswer(MstOutcome, episodeID : episodeID, outcomeID : outcomeID, ansArray: SelectArray as [AnyObject], comment: comment!)
                _ = navigationController?.popToViewController(navigationController!.viewControllers[2], animated: true)
            } else {
                outcomeCommon.goNext(self, mst: MstOutcome, episodeID : episodeID, outcomeID : outcomeID, ansArray: SelectArray as [AnyObject], comment: comment!)
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
}
