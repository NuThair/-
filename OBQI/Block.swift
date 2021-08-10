//
//  Block.swift
//  OBQI
//
//  Created by t.o on 2017/04/18.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class Block {
    // 背景色
    var overlay: UIView?
    // インジケータ
    var myIndiator: UIActivityIndicatorView?

    /*
     ブロックUI表示
     */
    public func showBlockUI(_ view : UIView) {
        // 背景色
        overlay = UIView(frame: view.frame)
        overlay?.backgroundColor = UIColor.black
        overlay?.alpha = 0.4

        // インジケータを生成.
        myIndiator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        myIndiator?.center = view.center
        myIndiator?.hidesWhenStopped = true
        myIndiator?.style = UIActivityIndicatorView.Style.whiteLarge
        myIndiator?.alpha = 0.0

        // UIACtivityIndicatorを表示.
        myIndiator?.startAnimating()

        // viewに追加.
        view.addSubview(overlay!)
        view.addSubview(myIndiator!)

        // 最前面に移動
        view.bringSubviewToFront(overlay!)
        view.bringSubviewToFront(myIndiator!)

        /*
         * フェードイン
         */
        UIView.animate(withDuration: 0.8, delay: 0.3, options: UIView.AnimationOptions.curveEaseInOut,
                       animations: {() -> Void in
                        self.myIndiator?.alpha = 1.0
        },
                       completion: {(finished: Bool) -> Void in
        })
    }

    /*
     ブロックUI解除
     */
    public func hideBlockUI() {
        // viewから削除
        overlay!.removeFromSuperview()
        myIndiator!.removeFromSuperview()
    }
}
