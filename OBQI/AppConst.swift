//
//  AppConst.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/10/14.
//  Copyright © 2016年 System. All rights reserved.
//

import Foundation

class AppConst {
    class var URLPrefix : String {
        return "http://52.196.223.0/api/"
        //return "http://10.0.1.4/api/"
    }
    class var UPDATE_URL : String {
        return "https://qool.co.jp/app/"
    }
    enum HTML_NAME : String {
        case DONWLOAD = "download.html"
        case VER = "ver.xml"
    }
    class var ErrCodeUnknown : String {
        return "ErrUnknown"
    }
    class var ErrStr : String {
        return "ErrCode"
    }
    class var ManSonotaStrings : [String] {
        return ["その他","テレビ","雑誌","ラジオ","ホームページ","インターネット","駅などの街頭広告","通りかかった","友人／知人の紹介","院内からの紹介","他院からの紹介","その他紹介"]
    }
    enum MethodType : String {
        case GET = "GET"
        case POST = "POST"
        case PUT = "PUT"
        case DELETE = "DELETE"
    }
    enum CsmSex : String {
        case MALE = "男性"
        case FEMALE = "女性"
    }
    enum ReportSex : String {
        case MALE = "1"
        case FEMALE = "2"
        case COMMON = "3"
    }
    enum EpisodeChangeMode : String {
        case END = "1"
        case RESTART = "2"
    }
    enum Flag : String {
        case ON = "1"
        case OFF = "0"
    }
    enum ArrowDirection : Int {
        case MAIN = 0
        case UP = 1
        case DOWN = 3
        case RIGHT = 2
        case LEFT = 4
    }
    enum AssKB : String {
        case NEW = "1"
        case CONTINUE = "2"
    }
    enum AssRecordKB : String {
        case COMP = "4"
    }
    enum EpisodeKbn : String {
        case START = "1"
        case END = "2"
        case RESTART = "3"
    }
    enum OutcomeKbn : String {
        case SELF = "1"
        case FAMILY = "2"
        case MEDICAL = "3"
    }
    
    enum SchemaKB : String {
        case NO_SCHEMA = "1"
        case SINGLE = "2"
        case MULTI = "3"
        case ONLY_SCHEMA_SINGLE = "4"
        case ONLY_SCHEMA_MULTI = "5"
        case ONLY_SCHEMA_PHOTO_SINGLE = "6"
        case ONLY_SCHEMA_PHOTO_MULTI = "7"
        case SINGLE_REQUIRE_PHOTO = "8"
        case MULTI_REQUIRE_PHOTO = "9"
        case ONLY_SCHEMA_PHOTO_SINGLE_REQUIRE_PHOTO = "10"
        case ONLY_SCHEMA_PHOTO_MULTI_REQUIRE_PHOTO = "11"
    }
    enum AppTypeKB : String {
        case ASSESSMENT = "1"
        case BUSINESS = "2"
        case MANZOKUDO = "3"
    }
    enum GenderDSKB : String {
        case MALE = "1"
        case FEMALE = "2"
        case BOTH = "3"
    }
    enum InputValueID : String {
        case NUM = "12"
    }
    enum InputKB : String {
        case SINGLE = "1"
        case MULTI = "2"
        case INPUT = "3"
        case BIRTHDAY = "4"
        case PHOTO = "5"
        case INPUT_AREA = "6"
        case NPS = "7"
        case DATETIME = "8"
        case BARCODE = "9"
        case DRUG = "10"
        case BUI = "11"
        case VIDEO = "12"
        case INPUT_AREA_READ_ONLY = "56" // 50番以降は読み取り専用
    }
    // 1：毎回初回、2：毎回2回目以降、3：引継初回、4：引継2回目以降、5：1回、6：入力不可引き継ぎなし、6：入力不可前回インクリメント
    enum InputTimeKB : String {
        case MAIKAI_SYOKAI = "1"
        case MAIKAI_NIKAIME = "2"
        case HIKITSUGI_SYOKAI = "3"
        case HIKITSUGI_NIKAIME = "4"
        case IKKAI = "5"
        case NYUURYOKUHUKA_MAIKAI = "6"
        case NYUURYOKUHUKA_ZENKAI_INCRIMENT = "7"
    }
    enum OutcomeRecordKB : String {
        case MIJISSHI = "1"
        case JISSHIZUMI = "2"
        case JISSHISHINAI = "3"
    }
    enum ReportType : String {
        case JIZEN = "00"
        case SOGO = "01"
        case KIN_BARANCE = "02"
        case KETSUEKI = "03"
        case SATSUEI_GAZOU = "04"
        case SHIDOHYO = "05"
        case IDENSHI = "06"
        case PATCH = "07"
        case ARERUGI = "08"
        case JITAKU = "09"
        case SHIDO_MAE = "10"
        case PROGRAM = "11"
    }

