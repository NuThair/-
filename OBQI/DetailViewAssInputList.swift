//
//  DetailAssInputList.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/11/24.
//  Copyright © 2016年 System. All rights reserved.
//

import UIKit

class DetailViewAssInputList: UIViewController, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate {


    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)


    // 対象のアセスメントアイテム
    var currentMstAssessmentList : [JSON] = []
    // 対象のイメージパーツ
    var imagePartsList:[JSON] = []
    // 表示するテーブルビュー
    var myTableView: UITableView? = nil
    // 入力値
    var inputAssList : JSON?


    override func viewDidLoad() {
        super.viewDidLoad()
        //var noSchema = false
        // シェーマ区分取得
        let schemaKb = appDelegate.SelectedMstAssessmentSubGroup!["SchemaKB"].asString
        // シェーマが無い場合は戻るボタン非表示
        if schemaKb! == AppConst.SchemaKB.NO_SCHEMA.rawValue {
            self.navigationItem.setHidesBackButton(true
                , animated: false)
            //noSchema = true
        }
        // 入力されているアセスメントを取得する
        let assCommon = AssCommon()
        inputAssList = assCommon.getSubGroupInputAssessmentList()


        // この画面のアセスメントだけ取り出す
        currentMstAssessmentList = []
        let assMenuGroupID = appDelegate.SelectedMstAssessmentSubGroup!["AssMenuGroupID"].asInt!
        let assMenuSubGroupID = appDelegate.SelectedMstAssessmentSubGroup!["AssMenuSubGroupID"].asInt!
        //for var i = 0; i < appDelegate.MstAssessmentList?.length; i += 1 {
        for i in 0 ..< appDelegate.MstAssessmentList!.length {
            let mst = appDelegate.MstAssessmentList![i]
            let mstMenuGroupID = mst["AssMenuGroupID"].asInt!
            let mstMenuSubGroupID = mst["AssMenuSubGroupID"].asInt!
            let mstItemID = mst["AssItemID"].asInt!
            //var imgPartsNo : Int? = mst["ImgPartsNo"].asInt

            if mstMenuGroupID == assMenuGroupID && mstMenuSubGroupID == assMenuSubGroupID {
                var exists = false
                //for var j = 0; j < inputAssList?.length; j += 1 {
                for j in 0 ..< inputAssList!.length {
                    let itemID = inputAssList?[j]["AssItemID"].asInt
                    if mstItemID == itemID {
                        exists = true
                        break
                    }
                }
                if exists {
                    currentMstAssessmentList.append(mst)
                }
            }
        }
        // この画面のImagePartsを取り出す
        imagePartsList = []
        for i in 0 ..< appDelegate.MstAssImagePartsList!.length {
            let imgPartsID = appDelegate.MstAssImagePartsList![i]["ImgPartsID"].asInt!
            let imgPartsSubID = appDelegate.MstAssImagePartsList![i]["ImgPartsSubID"].asInt!

            if imgPartsID == assMenuGroupID && imgPartsSubID == assMenuSubGroupID {
                imagePartsList.append(appDelegate.MstAssImagePartsList![i])
            }
        }

        print("対象のアセスメント数は　\(currentMstAssessmentList.count)")



        /*
         // Status Barの高さを取得を.する.
         let barHeight: CGFloat = UIApplication.sharedApplication().statusBarFrame.size.height

         // Viewの高さと幅を取得する.
         let displayWidth: CGFloat = self.view.frame.width
         let displayHeight: CGFloat = self.view.frame.height
         let navBarWidth = self.navigationController?.navigationBar.frame.size.width
         */

        // TableViewの生成( status barの高さ分ずらして表示 ).
        myTableView = UITableView(frame: CGRect(x: 0, y: appDelegate.barHeight!, width: appDelegate.detailNavBarWidth!, height: appDelegate.availableDetailViewHeight!), style: UITableView.Style.plain)

        // Cell名の登録をおこなう.
        myTableView!.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")

        // DataSourceの設定をする.
        myTableView!.dataSource = self

        // Delegateを設定する.
        myTableView!.delegate = self

        // Viewに追加する.
        self.view.addSubview(myTableView!)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /*
     セクションの数を返す.
     */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }


    /*
     Cellが選択された際に呼び出される.
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mst = currentMstAssessmentList[(indexPath as NSIndexPath).row]
        appDelegate.SelectedMstAssessmentItem = mst

        let cell = tableView.cellForRow(at: indexPath)


        switch (mst["AssInputKB"].asString!) {
        case AppConst.InputKB.PHOTO.rawValue:
            // 遷移(値が設定されている場合はtagが1)
            if cell!.tag == 1 {
                performSegue(withIdentifier: "SegueViewAssCamera",sender: self)
            }
            break
        default:
            break
        }
        // 選択を外す
        myTableView!.deselectRow(at: indexPath, animated: true)
    }

    /*
     テーブルに表示する配列の総数を返す.
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentMstAssessmentList.count
    }

    /*
     Cellに値を設定する.
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) as UITableViewCell
        let mst = currentMstAssessmentList[(indexPath as NSIndexPath).row]
        let mstAssMenuGroupID = mst["AssMenuGroupID"].asInt!
        let mstAssMenuSubGroupID = mst["AssMenuSubGroupID"].asInt!
        let mstAssItemID = mst["AssItemID"].asInt!
        let mstImgPartsNo = mst["ImgPartsNo"].asInt
        let mstAssInputKB = mst["AssInputKB"].asString!

        var unitStr : String! = ""
        let unit = mst["AssUnit"].asString
        if !AppCommon.isNilOrEmpty(unit) {
            unitStr = " (\(unit!))"
        }

        var text = mst["AssAbbreviatedName"].asString!
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
        // ImagePartsがある場合は部位名として取得する
        var bui : String?
        if (mstImgPartsNo != nil) {
            for i in 0 ..< imagePartsList.count {
                let imageParts = imagePartsList[i]
                let ImgPartsNo = imageParts["ImgPartsNo"].asInt!
                if (mstImgPartsNo! == ImgPartsNo) {
                    bui = imageParts["ImgPartsName"].asString
                    break
                }
            }
        }
        if !AppCommon.isNilOrEmpty(bui) {
            text = "【\(bui!)】 \(text)"
        }
        // 値が入力されている場合のみ単位をつける
        var isInput : Int! = 0
        var value : String? = ""
        if values.count > 0 {
            if mstAssInputKB == AppConst.InputKB.PHOTO.rawValue
                || mstAssInputKB == AppConst.InputKB.VIDEO.rawValue{
                value = "有り"
            } else {
                value = values.joined(separator: " , ") + unitStr
            }
            isInput = 1
        }


        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "\(text)")
        cell.textLabel?.text = "\(text)"
        cell.detailTextLabel?.text = value
        cell.tag = isInput
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
