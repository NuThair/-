//
//  MasterAssessmentMenu.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/11/17.
//  Copyright © 2016年 System. All rights reserved.
//
import UIKit

class MasterAssessmentMenu: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    // Tableで使用する配列を定義する.
    let patientItems: NSArray = ["利用者名","利用者ID"]
    let viewMenuItems: NSArray = ["情報参照"]
    let menuItems: NSArray = ["アセスメント"]
    var menuMijisshi : [Bool] = [] // 未実施の場合True
    let menuAssCompItems: NSArray = ["アセスメント完了"]
    let reportItems: NSArray = ["レポート一覧","レポート作成"]
    let appCommon = AppCommon()
    let assCommon = AssCommon()
    // Sectionで使用する配列を定義する.
    let mySections: NSArray = ["利用者情報", "メニュー", "", "", ""]
    // 表示するテーブルビュー
    var myTableView: UITableView? = nil
    // 詳細画面
    //var detailViewController: DetailViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTableView = UITableView(frame: CGRect(x: 0, y: appDelegate.barHeight!, width: appDelegate.tabBarWidth!, height: appDelegate.availableViewHeight!), style: UITableView.Style.grouped)
        
        // Cell名の登録をおこなう.
        myTableView!.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
        // DataSourceの設定をする.
        myTableView!.dataSource = self
        
        // Delegateを設定する.
        myTableView!.delegate = self
        
        // Viewに追加する.
        self.view.addSubview(myTableView!)
    }
    // アセスメント必須項目が全て入力されているか
    func isAssessmentInput() -> Bool {
        // 性別を取得する
        let appCommon = AppCommon()
        let gender = appCommon.getCustomerGender()
        // 入力さている値を取得する
        let assCommon = AssCommon()
        appDelegate.InputAssList = assCommon.getInputAssessmentList()
        var isAllOK = true
        //for var i = 0; i < appDelegate.MstAssessmentGroupList?.length; i += 1 {
        for i in 0 ..< appDelegate.MstAssessmentGroupList!.length {
            var isOk = true
            let mstGroup = appDelegate.MstAssessmentGroupList![i]
            let mstMenuGroupID = mstGroup["AssMenuGroupID"].asInt!
            for j in 0 ..< appDelegate.RequiredMstAssessmentList.count {
                var exists = false
                var requireCount = 0
                let mstItem = appDelegate.RequiredMstAssessmentList[j]
                let groupID = mstItem["AssMenuGroupID"].asInt!
                let subID = mstItem["AssMenuSubGroupID"].asInt!
                let itemID = mstItem["AssItemID"].asInt!
                let genderDSKB = mstItem["GenderDSKB"].asString!
                if mstMenuGroupID == groupID {
                    // 性別で絞込
                    if let gen = gender {
                        // genderDSKBが両方ではなく、自分の性別とも違う場合は対象外
                        if genderDSKB != AppConst.GenderDSKB.BOTH.rawValue && genderDSKB != gen {
                            continue
                        }
                    }
                    
                    requireCount += 1
                    //for var k = 0; k < appDelegate.InputAssList?.length; k += 1 {
                    for k in 0 ..< appDelegate.InputAssList!.length {
                        let trn = appDelegate.InputAssList![k]
                        let trnGroupID = trn["AssMenuGroupID"].asInt!
                        let trnSubID = trn["AssMenuSubGroupID"].asInt!
                        let trnItemID = trn["AssItemID"].asInt!
                        if (groupID == trnGroupID && subID == trnSubID && itemID == trnItemID) {
                            exists = true
                            break
                        }
                    }
                }
                if requireCount > 0 && !exists { // 必須が１つ以上 かつ 入力がない
                    isOk = false
                    break
                }
            }
            if !isOk {
                isAllOK = false
                break;
            }
        }
//        特殊なレポートのチェックが無いため削除
//        if isAllOK {
//            let str = appDelegate.LoginInfo!["LoginSessionKey"].asString!
//            let assID = appDelegate.SelectedAssAssID!
//            let url = "\(AppConst.URLPrefix)report/GetImageReportOK/\(str)/\(assID)"
//            let res = appCommon.getSynchronous(url)
//            if !AppCommon.isNilOrEmpty(res.errCode) {
//                return false
//            }
//            isAllOK = res.result! == "true"
//        }
        return !isAllOK
    }
    
    
    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillApper")

        // フラグが立っている場合はトップページ遷移
        if appDelegate.IsEndMan == true {
            appDelegate.IsEndMan = false // フラグを戻す
            viewDidLoad()
        }

        // assessmentHD取得
        assCommon.postAssState()
        menuMijisshi = [] // 未実施の場合true
        menuMijisshi.append(isAssessmentInput()) // アセスメントは必須項目ではなく、男女を含めた入力項目で確認する
        menuMijisshi.append(false)
        menuMijisshi.append(false)

        // 選択されている顧客情報を読み込む
        let shopID = String(appDelegate.LoginInfo!["ShopID"].asInt!)
        let customerID = appDelegate.SelectedCustomer!["CustomerID"].asString!
        // カスタマー取得
        //let str = "|".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        // api/customer/GetCustomer/{shopID}/{customerID?}/{csmName?}/{csmSex?}
        let url = "\(AppConst.URLPrefix)customer/GetCustomer/\(shopID)/\(customerID)"
        let res = appCommon.getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }
        let customerJson = JSON(string: res.result!) // JSON読み込み
        if customerJson["allCount"].asInt == 0 {
            return
        } else {
            let json : JSON? = customerJson["customerList"][0]
            appDelegate.SelectedCustomer = json
        }

        // テーブルリロード
        myTableView?.reloadData()

        // 詳細画面
        viewBasicInfo()
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
        return mySections[section] as? String
    }
    
    /*
     Cellが選択された際に呼び出される.
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0 {
            viewBasicInfo()
        } else if (indexPath as NSIndexPath).section == 1 {
            // 左側を変更
            performSegue(withIdentifier: "SegueAssInputList",sender: self)
            // 詳細を変更
            AppCommon.changeDetailView(sb: storyboard!, sv: splitViewController!, storyBoardID: "AssNavigationController")
        } else if (indexPath as NSIndexPath).section == 2 {
            // フラグを更新
            appDelegate.IsFirstAssMenu = true
            // 左側を変更
            performSegue(withIdentifier: "SegueAssGroupList",sender: self)
            // 詳細を変更
            AppCommon.changeDetailView(sb: storyboard!, sv: splitViewController!, storyBoardID: "AssNavigationController")
        } else if (indexPath as NSIndexPath).section == 3 {
            if appDelegate.SelectedAssHD!["AssRecordKB"].asString == AppConst.AssRecordKB.COMP.rawValue {
                let alertController = UIAlertController(title: "確認", message: "アセスメントは既に完了済みです。\n完了を解除しますか？", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "解除", style: UIAlertAction.Style.default, handler:{
                    (action: UIAlertAction!) -> Void in
                    print("解除 Button")
                    
                    let assID = self.appDelegate.SelectedAssAssID!
                    let url = "\(AppConst.URLPrefix)assessment/PutInCompAssessment/\(assID)"
                    let res = self.appCommon.putSynchronous(url, params: [:])
                    if AppCommon.isNilOrEmpty(res.errCode) {
                        let alertController = UIAlertController(title: "完了", message: "アセスメント完了の解除に成功しました。", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                            // ボタンが押された時の処理を書く（クロージャ実装）
                            (action: UIAlertAction!) -> Void in
                            print("pushed OK Button")
                        })
                        
                        // addActionした順に左から右にボタンが配置
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)

                        // assessmentHD取得
                        self.assCommon.postAssState()
                        self.menuMijisshi = [] // 未実施の場合true
                        self.menuMijisshi.append(self.appDelegate.SelectedAssHD!["AssRecordKB"].asString! == "1")
                        //menuMijisshi.append(appDelegate.SelectedAssHD!["BlogRecordKB"].asString! == "1")
                        self.menuMijisshi.append(false)
                        self.menuMijisshi.append(false)
                        self.myTableView?.reloadData()
                    } else {
                        let alertController = UIAlertController(title: "エラー", message: "更新できませんでした\nインターネット接続を確認して下さい。", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                            // ボタンが押された時の処理を書く（クロージャ実装）
                            (action: UIAlertAction!) -> Void in
                            print("pushed OK Button")
                        })
                        
                        // addActionした順に左から右にボタンが配置
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                })
                let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
                    (action: UIAlertAction!) -> Void in
                    print("キャンセル")
                    
                })
                // addActionした順に左から右にボタンが配置
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
            } else {
                if !menuMijisshi[2] {
                    let alertController = UIAlertController(title: "確認", message: "アセスメントを完了しますか？\nアセスメント完了後はアセスメントは変更できなくなります。", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "完了", style: UIAlertAction.Style.default, handler:{
                        (action: UIAlertAction!) -> Void in
                        print("完了 Button")// アセスメント完了
                        
                        let assID = self.appDelegate.SelectedAssAssID!
                        let url = "\(AppConst.URLPrefix)assessment/PutCompAssessment/\(assID)"
                        let res = self.appCommon.putSynchronous(url, params: [:])
                        if AppCommon.isNilOrEmpty(res.errCode) {
                            let alertController = UIAlertController(title: "完了", message: "アセスメント完了に成功しました。", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                                // ボタンが押された時の処理を書く（クロージャ実装）
                                (action: UIAlertAction!) -> Void in
                                print("pushed OK Button")
                            })
                            
                            // addActionした順に左から右にボタンが配置
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                            
                            // assessmentHD取得
                            self.assCommon.postAssState()
                            self.menuMijisshi = [] // 未実施の場合true
                            self.menuMijisshi.append(self.appDelegate.SelectedAssHD!["AssRecordKB"].asString! == "1")
                            //menuMijisshi.append(appDelegate.SelectedAssHD!["BlogRecordKB"].asString! == "1")
                            self.menuMijisshi.append(false)
                            self.menuMijisshi.append(self.appDelegate.SelectedAssHD!["SatisfactionRecordKB"].asString! == "1")
                            self.myTableView?.reloadData()
                        } else {
                            let alertController = UIAlertController(title: "エラー", message: "更新できませんでした\nインターネット接続を確認して下さい。", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                                // ボタンが押された時の処理を書く（クロージャ実装）
                                (action: UIAlertAction!) -> Void in
                                print("pushed OK Button")
                            })
                            
                            // addActionした順に左から右にボタンが配置
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    })
                    let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
                        (action: UIAlertAction!) -> Void in
                        print("キャンセル")
                    })
                    // addActionした順に左から右にボタンが配置
                    alertController.addAction(cancelAction)
                    alertController.addAction(okAction)
                    present(alertController, animated: true, completion: nil)
                    
                } else { // 満足度未実施
                    let alertController = UIAlertController(title: "お知らせ", message: "満足度の実施後に完了してください。", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                        // ボタンが押された時の処理を書く（クロージャ実装）
                        (action: UIAlertAction!) -> Void in
                        print("pushed OK Button")
                    })
                    
                    // addActionした順に左から右にボタンが配置
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        } else if (indexPath as NSIndexPath).section == 4 {
            let cell = tableView.cellForRow(at: indexPath)
            let text = cell?.reuseIdentifier
            if (text! == reportItems[0] as! String) { // Assessment
                // 詳細を変更
                AppCommon.changeDetailView(sb: storyboard!, sv: splitViewController!, storyBoardID: "ReportCheckNavigationController")
            } else if (text! == reportItems[1] as! String) { // レポート再作成
                let alertController = UIAlertController(title: "確認", message: "最新情報でレポートを作成しますか？\n※作成には1〜2分程度時間がかかります。", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "作成", style: UIAlertAction.Style.default, handler:{
                    (action: UIAlertAction!) -> Void in
                    print("作成 Button")// レポート作成
                    self.performSegue(withIdentifier: "SegueLoadingReport",sender: self)
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
        // 選択を外す
        myTableView!.deselectRow(at: indexPath, animated: true)
    }
    
    /*
     テーブルに表示する配列の総数を返す.
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return patientItems.count
        } else if section == 1 {
            return viewMenuItems.count
        } else if section == 2 {
            return menuItems.count
        } else if section == 3 {
            return menuAssCompItems.count
        } else if section == 4 {
            return reportItems.count
        } else {
            return 0
        }
    }
    
    /*
     Cellに値を設定する.
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        let customerID = appDelegate.SelectedCustomer!["CustomerID"].asString!
        var name = appDelegate.SelectedCustomer!["CsmName"].asString
        let createDateTime = appDelegate.SelectedCustomer!["CsmCreateDate"].asString
        if name == "" {
            name = createDateTime
        }
        
        if (indexPath as NSIndexPath).section == 0 {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.value2, reuseIdentifier: "MyCell")
            cell.textLabel?.text = "\(patientItems[(indexPath as NSIndexPath).row])"
            if (indexPath as NSIndexPath).row == 0 {
                cell.detailTextLabel?.text = "\(name!)"
            } else if (indexPath as NSIndexPath).row == 1 {
                cell.detailTextLabel?.text = "\(customerID)"
            }
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            return cell
        } else if (indexPath as NSIndexPath).section == 1 {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "\(viewMenuItems[(indexPath as NSIndexPath).row])")
            cell.textLabel?.text = "\(viewMenuItems[(indexPath as NSIndexPath).row])"
            cell.textLabel?.textColor = UIColor.blue
            cell.selectionStyle = UITableViewCell.SelectionStyle.gray
            cell.backgroundColor = UIColor.hexStr("eaeaea", alpha: 1.0)
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            return cell
        } else if (indexPath as NSIndexPath).section == 2 {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "\(menuItems[(indexPath as NSIndexPath).row])")
            cell.textLabel?.text = "\(menuItems[(indexPath as NSIndexPath).row])"
            cell.textLabel?.textColor = UIColor.blue
            if menuMijisshi[(indexPath as NSIndexPath).row] {
                cell.backgroundColor = UIColor.bad() // 必須項目が終わっていない場合は赤くする
            }
            cell.selectionStyle = UITableViewCell.SelectionStyle.gray
            //cell.textLabel?.textAlignment = NSTextAlignment.Center
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            return cell
        } else if (indexPath as NSIndexPath).section == 3 {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "\(menuAssCompItems[(indexPath as NSIndexPath).row])")
            cell.textLabel?.text = "\(menuAssCompItems[(indexPath as NSIndexPath).row])"
            cell.textLabel?.textColor = UIColor.blue
            cell.selectionStyle = UITableViewCell.SelectionStyle.gray
            cell.backgroundColor = UIColor.hexStr("eaeaea", alpha: 1.0)
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            return cell
        } else if (indexPath as NSIndexPath).section == 4 {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "\(reportItems[(indexPath as NSIndexPath).row])")
            cell.textLabel?.text = "\(reportItems[(indexPath as NSIndexPath).row])"
            cell.selectionStyle = UITableViewCell.SelectionStyle.blue
            cell.textLabel?.textColor = UIColor.red
            return cell
        } else  {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MyCell")
            return cell
        }
        
    }
    func viewBasicInfo() {
        // 詳細切り替え
        AppCommon.changeDetailView(sb: storyboard!, sv: splitViewController!, storyBoardID: "PatientBasicInfoNavigationController")
        
    }
}
