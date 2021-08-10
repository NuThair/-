//
//  MasterProgramList.swift
//  OBQI
//
//  Created by t.o on 2017/01/26.
//  Copyright © 2017年 System. All rights reserved.
//


import UIKit

class ModalMenuAdd: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate {

    @IBOutlet weak var myTableView: UITableView!

    // タブバー
    @IBOutlet weak var tabbar: UITabBar!
    @IBOutlet weak var tb1: UITabBarItem!
    @IBOutlet weak var tb2: UITabBarItem!
    @IBOutlet weak var tb3: UITabBarItem!

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()

    var mySections:[String]?
    var myItemsBySection:[[JSON]]?

    var selectedSection:Int?
    var selectedIndex:Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Cell名の登録をおこなう.
        myTableView!.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")

        // DataSourceの設定をする.
        myTableView!.dataSource = self

        // Delegateを設定する.
        myTableView!.delegate = self

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

        // 選択済み
        if tabbar.selectedItem == nil {
            tabbar.selectedItem = tb1
        }

        // セクション設定
        myItemsBySection = []
        switch tabbar.selectedItem! {
        case tb1: // 臨床プログラム
            // 手動を抜いたリスト
            mySections = appDelegate.MstMenu?.filter{ $0.1["MenuID"].asInt! != AppConst.ManualProgram }.map{ $0.1["MenuName"].asString! }

            // 表示内容を取得
            appDelegate.MstMenu?.filter{ $0.1["MenuID"].asInt! != 0 }.forEach{ (matchData) -> Void in
                var sectionData:[JSON] = []

                let bLogIDsList = appDelegate.MstMNBLRelation?.filter{ $0.1["MenuID"].asInt! == matchData.1["MenuID"].asInt! }.map{ (bLogGroupID: $0.1["BLogGroupID"].asInt!, bLogSubGroupID: $0.1["BLogSubGroupID"].asInt!) }

                bLogIDsList?.forEach{ (bLogIDs) -> Void in
                    let appendData = appDelegate.MstBusinessLogSubHDList?.filter{ $0.1["BLogGroupID"].asInt! == bLogIDs.bLogGroupID && $0.1["BLogSubGroupID"].asInt! == bLogIDs.bLogSubGroupID }.first.map{ $0.1 }
                    if appendData != nil {
                        sectionData.append(appendData!)
                    }
                }

                myItemsBySection?.append(sectionData)
            }

        case tb2: // グループ
            mySections = appDelegate.MstBusinessLogHDList?.map{ $0.1["BLogGroupName"].asString! }

            // 表示内容を取得
            appDelegate.MstBusinessLogHDList?.forEach{ (matchData) -> Void in
                let sectionData = appDelegate.MstBusinessLogSubHDList?.filter{ $0.1["BLogGroupID"].asInt! == matchData.1["BLogGroupID"].asInt! }.map{ $0.1 }

                myItemsBySection?.append(sectionData!)
            }

        case tb3: // 辞書順
            // 表示内容を取得
            let sectionData = appDelegate.MstBusinessLogSubHDList?.sorted{ $0.1["BLogSubGroupName"].asString!.toHiragana().uppercased() < $1.1["BLogSubGroupName"].asString!.toHiragana().uppercased() }.map{ $0 }

            // 形式を整えた後、先頭の一文字目を正規表現でひらがな、カタカナ、英数字以外をを#へ振り分ける
            let getConvertedInitialText = { (text: String) -> String in
                let convertedText = text.toHiragana().uppercased()
                let convertedInitialText = convertedText.substring(to: convertedText.index(after: convertedText.startIndex))
                if convertedInitialText.pregMatche(pattern: "[a-zA-z0-9_\\p{Hiragana}\\p{Katakana}]") {
                    return convertedInitialText
                } else {
                    return "#"
                }
            }

            // セクションの作成
            var tmpSection = [String]()
            sectionData?.forEach{
                tmpSection.append(getConvertedInitialText($0.1["BLogSubGroupName"].asString!))
            }
            let orderedSections = NSOrderedSet(array: tmpSection)
            mySections = orderedSections.array as? [String]

            // 表示内容をセクション毎に格納
            mySections?.forEach{ (val) in
                myItemsBySection?.append((sectionData?.filter{ getConvertedInitialText($0.1["BLogSubGroupName"].asString!) == val }.map{ $0.1 })!)
            }

        default: break
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return mySections!.count
    }

