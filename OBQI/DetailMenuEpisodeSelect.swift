//
//  DetailMenuEpisodeSelect.swift
//  OBQI
//
//  Created by t.o on 2017/02/09.
//  Copyright © 2017年 System. All rights reserved.
//


import UIKit

class DetailMenuEpisodeSelect: UITableViewController {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()

    var openEpisodeList = [JSON]()

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

        // api取得事前処理
        let customerID = appDelegate.SelectedCustomer!["CustomerID"].asString!

        var url:String
        var res:(result: String?, errCode: String?)

        // 介入計画ヘッダ一覧取得
        url = "\(AppConst.URLPrefix)episode/GetOpenEpisodeList/\(customerID)"
        res = appCommon.getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }
        let openEpisodeJson = JSON(string: res.result!) // JSON読み込み
        if openEpisodeJson.length == 0 {
            openEpisodeList = []
        } else {
            openEpisodeList = []
            for i in 0 ..< openEpisodeJson.length {
                let json : JSON? = openEpisodeJson[i]
                openEpisodeList.append(json!)
            }
        }

        // 再描画
        self.tableView.reloadData()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /*
     テーブルに表示する配列の総数を返す.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return openEpisodeList.count
    }

    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "MyCell")
        let index = (indexPath as NSIndexPath).row

        let episodeID = openEpisodeList[index]["EpisodeID"].asInt!
        let episodeName = openEpisodeList[index]["EpisodeName"].asString!
        let startDateTime = AppCommon.getDateFormat(date: openEpisodeList[index]["CreateDateTime"].asDate, format: "yyyy/MM/dd HH:mm:ss")!

        cell.textLabel?.text = episodeName
        cell.detailTextLabel?.text = "開始日：\(startDateTime)"

        // 選択済み
        if episodeID == appDelegate.MenuParamsTmp.Episode.EpisodeID {
            // チェックマークをつける
            cell.isSelected = true
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            self.tableView(self.tableView, didSelectRowAt: indexPath)
        }

        return cell
    }

    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let index = (indexPath as NSIndexPath).row

        appDelegate.MenuParamsTmp.Episode.EpisodeID = openEpisodeList[index]["EpisodeID"].asInt!
        appDelegate.MenuParamsTmp.Episode.EpisodeName = openEpisodeList[index]["EpisodeName"].asString!

        // チェックマークをつける
        cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
    }
    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)

        cell?.accessoryType = UITableViewCell.AccessoryType.none
    }

    /*
     作成画面へ遷移
     */
    @IBAction func clickCreate(_ sender: AnyObject) {
        performSegue(withIdentifier: "SegueModalMenuEpisodeCreate", sender: self)
    }
}
