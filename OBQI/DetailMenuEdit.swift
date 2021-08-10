//
//  DetailMenuList.swift
//  OBQI
//
//  Created by t.o on 2017/01/27.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class DetailMenuEdit: UITableViewController {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()

    let myItems: NSArray = ["名称", "担当者", "臨床プログラム", "傷病名", "エピソード"]

    // 保存ボタン活性状態
    var editIsEnabled = true

    @IBOutlet weak var myNaviBar: UINavigationItem!
    @IBOutlet weak var editButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")

        // DataSourceの設定をする.
        self.tableView.dataSource = self

        // Delegateを設定する.
        self.tableView.delegate = self

        // モードにより切り替え
        switch appDelegate.CurrentMenuEditMode! {
        case AppConst.Mode.CREATE:
            myNaviBar.title = "介入計画作成"
            editButton.title = "作成"
            editIsEnabled = true
            break

        case AppConst.Mode.UPDATE:
            myNaviBar.title = "介入計画編集"
            editButton.title = "保存"
            editIsEnabled = false
            break

        default: break
        }
    }

    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillApper")

        // 変更確認
        if appDelegate.CurrentMenuEditMode! == AppConst.Mode.UPDATE {
            editIsEnabled = appDelegate.MenuParams.isDifferent(otherObject: appDelegate.MenuParamsTmp)
        }

        // 保存ボタン活性状態
        editButton.isEnabled = editIsEnabled

        // テーブル内容再描画
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

        cell.textLabel?.text = "\(myItems[(indexPath as NSIndexPath).row])"
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator

        switch index {
        case 0: // 名称
            cell.detailTextLabel?.text = appDelegate.MenuParamsTmp.MenuHD.MenuSetName

        case 1: // 担当者
            cell.detailTextLabel?.text = appDelegate.MenuParamsTmp.MenuHD.MenuSetStaffNameKana

        case 2: // 臨床プログラム
            cell.detailTextLabel?.text = (appDelegate.MenuParamsTmp.Program.map{ $0!.MenuName! }).joined(separator: ",")

            // モードにより切り替え
            switch appDelegate.CurrentMenuEditMode! {
            case AppConst.Mode.CREATE:
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                break
            case AppConst.Mode.UPDATE:
                cell.accessoryType = UITableViewCell.AccessoryType.none
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                break
            default: break
            }

        case 3: // 傷病名
            cell.detailTextLabel?.text = (appDelegate.MenuParamsTmp.Disease.map{ $0!.MainName! }).joined(separator: ",")

        case 4: // エピソード
            cell.detailTextLabel?.text = appDelegate.MenuParamsTmp.Episode.EpisodeName

        default: break
        }

        return cell
    }

    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = (indexPath as NSIndexPath).row

        if index == 0 {
            performSegue(withIdentifier: "SegueDetailMenuSetNameInput", sender: self)
        } else if index == 1 {
            performSegue(withIdentifier: "SegueDetailMenuSetStaffSelect", sender: self)
        } else if index == 2 {
            // モードにより切り替え
            if appDelegate.CurrentMenuEditMode == AppConst.Mode.CREATE{
                performSegue(withIdentifier: "SegueDetailMenuProgramSelect", sender: self)
            }
        } else if index == 3 {
            performSegue(withIdentifier: "SegueDetailMenuDiseaseSelect", sender: self)
        } else if index == 4 {
            performSegue(withIdentifier: "SegueDetailMenuEpisodeSelect", sender: self)
        }
    }

    /*
     介入計画作成or上書き
     */
    @IBAction func clickEdit(_ sender: AnyObject) {
        // 必須項目チェック
        if AppCommon.isNilOrEmpty(appDelegate.MenuParamsTmp.MenuHD.MenuSetName) {
            AppCommon.alertMessage(controller: self, title: "エラー", message: "名称を入力してください。")
            return
        }
        if AppCommon.isNilOrEmpty(appDelegate.MenuParamsTmp.MenuHD.MenuSetStaffID) {
            AppCommon.alertMessage(controller: self, title: "エラー", message: "担当者を選択してください。")
            return
        }
        if appDelegate.MenuParamsTmp.Program.count == 0 {
            AppCommon.alertMessage(controller: self, title: "エラー", message: "臨床プログラムを選択してください。")
            return
        }
        if appDelegate.MenuParamsTmp.Disease.count == 0 {
            AppCommon.alertMessage(controller: self, title: "エラー", message: "傷病名を選択してください。")
            return
        }
        if appDelegate.MenuParamsTmp.Episode.EpisodeID == nil {
            AppCommon.alertMessage(controller: self, title: "エラー", message: "エピソードを選択してください。")
            return
        }

        // モードにより切り替え
        var modeText = ""
        var url = ""
        var apiCall = { (url: String!, params: [String: AnyObject]) -> (result: String?, errCode: String?) in return ("", "") }

        switch appDelegate.CurrentMenuEditMode! {
        case AppConst.Mode.CREATE:
            modeText = "作成"
            url = "\(AppConst.URLPrefix)menu/PostSelectedMenuHD"
            apiCall = { (url: String!, params: [String: AnyObject]) -> (result: String?, errCode: String?) in
                return self.appCommon.postSynchronous(url, params: params)
            }
            break
        case AppConst.Mode.UPDATE:
            modeText = "変更"
            url = "\(AppConst.URLPrefix)menu/PutSelectedMenuHD"
            apiCall = { (url: String!, params: [String: AnyObject]) -> (result: String?, errCode: String?) in
                return self.appCommon.putSynchronous(url, params: params)
            }
            break
        default: break
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
                    print("Save")

                    // 傷病と修飾語
                    var diseaseList: [[String: AnyObject]] = []
                    self.appDelegate.MenuParamsTmp.Disease.forEach{

                        var modifierList: [[String: AnyObject]] = []
                        $0?.Modifiers.forEach{
                            let mdfyInfo:[String: AnyObject] = [
                                "MdfyNumber":   $0?.MdfyNumber! as AnyObject,
                                "MdfyKbn":      $0?.MdfyKbn! as AnyObject,
                                "MdfyName":     $0?.MdfyName! as AnyObject
                            ]
                            modifierList.append(mdfyInfo)
                        }

                        let mnameInfo:[String: AnyObject] = [
                            "MainNumber":     $0?.MainNumber!  as AnyObject,
                            "MainName":       $0?.MainName!  as AnyObject,
                            "MdfyInfoList":   modifierList  as AnyObject
                        ]

                        diseaseList.append(mnameInfo)
                    }

                    // プログラム
                    var programList:[[String: AnyObject]] = []
                    self.appDelegate.MenuParamsTmp.Program.forEach{
                        let menuInfo:[String: AnyObject] = [
                            "MenuID": $0?.MenuID! as AnyObject
                        ]
                        programList.append(menuInfo)
                    }

                    var params:[String: AnyObject]  = [
                        "CustomerID":       self.appDelegate.SelectedCustomer!["CustomerID"].asString! as AnyObject,
                        "MenuSetName":      self.appDelegate.MenuParamsTmp.MenuHD.MenuSetName!  as AnyObject,
                        "MenuSetStaffID":   self.appDelegate.MenuParamsTmp.MenuHD.MenuSetStaffID!  as AnyObject,
                        "EpisodeID":        self.appDelegate.MenuParamsTmp.Episode.EpisodeID! as AnyObject,
                        "MnameInfoList":    diseaseList  as AnyObject,
                        "MenuInfoList":     programList  as AnyObject
                    ]
                    if self.appDelegate.MenuParams.MenuHD.MenuGroupID != nil {
                        params["MenuGroupID"] = self.appDelegate.MenuParams.MenuHD.MenuGroupID! as AnyObject
                    }

                    let res = apiCall(url, params)
                    if !AppCommon.isNilOrEmpty(res.errCode) {
                        print("エラー")
                    }

                    // 作成の場合は戻り値を格納
                    if self.appDelegate.CurrentMenuEditMode == AppConst.Mode.CREATE {
                        let createdMenuHDJson = JSON(string: res.result!)
                        self.appDelegate.MenuParams.MenuHD.MenuGroupID = createdMenuHDJson["MenuGroupID"].asInt!
                    }
                    
                    // 介入計画画面を一旦初期表示状態にする
                    let splitViewController = self.splitViewController
                    AppCommon.changeDetailView(sb: UIStoryboard(name: "Menu", bundle: nil), sv: splitViewController, storyBoardID: "MenuDetailStartView")
                    
                    // 追加された介入計画を選択済みにする
                    splitViewController?.loadView()
            })
        )

        AppCommon.alertAnyAction(controller: self, title: "確認", message: "介入計画を\(modeText)しますか？", actionList: actionList)
    }

}