    /*
     セクションのタイトルを返す.
     */
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return mySections?[section]
    }

    /*
     インデックスに表示するセクションのリストを取得する
     */
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        // 辞書順で並べた時だけ表示
        if tabbar.selectedItem == tb3 {
            return mySections
        }

        return nil
    }

    /*
     Cellが選択された際に呼び出される.
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let section = (indexPath as NSIndexPath).section
        let index = (indexPath as NSIndexPath).row


        // チェックマークをつける
        cell?.accessoryType = UITableViewCell.AccessoryType.checkmark

        // 選択済み行の設定
        selectedSection = section
        selectedIndex = index
    }
    /*
     Cellが選択された際に呼び出される.
     */
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)

        cell?.accessoryType = UITableViewCell.AccessoryType.none
    }

    /*
     テーブルに表示する配列の総数を返す.
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionItem = myItemsBySection?[section] else {
            return 0
        }

        return sectionItem.count
    }

    /*
     Cellに値を設定する.
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "MyCell")
        let section = (indexPath as NSIndexPath).section
        let index = (indexPath as NSIndexPath).row

        // セクション毎に処理分岐
        var textData = ""
        var textDetailData = ""

        if let itemData = myItemsBySection?[section][index] {
            textData = itemData["BLogSubGroupName"].asString!

            // tb2はセクションにグループ名が表示されている
            if tabbar.selectedItem != tb2 {
                textDetailData = appDelegate.MstBusinessLogHDList?.filter{ $0.1["BLogGroupID"].asInt! == itemData["BLogGroupID"].asInt! }.first.map{ $0.1["BLogGroupName"].asString! } ?? ""
            }
        }

        cell.textLabel?.text = textData
        cell.detailTextLabel?.text = textDetailData

        return cell
    }

    // タブ選択時
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // 描画内容の変更
        self.viewDidLoad()
        self.myTableView.reloadData()

        // 選択行のリセット
        selectedSection = nil
        selectedIndex = nil
    }

    /*
     BLogをmenuDTに追加
     */
    @IBAction func clickAdd(_ sender: Any) {
        // 必須項目チェック
        if selectedSection == nil || selectedIndex == nil {
            AppCommon.alertMessage(controller: self, title: "エラー", message: "追加するメニューを選択してください。")
            return
        }

        // 親コントローラ
        let parentSplitView = self.presentingViewController as! UISplitViewController
        let parentNavi = parentSplitView.viewControllers[1] as! UINavigationController
        let parentView = parentNavi.topViewController as! DetailMenuDetail

        let bLogGroupID = self.myItemsBySection?[selectedSection!][selectedIndex!]["BLogGroupID"].asInt!
        let bLogSubGroupID = self.myItemsBySection?[selectedSection!][selectedIndex!]["BLogSubGroupID"].asInt!

        // 推奨情報チェック
        var recommendationKB = "0"
        let appendedList = parentView.myItemsBySection[parentView.selectedRow!]
            .filter{
                $0?.BLogGroupID == bLogGroupID
                && $0?.BLogSubGroupID == bLogSubGroupID
            }

        if appendedList.count > 0 {  // DTリストの中に同様のメニューがあれば、同じ値を設定
            recommendationKB = (appendedList.first??.RecommendationKB!)!

        } else { // なければAPIで判定
            let url = "\(AppConst.URLPrefix)menu/GetMenuRecommendationInfo/\(appDelegate.MenuParams.MenuHD.MenuGroupID!)/\(bLogGroupID!)/\(bLogSubGroupID!)"
            let res = appCommon.getSynchronous(url)

            if !AppCommon.isNilOrEmpty(res.result) {
                let recommendationInfoJson = JSON(string: res.result!) // JSON読み込み
                recommendationKB = recommendationInfoJson["RecommendationKB"].asString!
            }
        }

        // 並び順
        var orderNo = 0
        if parentView.myItemsBySection[parentView.selectedRow!].count > 0 {
            orderNo = parentView.myItemsBySection[parentView.selectedRow!].last.map{ ($0?.OrderNo)! + 1 }!
        }

        // 対象日程にデータ追加
        let insertData = DetailMenuDetail.DMDMenuDTParamsFormat(
            Day:                parentView.mySections[parentView.selectedRow!],
            BLogGroupID:        bLogGroupID,
            BLogSubGroupID:     bLogSubGroupID,
            OrderNo:            orderNo,
            RecommendationKB:   recommendationKB,
            IsNew:              true
        )
        parentView.myItemsBySection[parentView.selectedRow!].append(insertData)

        // 保存ボタン活性化
        parentView.changeSaveArea(DetailMenuDetail.SaveAreaMode.UNSAVED)

        // 閉じる
        self.dismiss(animated: true, completion: nil)
        parentView.tableView.reloadData()
    }

    /*
     モーダル閉じる
     */
    @IBAction func clickCancel(_ sender: AnyObject) {
        // 閉じる
        self.dismiss(animated: true, completion: nil)
    }
    
}
