//
//  MenuEpisodeTextInput.swift
//  OBQI
//
//  Created by t.o on 2017/01/26.
//  Copyright © 2017年 System. All rights reserved.
//


import UIKit

class MenuEpisodeTextInput: UIViewController {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()

    var parentView:ModalMenuEpisodeCreate?

    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // 遷移元取得
        let navc = self.navigationController!
        parentView = navc.viewControllers[navc.viewControllers.count - 2] as? ModalMenuEpisodeCreate
    }

    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillApper")

        textView.text = parentView?.InputText
        textView.becomeFirstResponder()
    }

    // 値を更新する
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        parentView?.InputText = textView.text!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