    // 介入計画ステータス
    enum MenuStatus : String {
        case PENDING = "0"
        case DETERMINE = "1"
        case COMP = "2"
    }

    // 画面モード
    enum Mode : String {
        case CREATE = "1"
        case READ = "2"
        case UPDATE = "3"
        case DELETE = "9"
    }

    // リコメンド
    enum RecommendationKB : String {
        case NOTHING = "0"
        case RECOMMENDATION = "1"
        case DEPRECATED = "2"
    }

    // 修飾語区分
    enum ModifierKbn : Int {
        case PREFIX = 0
        case SUFFIX = 1
    }

    // レポート区分
    enum MenuReportKbn : Int {
        case ASSESSMENT = 1
        case OUTCOME = 2
    }

    // 電カル区分
    enum KarteKbn : String {
        case SUBJECT = "1"
        case OBJECT = "2"
        case ASSESSMENT = "3"
        case PLAN = "4"
        case ORDER = "99"
    }
    static let KarteKbnName: [KarteKbn: (Full: String, Short: String)] = [
        KarteKbn.SUBJECT: ("Subject", "S"),
        KarteKbn.OBJECT: ("Object", "O"),
        KarteKbn.ASSESSMENT: ("Assessment", "A"),
        KarteKbn.PLAN: ("Plan", "P"),
        ]
    // カルテ連携ステータス
    enum UpdateKbnName : String {
        case ADD_OR_CHANGE = "新規または変更"
        case DELETE = "削除"
        case NIL = "未連携"
    }
    // カルテ連携ステータス
    enum UpdateKbnStatus : String {
        case NORMAL = "0"
        case ADD = "1"
        case CHANGE = "2"
        case DELETE = "3"
    }
    // インデント幅
    enum IndentWidth : String {
        case None = ""
        case Space2 = "  "
        case Space4 = "    "
    }
    // 履歴区分
    enum KarteHistoryKbn : Int {
        case SOAP = 0
        case ORDER = 1
    }
    // 連携ステータス
    enum CooperationStatus : Int {
        case SENT = -1
        case SUCCESS = 0
        case ERROR = 9
    }

    // 事前問診オプションのID
    class var OptionID_IgE : [Int] {
        return [13,1,6]
    }
    class var OptionID_Idenshi : [Int] {
        return [13,1,7]
    }
    class var OptionID_Patche : [Int] {
        return [13,1,8]
    }
    class var OptionID_Jitaku : [Int] {
        return [13,1,9]
    }
    class var Option_Answer : String {
        return "有り"
    }
    // 血液検査の同意
    class var BloodTest_DOI : [Int] {
        return [13,1,11]
    }
    class var BloodTest_HIDOI : String {
        return "拒否"
    }
    // 血液検査のアセスメント
    class var BloodTest_IPPAN : [Int] {
        return [10,1]
    }
    class var BloodTest_SEIKAGAKU : [Int] {
        return [10,2]
    }
    // 毛穴のつまりのアセスメント
    class var Keana_Tsumari_Migi : [Int] {
        return [4,9,2]
    }
    class var Keana_Tsumari_Hidari : [Int] {
        return [4,9,6]
    }
    // 毛穴のつまりのアセスメント
    class var Keana_Syashin_Migi : [Int] {
        return [4,9,3]
    }
    class var Keana_Syashin_UV_Migi : [Int] {
        return [4,9,4]
    }
    class var Keana_Syashin_Hidari : [Int] {
        return [4,9,7]
    }
    class var Keana_Syashin_UV_Hidari : [Int] {
        return [4,9,8]
    }
    // キメの写真のアセスメント
    class var Kime_Syashin_Migi : [Int] {
        return [4,10,3]
    }
    class var Kime_Syashin_Hidari : [Int] {
        return [4,10,6]
    }
    
    // オプション検査の必須項目
    // 自宅
    class var Jitaku : [Int] {
        return [12]
    }

    // アウトカム区分
    class var OutcomeKbnName : [String] {
        return ["本人","家族","医療機関"]
    }

    // 介入計画ステータス
    class var MenuStatusName : [String] {
        return ["未確定","確定","完了"]
    }

    // 修飾語区分文言
    class var ModifierKbnText : [String] {
        return ["接頭語","接尾語"]
    }
    // 保険区分文言
    class var InsuranceKbnText : [String] {
        return ["自費","併用","保険"]
    }
    // アセスメント比較区分
    class var ComparisonAssKbn : [Int] {
        return [1, 2, 3, 4]
    }
    // アセスメント比較区分文言
    class var ComparisonAssKbnText : [String] {
        return ["介入計画初回作成時アセスメント","介入計画最終更新時アセスメント","介入計画終了時アセスメント","最新アセスメント"]
    }
    // 手動プログラム
    class var ManualProgram : Int {
        return 0
    }

