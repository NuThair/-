//
//  AppDelegate.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/10/13.
//  Copyright © 2016年 System. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // ログイン時に使用
    var delegate: LoginViewControllerDelegate!
    var IsFirst = true

    // 各大きさ
    var statusBarHeight:CGFloat?
    var navBarHeight :CGFloat?
    var navBarWidth :CGFloat?
    var detailNavBarWidth :CGFloat?
    var tabBarHeight :CGFloat?
    var tabBarWidth :CGFloat?
    var availableViewHeight :CGFloat? //self.view.frame.size.heightからstatusBarHeight,navbarHeight, tabbarHeightを引いたもの
    var availableDetailViewHeight :CGFloat? //self.view.frame.size.heightからstatusBarHeight,navbarHeightを引いたもの
    var layerWidth :CGFloat?
    var layerHeight :CGFloat?
    var barHeight :CGFloat?
    
    // 起動時の読み込みステータス
    var loadVersion : Bool! = false
    var loadMaster : Bool! = false

    // ログイン情報
    var LoginInfo : JSON?
    
    // マスタ情報
    // AssessmentGroupList
    var MstAssessmentGroupList : JSON?
    var MstAssessmentSubGroupList : JSON?
    var MstAssessmentList : JSON?
    var RequiredMstAssessmentList : [JSON] = []
    var MstAssImagePartsList : JSON?
    var MstUpdatePatternList : JSON?
    var MstOutcomeList : JSON?
    var MstBusinessLogHDList : JSON?
    var MstBusinessLogSubHDList : JSON?
    var MstBusinessLogDTList : JSON?
    var MstBssImagePartsList : JSON?
    var MstReportAssList : JSON?
    var MstInformedConsentList : JSON?
    var MstSatisfactionList : JSON?
    var MstMenu : JSON?
    var MstMNBLRelation : JSON?
    var MstMenuJobCategoryKB : JSON?
    var MstNmain400 : JSON?
    var MstMdfy400 : JSON?
    var MstIndex400 : JSON?
    var ViewDrug : JSON?
    var MstBui : JSON?
    var MstOrderRelation : JSON?
    var ErrorMessageList : JSON?
    
    // Version
    var Version : String?
    // 取得した画像を一時保存
    var ImageList : Dictionary<String, UIImage> = [:]
    // 選択されたカスタマー情報
    var SelectedCustomer : JSON?
    
    
    // 選択されたエピソード
    var SelectedEpisodeID : Int?
    var ChangeEpisode : Bool! = false
    var ChangeEpisodeStatus : Bool! = false
    var EpisodeStatusChangeMode : String?
    var EpisodeRestartReason : String?
    var EpisodeRestartDate : String?
    var EpisodeEndReason : String?
    var EpisodeEndDate : String?
    // インフォームド・コンセント
    var SelectedIC : JSON?
    var ChangeIC : Bool! = false
    
    // 選択されているAssID(Assessment)
    var SelectedAssAssID : Int?
    // 入力されたアセスメント
    var InputAssList : JSON?
    var ChangeInputAssFlagForShcema : Bool! = false
    var ChangeInputAssFlagForList : Bool! = false
    var CaptureBarcode : String?

    // 選択されたアセスメントグループ
    var SelectedMstAssessmentGroup : [String:JSON]?
    // 選択されたアセスメントサブグループ
    var SelectedMstAssessmentSubGroup : JSON?
    // 選択されているアセスメントアイテム
    var SelectedMstAssessmentItem : JSON?
    // 選択されているImagePartsNo(Assessment)
    var SelectedAssImagePartsNo : Int?
    // アセスメント初期表示時
    var IsFirstAssMenu = false
    var IsFirstAssSubMenu = false
    // 選択されているAssHD
    var SelectedAssHD : JSON?

    
    // 選択されているAssID(Business)
    var SelectedBssAssID : Int?

    // 満足度
    var SelectedOutcom : JSON?
    var SelectedOutcomeDT : JSON?
    var SelectedOutcomeKbn : String?
    var EndOutcome : Bool! = false
    // 現在の満足度調査の番号
    var SelectedSatisfactionNo : Int! = 0

    // 満足度が終わった時にトップ画面に戻すため
    var IsEndMan : Bool! = false

    // 介入計画
    var CurrentMenuEditMode : AppConst.Mode?
    var MenuParams = AppConst.MenuParamsFormat()
    var MenuParamsTmp = AppConst.MenuParamsFormat()
    var SelectedDiseaseIndex: Int?
    var SelectedModifierIndex: Int?

    // 介入結果
    var SelectedBLogSub = AppConst.BLogSubFormat()
    var SelectedBLogDT = AppConst.BLogDTFormat()
    var trnBLogSubHD:JSON?
    var trnBLogDTList:JSON?
    var inputTreatmentDateTime:String?
    var SelectedBLogImgPartsNo:Int?
    var BLogisChanged = false
    let BLogNotificationName = NSNotification.Name(rawValue: "reCheck")

    //-------------------------------- 電子カルテ連携 -------------------------------------
//    let SOAPNotificationName = NSNotification.Name(rawValue: "initSOAP")
//    let OrderNotificationName = NSNotification.Name(rawValue: "initOrder")

    var KarteReceptionList:[JSON?] = []
    var SelectedReception:JSON?
    var RelatedAssessment:[JSON?] = []

    // ヘッダー
    var SOAPHistoryHeaderList:[AppConst.SOAPHistoryHeaderFormat] = []

    // SOA
    var KarteSOA:KarteSOAClass?

    // P
    var KartePlan:KartePlanClass?

    // オーダー
    var KarteOrderList:[KarteOrderClass?] = []
    var SelectedSameDayBLogSubHDList:[JSON?] = []
    var SelectedKarteHistory:JSON? = nil
    //-------------------------------- 電子カルテ連携 -------------------------------------


    var window: UIWindow?


    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "OBQI")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "org.orangeact.app.SkinFloraME" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "OBQI", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("OBQI.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            //error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict as [NSObject : AnyObject])
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error ?? nil ), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
    }()
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        //var managedObjectContext = NSManagedObjectContext()
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()


    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

