//
//  MasterProgramList.swift
//  OBQI
//
//  Created by t.o on 2017/01/26.
//  Copyright © 2017年 System. All rights reserved.
//


import UIKit

class DetailMenuSetNameInput: UIViewController {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()

    @IBOutlet weak var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillApper")

        textField.text = appDelegate.MenuParamsTmp.MenuHD.MenuSetName
        textField.becomeFirstResponder()
    }

    // 値を更新する
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        appDelegate.MenuParamsTmp.MenuHD.MenuSetName = textField.text!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
