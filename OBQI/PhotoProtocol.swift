//
//  PhotoProtocol.swift
//  OBQI
//
//  Created by t.o on 2017/03/22.
//  Copyright © 2017年 System. All rights reserved.
//

// 押下されたパーツに応じたデータをセット
protocol PhotoProtocol: class {
    /*
     画像全件取得
     */
    func getPhotoFileList() -> [JSON?]

    /*
     表示する画像を変更
     */
    func showPhoto(seq: Int?)
    
    /*
     画像を保存
     */
    func savePhoto(fileString: String)
}
