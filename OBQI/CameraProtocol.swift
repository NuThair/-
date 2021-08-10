//
//  CameraProtocol.swift
//  OBQI
//
//  Created by t.o on 2017/03/22.
//  Copyright © 2017年 System. All rights reserved.
//

// 押下されたパーツに応じたデータをセット
protocol CameraProtocol: class {
    /*
     画像を保存
     */
    func savePhoto(fileString: String) -> Bool
}
