//
//  SchemaProtocol.swift
//  OBQI
//
//  Created by t.o on 2017/03/17.
//  Copyright © 2017年 System. All rights reserved.
//

// 押下されたパーツに応じたデータをセット
protocol SchemaProtocol: class {
    /*
     選択されたパーツに紐づくデータを取得
     */
    func getSelectedSchemaData(groupID: Int, subGroupID: Int, imgPartsNo: Int) -> JSON?
    /*
     パーツが登録済みかどうか判定
     */
    func checkSelected(groupID: Int, subGroupID: Int, imgPartsNo: Int) -> Bool

    /************************ シェーマパーツ選択時 ***********************/
    /*
     次の画面へ遷移
     */
    func moveNextView(selectedSchemaData: JSON?)

    /*
     シェーマを登録
     */
    func saveItem(selectedSchemaData: JSON?)

    /*
     シェーマを削除
     */
    func deleteItem(selectedSchemaData: JSON?)

    /*
     シェーマを全削除
     */
    func deleteItemAll()
    /************************ シェーマパーツ選択時 ***********************/

}
