//
//  DetailMenuICList.swift
//  OBQI
//
//  Created by t.o on 2017/02/09.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class DetailMenuICList: UITableViewController {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()

    let mySections = ["選択エピソード", "ICの必要なメニュー"]

    var icJson:JSON?

    @IBOutlet weak var myNaviBar: UINavigationItem!
    @IBOutlet weak var annotation: UILabel!

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

    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillApper")

        // タイトル設定
        myNaviBar.title = "\(appDelegate.MenuParams.MenuHD.MenuSetName!) IC一覧"

        // 注意書き設定
        annotation.numberOfLines = 0
        annotation.text = "　\(appDelegate.MenuParams.MenuHD.MenuSetName!)において、以下のIC登録が必要です。\n　選択されたエピソードに必要なICが登録されていない場合、そのICは赤く表示されます。"

        // 非推奨アセスメント一覧
        let url = "\(AppConst.URLPrefix)menu/GetRequiredIC/\(appDelegate.MenuParams.MenuHD.MenuGroupID!)"
        let res = appCommon.getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }
        icJson = JSON(string: res.result!) // JSON読み込み
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
     テーブルに表示する配列の総数を返す.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: // 選択エピソード
            return 1

        case 1: // ICの必要なメニュー
            if icJson == nil {
                return 0
            }
            return (icJson?.length)!

        default:
            return 0
        }
    }

    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "MyCell")
        let section = (indexPath as NSIndexPath).section
        let index = (indexPath as NSIndexPath).row

        switch section {
        case 0: // 選択エピソード
            cell.textLabel?.text = "エピソード名称"
            cell.detailTextLabel?.text = appDelegate.MenuParams.Episode.EpisodeName

        case 1: // ICの必要なメニュー
            cell.textLabel?.text = appDelegate.MstInformedConsentList?.filter{ $0.1["ICID"].asInt! == icJson?[index]["ICID"].asInt! }.first.map{ $0.1["ICName"].asString! }

            var detailLabelArray = [String]()
            icJson?[index]["BlogGroupInfoList"].forEach{ (bLogList) -> Void in
                let bLogSubGroupName = appDelegate.MstBusinessLogSubHDList?
                    .filter{ $0.1["BLogGroupID"].asInt! == bLogList.1["BLogGroupID"].asInt! && $0.1["BLogSubGroupID"].asInt! == bLogList.1["BLogSubGroupID"].asInt! }
                    .first.map{ $0.1["BLogSubGroupName"].asString! }

                detailLabelArray.append(bLogSubGroupName!)
            }
            cell.detailTextLabel?.text = detailLabelArray.joined(separator: ",")

            // IC取れていなかったら背景色変更
            if icJson?[index]["RegisteredFlg"].asBool! == false {
                cell.backgroundColor = UIColor.bad()
            }

        default: break
        }

        return cell
    }
}
