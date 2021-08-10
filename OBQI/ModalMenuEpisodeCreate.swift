//
//  ModalMenuEpisodeCreate.swift
//  OBQI
//
//  Created by t.o on 2017/01/26.
//  Copyright © 2017年 System. All rights reserved.
//


import UIKit

class ModalMenuEpisodeCreate: UITableViewController {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()

    let myItems = ["エピソード名称", "備考", "開始日"]

    var InputName:String?
    var InputText:String?

    @IBOutlet weak var annotation: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")

        // DataSourceの設定をする.
        self.tableView.dataSource = self

        // Delegateを設定する.
        self.tableView.delegate = self

        // 注釈
        annotation.text = "　本画面ではエピソードの基本情報だけ設定可能です。\n　ICやアウトカムの設定はエピソードで設定してください。"
    }

    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillApper")

        // テーブルデータリロード
        self.tableView.reloadData()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /*
     テーブルに表示する配列の総数を返す.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myItems.count
    }

    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "MyCell")
        let index = (indexPath as NSIndexPath).row

        cell.textLabel?.text = myItems[index]

        switch index {
        case 0: // エピソード名称
            cell.detailTextLabel?.text = InputName
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        case 1: // 備考
            cell.detailTextLabel?.text = InputText
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        case 2: // 開始日
            cell.detailTextLabel?.text = AppCommon.getDateFormat(date: Date(), format: "yyyy/MM/dd")
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
        default: break
        }

        return cell
    }

    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = (indexPath as NSIndexPath).row

        switch index {
        case 0: // エピソード名称
            performSegue(withIdentifier: "SegueMenuEpisodeNameInput", sender: self)
        case 1: // 備考
            performSegue(withIdentifier: "SegueMenuEpisodeTextInput", sender: self)
        default: break
        }
    }

    /*
     エピソードを作成し、元の画面に戻る
     */
    @IBAction func clickComp(_ sender: AnyObject) {
        // 必須項目チェック
        if AppCommon.isNilOrEmpty(InputName) {
            AppCommon.alertMessage(controller: self, title: "エラー", message: "エピソード名称を入力してください。")
            return
        }
        if AppCommon.isNilOrEmpty(InputText) {
            AppCommon.alertMessage(controller: self, title: "エラー", message: "備考を選択してください。")
            return
        }

        // アラートアクションの設定
        var actionList = [(title: String , style: UIAlertAction.Style ,action: (UIAlertAction) -> Void)]()

        // キャンセルアクション
        actionList.append(
            (
                title: "キャンセル",
                style: UIAlertAction.Style.cancel,
                action: {
                    (action: UIAlertAction!) -> Void in
                    print("Cancel")
            })
        )

        // OKアクション
        actionList.append(
            (
                title: "OK",
                style: UIAlertAction.Style.default,
                action: {
                    (action: UIAlertAction!) -> Void in
                    print("Create")

                    let customerID = self.appDelegate.SelectedCustomer!["CustomerID"].asString!
                    let shopID = String(describing: (self.appDelegate.LoginInfo?["ShopID"].asInt)!)

                    let url = "\(AppConst.URLPrefix)episode/postNewEpisode/"

                    let params: [String: AnyObject] = [
                        "ShopID": shopID as AnyObject,
                        "CustomerID": customerID as AnyObject,
                        "EpisodeName": self.InputName as AnyObject,
                        "EpisodeText": self.InputText as AnyObject
                    ]
                    let res = self.appCommon.postSynchronous(url, params: params)
                    if !AppCommon.isNilOrEmpty(res.errCode) {
                        AppCommon.alertMessage(controller: self, title: "エラー", message: "情報を更新できませんでした\nインターネット接続を確認して下さい。")
                    }

                    // 選択済みにする
                    let resultJson = JSON(string: "{\"EpisodeID\":\(res.result!)}")
                    self.appDelegate.MenuParamsTmp.Episode.EpisodeID = resultJson["EpisodeID"].asInt!

                    // 親画面リロード
                    let parentSplitView = self.presentingViewController as! UISplitViewController
                    let parentNavi = parentSplitView.viewControllers[1] as! UINavigationController
                    let parentView = parentNavi.topViewController as! DetailMenuEpisodeSelect
                    parentView.viewWillAppear(true)

                    // 閉じる
                    self.dismiss(animated: true, completion: nil)
            })
        )

        AppCommon.alertAnyAction(controller: self, title: "確認", message: "エピソードを作成しますか？", actionList: actionList)
    }

    /*
     モーダル閉じる
     */
    @IBAction func clickCancel(_ sender: AnyObject) {
        // 閉じる
        self.dismiss(animated: true, completion: nil)
    }
}
