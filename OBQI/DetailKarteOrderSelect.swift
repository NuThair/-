//
//  File2.swift
//  OBQI
//
//  Created by t.o on 2017/04/25.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class DetailKarteOrderSelect: UITableViewController {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    let karteCommon = KarteCommon()

    // 選択中オーダークラス
    var selectingIndex = 0
    var usingKarteOrder: KarteOrderClass?

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

        // 選択中オーダークラス
        usingKarteOrder = appDelegate.KarteOrderList[selectingIndex]
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
        return 1
    }

    /*
     セクション設定
     */
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let frame: CGRect = tableView.frame
        let headerView: UIView = UIButton(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        headerView.backgroundColor = UIColor.defaultSectionBackGround()

        let label = UILabel(frame: CGRect(x: 8, y: 0, width: 400, height: 48));
        label.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
        label.numberOfLines = 0
        label.text = ""
        if usingKarteOrder?.selectableHDData != nil {
            let bLogGroupID = usingKarteOrder?.selectableHDData?.BLogGroupID!
            let bLogSubGroupID = usingKarteOrder?.selectableHDData?.BLogSubGroupID!
            let groupName =  appDelegate.MstBusinessLogHDList?.filter{ $0.1["BLogGroupID"].asInt! == bLogGroupID }.first.map{ $0.1["BLogGroupName"].asString! }
            let subGroupName = appDelegate.MstBusinessLogSubHDList?.filter{ $0.1["BLogGroupID"].asInt! == bLogGroupID && $0.1["BLogSubGroupID"].asInt! == bLogSubGroupID }.first.map{ $0.1["BLogSubGroupName"].asString! }
            label.text = "【メニュー】\(groupName!)\n【サブメニュー】\(subGroupName!)"
        }
        headerView.addSubview(label)

        return headerView
    }

    /*
     テーブルに表示する配列の総数を返す.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let selectableDTData = usingKarteOrder?.selectableDTData else {
            return 0
        }

        return selectableDTData.count
    }

    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "MyCell")
        let index = (indexPath as NSIndexPath).row

        // マスタを取得する
        let mst = appDelegate.MstBusinessLogDTList?.filter{
            $0.1["BLogGroupID"].asInt! == usingKarteOrder?.selectableDTData[index].BLogGroupID
                && $0.1["BLogSubGroupID"].asInt! == usingKarteOrder?.selectableDTData[index].BLogSubGroupID
                && $0.1["BLogItemID"].asInt! == usingKarteOrder?.selectableDTData[index].BLogItemID
            }.map{ $0.1 }.first
        let mstImgPartsNo = mst?["ImgPartsNo"].asInt
        let mstBLogInputKB = mst?["BLogInputKB"].asString!

        var unitStr : String! = ""
        let unit = mst?["BLogUnit"].asString
        if !AppCommon.isNilOrEmpty(unit) {
            unitStr = " (\(unit!))"
        }

        var text = mst?["BLogAbbreviatedName"].asString!
        var value = [(usingKarteOrder?.selectableDTData[index].BLogChoicesAsr!)!].joined(separator: " , ") + unitStr

        // ImagePartsがある場合は部位名として取得する
        let parts = appDelegate.MstAssImagePartsList?.filter{
            $0.1["ImgPartsNo"].asInt! == mstImgPartsNo
            }.map{ $0.1 }.first

        if parts != nil && (parts?.length)! > 0 {
            text = "【\(parts!["ImgPartsName"].asString!)】 \(text!)"
        }

        // 画像の場合
        if mstBLogInputKB == AppConst.InputKB.PHOTO.rawValue
             || mstBLogInputKB == AppConst.InputKB.VIDEO.rawValue {
            value = "有り"
        }

        cell.textLabel?.text = text
        cell.detailTextLabel?.text = value


        // 選択済みにする
        let selectedData = usingKarteOrder?.currentSelectedData.filter{
            $0.BLogGroupID == usingKarteOrder?.selectableDTData[index].BLogGroupID
                && $0.BLogSubGroupID == usingKarteOrder?.selectableDTData[index].BLogSubGroupID
                && $0.BLogSEQNO == usingKarteOrder?.selectableDTData[index].BLogSEQNO
                && $0.BLogItemID == usingKarteOrder?.selectableDTData[index].BLogItemID
                && $0.SEQNO == usingKarteOrder?.selectableDTData[index].SEQNO
        }
        if selectedData != nil && (selectedData?.count)! > 0 {
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
            let isExist = self.usingKarteOrder?.currentSelectedData.filter{
                $0.BLogGroupID == self.usingKarteOrder?.selectableDTData[itemIndex].BLogGroupID
                    && $0.BLogSubGroupID == self.usingKarteOrder?.selectableDTData[itemIndex].BLogSubGroupID
                    && $0.BLogSEQNO == self.usingKarteOrder?.selectableDTData[itemIndex].BLogSEQNO
                    && $0.BLogItemID == self.usingKarteOrder?.selectableDTData[itemIndex].BLogItemID
                    && $0.SEQNO == self.usingKarteOrder?.selectableDTData[itemIndex].SEQNO
                }.first

            if isExist == nil {
                self.usingKarteOrder?.currentSelectedData.append(AppConst.KarteBLogDTParamsFormat(
                    BLogGroupID: self.usingKarteOrder?.selectableDTData[itemIndex].BLogGroupID,
                    BLogSubGroupID: self.usingKarteOrder?.selectableDTData[itemIndex].BLogSubGroupID,
                    BLogSEQNO: self.usingKarteOrder?.selectableDTData[itemIndex].BLogSEQNO,
                    BLogItemID: self.usingKarteOrder?.selectableDTData[itemIndex].BLogItemID,
                    SEQNO: self.usingKarteOrder?.selectableDTData[itemIndex].SEQNO,
                    BLogChoicesAsr: self.usingKarteOrder?.selectableDTData[itemIndex].BLogChoicesAsr
                ))
            }
        }
    }

    // 解除
    private func deSelectAction() -> ((Int, Int) -> Void) {
        return { (groupIndex: Int, itemIndex: Int) -> Void in
            // 選択解除された値を除外
            let orderIndex = self.usingKarteOrder?.currentSelectedData.enumerated().filter{
                $0.element.BLogGroupID == self.usingKarteOrder?.selectableDTData[itemIndex].BLogGroupID
                    && $0.element.BLogSubGroupID == self.usingKarteOrder?.selectableDTData[itemIndex].BLogSubGroupID
                    && $0.element.BLogSEQNO == self.usingKarteOrder?.selectableDTData[itemIndex].BLogSEQNO
                    && $0.element.BLogItemID == self.usingKarteOrder?.selectableDTData[itemIndex].BLogItemID
                    && $0.element.SEQNO == self.usingKarteOrder?.selectableDTData[itemIndex].SEQNO
                }
                .map{ $0.offset }
                .first

            if orderIndex != nil {
                self.usingKarteOrder?.currentSelectedData.remove(
                    at: orderIndex!
                )
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
