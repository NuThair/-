//
//  AppCommon.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/10/14.
//  Copyright © 2016年 System. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class MstEntity: NSManagedObject {
    
    @NSManaged var tableName: String
    @NSManaged var jsonString: String
    
}



class AppCommon: UIViewController , UIAlertViewDelegate, XMLParserDelegate {
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    var currentElementName : String!
    
    // 概要:四捨五入を行い結果を返す
    // 引数:
    //      value:四捨五入対象の値
    //      figures:何桁目を四捨五入するかを指定
    //               正の値:少数点以下の値を四捨五入
    //               負の値:整数部分の値を四捨五入
    // 戻り値:四捨五入した値
    func ponvireRound(_ value:Double, figures:Int) -> Double {
        if value == 0 {
            return 0
        }
        let tmp:Double = pow(10.0, Double(figures))
        
        if value > 0.0 {
            return floor((value * tmp) + 0.5) / tmp
        }
        else{
            return ceil((value * tmp) + 0.5) / tmp
        }
    }
    // 文字列がNilか空白の場合True
    /*
    static func isNilOrEmpty(_ nsstring: NSString?) -> Bool {
        switch nsstring {
        case .some(let nonNilString): return nonNilString.length == 0
        default:                      return true
        }
    }
    */
    static func isNilOrEmpty(_ string: String?) -> Bool {
        if string == nil {
            return true
        } else {
            let nsString = string as NSString?
            switch nsString {
            case .some(let nonNilString):
                return nonNilString.length == 0
            default:
                return true
            }
        }
    }
    func isNewVersion() -> Bool! {
        let version: String! = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)
        let info = version.split(omittingEmptySubsequences: false){$0 == "."}.map { String($0) }
        
        let nowMa  = info[0] // foo
        let nowMi  = info[1] // *
        print("app -ma:\(nowMa)")
        print("app -mi:\(nowMi)")
        
        let serverInfo = (appDelegate.Version!).split(omittingEmptySubsequences: false){$0 == "."}.map { String($0) }
        let serverMa  = serverInfo[0] // foo
        let serverMi  = serverInfo[1] // *
        print("app -ma:\(serverMa)")
        print("app -mi:\(serverMi)")
        
