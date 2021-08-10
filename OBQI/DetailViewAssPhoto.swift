//
//  DetailViewAssPhoto.swift
//  OBQI
//
//  Created by t.o on 2017/01/20.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit


class DetailViewAssPhoto: UIViewController,UIScrollViewDelegate {
    // 入力値
    var inputAssList : JSON?

    var imageView: UIImageView!
    var scrollView: UIScrollView!

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    // 写真ボタンを入れる
    var subViewButtons : [UIButton] = []
    // 選択されているSEQNO
    var selectedSeqNo : Int?
    // 写真アセスメントのリスト
    var trnAssessmentList : JSON?


    override func viewDidLoad() {
        super.viewDidLoad()

        // Viewの高さと幅を取得する.
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        // 画面一杯
        scrollView = UIScrollView()
        imageView = UIImageView()
        scrollView.frame = self.view.bounds
        imageView.frame = self.view.bounds
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        // ScrollView設定
        self.scrollView.delegate = self
        self.scrollView.minimumZoomScale = 1
        self.scrollView.maximumZoomScale = 8
        self.scrollView.isScrollEnabled = true
        self.scrollView.showsHorizontalScrollIndicator = true
        self.scrollView.showsVerticalScrollIndicator = true

        let doubleTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self
            , action:#selector(DetailViewAssPhoto.doubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        self.imageView.isUserInteractionEnabled = true
        self.imageView.addGestureRecognizer(doubleTapGesture)

        // UIボタンを作成.
        let closeButton = UIButton(frame: CGRect(x: 0,y: 0,width: 180,height: 50))
        closeButton.backgroundColor = UIColor.photoViewButton().withAlphaComponent(0.7)
        closeButton.layer.masksToBounds = true
        closeButton.setTitle("閉じる", for: UIControl.State())
        closeButton.layer.cornerRadius = 10.0
        closeButton.layer.position = CGPoint(x: (displayWidth/2), y:displayHeight-50)
        closeButton.addTarget(self, action: #selector(DetailViewAssPhoto.ClickClose(_:)), for: .touchUpInside)
        closeButton.setTitleColor(UIColor.gray, for: .highlighted)


        //
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(imageView)

        // UIボタンをViewに追加.
        self.view.addSubview(closeButton);
    }

    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {

        // Viewの高さと幅を取得する.
        let displayWidth: CGFloat = self.view.bounds.width

        // 写真アセスメントを全て取得する
        let assCommon = AssCommon()
        trnAssessmentList = assCommon.getPhotoAssessmentList()
        // 一旦全てのボタンを削除する
        for i in 0 ..< subViewButtons.count {
            subViewButtons[i].removeFromSuperview()
        }
        subViewButtons = [] // 初期化
        selectedSeqNo = nil
        // 写真ボタンの追加
        let haba : CGFloat = 100 // ボタンを動かす幅
        let centerX : CGFloat = (displayWidth/2)
        var x : CGFloat
        let y : CGFloat = 50
        for i in 0..<trnAssessmentList!.length {
            if i >= 10 {
                break
            }
            let trn = trnAssessmentList![i]
            let seqNo = trn["SEQNO"].asInt!
            let count = i
            x = centerX + ((CGFloat(count) - 4.5) * haba)
            // UIボタンを作成.
            let button = UIButton(frame: CGRect(x: 0,y: 0,width: 70,height: 30))
            button.addTarget(self, action: #selector(DetailViewAssPhoto.onClickPhotoButton(_:)), for: .touchUpInside)
            button.setTitle("写真\(i+1)", for: UIControl.State())
            if i == 0 { // 一つ目が選択状態
                button.titleLabel!.font = UIFont(name: "Helvetica-Bold",size: CGFloat(20))
                selectedSeqNo = seqNo
            } else {
                button.titleLabel!.font = UIFont(name: "Helvetica",size: CGFloat(20))
            }
            button.layer.position = CGPoint(x: x, y: y)
            button.setTitleColor(UIColor.textBlue(), for: UIControl.State())
            button.setTitleColor(UIColor.textBlue().withAlphaComponent(0.3), for: .highlighted)
            button.tag = trn["SEQNO"].asInt!
            // UIボタンをViewに追加.
            self.view.addSubview(button);
            // あとで削除するため保存する
            subViewButtons.append(button)
        }

        if selectedSeqNo != nil {
            // ファイルの取得
            let uiButton = UIButton()
            uiButton.tag = selectedSeqNo!
            onClickPhotoButton(uiButton)
        } else {
            let image = UIImage(named: "noimage.jpg")
            imageView.image = image
        }
    }
    /*
     写真ボタンクリックイベント.
     */
    @objc func onClickPhotoButton(_ sender: UIButton) {
        print("onClickPhotoButton")
        print(sender.tag)
        // tagにSEQNOが設定されている
        selectedSeqNo = sender.tag

        for i in 0 ..< subViewButtons.count {
            if subViewButtons[i].tag == selectedSeqNo { // 選択状態
                subViewButtons[i].titleLabel!.font = UIFont(name: "Helvetica-Bold",size: CGFloat(20))
            } else {
                subViewButtons[i].titleLabel!.font = UIFont(name: "Helvetica",size: CGFloat(20))
            }
        }


        // ファイルの取得
        let customerID = appDelegate.SelectedCustomer!["CustomerID"].asString!
        let assID = appDelegate.SelectedAssAssID!
        let menuGroupID = appDelegate.SelectedMstAssessmentItem!["AssMenuGroupID"].asInt!
        let menuSubGroupID = appDelegate.SelectedMstAssessmentItem!["AssMenuSubGroupID"].asInt!
        let assessmentID = appDelegate.SelectedMstAssessmentItem!["AssItemID"].asInt!

        let url = "\(AppConst.URLPrefix)assessment/GetAssPhotoFileBase64String/\(customerID)/\(assID)/\(menuGroupID)/\(menuSubGroupID)/\(assessmentID)/\(selectedSeqNo!)"
        let res = appCommon.getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            AppCommon.alertMessage(controller: self, title: "エラー(\(res.errCode!))", message: "写真の取得に失敗しました。")
            return
        }

        let decodedData = Data(base64Encoded: res.result! as String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
        var image : UIImage!
        if decodedData != nil && (decodedData?.count)! > 0 {
            image = UIImage(data: decodedData!)
        } else {
            image = UIImage(named: "noimage.jpg")
        }
        imageView.image = image
    }

    // ピンチイン・ピンチアウト
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        //print("pinch")
        return self.imageView
    }
    // ダブルタップ
    @objc func doubleTap(_ gesture: UITapGestureRecognizer) -> Void {

        print(self.scrollView.zoomScale, terminator: "")
        if ( self.scrollView.zoomScale < self.scrollView.maximumZoomScale ) {

            let newScale:CGFloat = self.scrollView.zoomScale * 3
            let zoomRect:CGRect = self.zoomRectForScale(newScale, center: gesture.location(in: gesture.view))
            self.scrollView.zoom(to: zoomRect, animated: true)

        } else {
            self.scrollView.setZoomScale(1.0, animated: true)
        }
    }
    // 領域
    func zoomRectForScale(_ scale:CGFloat, center: CGPoint) -> CGRect{
        var zoomRect: CGRect = CGRect()
        zoomRect.size.height = self.scrollView.frame.size.height / scale
        zoomRect.size.width = self.scrollView.frame.size.width / scale

        zoomRect.origin.x = center.x - zoomRect.size.width / 2.0
        zoomRect.origin.y = center.y - zoomRect.size.height / 2.0

        return zoomRect
    }



    @IBAction func ClickClose(_ sender: AnyObject) {
        // 閉じる
        self.dismiss(animated: true, completion: nil)
    }
    /*
     戻る
     */
    override func viewWillDisappear(_ animated: Bool) {
        print("back")
        super.viewWillDisappear(animated)
    }
    
}
