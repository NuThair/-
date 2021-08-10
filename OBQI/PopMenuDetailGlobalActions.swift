//
//  DetailMenuList.swift
//  OBQI
//
//  Created by t.o on 2017/01/27.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class PopMenuDetailGlobalActions: UITableViewController {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()

    let mySections = ["メニュー", "ステータス変更"]
    let myItems = [
        ["アセスメント比較", "介入計画基本情報設定", "IC一覧", "治療計画レポート"],
        ["介入計画未確定に戻す", "介入計画確定", "介入計画完了", "削除"],
    ]

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
        print("viewWillApper")
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /*
     セクションの数を返す.
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return mySections.count
    }

    /*
     セクションのタイトルを返す.
     */
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return mySections[section]
    }

    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = (indexPath as NSIndexPath).section
        let index = (indexPath as NSIndexPath).row

        // 選択を外す
        self.tableView.deselectRow(at: indexPath, animated: true)

        // 実行不可
        if !judgeCanExecute(section, index) {
            return
        }

        switch section {
        case 0: // メニュー
            switch index {
            case 0: // アセスメント比較
                clickMoveToAssessmentComparison()

            case 1: // 介入計画基本情報設定
                clickMoveToEditMenu()

            case 2: // IC一覧
                clickMoveToICList()

            case 3: // 治療計画レポート
                clickMoveToAmountReport()

            default: break
            }

        case 1: // ステータス変更
            switch index {
            case 0: // 介入計画未確定に戻す
                clickPending()

            case 1: // 介入計画確定
                clickDetermine()

            case 2: // 介入計画完了
                clickComp()

            case 3: // 削除
                clickDelete()

            default: break
            }

        default: break
        }
    }

    /*
     テーブルに表示する配列の総数を返す.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if myItems.indices.contains(section) {
            return self.myItems[section].count
        }

        return 0
    }

    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MyCell")

        let section = (indexPath as NSIndexPath).section
        let index = (indexPath as NSIndexPath).row

        let value = myItems[section][index]

        cell.textLabel?.text = value
        cell.textLabel?.textAlignment = NSTextAlignment.center
        if value == "削除" {
            cell.textLabel?.textColor = UIColor.textRed()
        } else {
            cell.textLabel?.textColor = UIColor.textBlue()
        }

        if !judgeCanExecute(section, index) {
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.textLabel?.textColor = UIColor.gray
        }

        return cell
    }


    // アセスメント比較押下時のアクション
    private func clickMoveToAssessmentComparison() {
        // 閉じる
        self.dismiss(animated: true, completion: nil)

        moveSecondaryView(segueIdentifier: "SegueDetailMenuAssessmentComparison")
    }

    // 介入計画基本情報設定押下時のアクション
    private func clickMoveToEditMenu() {
        // 編集モード
        appDelegate.CurrentMenuEditMode = AppConst.Mode.UPDATE

        // 閉じる
        self.dismiss(animated: true, completion: nil)

        // 変更が保存されていない状態で詳細画面に表示されるのを防ぐ
        appDelegate.MenuParamsTmp = appDelegate.MenuParams.copy()
        moveSecondaryView(segueIdentifier: "SegueDetailMenuEdit")
    }

    // IC登録押下時のアクション
    private func clickMoveToICList() {
        // 閉じる
        self.dismiss(animated: true, completion: nil)

        moveSecondaryView(segueIdentifier: "SegueDetailMenuICList")
    }

    // 治療計画レポート押下時のアクション
    private func clickMoveToAmountReport() {
        // 閉じる
        self.dismiss(animated: true, completion: nil)

        moveSecondaryView(segueIdentifier: "SegueModalMenuAmountReport")
    }


    // 介入計画未確定に戻す押下時のアクション
    private func clickPending() {
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
                    print("Pending")

                    let url = "\(AppConst.URLPrefix)menu/PostPendingMenu/\(self.appDelegate.MenuParams.MenuHD.MenuGroupID!)"

                    _ = self.appCommon.postSynchronous(url, params: [:])

                    // 閉じる
                    self.dismiss(animated: true, completion: nil)

                    // 介入計画画面を初期表示状態にする
                    let parentSplitView = self.presentingViewController as! UISplitViewController
                    parentSplitView.loadView()
                    AppCommon.changeDetailView(sb: UIStoryboard(name: "Menu", bundle: nil), sv: parentSplitView, storyBoardID: "MenuDetailStartView")
            })
        )
        
        AppCommon.alertAnyAction(controller: self, title: "確認", message: "介入計画を未確定に戻しますか？", actionList: actionList)
    }


    // 介入計画確定押下時のアクション
    private func clickDetermine() {
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
                    print("Determine")

                    let url = "\(AppConst.URLPrefix)menu/PostDetermineMenu/\(self.appDelegate.MenuParams.MenuHD.MenuGroupID!)"

                    _ = self.appCommon.postSynchronous(url, params: [:])

                    // 閉じる
                    self.dismiss(animated: true, completion: nil)

                    // 介入計画画面を初期表示状態にする
                    let parentSplitView = self.presentingViewController as! UISplitViewController
                    parentSplitView.loadView()
                    AppCommon.changeDetailView(sb: UIStoryboard(name: "Menu", bundle: nil), sv: parentSplitView, storyBoardID: "MenuDetailStartView")
            })
        )

        AppCommon.alertAnyAction(controller: self, title: "確認", message: "介入計画を確定しますか？", actionList: actionList)
    }

    // 介入計画完了押下時のアクション
    private func clickComp() {
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
                    print("Comp")

                    let url = "\(AppConst.URLPrefix)menu/PostCompMenu/\(self.appDelegate.MenuParams.MenuHD.MenuGroupID!)"

                    _ = self.appCommon.postSynchronous(url, params: [:])

                    // 閉じる
                    self.dismiss(animated: true, completion: nil)

                    // 介入計画画面を初期表示状態にする
                    let parentSplitView = self.presentingViewController as! UISplitViewController
                    parentSplitView.loadView()
                    AppCommon.changeDetailView(sb: UIStoryboard(name: "Menu", bundle: nil), sv: parentSplitView, storyBoardID: "MenuDetailStartView")
            })
        )

        AppCommon.alertAnyAction(controller: self, title: "確認", message: "介入計画を完了しますか？", actionList: actionList)
    }

    // 削除押下時のアクション
    private func clickDelete() {
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
                    print("Delete")

                    let url = "\(AppConst.URLPrefix)menu/DeleteSelectedMenuHD/\(self.appDelegate.MenuParams.MenuHD.MenuGroupID!)"

                    _ = self.appCommon.deleteSynchronous(url, params: [:])

                    // 閉じる
                    self.dismiss(animated: true, completion: nil)

                    // 介入計画画面を初期表示状態にする
                    let parentSplitView = self.presentingViewController as! UISplitViewController
                    parentSplitView.loadView()
                    AppCommon.changeDetailView(sb: UIStoryboard(name: "Menu", bundle: nil), sv: parentSplitView, storyBoardID: "MenuDetailStartView")
            })
        )

        AppCommon.alertAnyAction(controller: self, title: "確認", message: "本当に削除してよろしいですか？", actionList: actionList)
    }

    // 遷移元ビュー取得
    private func getParentView() -> UIViewController? {
        let parentSplitView = self.presentingViewController as! UISplitViewController
        let parentNavi = parentSplitView.viewControllers[1] as! UINavigationController
        let parentView = parentNavi.topViewController

        return parentView
    }

    // 画面遷移用ファンクション
    private func moveSecondaryView(segueIdentifier: String) {
        let parentView = getParentView()
        parentView?.performSegue(withIdentifier: segueIdentifier, sender: parentView)
    }

    // 実行可否判定
    private func judgeCanExecute(_ sectionIndex: Int, _ itemIndex: Int) -> Bool {
        var res = true
        switch sectionIndex {
        case 0: // メニュー
            switch itemIndex {
            case 0: // アセスメント比較
                // 常にenabled
                break

            case 1: // 介入計画基本情報設定
                // 未確定以外の場合はdisabled
                if appDelegate.MenuParams.MenuHD.MenuStatus! != AppConst.MenuStatus.PENDING.rawValue {
                    res = false
                }

            case 2: // IC一覧
                // 完了の場合はdisabled
                if appDelegate.MenuParams.MenuHD.MenuStatus! == AppConst.MenuStatus.COMP.rawValue {
                    res = false
                }

            case 3: // 治療計画レポート
                // 常にenabled
                break

            default: break
            }

        case 1: // ステータス変更
            switch itemIndex {
            case 0: // 介入計画未確定に戻す
                // 確定以外の場合はdisabled
                if appDelegate.MenuParams.MenuHD.MenuStatus! != AppConst.MenuStatus.DETERMINE.rawValue {
                    res = false
                }

            case 1: // 介入計画確定
                // 未確定以外の場合はdisabled
                if appDelegate.MenuParams.MenuHD.MenuStatus! != AppConst.MenuStatus.PENDING.rawValue {
                    res = false
                }

            case 2: // 介入計画完了
                // 確定以外の場合はdisabled
                if appDelegate.MenuParams.MenuHD.MenuStatus! != AppConst.MenuStatus.DETERMINE.rawValue {
                    res = false
                }

            case 3: // 削除
                // 未確定以外の場合はdisabled
                if appDelegate.MenuParams.MenuHD.MenuStatus! != AppConst.MenuStatus.PENDING.rawValue {
                    res = false
                }
                
            default: break
            }
            
        default: break
        }

        return res
    }

}