        return (nowMa == serverMa && nowMi == serverMi)
    }
    
    func loadVersion() {
        appDelegate.loadVersion = false
        let version: String! = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        //print("app -version:\(version ?? default value )")
        let info = version.split(omittingEmptySubsequences: false){$0 == "."}.map { String($0) }
        let nowMa  = info[0] // foo
        let nowMi  = info[1] // *
        print("app -ma:\(nowMa)")
        print("app -mi:\(nowMi)")
        
        
        // サーバのバージョンを取得する
        let url_with_basic_auth = "\(AppConst.UPDATE_URL)\(AppConst.HTML_NAME.VER.rawValue)"
        let url = URL(string: url_with_basic_auth)
        let req = NSMutableURLRequest(url: url!)
        
        //Authorizationヘッダーの作成
        let username = "qool"
        let password = "qoolpassword"
        let authStr = "\(username):\(password)"
        let data = authStr.data(using: String.Encoding.utf8)
        let authData = data!.base64EncodedString(options: NSData.Base64EncodingOptions())
        let authValue = "Basic \(authData)"
        
        //作成したAuthorizationヘッダーの付与
        req.setValue(authValue, forHTTPHeaderField: "Authorization")
       
        let semaphore = DispatchSemaphore(value: 0)
        URLSession.shared.dataTask(with: req as URLRequest, completionHandler: {
            (data, response, error) -> Void in
            do {
                let parser : XMLParser? = XMLParser(data: data!)
                if parser != nil {
                    // NSXMLParserDelegateをセット
                    parser!.delegate = self;
                    parser!.parse()
                    self.appDelegate.loadVersion = true
                } else {
                    self.appDelegate.loadVersion = false
                }
            }
            semaphore.signal()
        }).resume()
        semaphore.wait()
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        currentElementName = nil;
    }
    func parserDidStartDocument(_ parser: XMLParser)
    {
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        currentElementName = elementName
    }
    func parser(_ parser: XMLParser, foundCharacters string: String)
    {
        if currentElementName == "version" {
            appDelegate.Version = string
        }
    }
    
    
    // 画像を一旦保存する。
    func getImage(_ imagePath : String!) -> UIImage {
        if let image : UIImage = appDelegate.ImageList[imagePath] {
            return image
        } else {
            let imagePath64Encoded = imagePath.data(using: String.Encoding.utf8)?.base64EncodedString().addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            let url = "\(AppConst.URLPrefix)setting/GetPublicImageFileBase64String/\(imagePath64Encoded!)"
            let res = getSynchronous(url)

            if res.result == nil {
                return UIImage()
            }

            let decodedData = Data(base64Encoded: res.result! as String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
            if let image = UIImage(data: decodedData!) {
                appDelegate.ImageList.updateValue(image, forKey: imagePath)
                return image
            } else {
                return UIImage()
            }
        }
    }

    func createAllReport() {
        let assID = appDelegate.SelectedAssAssID!
        let str = appDelegate.LoginInfo!["LoginSessionKey"].asString!
        let url = "\(AppConst.URLPrefix)report/PostAllReport/\(str)/\(assID)"
        let params: [String: AnyObject] = [
            "loginSessionKey": str as AnyObject,
            ]
        
        _ = postSynchronous(url, params: params)
        return
    }
    func updateImgMaster() {
        let tableName = "MstAssImagePartsList"
        let url = "\(AppConst.URLPrefix)mstimageparts/GetMstImageParts/1"
        let res = getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }
        updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
        appDelegate.MstAssImagePartsList = JSON(string: res.result!) // JSON読み込み
        
    }
    // すべてのマスタ情報をAPIのデータで上書きする。メモリ上に保存してある画像ファイルも削除する
    func updateMaster() {
        // 読み込んだ画像ファイルを削除
        appDelegate.ImageList = [:]
        
        
        // AssessmentGroupList
        var tableName : String! = "MstAssessmentGroupList"
        //var list:[AnyObject]? = searchMstEntity(tableName)
        var url = "\(AppConst.URLPrefix)mstassessment/GetAssessmentGroupList/"
        var res = getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }
        updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
        appDelegate.MstAssessmentGroupList = JSON(string: res.result!) // JSON読み込み
        // AssessmentSubGroupList
        tableName = "MstAssessmentSubGroupList"
        url = "\(AppConst.URLPrefix)mstassessment/GetMstAssessmentSubGroup/"
        res = getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }
        updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
        appDelegate.MstAssessmentSubGroupList = JSON(string: res.result!) // JSON読み込み
        // 全項目情報を取得する
        tableName = "MstAssessmentList"
        url = "\(AppConst.URLPrefix)mstassessment/GetAssessmentInfoDataTable/"
        res = getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }
        updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
        appDelegate.MstAssessmentList = JSON(string: res.result!) // JSON読み込み
        // 必須項目を取得
        appDelegate.RequiredMstAssessmentList = []
        //for var i = 0; i < appDelegate.MstAssessmentList?.length; i += 1 {
        for i in 0 ..< appDelegate.MstAssessmentList!.length {
            let mst = appDelegate.MstAssessmentList![i]
            if mst["AssRequiredFlg"].asString == AppConst.Flag.ON.rawValue {
                appDelegate.RequiredMstAssessmentList.append(mst)
            }
        }
        // イメージパーツを取得する(ASS)
        tableName = "MstAssImagePartsList"
        url = "\(AppConst.URLPrefix)mstimageparts/GetMstImageParts/1"
        res = getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }
        updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
        appDelegate.MstAssImagePartsList = JSON(string: res.result!) // JSON読み込み
        // BusinessLogHDマスタ
        tableName = "MstBusinessLogHDList"
        url = "\(AppConst.URLPrefix)mstbusinesslog/GetMstBusinessLogHD/"
        res = getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }
        updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
        appDelegate.MstBusinessLogHDList = JSON(string: res.result!) // JSON読み込み
        // BusinessLogSubHDマスタ
        tableName = "MstBusinessLogSubHDList"
        url = "\(AppConst.URLPrefix)mstbusinesslog/GetMstBusinessLogSubHD/"
        res = getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }
        updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
        appDelegate.MstBusinessLogSubHDList = JSON(string: res.result!) // JSON読み込み
        // BusinessLogDTマスタ
        tableName = "MstBusinessLogDTList"
        url = "\(AppConst.URLPrefix)mstbusinesslog/GetMstBusinessLogDT/"
        res = getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }
        updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
        appDelegate.MstBusinessLogDTList = JSON(string: res.result!) // JSON読み込み
        // イメージパーツを取得する(BSS)
        tableName = "MstBssImagePartsList"
        url = "\(AppConst.URLPrefix)mstimageparts/GetMstImageParts/2"
        res = getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }
        updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
        appDelegate.MstBssImagePartsList = JSON(string: res.result!) // JSON読み込み
        // 満足度マスタ
        tableName = "MstOutcomeList"
        url = "\(AppConst.URLPrefix)mstsatisfaction/GetOutcomeList/"
        res = getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }
        updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
        appDelegate.MstOutcomeList = JSON(string: res.result!) // JSON読み込み
        // 更新パターンを取得する
        tableName = "MstUpdatePatternList"
        url = "\(AppConst.URLPrefix)mstupdatepattern/GetMasterData/"
        res = getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }
        updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
        appDelegate.MstUpdatePatternList = JSON(string: res.result!) // JSON読み込み
        // インフォームド・コンセントを取得する
        tableName = "MstInformedConsentList"
        url = "\(AppConst.URLPrefix)ic/GetMstInformedConsent"
        res = getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }
        updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
        appDelegate.MstInformedConsentList = JSON(string: res.result!) // JSON読み込み
        // メニューを取得する
        tableName = "MstMenu"
        url = "\(AppConst.URLPrefix)menu/GetMasterData"
        res = getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }
        updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
        appDelegate.MstMenu = JSON(string: res.result!) // JSON読み込み
        // メニュービジネスログ関連マスタを取得する
        tableName = "MstMNBLRelation"
        url = "\(AppConst.URLPrefix)menu/GetMasterMNBLRelation"
        res = getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }
        updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
        appDelegate.MstMNBLRelation = JSON(string: res.result!) // JSON読み込み
        // メニュー権限マスタを取得する
        tableName = "MstMenuJobCategoryKB"
        url = "\(AppConst.URLPrefix)menu/GetMenuJobCategoryKB"
        res = getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }
        updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
        appDelegate.MstMenuJobCategoryKB = JSON(string: res.result!) // JSON読み込み
        // 病名基本テーブルを取得する
        tableName = "MstNmain400"
        url = "\(AppConst.URLPrefix)dictionary/GetNmain400List"
        res = getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }
        updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
        appDelegate.MstNmain400 = JSON(string: res.result!) // JSON読み込み
        // 修飾語テーブルを取得する
        tableName = "MstMdfy400"
        url = "\(AppConst.URLPrefix)dictionary/GetMdfy400List"
        res = getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }
        updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
        appDelegate.MstMdfy400 = JSON(string: res.result!) // JSON読み込み
