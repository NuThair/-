//
//  DetailOutcomeList.swift
//  OBQI
//
//  Created by t.o on 2017/01/13.
//  Copyright © 2017年 System. All rights reserved.
//


import UIKit

class DetailOutcomeList: UITableViewController {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    var outcomeItemGroup:[[JSON]] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")

        // DataSourceの設定をする.
        self.tableView.dataSource = self

        // Delegateを設定する.
        self.tableView.delegate = self
    }
    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let episodeID = appDelegate.SelectedOutcom?["EpisodeID"].asInt
        let outcomeID = appDelegate.SelectedOutcom?["OutcomeID"].asInt
        let outcomeKbn = Int(appDelegate.SelectedOutcomeKbn!)

        appDelegate.SelectedOutcomeDT = OutcomeCommon.getOutcomeDTInfo(episodeID: episodeID!, outcomeID: outcomeID!, outcomeKbn: outcomeKbn!)

        // outcomeItemID毎にまとめる
        outcomeItemGroup = []
        var currentOutcomeItemID = 0
        for outcomeDT in appDelegate.SelectedOutcomeDT! {
            if outcomeDT.1["OutcomeItemID"].asInt! != currentOutcomeItemID
            {
                currentOutcomeItemID = outcomeDT.1["OutcomeItemID"].asInt!
                outcomeItemGroup.append([outcomeDT.1])
            }

            else
            {
                outcomeItemGroup[outcomeItemGroup.count - 1].append(outcomeDT.1)
            }
        }

        self.tableView.reloadData()
    }

    /*
     セクションの数を返す.
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    /*
     セクションのタイトルを返す.
     */
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return AppConst.OutcomeKbnName[Int(appDelegate.SelectedOutcomeKbn!)! - 1]
    }

    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowIndex = (indexPath as NSIndexPath).row

        appDelegate.SelectedSatisfactionNo = rowIndex // 最初の問題からスタートする

        let outcomeKbn = (self.appDelegate.SelectedOutcomeKbn)!
        let outcomeListByKbn = appDelegate.MstOutcomeList?.enumerated().filter{ $0.element.1["OutcomeKbn"].asString == outcomeKbn }.map{ $0.element.1 }
        let outcome = outcomeListByKbn![appDelegate.SelectedSatisfactionNo]
        let inputKB = outcome["OutcomeInputKB"].asString!
        switch(inputKB) {
        case AppConst.InputKB.SINGLE.rawValue:
            performSegue(withIdentifier: "toDetailOutcomeSingle",sender: self)
            break
        case AppConst.InputKB.MULTI.rawValue:
            performSegue(withIdentifier: "toDetailOutcomeMulti",sender: self)
            break
        case AppConst.InputKB.INPUT.rawValue:
            performSegue(withIdentifier: "toDetailOutcomeInput",sender: self)
            break
        case AppConst.InputKB.NPS.rawValue:
            performSegue(withIdentifier: "toDetailOutcomeNPS",sender: self)
            break
        default:
            // alert
            AppCommon.alertMessage(controller: self, title: "エラー", message: "画面の表示に失敗しました。")
            break
        }

        // 選択を外す
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    /*
     * 画面遷移
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        switch(segue.identifier!) {
        case "toDetailOutcomeSingle":
            (segue.destination as! DetailManSingle).isReAnswer = true
            (segue.destination as! DetailManSingle).outcomeItemGroup = outcomeItemGroup
            break
        case "toDetailOutcomeMulti":
            (segue.destination as! DetailManMulti).isReAnswer = true
            (segue.destination as! DetailManMulti).outcomeItemGroup = outcomeItemGroup
            break
        case "toDetailOutcomeInput":
            (segue.destination as! DetailManText).isReAnswer = true
            (segue.destination as! DetailManText).outcomeItemGroup = outcomeItemGroup
            break
        case "toDetailOutcomeNPS":
            (segue.destination as! DetailManNPS).isReAnswer = true
            (segue.destination as! DetailManNPS).outcomeItemGroup = outcomeItemGroup
            break
        default:
            break
        }
    }

    /*
     テーブルに表示する配列の総数を返す.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return outcomeItemGroup.count
    }

    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "MyCell")
        let index = (indexPath as NSIndexPath).row

        // 調査項目
        cell.textLabel?.text = (appDelegate.MstOutcomeList?.enumerated()
            .filter{ $0.element.1["OutcomeItemID"].asInt! == outcomeItemGroup[index][0]["OutcomeItemID"].asInt! }
            .first.map{ $0.element.1["OutcomeItemAbbreviatedName"].asString })!

        // 回答内容
        var outcomeText = ""
        for outcomeItemJson in outcomeItemGroup[index] {
            // その他系の回答は改行して表示
            if outcomeItemJson["CommentInputFlg"].asString! == "1" {
                outcomeText = outcomeText.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                outcomeText += "\n"
            }

            outcomeText += "\(outcomeItemJson["OutcomeChoicesAsr"].asString!),"
        }
        cell.detailTextLabel?.text = outcomeText.trimmingCharacters(in: CharacterSet.punctuationCharacters)

        // 医療機関のみ修正可能
        if appDelegate.SelectedOutcomeKbn == AppConst.OutcomeKbn.MEDICAL.rawValue {
            // 右矢印
            UITableViewCell.AccessoryType.disclosureIndicator
        } else {
            // 選択不可
            self.tableView.allowsSelection = false
        }

        return cell
    }
    
}
