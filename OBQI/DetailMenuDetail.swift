//
//  DetailMenuList.swift
//  OBQI
//
//  Created by t.o on 2017/01/27.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class DetailMenuDetail: UITableViewController, UIPopoverPresentationControllerDelegate {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()

    var mySections = [Int]()
    var myItemsBySection:[[DMDMenuDTParamsFormat?]] = []

    enum SaveAreaMode : Int {
        case UNEDITED = 0
        case UNSAVED = 1
        case CLICKABLE = 2
    }

    // 表示用DTパラメータ
    struct DMDMenuDTParamsFormat {
        var Day:Int?
        var BLogGroupID:Int?
        var BLogSubGroupID:Int?
        var OrderNo:Int?
        var RecommendationKB:String?
        var IsNew:Bool?
    }

    // ボタンが押下された行
    var selectedRow:Int?

    // 選択されたBLog
    var selectedBLogGroupID:Int?
    var selectedBLogSubGroupID:Int?

    @IBOutlet weak var myNaviBar: UINavigationItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")

        // DataSourceの設定をする.
        self.tableView.dataSource = self

        // Delegateを設定する.
        self.tableView.delegate = self

        // 未確定以外の場合は編集不可
        if appDelegate.MenuParams.MenuHD.MenuStatus! != AppConst.MenuStatus.PENDING.rawValue {
            // 非編集モード
            self.tableView.isEditing = false

        } else {
            // 編集モード
            self.tableView.isEditing = true
            // 編集モード中もタップを許可する
            self.tableView.allowsSelectionDuringEditing = true
        }

        // 保存ボタン描画
        changeSaveArea(SaveAreaMode.UNEDITED)

        // タイトル設定
        myNaviBar.title = appDelegate.MenuParams.MenuHD.MenuSetName

        // ハンバーガーメニューフォント設定
        myNaviBar.leftBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 32)], for: UIControl.State())
        myNaviBar.leftBarButtonItem?.setBackgroundVerticalPositionAdjustment(5, for: UIBarMetrics.default)

        // 詳細データセット
        var url = ""
        var res:(result: String?, errCode: String?)
        var menuDTList:[AppConst.MenuDTParamsFormat] = []

        url = "\(AppConst.URLPrefix)menu/GetSelectedMenuDT/\(appDelegate.MenuParams.MenuHD.MenuGroupID!)"
        res = appCommon.getSynchronous(url)

        if AppCommon.isNilOrEmpty(res.errCode) {
            let selectedMenuDTJson = JSON(string: res.result!) // JSON読み込み

            // 推奨情報
            url = "\(AppConst.URLPrefix)menu/GetSelectedMenu/\(appDelegate.MenuParams.MenuHD.MenuGroupID!)"
            res = appCommon.getSynchronous(url)

            var recommendJson:JSON?
            if AppCommon.isNilOrEmpty(res.errCode) {
                recommendJson = JSON(string: res.result!) // JSON読み込み
            }

            selectedMenuDTJson.forEach{ (selectedMenuDT) -> Void in
                let menuDT = AppConst.MenuDTParamsFormat(
                    Day:                selectedMenuDT.1["Day"].asInt!,
                    BLogGroupID:        selectedMenuDT.1["BLogGroupID"].asInt!,
                    BLogSubGroupID:     selectedMenuDT.1["BLogSubGroupID"].asInt!,
                    OrderNo:            selectedMenuDT.1["OrderNo"].asInt!,
                    RecommendationKB:   recommendJson?
                        .filter{ (recommend) -> Bool in
                            recommend.1["BLogGroupID"].asInt! == selectedMenuDT.1["BLogGroupID"].asInt!
                            && recommend.1["BLogSubGroupID"].asInt! == selectedMenuDT.1["BLogSubGroupID"].asInt!
                        }
                        .first
                        .map{ $0.1["RecommendationKB"].asString! }
                )

                menuDTList.append(menuDT)
            }
        }
        appDelegate.MenuParams.MenuDT = menuDTList

        // 詳細に含まれるDayをユニーク化
        let allDays = menuDTList.map{
            $0.Day!
        }
        let orderedDays = NSOrderedSet(array: allDays)
        mySections = (orderedDays.array as! [Int]).sorted(by: <)

        // 日程毎にBLogIDを格納
        myItemsBySection = []
        mySections.forEach{ (day) -> Void in
            let filterdItems = appDelegate.MenuParams.MenuDT.filter{ $0?.Day! == day }
            var appdenItem:[DMDMenuDTParamsFormat?] = []
            filterdItems.forEach{
                appdenItem.append(DMDMenuDTParamsFormat(
                    Day:                $0?.Day,
                    BLogGroupID:        $0?.BLogGroupID,
                    BLogSubGroupID:     $0?.BLogSubGroupID,
                    OrderNo:            $0?.OrderNo,
                    RecommendationKB:   $0?.RecommendationKB,
                    IsNew:              false
                ))
            }

            myItemsBySection.append(appdenItem)
        }

        // DTが0件の時は、空の「1回目」を表示しておく
        if mySections.count == 0 {
            // データ挿入
            mySections.append(1)
            myItemsBySection.append([])

            // 保存ボタン活性化
            changeSaveArea(DetailMenuDetail.SaveAreaMode.UNSAVED)
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
     テーブルに表示する配列の総数を返す.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myItemsBySection[section].count
    }

    /*
     セクションの数を返す.
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return mySections.count
    }

    /*
     セクション設定
     */
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let frame: CGRect = tableView.frame
        let headerView: UIView = UIButton(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        headerView.backgroundColor = UIColor.defaultSectionBackGround()

        let label = UILabel(frame: CGRect(x: 16, y: 0, width: 400, height: 32));
        label.text = "\(String(mySections[section]))回目"
        label.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
        headerView.addSubview(label)

        let addButton: UIButton = UIButton(frame: CGRect(x: frame.size.width - 44, y: 0, width: 32, height: 32))
        addButton.setTitle("・・・", for: UIControl.State())
        addButton.setTitleColor(UIColor.textBlue(), for: UIControl.State())
        addButton.titleLabel!.font = UIFont(name: "Helvetica-Bold", size: CGFloat(30))
        addButton.tag = section
        addButton.addTarget(self, action: #selector(DetailMenuDetail.clickPopSectionActions(_:)), for: .touchUpInside)
        headerView.addSubview(addButton)

        return headerView
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

        // 選択しても色を変えない
        cell.selectionStyle = UITableViewCell.SelectionStyle.none

        // 対応する日程に一致するデータを表示
        let bLogGroupID = myItemsBySection[section][index]?.BLogGroupID!
        let bLogSubGroupID = myItemsBySection[section][index]?.BLogSubGroupID!
        let recommendationKB = myItemsBySection[section][index]?.RecommendationKB!
        let isNew = myItemsBySection[section][index]?.IsNew!

        cell.textLabel?.text = appDelegate.MstBusinessLogSubHDList?
            .filter{ $0.1["BLogGroupID"].asInt! == bLogGroupID && $0.1["BLogSubGroupID"].asInt! == bLogSubGroupID }
            .first.map{ $0.1["BLogSubGroupName"].asString! }

        // 推奨区分により背景色の変更
        switch recommendationKB! {
        case AppConst.RecommendationKB.RECOMMENDATION.rawValue:
            cell.backgroundColor = UIColor.good()
            break
        case AppConst.RecommendationKB.DEPRECATED.rawValue:
            cell.backgroundColor = UIColor.bad()
            break
        default:
            break
        }

        // 新規追加の場合は文字色変更
        if isNew! {
            cell.textLabel?.textColor = UIColor.disabled()
        }

        return cell
    }

    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = (indexPath as NSIndexPath).section
        let index = (indexPath as NSIndexPath).row

        // 非推奨の時だけ遷移
        let recommendationKB = myItemsBySection[section][index]?.RecommendationKB!
        if recommendationKB == AppConst.RecommendationKB.DEPRECATED.rawValue {
            // 選択されたBLog
            selectedBLogGroupID = myItemsBySection[section][index]?.BLogGroupID!
            selectedBLogSubGroupID = myItemsBySection[section][index]?.BLogSubGroupID!
            self.performSegue(withIdentifier: "SegueDetailMenuDeprecatedAssessmentList", sender: self)
        }
    }

    // セル 削除
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // 未確定以外の場合は削除不可
        if appDelegate.MenuParams.MenuHD.MenuStatus! != AppConst.MenuStatus.PENDING.rawValue {
            return false

        } else {
            return true
        }
    }
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "削除"
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let section = (indexPath as NSIndexPath).section
        let index = (indexPath as NSIndexPath).row

        if editingStyle == UITableViewCell.EditingStyle.delete {
            let alertController = UIAlertController(title: "確認", message: "本当に削除しますか？", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                (action: UIAlertAction!) -> Void in
                print("削除")

                self.myItemsBySection[section].remove(at: index)
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)

                // 保存ボタン活性化
                self.changeSaveArea(SaveAreaMode.UNSAVED)
            })
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
                (action: UIAlertAction!) -> Void in
                print("キャンセル")
            })
            // addActionした順に左から右にボタンが配置
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
    }

    // セル ドラッグ＆ドロップ
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let fromSection = (sourceIndexPath as NSIndexPath).section
        let fromIndex = (sourceIndexPath as NSIndexPath).row
        let toSection = (destinationIndexPath as NSIndexPath).section
        let toIndex = (destinationIndexPath as NSIndexPath).row

        // 変化を見る
        if fromSection != toSection || fromIndex != toIndex {
            // データ退避
            let movingData = myItemsBySection[fromSection][fromIndex]

            // 移動元削除
            myItemsBySection[fromSection].remove(at: fromIndex)

            // 移動先に挿入
            myItemsBySection[toSection].insert(movingData, at: toIndex)

            // 保存ボタン活性化
            changeSaveArea(SaveAreaMode.UNSAVED)
        }
    }

    /*
     詳細アクションを表示
     */
    @IBAction func clickPopActions(_ sender: UIBarButtonItem) {
        //Prepare the instance of ContentViewController which is the content of popover.
        let contentVC = PopMenuDetailGlobalActions()
        //define use of popover
        contentVC.modalPresentationStyle = UIModalPresentationStyle.popover
        //set size
        contentVC.preferredContentSize = CGSize(width: 300, height: 365)
        //set origin
        contentVC.popoverPresentationController?.barButtonItem = sender
        //set arrow direction
        contentVC.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        //set delegate
        contentVC.popoverPresentationController?.delegate = self
        //present
        present(contentVC, animated: true, completion: nil)
    }


    /*
     日程毎に使用可能なアクションを表示
     */
    @objc internal func clickPopSectionActions(_ sender: UIButton) {
        // set section index
        self.selectedRow = sender.tag

        //Prepare the instance of ContentViewController which is the content of popover.
        let contentVC = PopMenuDetailSectionActions()
        //define use of popover
        contentVC.modalPresentationStyle = UIModalPresentationStyle.popover
        //set size
        contentVC.preferredContentSize = CGSize(width: 200, height: 175)
        //set origin
        contentVC.popoverPresentationController?.sourceView = self.view
        // 表示位置計算
        let convertFrame = sender.superview?.convert(sender.frame, to: self.view)
        contentVC.popoverPresentationController?.sourceRect = convertFrame!
        //set arrow direction
        contentVC.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        //set delegate
        contentVC.popoverPresentationController?.delegate = self
        //present
        present(contentVC, animated: true, completion: nil)
    }

    /*
     保存ボタン表示領域の状態変更
     */
    internal func changeSaveArea(_ mode: SaveAreaMode){
        // 保存
        let saveAreaView = UIView(frame: CGRect(x:0, y:0, width: 100, height:44))
        let text: UIButton = UIButton(frame: CGRect(x: saveAreaView.frame.width - 40, y: 0, width: 40, height: 44))
        text.setTitle("保存", for: UIControl.State.normal)
        text.addTarget(self, action: #selector(DetailMenuDetail.saveAlert(_:)), for: .touchUpInside)

        switch mode {
        case SaveAreaMode.UNEDITED:
            text.setTitleColor(UIColor.lightGray, for: UIControl.State.normal)
            text.isEnabled = false

        case SaveAreaMode.UNSAVED:
            text.setTitleColor(UIColor.textBlue(), for: UIControl.State.normal)
            text.isEnabled = true

            // 警告アイコン
            let icon: UIImage = UIImage(named: "alert.png")!
            let iconView = UIImageView(image: icon)
            iconView.frame = CGRect(x: saveAreaView.frame.width - 12, y: 0, width: 12, height: 12)
            saveAreaView.addSubview(iconView)

        case SaveAreaMode.CLICKABLE:
            text.setTitleColor(UIColor.textBlue(), for: UIControl.State.normal)
            text.isEnabled = true
        }

        saveAreaView.addSubview(text)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveAreaView)
    }

    /*
     保存確認用アラート
     */
    @objc internal func saveAlert(_ sender: UIButton) {
        // BLogが含まれていない日程のチェック
        let isEmpty = self.myItemsBySection.contains{ daySection in
            daySection.count == 0
        }
        if isEmpty {
            AppCommon.alertMessage(controller: self, title: "エラー", message: "メニューが含まれていない日程があります")
        }

        // アラートアクションの設定
        var actionListSave = [(title: String , style: UIAlertAction.Style ,action: (UIAlertAction) -> Void)]()

        // キャンセルアクション
        actionListSave.append(
            (
                title: "キャンセル",
                style: UIAlertAction.Style.cancel,
                action: {
                    (action: UIAlertAction!) -> Void in
                    print("Cancel")
            })
        )

        // OKアクション
        actionListSave.append(
            (
                title: "OK",
                style: UIAlertAction.Style.default,
                action: {
                    (action: UIAlertAction!) -> Void in
                    print("Save")


                    // 非推奨アセスメント確認
                    let isDeprecated = self.myItemsBySection.contains{ daySection in
                        daySection.contains{ selectedDT in
                            return selectedDT?.RecommendationKB == AppConst.RecommendationKB.DEPRECATED.rawValue
                        }
                    }

                    // 非推奨を含む場合はさらにアラートを表示
                    if isDeprecated {
                        // 非推奨アセスメント確認アクションの設定
                        var actionListDeprecated = [(title: String , style: UIAlertAction.Style ,action: (UIAlertAction) -> Void)]()

                        // キャンセルアクション
                        actionListDeprecated.append(
                            (
                                title: "キャンセル",
                                style: UIAlertAction.Style.cancel,
                                action: {
                                    (action: UIAlertAction!) -> Void in
                                    print("Cancel Deprecated")
                            })
                        )

                        // OKアクション
                        actionListDeprecated.append(
                            (
                                title: "OK",
                                style: UIAlertAction.Style.default,
                                action: {
                                    (action: UIAlertAction!) -> Void in
                                    print("Save Deprecated")

                                    // 保存
                                    self.save()
                            })
                        )

                        AppCommon.alertAnyAction(controller: self, title: "確認", message: "非推奨メニューが含まれていますがよろしいですか？", actionList: actionListDeprecated)

                    } else {
                        // 保存
                        self.save()
                    }
            })
        )

        AppCommon.alertAnyAction(controller: self, title: "確認", message: "変更を保存しますか？", actionList: actionListSave)
    }

    /*
     保存処理
     */
    private func save() {
        // 日付、並び順の調整
        fixSelectedDT()

        var params:[[String: AnyObject]] = []
        myItemsBySection.forEach{ (daySection) -> Void in
            daySection.forEach{ (selectedDT) -> Void in
                let detailList:[String: AnyObject]  = [
                    "MenuGroupID":      self.appDelegate.MenuParams.MenuHD.MenuGroupID! as AnyObject,
                    "Day":              selectedDT?.Day!  as AnyObject,
                    "BLogGroupID":      selectedDT?.BLogGroupID!  as AnyObject,
                    "BLogSubGroupID":   selectedDT?.BLogSubGroupID!  as AnyObject,
                    "OrderNo":          selectedDT?.OrderNo!  as AnyObject
                ]

                params.append(detailList)
            }
        }

        let url = "\(AppConst.URLPrefix)menu/PutSelectedMenuDT"
        let req = appCommon.createApiURL(url, AppConst.MethodType.PUT)
        req.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])

        let res = appCommon.requestSynchronous(req)

        if !AppCommon.isNilOrEmpty(res.errCode) {
            print("エラー")
        }

        // 再描画
        self.viewDidLoad()
        self.tableView.reloadData()
    }

    /*
     日程変更後、各種パラメータ調整処理
     */
    public func fixSelectedDT() {
        myItemsBySection.enumerated().forEach{ (secIndex, daySection) -> Void in
            daySection.enumerated().forEach{ (dtIndex, selectedDT) -> Void in
                myItemsBySection[secIndex][dtIndex]?.Day = secIndex + 1
                myItemsBySection[secIndex][dtIndex]?.OrderNo = dtIndex
            }
        }
    }

}


