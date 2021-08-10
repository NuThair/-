//
//  MasterBLogMenuDetailList.swift
//  OBQI
//
//  Created by t.o on 2017/03/13.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class MasterBLogSubGroupList: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()

    var mySections = [String]()
    var myItemsBySection:[[AppConst.BLogSubFormat?]] = []

    // 選択されたBLog
    var selectedBLogGroupID:Int?
    var selectedBLogSubGroupID:Int?

    // 実施済みチェック用
    var PerformedChecker:[JSON?] = []

    // 最後に選択していた行
    var lastSelectRow:(Section: Int, Index: Int)?

    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var myNaviBar: UINavigationItem!

    // タブバー
    @IBOutlet weak var tabbar: UITabBar!
    @IBOutlet weak var tb1: UITabBarItem!
    @IBOutlet weak var tb2: UITabBarItem!
    @IBOutlet weak var tb3: UITabBarItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Cell名の登録をおこなう.
        myTableView!.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")

        // DataSourceの設定をする.
        myTableView!.dataSource = self

        // Delegateを設定する.
        myTableView!.delegate = self

        // IDがセットされていない場合は計画外実施
        if appDelegate.MenuParams.MenuHD.MenuGroupID == nil {
            // タイトル設定
            myNaviBar.title = "計画外実施"
            // 全メニュー
            tabbar.selectedItem = tb3

            // タブ1,2の無効化
            tb1.isEnabled = false
            tb2.isEnabled = false

        } else {
            // タイトル設定
            myNaviBar.title = appDelegate.MenuParams.MenuHD.MenuSetName
            // 計画
            tabbar.selectedItem = tb1
        }

        // タブバーボタン設定
        tabbar.delegate = self
        let fontSize = [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)
        ]
        let position = UIOffset(horizontal: 0, vertical: -9)
        tb1.setTitleTextAttributes(fontSize, for: UIControl.State.normal)
        tb1.titlePositionAdjustment = position
        tb2.setTitleTextAttributes(fontSize, for: UIControl.State.normal)
        tb2.titlePositionAdjustment = position
        tb3.setTitleTextAttributes(fontSize, for: UIControl.State.normal)
        tb3.titlePositionAdjustment = position

        // Regist Notification（登録）
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(MasterBLogSubGroupList.reCheck), name: appDelegate.BLogNotificationName, object: nil)
    }

    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillApper")

        PerformedChecker = []
        // IDがセットされていない場合は計画外実施
        if appDelegate.MenuParams.MenuHD.MenuGroupID != nil {
            // 介入計画ヘッダ一覧取得
            let customerID = appDelegate.SelectedCustomer!["CustomerID"].asString!
            let url = "\(AppConst.URLPrefix)business/GetBusinessLogSubHDList/\(customerID)/\(appDelegate.MenuParams.MenuHD.MenuGroupID!)"
            let res = appCommon.getSynchronous(url)

            if !AppCommon.isNilOrEmpty(res.result) {
                PerformedChecker = JSON(string: res.result!).map{ $0.1 } // JSON読み込み
            }
        }

        switch tabbar.selectedItem! {
        case tb1: // 計画
            // 詳細データセット
            var menuDTList:[AppConst.MenuDTParamsFormat] = []
            let url = "\(AppConst.URLPrefix)menu/GetSelectedMenuDT/\(appDelegate.MenuParams.MenuHD.MenuGroupID!)"
            let res = appCommon.getSynchronous(url)

            if AppCommon.isNilOrEmpty(res.errCode) {
                let selectedMenuDTJson = JSON(string: res.result!) // JSON読み込み

                selectedMenuDTJson.forEach{ (selectedMenuDT) -> Void in
                    let menuDT = AppConst.MenuDTParamsFormat(
                        Day:                selectedMenuDT.1["Day"].asInt!,
                        BLogGroupID:        selectedMenuDT.1["BLogGroupID"].asInt!,
                        BLogSubGroupID:     selectedMenuDT.1["BLogSubGroupID"].asInt!,
                        OrderNo:            selectedMenuDT.1["OrderNo"].asInt!,
                        RecommendationKB:   nil
                    )

                    menuDTList.append(menuDT)
                }
            }

            // 詳細に含まれるDayをユニーク化
            let allDays = menuDTList.map{
                $0.Day!
            }
            let orderedDays = NSOrderedSet(array: allDays)
            let uniqueOrderedDays = (orderedDays.array as! [Int]).sorted(by: <)

            // 日程毎にBLogIDを格納
            mySections = []
            myItemsBySection = []
            uniqueOrderedDays.forEach{ (day) -> Void in
                let filterdItems = menuDTList.filter{ $0.Day! == day }.map{ AppConst.BLogSubFormat(BLogGroupID: $0.BLogGroupID!, BLogSubGroupID: $0.BLogSubGroupID!) }

                mySections.append("\(day)回目")
                myItemsBySection.append(filterdItems)
            }

        case tb2: // 計画&実施済み

            // 詳細データセット
            var showBLogKeyList:[String?] = []
            let url = "\(AppConst.URLPrefix)menu/GetSelectedMenuDT/\(appDelegate.MenuParams.MenuHD.MenuGroupID!)"
            let res = appCommon.getSynchronous(url)

            if AppCommon.isNilOrEmpty(res.errCode) {
                let selectedMenuDTJson = JSON(string: res.result!) // JSON読み込み

                showBLogKeyList = selectedMenuDTJson.map{ "\($0.1["BLogGroupID"].asInt!),\($0.1["BLogSubGroupID"].asInt!)" }
            }

            // 計画データに実施済みを加え、キー値でユニークにする
            showBLogKeyList = showBLogKeyList + PerformedChecker.map{ "\(($0?["BLogGroupID"].asInt)!),\(($0?["BLogSubGroupID"].asInt)!)" }
            let uniqueBLogKeyList = NSOrderedSet(array: showBLogKeyList ?? [])
            var showBLogList:[AppConst.BLogSubFormat?] = []
            (uniqueBLogKeyList.array as! [String]).forEach{
                let arrayKeys = $0.components(separatedBy: ",")
                let groupID = Int(arrayKeys[0])
                let subGroupID = Int(arrayKeys[1])
                

                if ((appDelegate.MstBusinessLogSubHDList?.filter{ $0.1["BLogGroupID"].asInt! == groupID && $0.1["BLogSubGroupID"].asInt! == subGroupID }.count)! > 0) {
                    showBLogList.append(AppConst.BLogSubFormat(BLogGroupID: groupID, BLogSubGroupID: subGroupID))
                }
            }

            mySections = [""]
            myItemsBySection = [showBLogList]

        case tb3: // 全メニュー
            mySections = (appDelegate.MstBusinessLogHDList?.map{ $0.1["BLogGroupName"].asString! })!

            // 表示内容を取得
            myItemsBySection = []
            appDelegate.MstBusinessLogHDList?.forEach{ (matchData) -> Void in
                let sectionData = appDelegate.MstBusinessLogSubHDList?
                    .filter{ $0.1["BLogGroupID"].asInt! == matchData.1["BLogGroupID"].asInt! }
                    .map{ AppConst.BLogSubFormat(BLogGroupID: $0.1["BLogGroupID"].asInt!, BLogSubGroupID: $0.1["BLogSubGroupID"].asInt!) }

                myItemsBySection.append(sectionData!)
            }

        default: break
        }

        // 再描画
        myTableView.reloadData()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /*
     セクションの数を返す.
     */
    func numberOfSections(in tableView: UITableView) -> Int {
        return mySections.count
    }

    /*
     セクションのタイトルを返す.
     */
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if mySections.count == 0 {
            return nil
        }

        return mySections[section]
    }

    /*
     テーブルに表示する配列の総数を返す.
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myItemsBySection[section].count
    }

    /*
     Cellに値を設定する.
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "MyCell")
        let section = (indexPath as NSIndexPath).section
        let index = (indexPath as NSIndexPath).row


        // 対応する日程に一致するデータを表示
        let bLogGroupID = myItemsBySection[section][index]?.BLogGroupID
        let bLogSubGroupID = myItemsBySection[section][index]?.BLogSubGroupID

        cell.textLabel?.text = appDelegate.MstBusinessLogSubHDList?
            .filter{ $0.1["BLogGroupID"].asInt! == bLogGroupID && $0.1["BLogSubGroupID"].asInt! == bLogSubGroupID }
            .first.map{ $0.1["BLogSubGroupName"].asString! }

        // 実施済みならチェックマークをつける
        let performedIndex = PerformedChecker.enumerated().filter{ $0.element?["BLogGroupID"].asInt! == bLogGroupID! && $0.element?["BLogSubGroupID"].asInt! == bLogSubGroupID! }.first.map{ $0.offset }
        if performedIndex != nil {
            // チェックマークをつける
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            // 使用済みのチェッカーを取り除く
            PerformedChecker.remove(at: performedIndex!)
        }

        // 再描画された際も選択済み状態を保つ
        if lastSelectRow != nil && lastSelectRow!.Section == section && lastSelectRow!.Index == index {
            cell.isSelected = true
            myTableView!.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }

        return cell
    }

    /*
     Cellが選択された際に呼び出される.
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = (indexPath as NSIndexPath).section
        let index = (indexPath as NSIndexPath).row

        // 選択された行をセット
        lastSelectRow = (Section: section, Index: index)

        // 選択されたBLogSubをセット
        appDelegate.SelectedBLogSub = myItemsBySection[section][index]!
        self.performSegue(withIdentifier: "SegueNavigationDetailBLog", sender: self)
    }

    // タブ選択時
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // 描画内容の変更
        lastSelectRow = nil
        self.viewWillAppear(false)
        self.myTableView.reloadData()
    }

    //　secondaryの処理状況に応じてチェックマークをつける
    @objc func reCheck() {
        self.viewWillAppear(false)
    }
    
}