//        // 索引テーブルを取得する
//        tableName = "MstIndex400"
//        url = "\(AppConst.URLPrefix)dictionary/GetIndex400List"
//        res = getSynchronous(url)
//        if !AppCommon.isNilOrEmpty(res.errCode) {
//            return
//        }
//        updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
//        appDelegate.MstIndex400 = JSON(string: res.result!) // JSON読み込み
        // 医薬品テーブルを取得する
        tableName = "ViewDrug"
        url = "\(AppConst.URLPrefix)dictionary/GetDrugList"
        res = getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }
        updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
        appDelegate.ViewDrug = JSON(string: res.result!) // JSON読み込み
        // 部位テーブルを取得する
        tableName = "MstBui"
        url = "\(AppConst.URLPrefix)dictionary/GetBuiList"
        res = getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }
        updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
        appDelegate.MstBui = JSON(string: res.result!) // JSON読み込み
        // 電カルオーダー出力内容定義テーブルを取得する
        tableName = "MstOrderRelation"
        url = "\(AppConst.URLPrefix)dictionary/GetOrderRelationList"
        res = getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }
        updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
        appDelegate.MstOrderRelation = JSON(string: res.result!) // JSON読み込み
        // エラーメッセージを取得する
        tableName = "ErrorMessageList"
        url = "\(AppConst.URLPrefix)setting/GetErrorMessageList"
        res = getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }
        updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
        appDelegate.ErrorMessageList = JSON(string: res.result!) // JSON読み込み

        /******************
        // ReportAssマスタ
        tableName = "MstReportAssList"
        url = "\(AppConst.URLPrefix)report/GetReportAss/\(loginSessionKey!)"
        print(url)
        res = getSynchronous(url)
        if res == nil {
            return
        }
        updateMstEntity(tableName: tableName, jsonString: res!) // 登録
        appDelegate.MstReportAssList = JSON(string: res!) // JSON読み込み
        *******************/
    }
    // マスタ情報読み込み。ローカルのデータで保持していなかったら、APIより取得する
    func loadMaster() {
        // AssessmentGroupList
        var tableName : String! = "MstAssessmentGroupList"
        var list:[AnyObject]? = searchMstEntity(tableName)
        //list = nil
        if list == nil { // ないので新規に登録する
            let url = "\(AppConst.URLPrefix)mstassessment/GetAssessmentGroupList/"
            let res = getSynchronous(url)
            if !AppCommon.isNilOrEmpty(res.errCode) {
                return
            }
            updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
            appDelegate.MstAssessmentGroupList = JSON(string: res.result!) // JSON読み込み
        } else {
            for entity in list! {
                let firstEntity = entity as! MstEntity
                appDelegate.MstAssessmentGroupList = JSON(string: firstEntity.jsonString)
                break
            }
        }
        // AssessmentSubGroupList
        tableName = "MstAssessmentSubGroupList"
        list = searchMstEntity(tableName)
        if list == nil { // ないので新規に登録する
            let url = "\(AppConst.URLPrefix)mstassessment/GetMstAssessmentSubGroup/"
            let res = getSynchronous(url)
            if !AppCommon.isNilOrEmpty(res.errCode) {
                return
            }
            updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
            appDelegate.MstAssessmentSubGroupList = JSON(string: res.result!) // JSON読み込み
        } else {
            for entity in list! {
                let firstEntity = entity as! MstEntity
                appDelegate.MstAssessmentSubGroupList = JSON(string: firstEntity.jsonString)
                break
            }
        }
        
        // 全項目情報を取得する
        tableName = "MstAssessmentList"
        list = searchMstEntity(tableName)
        if list == nil { // ないので新規に登録する
            //for var i = 0; i <= appDelegate.MstAssessmentSubGroupList!.length; i++ {
            //let menuGroupID : String! = appDelegate.MstAssessmentSubGroupList![i]["AssMenuGroupID"].asString!
            let url = "\(AppConst.URLPrefix)mstassessment/GetAssessmentInfoDataTable/"
            let res = getSynchronous(url)
            if !AppCommon.isNilOrEmpty(res.errCode) {
                return
            }
            updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
            appDelegate.MstAssessmentList = JSON(string: res.result!) // JSON読み込み
        } else {
            for entity in list! {
                let firstEntity = entity as! MstEntity
                appDelegate.MstAssessmentList = JSON(string: firstEntity.jsonString)
                break
            }
        }
        // 必須項目を取得
        appDelegate.RequiredMstAssessmentList = []
        //for var i = 0; i < appDelegate.MstAssessmentList?.length; i += 1 {
        for i in 0 ..< appDelegate.MstAssessmentList!.length {
            let mst = appDelegate.MstAssessmentList![i]
            if mst["AssRequiredFlg"].asString == AppConst.Flag.ON.rawValue {
                appDelegate.RequiredMstAssessmentList.append(mst)
            }
        }
        
        // イメージパーツを取得する
        tableName = "MstAssImagePartsList"
        list = searchMstEntity(tableName)
        if list == nil { // ないので新規に登録する
            let url = "\(AppConst.URLPrefix)mstimageparts/GetMstImageParts/1"
            let res = getSynchronous(url)
            if !AppCommon.isNilOrEmpty(res.errCode) {
                return
            }
            updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
            appDelegate.MstAssImagePartsList = JSON(string: res.result!) // JSON読み込み
        } else {
            for entity in list! {
                let firstEntity = entity as! MstEntity
                appDelegate.MstAssImagePartsList = JSON(string: firstEntity.jsonString)
                break
            }
        }
        // BusinessLogHDマスタ
        tableName = "MstBusinessLogHDList"
        list = searchMstEntity(tableName)
        if list == nil { // ないので新規に登録する
            let url = "\(AppConst.URLPrefix)mstbusinesslog/GetMstBusinessLogHD/"
            let res = getSynchronous(url)
            if !AppCommon.isNilOrEmpty(res.errCode) {
                return
            }
            updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
            appDelegate.MstBusinessLogHDList = JSON(string: res.result!) // JSON読み込み
        } else {
            for entity in list! {
                let firstEntity = entity as! MstEntity
                appDelegate.MstBusinessLogHDList = JSON(string: firstEntity.jsonString)
                break
            }
        }
        
        // BusinessLogSubHDマスタ
        tableName = "MstBusinessLogSubHDList"
        list = searchMstEntity(tableName)
        if list == nil { // ないので新規に登録する
            let url = "\(AppConst.URLPrefix)mstbusinesslog/GetMstBusinessLogSubHD/"
            let res = getSynchronous(url)
            if !AppCommon.isNilOrEmpty(res.errCode) {
                return
            }
            updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
            appDelegate.MstBusinessLogSubHDList = JSON(string: res.result!) // JSON読み込み
        } else {
            for entity in list! {
                let firstEntity = entity as! MstEntity
                appDelegate.MstBusinessLogSubHDList = JSON(string: firstEntity.jsonString)
                break
            }
        }
        // BusinessLogDTマスタ
        tableName = "MstBusinessLogDTList"
        list = searchMstEntity(tableName)
        if list == nil { // ないので新規に登録する
            let url = "\(AppConst.URLPrefix)mstbusinesslog/GetMstBusinessLogDT/"
            let res = getSynchronous(url)
            if !AppCommon.isNilOrEmpty(res.errCode) {
                return
            }
            updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
            appDelegate.MstBusinessLogDTList = JSON(string: res.result!) // JSON読み込み
        } else {
            for entity in list! {
                let firstEntity = entity as! MstEntity
                appDelegate.MstBusinessLogDTList = JSON(string: firstEntity.jsonString)
                break
            }
        }
        // イメージパーツを取得する(BSS)
        tableName = "MstBssImagePartsList"
        list = searchMstEntity(tableName)
        if list == nil { // ないので新規に登録する
            let url = "\(AppConst.URLPrefix)mstimageparts/GetMstImageParts/2"
            let res = getSynchronous(url)
            if !AppCommon.isNilOrEmpty(res.errCode) {
                return
            }
            updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
            appDelegate.MstBssImagePartsList = JSON(string: res.result!) // JSON読み込み
        } else {
            for entity in list! {
                let firstEntity = entity as! MstEntity
                appDelegate.MstBssImagePartsList = JSON(string: firstEntity.jsonString)
                break
            }
        }
        
        // 満足度マスタを取得する
        tableName = "MstOutcomeList"
        list = searchMstEntity(tableName)
        if list == nil { // ないので新規に登録する
            let url = "\(AppConst.URLPrefix)mstsatisfaction/GetOutcomeList/"
            let res = getSynchronous(url)
            if !AppCommon.isNilOrEmpty(res.errCode) {
                return
            }
            updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
            appDelegate.MstOutcomeList = JSON(string: res.result!) // JSON読み込み
        } else {
            for entity in list! {
                let firstEntity = entity as! MstEntity
                appDelegate.MstOutcomeList = JSON(string: firstEntity.jsonString)
                break
            }
        }
        // 更新パターンを取得する
        tableName = "MstUpdatePatternList"
        list = searchMstEntity(tableName)
        if list == nil { // ないので新規に登録する
            let url = "\(AppConst.URLPrefix)mstupdatepattern/GetMasterData/"
            let res = getSynchronous(url)
            if !AppCommon.isNilOrEmpty(res.errCode) {
                return
            }
            updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
            appDelegate.MstUpdatePatternList = JSON(string: res.result!) // JSON読み込み
        } else {
            for entity in list! {
                let firstEntity = entity as! MstEntity
                appDelegate.MstUpdatePatternList = JSON(string: firstEntity.jsonString)
                break
            }
        }
        // インフォームド・コンセントを取得する
        tableName = "MstInformedConsentList"
        list = searchMstEntity(tableName)
        if list == nil { // ないので新規に登録する
            let url = "\(AppConst.URLPrefix)ic/GetMstInformedConsent"
            let res = getSynchronous(url)
            if !AppCommon.isNilOrEmpty(res.errCode) {
                return
            }
            updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
            appDelegate.MstInformedConsentList = JSON(string: res.result!) // JSON読み込み
        } else {
            for entity in list! {
                let firstEntity = entity as! MstEntity
                appDelegate.MstInformedConsentList = JSON(string: firstEntity.jsonString)
                break
            }
        }
        // メニューを取得する
        tableName = "MstMenu"
        list = searchMstEntity(tableName)
        if list == nil { // ないので新規に登録する
            let url = "\(AppConst.URLPrefix)menu/GetMAsterData"
            let res = getSynchronous(url)
            if !AppCommon.isNilOrEmpty(res.errCode) {
                return
            }
            updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
            appDelegate.MstMenu = JSON(string: res.result!) // JSON読み込み
        } else {
            for entity in list! {
                let firstEntity = entity as! MstEntity
                appDelegate.MstMenu = JSON(string: firstEntity.jsonString)
                break
            }
        }
        // メニュービジネスログ関連マスタを取得する
        tableName = "MstMNBLRelation"
        list = searchMstEntity(tableName)
        if list == nil { // ないので新規に登録する
            let url = "\(AppConst.URLPrefix)menu/GetMAsterMNBLRelation"
            let res = getSynchronous(url)
            if !AppCommon.isNilOrEmpty(res.errCode) {
                return
            }
            updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
            appDelegate.MstMNBLRelation = JSON(string: res.result!) // JSON読み込み
        } else {
            for entity in list! {
                let firstEntity = entity as! MstEntity
                appDelegate.MstMNBLRelation = JSON(string: firstEntity.jsonString)
                break
            }
        }
        // メニュー権限マスタを取得する
        tableName = "MstMenuJobCategoryKB"
        list = searchMstEntity(tableName)
        if list == nil { // ないので新規に登録する
            let url = "\(AppConst.URLPrefix)menu/GetMenuJobCategoryKB"
            let res = getSynchronous(url)
            if !AppCommon.isNilOrEmpty(res.errCode) {
                return
            }
            updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
            appDelegate.MstMenuJobCategoryKB = JSON(string: res.result!) // JSON読み込み
        } else {
            for entity in list! {
                let firstEntity = entity as! MstEntity
                appDelegate.MstMenuJobCategoryKB = JSON(string: firstEntity.jsonString)
                break
            }
        }
        // 病名基本テーブルを取得する
        tableName = "MstNmain400"
        list = searchMstEntity(tableName)
        if list == nil { // ないので新規に登録する
            let url = "\(AppConst.URLPrefix)dictionary/GetNmain400List"
            let res = getSynchronous(url)
            if !AppCommon.isNilOrEmpty(res.errCode) {
                return
            }
            updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
            appDelegate.MstNmain400 = JSON(string: res.result!) // JSON読み込み
        } else {
            for entity in list! {
                let firstEntity = entity as! MstEntity
                appDelegate.MstNmain400 = JSON(string: firstEntity.jsonString)
                break
            }
        }
        // 修飾語テーブルを取得する
        tableName = "MstMdfy400"
        list = searchMstEntity(tableName)
        if list == nil { // ないので新規に登録する
            let url = "\(AppConst.URLPrefix)dictionary/GetMdfy400List"
            let res = getSynchronous(url)
            if !AppCommon.isNilOrEmpty(res.errCode) {
                return
            }
            updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
            appDelegate.MstMdfy400 = JSON(string: res.result!) // JSON読み込み
        } else {
            for entity in list! {
                let firstEntity = entity as! MstEntity
                appDelegate.MstMdfy400 = JSON(string: firstEntity.jsonString)
                break
            }
        }
//        // 索引テーブルを取得する
//        tableName = "MstIndex400"
//        list = searchMstEntity(tableName)
//        if list == nil { // ないので新規に登録する
//            let url = "\(AppConst.URLPrefix)dictionary/GetIndex400List"
//            let res = getSynchronous(url)
//            if !AppCommon.isNilOrEmpty(res.errCode) {
//                return
//            }
//            updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
//            appDelegate.MstIndex400 = JSON(string: res.result!) // JSON読み込み
//        } else {
//            for entity in list! {
//                let firstEntity = entity as! MstEntity
//                appDelegate.MstIndex400 = JSON(string: firstEntity.jsonString)
//                break
//            }
//        }
        // 医薬品テーブルを取得する
        tableName = "ViewDrug"
        list = searchMstEntity(tableName)
        if list == nil { // ないので新規に登録する
            let url = "\(AppConst.URLPrefix)dictionary/GetDrugList"
            let res = getSynchronous(url)
            if !AppCommon.isNilOrEmpty(res.errCode) {
                return
            }
            updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
            appDelegate.ViewDrug = JSON(string: res.result!) // JSON読み込み
        } else {
            for entity in list! {
                let firstEntity = entity as! MstEntity
                appDelegate.ViewDrug = JSON(string: firstEntity.jsonString)
                break
            }
        }
        // 部位テーブルを取得する
        tableName = "MstBui"
        list = searchMstEntity(tableName)
        if list == nil { // ないので新規に登録する
            let url = "\(AppConst.URLPrefix)dictionary/GetBuiList"
            let res = getSynchronous(url)
            if !AppCommon.isNilOrEmpty(res.errCode) {
                return
            }
            updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
            appDelegate.MstBui = JSON(string: res.result!) // JSON読み込み
        } else {
            for entity in list! {
                let firstEntity = entity as! MstEntity
                appDelegate.MstBui = JSON(string: firstEntity.jsonString)
                break
            }
        }
        // 電カルオーダー出力内容定義テーブルを取得する
        tableName = "MstOrderRelation"
        list = searchMstEntity(tableName)
        if list == nil { // ないので新規に登録する
            let url = "\(AppConst.URLPrefix)dictionary/GetOrderRelationList"
            let res = getSynchronous(url)
            if !AppCommon.isNilOrEmpty(res.errCode) {
                return
            }
            updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
            appDelegate.MstOrderRelation = JSON(string: res.result!) // JSON読み込み
        } else {
            for entity in list! {
                let firstEntity = entity as! MstEntity
                appDelegate.MstOrderRelation = JSON(string: firstEntity.jsonString)
                break
            }
        }
        // エラーメッセージを取得する
        tableName = "ErrorMessageList"
        list = searchMstEntity(tableName)
        if list == nil { // ないので新規に登録する
            let url = "\(AppConst.URLPrefix)setting/GetErrorMessageList"
            let res = getSynchronous(url)
            if !AppCommon.isNilOrEmpty(res.errCode) {
                return
            }
            updateMstEntity(tableName: tableName, jsonString: res.result!) // 登録
            appDelegate.ErrorMessageList = JSON(string: res.result!) // JSON読み込み
        } else {
            for entity in list! {
                let firstEntity = entity as! MstEntity
                appDelegate.ErrorMessageList = JSON(string: firstEntity.jsonString)
                break
            }
        }

        /************
         
        // ReportAssマスタ
        tableName = "MstReportAssList"
        list = searchMstEntity(tableName)
        if list == nil { // ないので新規に登録する
            let url = "\(AppConst.URLPrefix)report/GetReportAss/\(loginSessionKey!)"
            let res = getSynchronous(url)
            if res == nil {
                return
            }
            updateMstEntity(tableName: tableName, jsonString: res!) // 登録
            appDelegate.MstReportAssList = JSON(string: res!) // JSON読み込み
        } else {
            for entity in list! {
                let firstEntity = entity as! MstEntity
                appDelegate.MstReportAssList = JSON(string: firstEntity.jsonString)
                break
            }
        }
        ************/
    }
    
    // エンティティ追加
    func createMstEntity(tableName:String, jsonString:String) {
        let entityDescription = NSEntityDescription.entity(forEntityName: "MstEntity", in: managedObjectContext!)
        let mstEntity = MstEntity(entity: entityDescription!, insertInto: managedObjectContext!)
        mstEntity.tableName = tableName
        mstEntity.jsonString = jsonString
        do {
            try managedObjectContext?.save()
        } catch let error1 as NSError {
            print(error1)
        }
    }
    // エンティティ検索
    func searchMstEntity(_ tableName : String) -> [AnyObject]? {
        //let request : NSFetchRequest = NSFetchRequest(entityName: "MstEntity")
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MstEntity")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format:"tableName == %@", tableName)
        let sortDescriptor:NSSortDescriptor = NSSortDescriptor(key: "tableName", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        let matches = try! managedObjectContext!.fetch(request) as! [MstEntity]
        if matches.count > 0 {
            var exists = false
            for ob in matches {
                if ob is MstEntity {
                    exists = true
                } else {
                    managedObjectContext!.delete(ob as NSManagedObject)
                }
            }
            
            if exists {
                print("\(tableName) Found!")
                return matches
            } else {
                print("\(tableName) Not Found2!")
                return nil
            }
        } else {
            print("\(tableName) Not Found!")
            return nil
        }
        
    }
    // 更新(なかったら新規追加)
    func updateMstEntity(tableName:String, jsonString:String) {
        
        //let request : NSFetchRequest = NSFetchRequest(entityName: "MstEntity")
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MstEntity")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format:"tableName == %@", tableName)
        let sortDescriptor:NSSortDescriptor = NSSortDescriptor(key: "tableName", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        let matches:[AnyObject] = try! managedObjectContext!.fetch(request)
        if matches.count > 0 {
            print("\(tableName) Found2!")
            var count = 0
            for managedObject in matches {
                if managedObject is MstEntity {
                    let model = managedObject as! MstEntity;
                    
                    // レコードの更新！
                    model.jsonString = jsonString
                    count += 1
                } else {
                    managedObjectContext?.delete(managedObject as! NSManagedObject)
                }
            }
            if count == 0 {
                print("\(tableName) Not Found2!")
                createMstEntity(tableName: tableName, jsonString: jsonString)
                print("Insert2!")
            }
            do {
                // AppDelegateクラスに自動生成された saveContext で保存完了
                try managedObjectContext!.save()
            } catch let error1 as NSError {
                print(error1)
            }
            print("Update!")
        } else {
            print("\(tableName) Not Found2!")
            createMstEntity(tableName: tableName, jsonString: jsonString)
            print("Insert2!")
        }
    }
    // 性別を取得する
    func getCustomerGender() -> String? {
        if let _ = appDelegate.SelectedCustomer {
            if let csmSex = appDelegate.SelectedCustomer!["CsmSex"].asString {
                if csmSex == AppConst.CsmSex.MALE.rawValue {
                    return AppConst.GenderDSKB.MALE.rawValue
                } else if csmSex == AppConst.CsmSex.FEMALE.rawValue {
                    return AppConst.GenderDSKB.FEMALE.rawValue
                } else {
                    return nil
                }
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    static func changeDetailView(sb:UIStoryboard!, sv:UISplitViewController!, storyBoardID:String!) -> Void {
        // 詳細を変更
        let vc = sb.instantiateViewController(withIdentifier: storyBoardID)
        // NavigationItemを移植
        var item = vc.navigationItem
        if let nc = vc as? UINavigationController {
            item = nc.topViewController!.navigationItem
        }
        
        item.leftBarButtonItem = sv!.displayModeButtonItem
        item.leftItemsSupplementBackButton = true
        
        // ViewControllerを変更
        sv!.showDetailViewController(vc, sender: self)
    }

    // 日付フォーマット変更
    static func getDateFormat(date:Date?, format:String!) -> String! {
        if date == nil {
            return ""
        }
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let strLastDate: NSString = dateFormatter.string(from: date!) as NSString
        return strLastDate as String?
    }
    
    // 選択されている顧客情報を最新に更新する
    func updateSelectedCustomer() {
        if let customer = appDelegate.SelectedCustomer {
            let shopID = String(appDelegate.LoginInfo!["ShopID"].asInt!)
            let customerID = customer["CustomerID"].asString!
            // カスタマー取得
            let str = "|".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            let url = "\(AppConst.URLPrefix)customer/GetCustomer/\(customerID)/\(str)/\(str)/\(str)/\(shopID)/\(str)/\(str)"
            let res = getSynchronous(url)
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
        }
    }

    /*
     内部ネットワークかどうか判定
     */
    func isInside() -> Bool {
        let url = "\(AppConst.URLPrefix)setting/GetInsideVPN/"
        let res = getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return false
        }

        guard let result = res.result else {
            return false
        }

        switch result {
        case "true":
            return true

        case "false":
            return false

        default:
            return false
        }
    }

    /******************** リクエスト関連 ********************/
    // 認証ヘッダ付きURL生成
    func createApiURL(_ url: String, _ method: AppConst.MethodType) -> NSMutableURLRequest {
        let req = NSMutableURLRequest(url: URL(string: url)!)
        req.httpMethod = method.rawValue
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.addValue("application/json", forHTTPHeaderField: "Accept")
        req.addValue(NSUUID().uuidString, forHTTPHeaderField: "MACAddress") // 機種固有番号
        if  appDelegate.LoginInfo != nil { // 認証情報がある場合はヘッダーに設定する。
            req.addValue(appDelegate.LoginInfo!["LoginSessionKey"].asString!, forHTTPHeaderField: "Authorization")
        }

        return req
    }
    // 同期リクエスト共通
    func requestSynchronous(_ req: NSMutableURLRequest) -> (result: String?, errCode: String?) {
        var result : String! = nil
        var errCode : String? = nil

        let semaphore = DispatchSemaphore(value: 0)
        URLSession.shared.dataTask(with: req as URLRequest, completionHandler: {
            (data, response, error) -> Void in
            do {
                if error == nil {
                    result = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as String?

                    if (result != nil) {
                        if let _ = result!.range(of: AppConst.ErrStr) {
                            let resultJson = JSON(string: result!)
                            errCode = resultJson[AppConst.ErrStr].asString
                        }
                    }
                } else {
                    errCode = AppConst.ErrCodeUnknown
                }
            }
            semaphore.signal()
        }).resume()
        semaphore.wait()

        return (result, errCode)
    }

    // GETリクエスト(同期)
    func getSynchronous(_ url: String!) -> (result: String?, errCode: String?) {
        let req = createApiURL(url, AppConst.MethodType.GET)

        return requestSynchronous(req)
    }
    // POSTリクエスト（同期）
    func postSynchronous(_ url: String!, params: [String: AnyObject]) -> (result: String?, errCode: String?) {
        let req = createApiURL(url, AppConst.MethodType.POST)
        req.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])

        return requestSynchronous(req)
    }
    // PUTリクエスト（同期）
    func putSynchronous(_ url: String!, params: [String: AnyObject]) -> (result: String?, errCode: String?) {
        let req = createApiURL(url, AppConst.MethodType.PUT)
        req.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])

        return requestSynchronous(req)
    }
    // DELETEリクエスト（同期）
    func deleteSynchronous(_ url: String!, params: [String: AnyObject]) -> (result: String?, errCode: String?) {
        let req = createApiURL(url, AppConst.MethodType.DELETE)
        req.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])

        return requestSynchronous(req)
    }
    /******************** リクエスト関連 ********************/


    /******************** アラート関連 ********************/
    // サーバから取得したエラーメッセージを表示
    static func alertError(controller : UIViewController, result : String?, errCode : String!) {
        let title = "エラー"
        var message = "予期せぬエラーが発生しました。"
        if errCode == AppConst.ErrCodeUnknown {
            message = "予期せぬエラーが発生しました。"
        } else {
            let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
            for i in 0 ..< appDelegate.ErrorMessageList!.length {
                if appDelegate.ErrorMessageList![i]["ID"].asString! == errCode {
                    message = appDelegate.ErrorMessageList![i]["Message"].asString!
                    break
                }
            }
        }
        
        let alertController = UIAlertController(title: title, message: "\(message)(\(errCode!))", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) {
            action in NSLog("OKボタンが押されました")
        }
        // addActionした順に左から右にボタンが配置されます
        alertController.addAction(okAction)
        controller.present(alertController, animated: true, completion: nil)
    }

    // 任意のメッセージを表示
    static func alertMessage(controller : UIViewController, title : String!, message : String!) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) {
            action in NSLog("OKボタンが押されました")
        }
        // addActionした順に左から右にボタンが配置されます
        alertController.addAction(okAction)
        controller.present(alertController, animated: true, completion: nil)
    }

    // 任意のアクションを設定
    static func alertAnyAction(controller : UIViewController, title : String!, message : String!, actionList : [(title : String , style : UIAlertAction.Style ,action : (UIAlertAction) -> Void)]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        // addActionした順に左から右にボタンが配置されます
        actionList.forEach{
            alertController.addAction(UIAlertAction(title: $0.title, style: $0.style, handler: $0.action))
        }
        controller.present(alertController, animated: true, completion: nil)
    }
    /******************** アラート関連 ********************/

    // 引っ張ってリロード
    static func getRefreshControl(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) -> UIRefreshControl {
        //リフレッシュコントロールを作成する。
        let refresh = UIRefreshControl()

        //インジケーターの下に表示する文字列を設定する。
        refresh.attributedTitle = NSAttributedString(string: "読込中")

        //テーブルビューを引っ張ったときの呼び出しメソッドを登録する。
        refresh.addTarget(target, action: action, for: controlEvents)

        return refresh
    }

    /*
     カメラ起動許可
     */
    static func checkCameraAuthStatus(controller : UIViewController) -> Bool {
        var ret = false

        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch status {
        case .authorized, .notDetermined:
            ret = true
            break

        case .denied:
            self.alertMessage(controller: controller, title: "エラー", message: "カメラへのアクセスが許可されていません。")
            break

        case .restricted:
            break
        @unknown default:
            ret = false
        }
        
        return ret
    }

    /*
     マイク起動許可
     */
    static func checkMicrophoneAuthStatus(controller : UIViewController) -> Bool {
        var ret = false

        let status = AVAudioSession.sharedInstance().recordPermission
        switch status {
        case AVAudioSessionRecordPermission.granted, AVAudioSessionRecordPermission.undetermined:
            ret = true
            break

        case AVAudioSessionRecordPermission.denied:
            self.alertMessage(controller: controller, title: "エラー", message: "マイクへのアクセスが許可されていません。")
            break

        default:
            break
        }
        
        return ret
    }
}


