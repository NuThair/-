//
//  ModalKartePlanDTListSelect.swift
//  OBQI
//
//  Created by t.o on 2017/05/22.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class ModalKartePlanDTListSelect: UITableViewController, UIPopoverPresentationControllerDelegate {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    let karteCommon = KarteCommon()

    var mySections = [Int]()
    var myItemsBySection:[[AppConst.KarteMenuDTParamsFormat?]] = []

    @IBOutlet weak var myNaviBar: UINavigationItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")

        // DataSourceの設定をする.
        self.tableView.dataSource = self

        // Delegateを設定する.
        self.tableView.delegate = self

        // 複数選択可
        self.tableView.allowsMultipleSelection = true

        // タイトル設定
        myNaviBar.title = appDelegate.MenuParams.MenuHD.MenuSetName


        // 詳細に含まれるDayをユニーク化
        let allDays = appDelegate.KartePlan?.selectableDTData.map{
            $0.Day!
        }
        let orderedDays = NSOrderedSet(array: allDays!)
        mySections = (orderedDays.array as! [Int]).sorted(by: <)

        // 日程毎にBLogIDを格納
        myItemsBySection = []
        mySections.forEach{ (day) -> Void in
            let filterdItems = appDelegate.KartePlan?.selectableDTData.filter{ $0.Day! == day }
            var appdenItem:[AppConst.KarteMenuDTParamsFormat?] = []
            filterdItems?.forEach{
                appdenItem.append($0)
            }

            myItemsBySection.append(appdenItem)
        }

        // DTが0件の時は、空の「1回目」を表示しておく
        if mySections.count == 0 {
            // データ挿入
            mySections.append(1)
            myItemsBySection.append([])
        }
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
        return "\(String(mySections[section]))回目"
    }

    /*
     テーブルに表示する配列の総数を返す.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myItemsBySection[section].count
    }

    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "MyCell")
        let section = (indexPath as NSIndexPath).section
        let index = (indexPath as NSIndexPath).row

        // 新規追加されたばかりの日程はスキップ
        if myItemsBySection[section].count <= 0 {
            return cell
        }

        // 対応する日程に一致するデータを表示
        let menuGroupID = myItemsBySection[section][index]?.MenuGroupID!
        let day = myItemsBySection[section][index]?.Day!
        let bLogGroupID = myItemsBySection[section][index]?.BLogGroupID!
        let bLogSubGroupID = myItemsBySection[section][index]?.BLogSubGroupID!
        let orderNo = myItemsBySection[section][index]?.OrderNo!

        cell.textLabel?.text = appDelegate.MstBusinessLogSubHDList?
            .filter{ $0.1["BLogGroupID"].asInt! == bLogGroupID && $0.1["BLogSubGroupID"].asInt! == bLogSubGroupID }
            .first.map{ $0.1["BLogSubGroupName"].asString! }

        // 選択済みにする
        let DTCount = appDelegate.KartePlan?.newSelectedData.filter{
            $0.MenuGroupID == menuGroupID
                && $0.Day == day
                && $0.BLogGroupID == bLogGroupID
                && $0.BLogSubGroupID == bLogSubGroupID
                && $0.OrderNo == orderNo
            }.count
        if DTCount != nil && DTCount! > 0 {
            cell.isSelected = true
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }

        return cell
    }

    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let section = (indexPath as NSIndexPath).section
        let index = (indexPath as NSIndexPath).row

        // 選択
        selectAction()(section, index)

        cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
    }
    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let section = (indexPath as NSIndexPath).section
        let index = (indexPath as NSIndexPath).row

        // 解除
        deSelectAction()(section, index)

        cell?.accessoryType = UITableViewCell.AccessoryType.none
    }

    // 選択
    private func selectAction() -> ((Int, Int) -> Void) {
        return { (groupIndex: Int, itemIndex: Int) -> Void in
            // 選択済の場合はスキップ
            let isExist = self.appDelegate.KartePlan?.newSelectedData.filter{
                $0.MenuGroupID == self.myItemsBySection[groupIndex][itemIndex]?.MenuGroupID
                    && $0.Day == self.myItemsBySection[groupIndex][itemIndex]?.Day
                    && $0.BLogGroupID == self.myItemsBySection[groupIndex][itemIndex]?.BLogGroupID
                    && $0.BLogSubGroupID == self.myItemsBySection[groupIndex][itemIndex]?.BLogSubGroupID
                    && $0.OrderNo == self.myItemsBySection[groupIndex][itemIndex]?.OrderNo
                }.first

            if isExist == nil {
                self.appDelegate.KartePlan?.newSelectedData.append(self.myItemsBySection[groupIndex][itemIndex]!)
            }
        }
    }

    // 解除
    private func deSelectAction() -> ((Int, Int) -> Void) {
        return { (groupIndex: Int, itemIndex: Int) -> Void in
            // 選択解除された値を除外
            let DTIndex = self.appDelegate.KartePlan?.newSelectedData.enumerated().filter{
                $1.MenuGroupID == self.myItemsBySection[groupIndex][itemIndex]?.MenuGroupID
                    && $1.Day == self.myItemsBySection[groupIndex][itemIndex]?.Day
                    && $1.BLogGroupID == self.myItemsBySection[groupIndex][itemIndex]?.BLogGroupID
                    && $1.BLogSubGroupID == self.myItemsBySection[groupIndex][itemIndex]?.BLogSubGroupID
                    && $1.OrderNo == self.myItemsBySection[groupIndex][itemIndex]?.OrderNo
                }
                .map{ $0.offset }
                .first

            if DTIndex != nil {
                self.appDelegate.KartePlan?.newSelectedData.remove(at: DTIndex!)
            }
        }
    }

    // 一括選択
    @IBAction func ClickAllSelect(_ sender: UIBarButtonItem) {
        karteCommon.allSelect(tableView, action: selectAction())
    }

    // 一括解除
    @IBAction func ClickAllDeSelect(_ sender: UIBarButtonItem) {
        karteCommon.allDeSelect(tableView, action: deSelectAction())
    }
}
