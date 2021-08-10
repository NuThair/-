//
//  DetailMenuList.swift
//  OBQI
//
//  Created by t.o on 2017/01/27.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class PopMenuDetailSectionActions: UITableViewController {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()

    let myItems = ["前回日程追加", "次回日程追加", "メニュー追加", "削除"]

    enum InsertPosition : String {
        case BEFORE = "前回日程"
        case AFTER = "次回日程"
    }

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
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = (indexPath as NSIndexPath).row

        // 選択を外す
        self.tableView.deselectRow(at: indexPath, animated: true)

        // 実行不可
        if !judgeCanExecute(index) {
            return
        }

        switch index {
        case 0: // 前回日程追加
            // 閉じる
            self.dismiss(animated: true, completion: nil)

            // 日程追加
            insertData(InsertPosition.BEFORE)

        case 1: // 次回日程追加
            // 閉じる
            self.dismiss(animated: true, completion: nil)

            // 日程追加
            insertData(InsertPosition.AFTER)

        case 2: // メニュー追加
            // 閉じる
            self.dismiss(animated: true, completion: nil)

            // メニュー追加モーダル表示
            moveSecondaryView(segueIdentifier: "SegueModalMenuAdd")

        case 3: // 削除
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

                        // 閉じる
                        self.dismiss(animated: true, completion: nil)

                        let parentView = (self.getParentView() as! DetailMenuDetail)
                        parentView.mySections.remove(at: parentView.selectedRow!)
                        parentView.myItemsBySection.remove(at: parentView.selectedRow!)
                        parentView.tableView.reloadData()

                        // 保存ボタン活性化
                        parentView.changeSaveArea(DetailMenuDetail.SaveAreaMode.UNSAVED)
                })
            )
            
            AppCommon.alertAnyAction(controller: self, title: "確認", message: "本当に削除してよろしいですか？", actionList: actionList)

        default: break
        }
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
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MyCell")
        let index = (indexPath as NSIndexPath).row

        let value = myItems[index]

        cell.textLabel?.text = value
        cell.textLabel?.textAlignment = NSTextAlignment.center
        if value == "削除" {
            cell.textLabel?.textColor = UIColor.textRed()
        } else {
            cell.textLabel?.textColor = UIColor.textBlue()
        }

        if !judgeCanExecute(index) {
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.textLabel?.textColor = UIColor.gray
        }
        
        return cell
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

    // 日程挿入
    private func insertData(_ insertPosition: InsertPosition) {
        let parentView = (getParentView() as! DetailMenuDetail)

        // ボタンが押された行の日程
        let selectedDay = parentView.mySections[parentView.selectedRow!]

        // 挿入位置の計算
        var insertSection:Int?
        var insertDay:Int?
        switch insertPosition {
        case .BEFORE:
            insertSection = parentView.selectedRow!
            insertDay = selectedDay

            // 前日の存在チェック(0日目は作成不可)
            if selectedDay > 1 && !parentView.mySections.contains(selectedDay - 1) {
                insertDay = selectedDay - 1
            }

        case .AFTER:
            insertSection = parentView.selectedRow! + 1
            insertDay = selectedDay + 1
        }

        if insertSection == nil || insertDay == nil {
            return
        }

        // データ挿入
        parentView.mySections.insert(insertDay!, at: insertSection!)
        parentView.myItemsBySection.insert([], at: insertSection!)

        // 挿入の結果、日程が被った場合ずらす
        var preDay = 0
        parentView.mySections.enumerated().forEach{ (key, value) -> Void in
            // 既存日程
            var currentDay = value

            if currentDay == preDay {
                currentDay = preDay + 1

                parentView.mySections[key] = currentDay
                parentView.myItemsBySection[key] = parentView.myItemsBySection[key].map{ (value) -> DetailMenuDetail.DMDMenuDTParamsFormat? in
                    var DTdata = value
                    DTdata?.Day = currentDay
                    return DTdata
                }
            }

            // 最終挿入日
            preDay = currentDay
        }

        // 親画面リロード
        parentView.tableView.reloadData()

        // 保存ボタン活性化
        parentView.changeSaveArea(DetailMenuDetail.SaveAreaMode.UNSAVED)
    }

    // 実行可否判定
    private func judgeCanExecute(_ itemIndex: Int) -> Bool {
        var res = true
        switch itemIndex {
        case 0: // 前回日程追加
            // 未確定以外の場合はdisabled
            if appDelegate.MenuParams.MenuHD.MenuStatus! != AppConst.MenuStatus.PENDING.rawValue {
                res = false
            }

        case 1: // 次回日程追加
            // 未確定以外の場合はdisabled
            if appDelegate.MenuParams.MenuHD.MenuStatus! != AppConst.MenuStatus.PENDING.rawValue {
                res = false
            }

        case 2: // メニュー追加
            // 未確定以外の場合はdisabled
            if appDelegate.MenuParams.MenuHD.MenuStatus! != AppConst.MenuStatus.PENDING.rawValue {
                res = false
            }

        case 3: // 削除
            // 未確定以外の場合はdisabled
            if appDelegate.MenuParams.MenuHD.MenuStatus! != AppConst.MenuStatus.PENDING.rawValue {
                res = false
            }

        default: break
        }

        return res
    }
}


