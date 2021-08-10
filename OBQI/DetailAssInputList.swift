//
//  DetailAssInputList.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/11/24.
//  Copyright © 2016年 System. All rights reserved.
//

import UIKit

class DetailAssInputList: UITableViewController {
    
    
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    let assCommon = AssCommon()
    // 対象のアセスメントアイテム
    var currentMstAssessmentList : [JSON] = []
    // 入力値
    var inputAssList : JSON?
    // シェーマがあるか
    var noSchema = false
    // 必須が入っているか
    var isOkList : [Bool] = []
    // 戻り先
    var boforeSelectedItem : JSON?
    // 戻るボタンで戻っているか
    var isBackButton = true
    var isTableView = false
    // 毛穴のアセスである
    var isKeana = false
    // キメのあせすである
    var isKime = false

    // 内部ネットワークかどうか
    var isInside = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 戻り先確保のため
        boforeSelectedItem = appDelegate.SelectedMstAssessmentItem
        // 初回アセスかどうかの区分を取得する
        let assKB = appDelegate.SelectedAssHD!["AssKB"].asString!
        // シェーマ区分取得
        let schemaKb = appDelegate.SelectedMstAssessmentSubGroup!["SchemaKB"].asString
        // シェーマが無い場合は戻るボタン非表示
        if schemaKb! == AppConst.SchemaKB.NO_SCHEMA.rawValue {
            self.navigationItem.setHidesBackButton(true
                , animated: false)
            noSchema = true
        }
        
        // 性別を取得する
        let appCommon = AppCommon()
        let gender = appCommon.getCustomerGender()
        // この画面のアセスメントだけ取り出す
        currentMstAssessmentList = []
        let assMenuGroupID = appDelegate.SelectedMstAssessmentSubGroup!["AssMenuGroupID"].asInt!
        let assMenuSubGroupID = appDelegate.SelectedMstAssessmentSubGroup!["AssMenuSubGroupID"].asInt!
        
        
        if assMenuGroupID == AppConst.Keana_Syashin_Migi[0] && assMenuSubGroupID == AppConst.Keana_Syashin_Migi[1] {
            // 毛穴かチェック
            isKeana = true
            
        } else if assMenuGroupID == AppConst.Kime_Syashin_Migi[0] && assMenuSubGroupID == AppConst.Kime_Syashin_Migi[1] {
            // キメかチェック
            isKime = true
        }
        
        //for var i = 0; i < appDelegate.MstAssessmentList?.length; i += 1 {
        for i in 0 ..< appDelegate.MstAssessmentList!.length {
            let mst = appDelegate.MstAssessmentList![i]
            let mstMenuGroupID = mst["AssMenuGroupID"].asInt!
            let mstMenuSubGroupID = mst["AssMenuSubGroupID"].asInt!
            let imgPartsNo : Int? = mst["ImgPartsNo"].asInt
            let genderDSKB = mst["GenderDSKB"].asString!
            let assInputTimeKB = mst["AssInputTimeKB"].asString!
            
            if mstMenuGroupID == assMenuGroupID && mstMenuSubGroupID == assMenuSubGroupID {
                // 性別で絞込
                if let gen = gender {
                    // genderDSKBが両方ではなく、自分の性別とも違う場合は対象外
                    if genderDSKB != AppConst.GenderDSKB.BOTH.rawValue && genderDSKB != gen {
                        continue
                    }
                }
                // 2回目以降入力する項目で、初回アセスの場合は対象外
                if (assKB == AppConst.AssKB.NEW.rawValue && (assInputTimeKB == AppConst.InputTimeKB.HIKITSUGI_NIKAIME.rawValue || assInputTimeKB == AppConst.InputTimeKB.MAIKAI_NIKAIME.rawValue)) {
                    continue
                }
                // シェーマがないか、イメージパーツNoが同じ
                if noSchema || imgPartsNo == appDelegate.SelectedAssImagePartsNo {
                    currentMstAssessmentList.append(mst)
                }
            }
        }
        print("対象のアセスメント数は　\(currentMstAssessmentList.count)")
        