    /******************* 介入計画 データフォーマット **********************/
    // メニュー系パラメータ
    class MenuParamsFormat {
        var MenuHD:MenuHDParamsFormat
        var Episode:EpisodeParamsFormat
        var MenuDT:[MenuDTParamsFormat?]
        var Program:[ProgramParamsFormat?]
        var Disease:[DiseaseParamsFormat?]

        init() {
            self.MenuHD = MenuHDParamsFormat()
            self.Episode = EpisodeParamsFormat()
            self.MenuDT = []
            self.Program = []
            self.Disease = []
        }
        init(MenuHD:MenuHDParamsFormat, Episode:EpisodeParamsFormat, MenuDT:[MenuDTParamsFormat?], Program:[ProgramParamsFormat?], Disease:[DiseaseParamsFormat?]) {
            self.MenuHD = MenuHD
            self.Episode = Episode
            self.MenuDT = MenuDT
            self.Program = Program
            self.Disease = Disease
        }
        init(otherObject:MenuParamsFormat) {
            self.MenuHD = otherObject.MenuHD
            self.Episode = otherObject.Episode
            self.MenuDT = otherObject.MenuDT
            self.Program = otherObject.Program
            self.Disease = otherObject.Disease
        }

        func copy() -> MenuParamsFormat {
            return MenuParamsFormat(otherObject: self)
        }

        func isDifferent(otherObject:MenuParamsFormat) -> Bool {
            var ret = false

            // 介入計画ヘッダー
            if self.MenuHD.MenuSetName != otherObject.MenuHD.MenuSetName
                || self.MenuHD.MenuStatus != otherObject.MenuHD.MenuStatus
                || self.MenuHD.CustomerID != otherObject.MenuHD.CustomerID
                || self.MenuHD.MenuSetStaffID != otherObject.MenuHD.MenuSetStaffID
                || self.MenuHD.MenuSetStaffName != otherObject.MenuHD.MenuSetStaffName
                || self.MenuHD.MenuSetStaffNameKana != otherObject.MenuHD.MenuSetStaffNameKana
                || self.MenuHD.CriteriaAssID != otherObject.MenuHD.CriteriaAssID
                || self.MenuHD.MenuGroupID != otherObject.MenuHD.MenuGroupID
                || self.MenuHD.MenuOrderNo != otherObject.MenuHD.MenuOrderNo
                || self.MenuHD.UpdateDateTime != otherObject.MenuHD.UpdateDateTime
                || self.MenuHD.CreateDateTime != otherObject.MenuHD.CreateDateTime
            {
                ret = true
            }

            // エピソード
            if self.Episode.EpisodeID != otherObject.Episode.EpisodeID
                || self.Episode.EpisodeName != otherObject.Episode.EpisodeName
            {
                ret = true
            }

            // 介入計画詳細リスト
            if self.MenuDT.count != otherObject.MenuDT.count
            {
                ret = true
            }
            else
            {
                for i in 0 ..< self.MenuDT.count {
                    if self.MenuDT[i]?.Day != otherObject.MenuDT[i]?.Day
                        || self.MenuDT[i]?.BLogGroupID != otherObject.MenuDT[i]?.BLogGroupID
                        || self.MenuDT[i]?.BLogSubGroupID != otherObject.MenuDT[i]?.BLogSubGroupID
                        || self.MenuDT[i]?.OrderNo != otherObject.MenuDT[i]?.OrderNo
                        || self.MenuDT[i]?.RecommendationKB != otherObject.MenuDT[i]?.RecommendationKB
                    {
                        ret = true
                        break
                    }
                }
            }

            // 臨床プログラムリスト
            if self.Program.count != otherObject.Program.count
            {
                ret = true
            }
            else
            {
                for i in 0 ..< self.Program.count {
                    if self.Program[i]?.MenuID != otherObject.Program[i]?.MenuID
                        || self.Program[i]?.MenuName != otherObject.Program[i]?.MenuName
                    {
                        ret = true
                        break
                    }
                }
            }

            // 傷病名リスト
            if self.Disease.count != otherObject.Disease.count
            {
                ret = true
            }
            else
            {
                for i in 0 ..< self.Disease.count {
                    if self.Disease[i]?.MainNumber != otherObject.Disease[i]?.MainNumber
                        || self.Disease[i]?.MainName != otherObject.Disease[i]?.MainName
                        || self.Disease[i]?.MainNameKana != otherObject.Disease[i]?.MainNameKana
                        || self.Disease[i]?.ICD10 != otherObject.Disease[i]?.ICD10
                    {
                        ret = true
                        break
                    }

                    // 修飾語リスト
                    if self.Disease[i]?.Modifiers.count != otherObject.Disease[i]?.Modifiers.count
                    {
                        ret = true
                    }
                    else
                    {
                        for j in 0 ..< self.Disease[i]!.Modifiers.count {
                            if self.Disease[i]?.Modifiers[j]?.MdfyNumber != otherObject.Disease[i]?.Modifiers[j]?.MdfyNumber
                                || self.Disease[i]?.Modifiers[j]?.MdfyName != otherObject.Disease[i]?.Modifiers[j]?.MdfyName
                                || self.Disease[i]?.Modifiers[j]?.MdfyNameKana != otherObject.Disease[i]?.Modifiers[j]?.MdfyNameKana
                                || self.Disease[i]?.Modifiers[j]?.MdfyKbn != otherObject.Disease[i]?.Modifiers[j]?.MdfyKbn
                            {
                                ret = true
                                break
                            }
                        }
                    }
                }
            }

            return ret
        }
    }
    // 介入計画ヘッダー
    struct MenuHDParamsFormat {
        var MenuSetName:String?
        var MenuStatus:String?
        var CustomerID:Int?
        var MenuSetStaffID:String?
        var MenuSetStaffName:String?
        var MenuSetStaffNameKana:String?
        var CriteriaAssID:Int?
        var MenuGroupID:Int?
        var MenuOrderNo:Int?
        var UpdateDateTime:String?
        var CreateDateTime:String?
    }
    // エピソード
    struct EpisodeParamsFormat {
        var EpisodeID:Int?
        var EpisodeName:String?
    }
    // 介入計画詳細リスト
    struct MenuDTParamsFormat {
        var Day:Int?
        var BLogGroupID:Int?
        var BLogSubGroupID:Int?
        var OrderNo:Int?
        var RecommendationKB:String?
    }
    // 臨床プログラムリスト
    struct ProgramParamsFormat {
        var MenuID:Int?
        var MenuName:String?
    }
    // 傷病名リスト
    struct DiseaseParamsFormat {
        var MainNumber:Int?
        var MainName:String?
        var MainNameKana:String?
        var ICD10:String?
        var Modifiers:[AppConst.ModifierParamsFormat?]
    }
    // 修飾語リスト
    struct ModifierParamsFormat {
        var MdfyNumber:Int?
        var MdfyName:String?
        var MdfyNameKana:String?
        var MdfyKbn:Int?
    }
    /******************* 介入計画 データフォーマット **********************/


