//
//  ModalBLogCamera.swift
//  OBQI
//
//  Created by t.o on 2017/03/22.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class ModalBLogBarcode: BarcodeBaseController{
    let bLogCommon = BLogCommon()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}


// 抽象メソッドの実装
extension ModalBLogBarcode: BarcodeProtocol {
    /*
     stringに変換されたバーコード情報を取得
     */
    func setDecodedString(decodedString: String){
        let parentSplitView = self.presentingViewController as! UISplitViewController
        let parentNavi = parentSplitView.viewControllers[1] as! UINavigationController
        let parentView = parentNavi.topViewController as! DetailBLogBarcode

        parentView.InputText.text = decodedString
        if decodedString == "" {
            parentView.ErrorLabel.text = ""
            return
        }
        if parentView.selectedMstBLogDT?["InputValueID"].asString! == AppConst.InputValueID.NUM.rawValue
        {
            let val = decodedString.toDouble()
            print("val: \(val)")
            if val == nil {
                parentView.ErrorLabel.text = "半角数値で入力してください。"
                return
            } else {
                parentView.ErrorLabel.text = ""
                return
            }
        }
    }
}
