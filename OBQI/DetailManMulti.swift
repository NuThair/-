//
//  DetailManMulti.swift
//  SkinFloraME
//
//  Created by ToyamaYoshimasa on 2015/01/26.
//  Copyright (c) 2015年 OrangeAct. All rights reserved.
//

import UIKit

class DetailManMulti: OutcomeViewController, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate {
    var isNext = false
    var isReAnswer = false
    var outcomeItemGroup:[[JSON]] = []
    let outcomeCommon = OutcomeCommon()
    let assCommon = AssCommon()
    let appCommon = AppCommon()
    // 表示する値の配列.
    var choiceValues: [String] = []
    // その他を入力するか
    var isInputComment = false
    // 入力した値
    var SelectArray : [AnyObject] = []
    
    @IBOutlet weak var labelItemName: UILabel!
    @IBOutlet weak var myTableView: UITableView!

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var middleEndButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // アウトカム結果一覧から遷移した場合はボタン非表示
        if isReAnswer {
            // その他系が選択されている場合
            if (outcomeItemGroup[appDelegate.SelectedSatisfactionNo!].filter{ AppConst.ManSonotaStrings.contains($0["OutcomeChoicesAsr"].asString!) }).count > 0 {
                nextButton.setTitle("次へ", for: UIControl.State.normal)
            } else {
                nextButton.setTitle("変更を確定して一覧へ戻る", for: UIControl.State.normal)
            }
            middleEndButton.isHidden = true
            navigationItem.hidesBackButton = true
        }

        // 戻るボタン非表示
        //self.navigationController!.setNavigationBarHidden(true, animated: true)
        
        // 問題文設定
        let itemName = MstOutcome["OutcomeItemName"].asString!
        labelItemName.text = itemName
        // 選択肢を取得する
        myTableView.allowsMultipleSelection = true
        choiceValues = MstOutcome["OutcomeChoices"].asString!.components(separatedBy: ",")

        // DataSourceの設定をする.
        myTableView!.dataSource = self
        // Delegateを設定する.
        myTableView!.delegate = self
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
        isInputComment = false
        // 選択されているインデックスを取得する
        let indexPaths = myTableView?.indexPathsForSelectedRows
        if indexPaths != nil && (indexPaths?.count)! > 0 {
            SelectArray = []
            var isSonotaSelect = false
            for i in 0 ..< indexPaths!.count {
                let choice = choiceValues[(indexPaths![i] as NSIndexPath).row]
                SelectArray.append(choice as AnyObject)
                // その他が選択されている
                if !isSonotaSelect && AppConst.ManSonotaStrings.contains(choice) {
                    isSonotaSelect = true
                }
            }

            let episodeID = appDelegate.SelectedOutcom?["EpisodeID"].asInt
            let outcomeID = appDelegate.SelectedOutcom?["OutcomeID"].asInt

            let commentInputFlg = MstOutcome["CommentInputFlg"].asString!
            // コメント入力フラグが立っていて、その他が選択されている
            if commentInputFlg == AppConst.Flag.ON.rawValue && isSonotaSelect {
                isInputComment = true
                performSegue(withIdentifier: "SegueManSonota",sender: self)
                return
            } else {
                // アウトカム結果一覧から遷移した場合は一覧画面から戻る
                if isReAnswer {
                    outcomeCommon.saveAnswer(MstOutcome, episodeID : episodeID, outcomeID : outcomeID, ansArray: SelectArray as [AnyObject])
                    _ = navigationController?.popViewController(animated: true)
                } else {
                    outcomeCommon.goNext(self, mst: MstOutcome, episodeID : episodeID, outcomeID : outcomeID, ansArray: SelectArray as [AnyObject])
                }
            }
        } else {
            AppCommon.alertMessage(controller: self, title: "エラー", message: "回答を選択してください。")
        }
    }
    /*
    * 画面遷移
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if isInputComment {
            let sonotaView:DetailManSonota = segue.destination as! DetailManSonota
            sonotaView.SelectArray = self.SelectArray
            sonotaView.MstOutcome = self.MstOutcome
            if isReAnswer {
                sonotaView.isReAnswer = true
                sonotaView.outcomeItemGroup = outcomeItemGroup
            }
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
    
    /*
    セクションの数を返す.
    */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    /*
    Cellが選択された際に呼び出される.
    */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let text = cell?.reuseIdentifier

        cell?.accessoryType = UITableViewCell.AccessoryType.checkmark

        // その他系が選択されている場合
        if isReAnswer && AppConst.ManSonotaStrings.contains(text!) {
            nextButton.setTitle("次へ", for: UIControl.State.normal)
        }
    }
    /*
    Cellが選択された際に呼び出される.
    */
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let text = cell?.reuseIdentifier

        cell?.accessoryType = UITableViewCell.AccessoryType.none

        // その他系が選択されている場合
        if isReAnswer && AppConst.ManSonotaStrings.contains(text!) {
            nextButton.setTitle("変更を確定して一覧へ戻る", for: UIControl.State.normal)
        }
    }
    
    /*
    テーブルに表示する配列の総数を返す.
    */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choiceValues.count
    }
    
    /*
    Cellに値を設定する.
    */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let choice = choiceValues[(indexPath as NSIndexPath).row]
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: choice)
        cell.accessoryType = UITableViewCell.AccessoryType.none
        cell.textLabel?.text = choice

        if isReAnswer && (outcomeItemGroup[appDelegate.SelectedSatisfactionNo!].filter{ $0["OutcomeChoicesAsr"].asString! == choice }).count > 0 {
            cell.isSelected = true
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            myTableView!.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        
        return cell
    }

}
