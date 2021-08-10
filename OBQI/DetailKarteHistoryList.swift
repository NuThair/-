//
//  DetailKarteHistoryList.swift
//  OBQI
//
//  Created by t.o on 2017/05/26.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class DetailKarteHistoryList: UITableViewController, UIPopoverPresentationControllerDelegate {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    let kcCommon = KarteCommon()

    var myItems = [JSON]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")

        // DataSourceの設定をする.
        self.tableView.dataSource = self

        // Delegateを設定する.
        self.tableView.delegate = self

        // リフレッシュコントロールを設定する。
        self.tableView.refreshControl = AppCommon.getRefreshControl(self, action: #selector(self.refreshTable), for: UIControl.Event.valueChanged)

        // 連携履歴取得
        let customerID = appDelegate.SelectedCustomer!["CustomerID"].asString!
        let url = "\(AppConst.URLPrefix)ic/GetKarteHistoryList/\(customerID)"
        let res = appCommon.getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }

        let karteHistoryListJson = JSON(string: res.result!) // JSON読み込み
        if karteHistoryListJson.length > 0 {
            myItems = karteHistoryListJson.map{ $0.1 }
        }
    }

    //テーブルビュー引っ張り時の呼び出しメソッド
    @objc func refreshTable(){
        //テーブルを再読み込みする。
        self.viewDidLoad()
        self.viewWillAppear(false)

        //読込中の表示を消す。
        self.tableView.refreshControl?.endRefreshing()
    }

    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillApper")

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
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! KarteHistoryCustomCell
        let index = (indexPath as NSIndexPath).row

        let cooperationDateTimeString = AppCommon.getDateFormat(date: myItems[index]["CooperationDateTime"].asDate, format: "yyyy/MM/dd HH:mm")!

        // 区分判定
        var kbn = ""
        switch(AppConst.KarteHistoryKbn(rawValue: myItems[index]["Kbn"].asInt!)!) {
        case AppConst.KarteHistoryKbn.SOAP:
            kbn = "SOAP"
            break
        case AppConst.KarteHistoryKbn.ORDER:
            kbn = "オーダー"
            break
        }

        // ステータス判定
        var status = ""
        switch(AppConst.CooperationStatus(rawValue: myItems[index]["CooperationStatus"].asInt!)!) {
        case AppConst.CooperationStatus.SENT:
            status = "送信済"
            break
        case AppConst.CooperationStatus.SUCCESS:
            status = "連携済"
            break
        case AppConst.CooperationStatus.ERROR:
            status = "連携エラー"
            break
        }

        cell.setMainLabel(mainText: "連携日時: \(cooperationDateTimeString)")
        cell.setSubLabel(subText: "区分: \(kbn)")
        cell.setDescriptionLabel(descriptionText: "\(status)")

        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator

        return cell
    }

    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = (indexPath as NSIndexPath).row

        appDelegate.SelectedKarteHistory = myItems[index]

        switch(AppConst.KarteHistoryKbn(rawValue: myItems[index]["Kbn"].asInt!)!) {
        case AppConst.KarteHistoryKbn.SOAP:
            performSegue(withIdentifier: "SegueDetailKarteSOAPHistory", sender: self)
            break
        case AppConst.KarteHistoryKbn.ORDER:
            performSegue(withIdentifier: "SegueDetailKarteOrderHistory", sender: self)
            break
        }
    }
}

class KarteHistoryCustomCell: UITableViewCell {

    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setMainLabel(mainText: String) {
        mainLabel.text = mainText
    }
    func setSubLabel(subText: String) {
        subLabel.text = subText
    }
    func setDescriptionLabel(descriptionText: String) {
        descriptionLabel.text = descriptionText
    }
}
