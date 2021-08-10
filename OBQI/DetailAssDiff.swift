//
//  DetailAssDiff.swift
//  OBQI
//
//  Created by t.o on 2017/04/28.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class DetailAssDiff: UITableViewController {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let assCommon = AssCommon()

    // 表示用データの型用意
    struct inputAssListFormat {
        var assMenuGroupID:Int?
        var assMenuSubGroupID:Int?
        var trnAssDTList:[JSON?]
    }
    // 入力値
    var inputAssList: [inputAssListFormat] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")

        // DataSourceの設定をする.
        self.tableView.dataSource = self

        // Delegateを設定する.
        self.tableView.delegate = self

        // 選択不可
        self.tableView.allowsSelection = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // 入力されているアセスメントを取得する
        let inputAssJson = assCommon.getInputAssessmentList()

        // 引き継ぎされた項目は除く
        let inputOnlyList = (inputAssJson?.filter{ $0.1["TakeoverFlg"].asString! == "0" }.map{ $0.1 })!

        // グループ+サブグループ単位でセクションを分ける
        inputOnlyList.forEach { inputOnlyJson in
            let existIndex = inputAssList.enumerated()
                .filter{
                    $1.assMenuGroupID == inputOnlyJson["AssMenuGroupID"].asInt!
                    && $1.assMenuSubGroupID == inputOnlyJson["AssMenuSubGroupID"].asInt!
                }
                .map{ $0.offset }
                .first

            if existIndex == nil {
                let inputAss = inputAssListFormat(
                    assMenuGroupID: inputOnlyJson["AssMenuGroupID"].asInt!,
                    assMenuSubGroupID: inputOnlyJson["AssMenuSubGroupID"].asInt!,
                    trnAssDTList: [inputOnlyJson]
                )

                inputAssList.append(inputAss)

            } else {
                inputAssList[existIndex!].trnAssDTList.append(inputOnlyJson)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
            var groupName =  appDelegate.MstAssessmentGroupList?.filter{ $0.1["AssMenuGroupID"].asInt! == assGroupId }.first.map{ $0.1["AssMenuGroupName"].asString! }
            var subGroupName = appDelegate.MstAssessmentSubGroupList?.filter{ $0.1["AssMenuGroupID"].asInt! == assGroupId && $0.1["AssMenuSubGroupID"].asInt! == assSubGroupId }.first.map{ $0.1["AssMenuSubGroupName"].asString! }
            if groupName == nil {
                groupName = ""
            }
            if subGroupName == nil {
                subGroupName = ""
            }
            label.text = "【メニュー】\(groupName!)\n【サブメニュー】\(subGroupName!)"
        }
        headerView.addSubview(label)

        return headerView
    }


    /*
     テーブルに表示する配列の総数を返す.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inputAssList[section].trnAssDTList.count
    }
    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // 選択を外す
        self.tableView.deselectRow(at: indexPath, animated: true)
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
            $0.1["AssMenuGroupID"].asInt! == inputAss?["AssMenuGroupID"].asInt!
            && $0.1["AssMenuSubGroupID"].asInt! == inputAss?["AssMenuSubGroupID"].asInt!
            && $0.1["AssItemID"].asInt! == inputAss?["AssItemID"].asInt!
        }.map{ $0.1 }.first
        let mstImgPartsNo = mst?["ImgPartsNo"].asInt
        let mstAssInputKB = mst?["AssInputKB"].asString!

        var unitStr : String! = ""
        let unit = mst?["AssUnit"].asString
        if !AppCommon.isNilOrEmpty(unit) {
            unitStr = " (\(unit!))"
        }

        var text = mst?["AssAbbreviatedName"].asString!
        var value = [inputAss!["AssChoicesAsr"].asString!].joined(separator: " , ") + unitStr

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
        return cell
    }
    /*
     戻る
     */
    override func viewWillDisappear(_ animated: Bool) {
        print("back")
        super.viewWillDisappear(animated)


    }

}
