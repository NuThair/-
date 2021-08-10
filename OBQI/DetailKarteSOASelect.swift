//
//  File2.swift
//  OBQI
//
//  Created by t.o on 2017/04/25.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class DetailKarteSelectSOA: UITableViewController {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    let karteCommon = KarteCommon()

    // 表示用データの型用意
    struct inputAssListFormat {
        var assMenuGroupID:Int?
        var assMenuSubGroupID:Int?
        var trnAssDTList:[AppConst.KarteAssDTFormat]
    }
    // 入力値
    var inputAssList: [inputAssListFormat] = []

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
        myNaviBar.title = AppConst.KarteKbnName[(appDelegate.KarteSOA?.targetKarteKbn!)!]?.Full

        // グループ+サブグループ単位でセクションを分ける
        appDelegate.KarteSOA?.selectableData[(appDelegate.KarteSOA?.targetKarteKbn!)!]?.forEach { targetKarteKbnAssJson in
            let existIndex = inputAssList.enumerated()
                .filter{
                    $1.assMenuGroupID == targetKarteKbnAssJson.AssMenuGroupID
                    && $1.assMenuSubGroupID == targetKarteKbnAssJson.AssMenuSubGroupID
                }
                .map{ $0.offset }
                .first

            if existIndex == nil {
                let inputAss = inputAssListFormat(
                    assMenuGroupID: targetKarteKbnAssJson.AssMenuGroupID,
                    assMenuSubGroupID: targetKarteKbnAssJson.AssMenuSubGroupID,
                    trnAssDTList: [targetKarteKbnAssJson]
                )

                inputAssList.append(inputAss)

            } else {
                inputAssList[existIndex!].trnAssDTList.append(targetKarteKbnAssJson)
            }
        }
    }

    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
    }

    /*
     戻る
     値を更新する
     */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    /*
     セクションの数を返す.
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return inputAssList.count
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
        if inputAssList.count > 0 {
            let assGroupId = inputAssList[section].assMenuGroupID!
            let assSubGroupId = inputAssList[section].assMenuSubGroupID!
            let groupName =  appDelegate.MstAssessmentGroupList?.filter{ $0.1["AssMenuGroupID"].asInt! == assGroupId }.first.map{ $0.1["AssMenuGroupName"].asString! }
            let subGroupName = appDelegate.MstAssessmentSubGroupList?.filter{ $0.1["AssMenuGroupID"].asInt! == assGroupId && $0.1["AssMenuSubGroupID"].asInt! == assSubGroupId }.first.map{ $0.1["AssMenuSubGroupName"].asString! }
            label.text = "【メニュー】\(groupName!)\n【サブメニュー】\(subGroupName!)"
        }
        headerView.addSubview(label)

        return headerView
    }

    /*
     テーブルに表示する配列の総数を返す.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if inputAssList.count == 0 {
            return 0
        }

        return inputAssList[section].trnAssDTList.count
    }
    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "MyCell")
        let section = (indexPath as NSIndexPath).section
        let index = (indexPath as NSIndexPath).row

        let inputAss = inputAssList[section].trnAssDTList[index]

        let mst = appDelegate.MstAssessmentList?.filter{
            $0.1["AssMenuGroupID"].asInt! == inputAss.AssMenuGroupID
                && $0.1["AssMenuSubGroupID"].asInt! == inputAss.AssMenuSubGroupID
                && $0.1["AssItemID"].asInt! == inputAss.AssItemID
            }.map{ $0.1 }.first
        let mstImgPartsNo = mst?["ImgPartsNo"].asInt
        let mstAssInputKB = mst?["AssInputKB"].asString!

        var unitStr : String! = ""
        let unit = mst?["AssUnit"].asString
        if !AppCommon.isNilOrEmpty(unit) {
            unitStr = " (\(unit!))"
        }

        var text = mst?["AssAbbreviatedName"].asString!
        var value = [inputAss.AssChoicesAsr!].joined(separator: " , ") + unitStr

        // ImagePartsがある場合は部位名として取得する
        let parts = appDelegate.MstAssImagePartsList?.filter{
            $0.1["ImgPartsNo"].asInt! == mstImgPartsNo
            }.map{ $0.1 }.first

        if parts != nil && (parts?.length)! > 0 {
            text = "【\(parts!["ImgPartsName"].asString!)】 \(text!)"
        }

        // 画像の場合
        if mstAssInputKB == AppConst.InputKB.PHOTO.rawValue
            || mstAssInputKB == AppConst.InputKB.VIDEO.rawValue {
            value = "有り"
        }

        cell.textLabel?.text = text
        cell.detailTextLabel?.text = value

        // 選択済みにする
        let selectedData = appDelegate.KarteSOA?.currentSelectedData[(appDelegate.KarteSOA?.targetKarteKbn!)!]?.filter{
            $0.AssMenuGroupID == inputAss.AssMenuGroupID
            && $0.AssMenuSubGroupID == inputAss.AssMenuSubGroupID
            && $0.AssItemID == inputAss.AssItemID
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
            let isExist = self.appDelegate.KarteSOA?.currentSelectedData[(self.appDelegate.KarteSOA?.targetKarteKbn!)!]?.filter{
                $0.AssMenuGroupID == self.inputAssList[groupIndex].assMenuGroupID!
                    && $0.AssMenuSubGroupID == self.inputAssList[groupIndex].assMenuSubGroupID!
                    && $0.AssItemID == self.inputAssList[groupIndex].trnAssDTList[itemIndex].AssItemID
                }.first

            if isExist == nil {
                self.appDelegate.KarteSOA?.currentSelectedData[(self.appDelegate.KarteSOA?.targetKarteKbn!)!]?.append(self.inputAssList[groupIndex].trnAssDTList[itemIndex])
            }
        }
    }

    // 解除
    private func deSelectAction() -> ((Int, Int) -> Void) {
        return { (groupIndex: Int, itemIndex: Int) -> Void in
            // 選択解除された値を除外
            let SOAindex = self.appDelegate.KarteSOA?.currentSelectedData[(self.appDelegate.KarteSOA?.targetKarteKbn!)!]?.enumerated().filter{
                $1.AssMenuGroupID == self.inputAssList[groupIndex].assMenuGroupID!
                    && $1.AssMenuSubGroupID == self.inputAssList[groupIndex].assMenuSubGroupID!
                    && $1.AssItemID == self.inputAssList[groupIndex].trnAssDTList[itemIndex].AssItemID
                }
                .map{ $0.offset }
                .first

            if SOAindex != nil {
                self.appDelegate.KarteSOA?.currentSelectedData[(self.appDelegate.KarteSOA?.targetKarteKbn!)!]?.remove(
                    at: SOAindex!
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
