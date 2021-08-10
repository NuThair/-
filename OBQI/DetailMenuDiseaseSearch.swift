//
//  MasterProgramList.swift
//  OBQI
//
//  Created by t.o on 2017/01/26.
//  Copyright © 2017年 System. All rights reserved.
//


import UIKit

class DetailMenuDiseaseSearch: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()

    // 検索モード
    enum SearchMode : String {
        case PARTIAL = "部分"
        case PREFIX = "前方"
        case SUFFIX = "後方"
        case PERFECT = "完全"
    }
    var SearchModeCases: [SearchMode] {
        return [.PARTIAL, .PREFIX, .SUFFIX, .PERFECT]
    }

    // 検索対象
    enum SearchTarget : String {
        case ALL = "傷病名+ICD10"
        case NAME = "傷病名"
        case CODE = "ICD10"
        case HISTORY = "履歴"
    }
    var SearchTargetCases: [SearchTarget] {
        return [.ALL, .NAME, .CODE, .HISTORY]
    }

    // 最大検索件数
    let limitSearchResultCount = 50
    // 検索結果配列
    var searchResults = [JSON]()

    // 選択中の検索オプション
    var currentSearchMode : SearchMode = SearchMode.PARTIAL
    var currentSearchTarget: SearchTarget = SearchTarget.ALL

    // 履歴テーブル
    var historyTable:JSON?

    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var mySearchBar: UISearchBar!
    @IBOutlet weak var mySegmentedControl: UISegmentedControl!
    @IBOutlet weak var SearchModeButton: UIButton!
    @IBOutlet weak var SearchOptionAreaButtomMargin: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Cell名の登録をおこなう.
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")

        // DataSourceの設定をする.
        myTableView.dataSource = self

        // Delegateを設定する.
        myTableView.delegate = self

        // 検索バーの設定
        mySearchBar.delegate = self
        mySearchBar.showsBookmarkButton = false
        mySearchBar.showsSearchResultsButton = false
        mySearchBar.placeholder = "傷病名またはICD10を入力してください"

        // 検索オプションの設定
        SearchModeButton.setTitle(SearchMode.PARTIAL.rawValue, for: UIControl.State.normal)
        currentSearchMode = SearchMode.PARTIAL
        currentSearchTarget = SearchTarget.ALL

        // 履歴テーブル
        let url = "\(AppConst.URLPrefix)dictionary/GetNmainHistory"
        let res = appCommon.getSynchronous(url)
        if AppCommon.isNilOrEmpty(res.errCode) {
            historyTable = JSON(string: res.result!) // JSON読み込み
        }

    }

    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startObserveKeyboardNotification()
        mySearchBar.becomeFirstResponder()
        print("viewWillApper")
    }

    // 画面が破棄される都度
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopOberveKeyboardNotification()
        print("viewWillDisappear")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    /*
     テーブルに表示する配列の総数を返す.
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    /*
     Cellに値を設定する.
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "MyCell")
        let index = (indexPath as NSIndexPath).row

        cell.textLabel?.text = searchResults[index]["MainName"].asString
        cell.detailTextLabel?.text = searchResults[index]["ICD10"].asString

        return cell
    }

    /*
     Cellが選択された際に呼び出される.
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = (indexPath as NSIndexPath).row

        // キーボード閉じる
        self.view.endEditing(true)

        // アラートアクションの設定
        var actionList = [(title: String , style: UIAlertAction.Style ,action: (UIAlertAction) -> Void)]()

        // キャンセルアクション
        actionList.append(
            (
                title: "キャンセル",
                style: UIAlertAction.Style.cancel,
                action: {
                    (action: UIAlertAction!) -> Void in
                    print("Cancel")
            })
        )

        // 決定アクション
        actionList.append(
            (
                title: "決定",
                style: UIAlertAction.Style.default,
                action: {
                    (action: UIAlertAction!) -> Void in
                    print("Decide")

                    // 選択したデータを保持
                    let selectedDisease = AppConst.DiseaseParamsFormat(
                        MainNumber: self.searchResults[index]["MainNumber"].asInt!,
                        MainName: self.searchResults[index]["MainName"].asString!,
                        MainNameKana: self.searchResults[index]["MainNameKana"].asString!,
                        ICD10: self.searchResults[index]["ICD10"].asString!,
                        Modifiers: []
                    )

                    // 選択済みインデックスにより処理分岐
                    if let diseaseIndex = self.appDelegate.SelectedDiseaseIndex { // 更新
                        self.appDelegate.MenuParamsTmp.Disease[diseaseIndex] = selectedDisease

                    } else { // 追加
                        self.appDelegate.MenuParamsTmp.Disease.append(selectedDisease)
                    }
                    
                    // 傷病名一覧画面へ戻る
                    _ = self.navigationController?.popViewController(animated: true)
            })
        )

        let messageText = "傷病名：\(searchResults[index]["MainName"].asString!)\nICD10：\(searchResults[index]["ICD10"].asString!)"
        AppCommon.alertAnyAction(controller: self, title: "以下の傷病名でよろしいでしょうか？", message: messageText, actionList: actionList)

        // 選択を外す
        myTableView.deselectRow(at: indexPath, animated: true)
    }

    /*
     テキストが変更される毎に呼ばれる
     */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchDisease(convertSearchText(searchText))
    }

    /*
     Searchボタンが押された時に呼ばれる
     */
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // キーボード閉じる
        self.view.endEditing(true)
    }

    /*
     検索モード変更
     */
    @IBAction func clickSearchMode(_ sender: UIButton) {
        // 次の検索モードを表示する 完全まで行ったら部分に戻る
        let nextIndex = ((SearchModeCases.index(of: currentSearchMode))! + 1) % SearchModeCases.count
        SearchModeButton.setTitle(SearchModeCases[nextIndex].rawValue, for: UIControl.State.normal)
        currentSearchMode = SearchModeCases[nextIndex]

        // モードが変わったら再検索
        searchDisease(convertSearchText(mySearchBar.text!))
    }

    /*
     検索ターゲット変更
     */
    @IBAction func clickSearchTarget(_ sender: UISegmentedControl) {
        // 選択中のターゲットを格納
        currentSearchTarget = SearchTargetCases[sender.selectedSegmentIndex]

        // ターゲットが変わったら再検索
        searchDisease(convertSearchText(mySearchBar.text!))
    }

    /*
     検索処理
     */
    private func searchDisease(_ searchText:String) {

        // 検索対象テーブル
        var searchTable:JSON?
        // 0文字検索許可フラグ
        var isSearchable = false

        // 条件生成 検索ターゲット
        var whereTargets = [String]()
        switch currentSearchTarget {
        case SearchTarget.ALL: // 傷病名+ICD10
            // 検索対象テーブル
            searchTable = appDelegate.MstNmain400
            // 検索対象カラム
            whereTargets = ["MainName", "MainNameKana", "ICD10"]
            break

        case SearchTarget.NAME: // 傷病名
            // 検索対象テーブル
            searchTable = appDelegate.MstNmain400
            // 検索対象カラム
            whereTargets = ["MainName", "MainNameKana"]
            break

        case SearchTarget.CODE: // ICD10
            // 検索対象テーブル
            searchTable = appDelegate.MstNmain400
            // 検索対象カラム
            whereTargets = ["ICD10"]
            break

        case SearchTarget.HISTORY: // 履歴
            searchTable = historyTable

            // 検索対象カラム
            whereTargets = ["MainName", "MainNameKana", "ICD10"]
            // 0文字検索許可
            isSearchable = true
        }

        // 0文字検索許可判定
        if !isSearchable && AppCommon.isNilOrEmpty(searchText) {

            // 表示内容リセット
            searchResults = [JSON]()
            myTableView.reloadData()

            return
        }


        // 条件生成 検索モード
        let closure: (_ targetWord: String, _ searchText: String) -> Bool
        switch currentSearchMode {
        case SearchMode.PARTIAL: // 部分
            closure = {
                (targetWord: String, searchText: String) -> Bool in

                return AppCommon.isNilOrEmpty(searchText) || targetWord.contains(searchText)
            }
            break

        case SearchMode.PREFIX: // 前方
            closure = {
                (targetWord: String, searchText: String) -> Bool in

                return targetWord.hasPrefix(searchText)
            }
            break

        case SearchMode.SUFFIX: // 後方
            closure = {
                (targetWord: String, searchText: String) -> Bool in

                return targetWord.hasSuffix(searchText)
            }
            break

        case SearchMode.PERFECT: // 完全
            closure = {
                (targetWord: String, searchText: String) -> Bool in

                return AppCommon.isNilOrEmpty(searchText) || targetWord == searchText
            }
            break
        }

        // 生成された条件で検索
        searchResults = (searchTable?
            .filter{
                (mstObj: (AnyObject, JSON)) -> Bool in
                
                // 検索ターゲットのいずれかにマッチすればtrue
                var result: Bool = false
                
                whereTargets.forEach{ (target) in
                    if result { return }
                    guard let targetWord = mstObj.1[target].asString else {
                        return
                    }
                    result = closure(targetWord, searchText)
                }
                
                return result
                
            }
            .map{
                $0.1
            })!

        // 上限検索件数に設定
        searchResults = searchResults.enumerated()
            .filter{
                $0.0 < limitSearchResultCount
            }
            .map{
                $0.1
            }

        // テーブルリロード
        myTableView.reloadData()
    }


    /*
     検索用文字列へ変換
     */
    private func convertSearchText(_ searchText: String) -> String {
        // ひらがな->カタカナ
        var convertedText = searchText.toKatakana()
        // 半角カナ->全角カナ
        convertedText = convertedText.transformFullwidthHalfwidth(transformTypes: [.Katakana], reverse: true)
        // 全角英数->半角英数
        convertedText = convertedText.transformFullwidthHalfwidth(transformTypes: [.English, .Numeric])
        // 半角小文字->半角大文字
        convertedText = convertedText.uppercased()

        return convertedText
    }

}

extension DetailMenuDiseaseSearch {
    /** キーボードのNotificationを購読開始 */
    func startObserveKeyboardNotification(){
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(type(of: self).willShowKeyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(type(of: self).willHideKeyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    /** キーボードのNotificationの購読停止 */
    func stopOberveKeyboardNotification(){
        let center = NotificationCenter.default
        center.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        center.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    /** キーボードが開いたときに呼び出されるメソッド */
    @objc private func willShowKeyboard(notification:NSNotification){
        NSLog("willShowKeyboard called.")

        let duration = notification.duration()
        let rect = notification.rect()
        if let duration = duration,let rect = rect {
            self.view.layoutIfNeeded()
            self.SearchOptionAreaButtomMargin.constant = rect.size.height - self.bottomLayoutGuide.length;
            UIView.animate(withDuration: duration, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
    }
    /** キーボードが閉じたときに呼び出されるメソッド */
    @objc func willHideKeyboard(notification:NSNotification){
        NSLog("willHideKeyboard called.")

        let duration = notification.duration()
        if let duration=duration {
            self.view.layoutIfNeeded()
            self.SearchOptionAreaButtomMargin.constant=0
            UIView.animate(withDuration: duration,animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
    }
}