        // 入力されているアセスメントを取得する
        inputAssList = assCommon.getSubGroupInputAssessmentList()
        createIsOKList()
        
        
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

        isInside = appCommon.isInside()
        
        if appDelegate.ChangeInputAssFlagForList == true {
            // 入力されているアセスメントを取得する
            let assCommon = AssCommon()
            appDelegate.InputAssList = assCommon.getSubGroupInputAssessmentList()
            inputAssList = appDelegate.InputAssList
            createIsOKList()
            
            self.tableView.reloadData()
            // フラグを戻す｀
            appDelegate.ChangeInputAssFlagForList = false
            appDelegate.ChangeInputAssFlagForShcema = true
        }
    }
    func isInput(_ groupID : Int, subID : Int, itemID : Int) -> Bool {
        var exists = false
        //for var k = 0; k < inputAssList?.length; k += 1 {
        for k in 0 ..< inputAssList!.length {
            let trn = inputAssList![k]
            let trnGroupID = trn["AssMenuGroupID"].asInt!
            let trnSubID = trn["AssMenuSubGroupID"].asInt!
            let trnItemID = trn["AssItemID"].asInt!
            if (groupID == trnGroupID && subID == trnSubID && itemID == trnItemID) {
                exists = true
                break
            }
        }
        return exists
    }
    func createIsOKList() {
        isOkList = []
        let selectGroupID = appDelegate.SelectedMstAssessmentSubGroup!["AssMenuGroupID"].asInt!
        let selectSubGroupID = appDelegate.SelectedMstAssessmentSubGroup!["AssMenuSubGroupID"].asInt!
        
        for i in 0 ..< currentMstAssessmentList.count {
            var isOk = true
            let mstItemID = currentMstAssessmentList[i]["AssItemID"].asInt!
            for j in 0 ..< appDelegate.RequiredMstAssessmentList.count {
                var exists = false
                var requireCount = 0
                let mstItem = appDelegate.RequiredMstAssessmentList[j]
                let groupID = mstItem["AssMenuGroupID"].asInt!
                let subID = mstItem["AssMenuSubGroupID"].asInt!
                let itemID = mstItem["AssItemID"].asInt!
                if selectGroupID == groupID && selectSubGroupID == subID && mstItemID == itemID {
                    requireCount += 1
                    exists = isInput(groupID,subID: selectSubGroupID,itemID: mstItemID)
                    
                }
                if requireCount > 0 && !exists { // 必須が１つ以上 かつ 入力がない
                    isOk = false
                    break
                }
            }
            isOkList.append(isOk)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /*
     セクションの数を返す.
     */
    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        return mySections.count
    }
    */
    
    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mst = currentMstAssessmentList[(indexPath as NSIndexPath).row]
        let assInputTimeKB = mst["AssInputTimeKB"].asString!
        // 初回アセスかどうかの区分を取得する
        let assKB = appDelegate.SelectedAssHD!["AssKB"].asString!
        
        // 入力不可の場合は遷移させない
        if (
            assInputTimeKB != AppConst.InputTimeKB.NYUURYOKUHUKA_MAIKAI.rawValue
                && !(assKB == AppConst.AssKB.CONTINUE.rawValue && assInputTimeKB == AppConst.InputTimeKB.IKKAI.rawValue)
                && assInputTimeKB != AppConst.InputTimeKB.NYUURYOKUHUKA_ZENKAI_INCRIMENT.rawValue
            )
            &&
            (
                isInside
                    || mst["PrivateFlg"].asString! == AppConst.Flag.OFF.rawValue
            )
        {
            appDelegate.SelectedMstAssessmentItem = mst
            switch (mst["AssInputKB"].asString!) {
            case AppConst.InputKB.SINGLE.rawValue:
                // 遷移
                performSegue(withIdentifier: "SegueAssInputSingle",sender: self)
                break
            case AppConst.InputKB.MULTI.rawValue:
                // 遷移
                performSegue(withIdentifier: "SegueAssInputMulti",sender: self)
                break
            case AppConst.InputKB.BIRTHDAY.rawValue:
                // 遷移
                performSegue(withIdentifier: "SegueAssInputDate",sender: self)
                break
            case AppConst.InputKB.DATETIME.rawValue:
                // 遷移
                performSegue(withIdentifier: "SegueAssInputDateTime",sender: self)
                break
            case AppConst.InputKB.INPUT.rawValue:
                // 遷移
                performSegue(withIdentifier: "SegueAssInputText",sender: self)
                break
            case AppConst.InputKB.INPUT_AREA.rawValue:
                // 遷移
                performSegue(withIdentifier: "SegueAssInputTextArea",sender: self)
                break
            case AppConst.InputKB.PHOTO.rawValue:
                // 遷移
                if noSchema {
                    performSegue(withIdentifier: "SegueAssPhoto",sender: self)
                } else {
                    isBackButton = false
                    //self.navigationController?.popViewController(animated: true);
                }
                break
            case AppConst.InputKB.BARCODE.rawValue:
                // 遷移
                performSegue(withIdentifier: "SegueAssBarcode",sender: self)
                break
            case AppConst.InputKB.VIDEO.rawValue:
                // 遷移
                performSegue(withIdentifier: "SegueAssVideo",sender: self)
                break
            default:
                break
            }
        }
        // 選択を外す
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /*
     テーブルに表示する配列の総数を返す.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentMstAssessmentList.count
    }
    
    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) as UITableViewCell
        let mst = currentMstAssessmentList[(indexPath as NSIndexPath).row]
        let mstAssMenuGroupID = mst["AssMenuGroupID"].asInt!
        let mstAssMenuSubGroupID = mst["AssMenuSubGroupID"].asInt!
        let mstAssItemID = mst["AssItemID"].asInt!
        let mstAssInputKB = mst["AssInputKB"].asString!
        var unitStr : String! = ""
        let unit = mst["AssUnit"].asString
        let assInputTimeKB = mst["AssInputTimeKB"].asString!
        let assKB = appDelegate.SelectedAssHD!["AssKB"].asString!

        if !AppCommon.isNilOrEmpty(unit) {
            unitStr = " (\(unit!))"
        }
        
        
        let text = mst["AssAbbreviatedName"].asString!
        var values : [String] = []
        //for var i = 0; i < inputAssList?.length; i += 1 {
        for i in 0 ..< inputAssList!.length {
            let ob = inputAssList![i]
            let inputAssMenuGroupID = ob["AssMenuGroupID"].asInt!
            let inputAssMenuSubGroupID = ob["AssMenuSubGroupID"].asInt!
            let inputAssItemID = ob["AssItemID"].asInt!
            let inputValue = ob["AssChoicesAsr"].asString
            
            if mstAssMenuGroupID == inputAssMenuGroupID
                && mstAssMenuSubGroupID == inputAssMenuSubGroupID
                && mstAssItemID == inputAssItemID {
                if !AppCommon.isNilOrEmpty(inputValue) {
                    values.append(ob["AssChoicesAsr"].asString!)
                }
            }
        }
        // 値が入力されている場合のみ単位をつける
        var value : String? = ""
        if values.count > 0 {
            if mstAssInputKB == AppConst.InputKB.PHOTO.rawValue
                 || mstAssInputKB == AppConst.InputKB.VIDEO.rawValue{
                value = "有り"
            } else {
                value = values.joined(separator: " , ") + unitStr
            }
        }
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "\(text)")
        cell.textLabel?.text = "\(text)"
        cell.detailTextLabel?.text = value
        if !isOkList[(indexPath as NSIndexPath).row] {
            cell.backgroundColor = UIColor.bad() // 必須項目が終わっていない場合は赤くする
        }
        if (
            assInputTimeKB != AppConst.InputTimeKB.NYUURYOKUHUKA_MAIKAI.rawValue
                && !(assKB == AppConst.AssKB.CONTINUE.rawValue && assInputTimeKB == AppConst.InputTimeKB.IKKAI.rawValue)
                && assInputTimeKB != AppConst.InputTimeKB.NYUURYOKUHUKA_ZENKAI_INCRIMENT.rawValue
            )
            &&
            (
                isInside
                    || mst["PrivateFlg"].asString! == AppConst.Flag.OFF.rawValue
            )
        {
            // 右側に矢印
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        } else {
            // 右側に矢印なし
            cell.accessoryType = UITableViewCell.AccessoryType.none
        }
        
        return cell
    }
    /*
     戻る
     */
    override func viewWillDisappear(_ animated: Bool) {
        print("back")
        
        let viewControllers = self.navigationController?.viewControllers
        if indexOfArray(viewControllers!, searchObject: self) == nil {
            // 戻るボタンが押された処理
            if isBackButton {
                appDelegate.SelectedMstAssessmentItem = boforeSelectedItem
            }
            print("back!")
        }
        
        
        super.viewWillDisappear(animated)
    }
    func indexOfArray(_ array:[AnyObject], searchObject: AnyObject)-> Int? {
        for (index, value) in array.enumerated() {
            if value as! UIViewController == searchObject as! UIViewController {
                return index
            }
        }
        return nil
    }
    @IBAction func ClickDelete(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "確認", message: "入力項目を全て削除しますか？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "削除", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            print("削除 Button")// アセスメント完了
            
            let assCommon : AssCommon = AssCommon()
            // 初回アセスかどうかの区分を取得する
            let assKB = self.appDelegate.SelectedAssHD!["AssKB"].asString!
            if !self.noSchema { // シェーマがある場合
                // アセスメント削除(非同期)
                for i in 0 ..< self.currentMstAssessmentList.count {
                    let assMster = self.currentMstAssessmentList[i]
                    let assInputTimeKB = assMster["AssInputTimeKB"].asString!
                    if assInputTimeKB != AppConst.InputTimeKB.NYUURYOKUHUKA_MAIKAI.rawValue && !(assKB == AppConst.AssKB.CONTINUE.rawValue && assInputTimeKB == AppConst.InputTimeKB.IKKAI.rawValue) && assInputTimeKB != AppConst.InputTimeKB.NYUURYOKUHUKA_ZENKAI_INCRIMENT.rawValue {
                        let res = assCommon.delAss(self.appDelegate.SelectedAssAssID!, selectedAss: assMster, isSync: false)
                        if !AppCommon.isNilOrEmpty(res.errCode) {
                            AppCommon.alertMessage(controller: self, title: "エラー(\(res.errCode!))", message: "削除に失敗しました。")
                        }
                    }
                }
                // 戻る
                self.appDelegate.ChangeInputAssFlagForShcema = true
                self.navigationController!.popViewController(animated: true)
            } else {
                // アセスメント削除(同期)
                for i in 0 ..< self.currentMstAssessmentList.count {
                    let assMster = self.currentMstAssessmentList[i]
                    let assInputTimeKB = assMster["AssInputTimeKB"].asString!
                    if assInputTimeKB != AppConst.InputTimeKB.NYUURYOKUHUKA_MAIKAI.rawValue && !(assKB == AppConst.AssKB.CONTINUE.rawValue && assInputTimeKB == AppConst.InputTimeKB.IKKAI.rawValue) && assInputTimeKB != AppConst.InputTimeKB.NYUURYOKUHUKA_ZENKAI_INCRIMENT.rawValue {
                        let res = assCommon.delAss(self.appDelegate.SelectedAssAssID!, selectedAss: assMster, isSync: true)
                        if !AppCommon.isNilOrEmpty(res.errCode) {
                            AppCommon.alertMessage(controller: self, title: "エラー(\(res.errCode!))", message: "削除に失敗しました。")
                        }
                    }
                }
                self.appDelegate.ChangeInputAssFlagForList = true
                self.viewWillAppear(false)
            }

            if self.appDelegate.ChangeInputAssFlagForShcema! || self.appDelegate.ChangeInputAssFlagForList! {
                // Post Notification（送信）
                let center = NotificationCenter.default
                center.post(name: NSNotification.Name(rawValue: "requiredAssSubList"), object: nil)
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

    }
    
}