    /******************* 介入結果 データフォーマット **********************/
    // BLogSub
    struct BLogSubFormat {
        var BLogGroupID:Int?
        var BLogSubGroupID:Int?
    }
    // BLogDT
    struct BLogDTFormat {
        var BLogGroupID:Int?
        var BLogSubGroupID:Int?
        var BLogItemID:Int?
    }
    /******************* 介入結果 データフォーマット **********************/


    /******************* 電子カルテ連携 データフォーマット **********************/
    // 介入計画ヘッダー
    struct SOAPHistoryHeaderFormat {
        var SOAPHistoryHeaderID:Int?
        var ReceptionID:Int?
        var SUpdateKbn:String?
        var OUpdateKbn:String?
        var AUpdateKbn:String?
        var PUpdateKbn:String?
        var UpdateDateTime:Date?
        var CreateDateTime:Date?
    }

    //
    struct KarteAssDTFormat {
        var AssID:Int?
        var AssMenuGroupID:Int?
        var AssMenuSubGroupID:Int?
        var AssItemID:Int?
        var SEQNO:Int?
        var AssChoicesAsr:String?
        var TakeoverFlg:String?
    }

    // 介入計画ヘッダー
    struct KarteMenuHDParamsFormat {
        var MenuSetName:String?
        var MenuStatus:String?
        var CustomerID:Int?
        var CriteriaAssID:Int?
        var MenuGroupID:Int?
        var MenuOrderNo:Int?
        var CreateDateTime:String?
        var MenuInfoList:[ProgramParamsFormat]
        var MnameInfoList:[DiseaseParamsFormat]
    }
    // 介入計画詳細リスト
    struct KarteMenuDTParamsFormat {
        var MenuGroupID:Int?
        var Day:Int?
        var BLogGroupID:Int?
        var BLogSubGroupID:Int?
        var OrderNo:Int?
    }

    // 介入結果ヘッダー
    struct KarteBLogSubHDParamsFormat {
        var BLogGroupID:Int?
        var BLogSubGroupID:Int?
        var BLogSEQNO:Int?
        var TreatmentDateTIme:Date?
    }
    // 介入結果詳細
    struct KarteBLogDTParamsFormat {
        var BLogGroupID:Int?
        var BLogSubGroupID:Int?
        var BLogSEQNO:Int?
        var BLogItemID:Int?
        var SEQNO:Int?
        var BLogChoicesAsr:String?
    }
    /******************* 電子カルテ連携 データフォーマット **********************/

}
