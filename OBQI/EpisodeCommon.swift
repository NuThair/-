//
//  EpisodeCommon.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/11/28.
//  Copyright © 2016年 System. All rights reserved.
//

import UIKit

class EpisodeCommon {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    
    // EpisodeName更新
    func regEpisodeName(episodeID : Int!, text : String!) {
        let url = "\(AppConst.URLPrefix)episode/PutEpisodeName"
        
        let params: [String: AnyObject] = [
            "EpisodeID": episodeID as AnyObject,
            "EpisodeName": text as AnyObject,
            ]
        _ = appCommon.putSynchronous(url, params: params)
    }
    // EpisodeText更新
    func regEpisodeText(episodeID : Int!, text : String!) {
        let url = "\(AppConst.URLPrefix)episode/PutEpisodeText"
        
        let params: [String: AnyObject] = [
            "EpisodeID": episodeID as AnyObject,
            "EpisodeText": text as AnyObject,
            ]
        _ = appCommon.putSynchronous(url, params: params)
    }
    // エピソード情報の取得
    static func getEpisodeInfo(selectedEipsodeID : Int?) -> JSON {
        let url = "\(AppConst.URLPrefix)episode/GetEpisode/\(selectedEipsodeID!)"
        let appCommon = AppCommon()
        let res = appCommon.getSynchronous(url)
        return JSON(string: res.result!) // JSON読み込み
    }
    
}
