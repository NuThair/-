//
//  KCDelegate.swift
//  OBQI
//
//  Created by t.o on 2017/05/26.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class KCDelegate: UIResponder, UIApplicationDelegate {

    // 電子カルテ連携
    var test = 0
    var SelectedReception:JSON?
    var RelatedAssessment:[JSON?] = []
    var SelectedKarteKbn:AppConst.KarteKbn?
    var SelectableSOAList:[AppConst.KarteKbn:[JSON?]] = [
        AppConst.KarteKbn.SUBJECT:[],
        AppConst.KarteKbn.OBJECT:[],
        AppConst.KarteKbn.ASSESSMENT:[],
        ]
    var CurrentSelectedSOAList:[AppConst.KarteKbn:[(AssMenuGroupID:Int, AssMenuSubGroupID:Int, AssItemID:Int)]] = [
        AppConst.KarteKbn.SUBJECT:[],
        AppConst.KarteKbn.OBJECT:[],
        AppConst.KarteKbn.ASSESSMENT:[],
        ]
    var LastSelectedSOAList:[AppConst.KarteKbn:[(AssMenuGroupID:Int, AssMenuSubGroupID:Int, AssItemID:Int)]]?
    var CurrentSelectedPList:[AppConst.KCMenuDTParamsFormat] = []
    var LastSelectedPList:[AppConst.KCMenuDTParamsFormat] = []
    var NewSelectedPList:[AppConst.KCMenuDTParamsFormat] = []

}
