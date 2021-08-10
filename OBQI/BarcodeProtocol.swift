//
//  CameraProtocol.swift
//  OBQI
//
//  Created by t.o on 2017/03/22.
//  Copyright © 2017年 System. All rights reserved.
//

// 押下されたパーツに応じたデータをセット
protocol BarcodeProtocol: class {
    /*
     stringに変換されたバーコード情報を取得
     */
    func setDecodedString(decodedString: String)
}
