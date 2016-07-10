//
//  AppDelegate.swift
//  MeetUp
//
//  Created by Chris Duan on 16/02/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import UIKit
import CoreData
import Fabric
import DigitsKit
import Crashlytics
import FBSDKCoreKit
import PonyDebugger

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    //time to expire in milliseconds
    static var SESSION_TIME_TO_EXPIRE: NSNumber?

    var window: UIWindow?
    static let plistDic = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("GlobalVariable", ofType: "plist")!)

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Fabric.with([Digits.self, Crashlytics.self])
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let user = ModelFactory.sharedInstance.provideUserDefaults().getUserFromDefaults()
        
        if user == nil {
            setLoginRootViewController(false)
        } else if user!.userName!.isEmpty {
            setLoginRootViewController(true)
        } else {
            setMainRootViewController()
        }
        
        window?.makeKeyAndVisible()

        //PONY DEBUGGER
//        let debugger = PDDebugger.defaultInstance()
//        let url = NSURL(string: "ws://192.168.1.65:9000/device")
//        debugger.connectToURL(url)
//        debugger.forwardAllNetworkTraffic()
//        debugger.enableNetworkTrafficDebugging()
//        debugger.enableCoreDataDebugging()
//        debugger.addManagedObjectContext(self.managedObjectContext)
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func setMainRootViewController() {
        let mainViewController = MainViewController(nibName: "MainViewController", bundle: nil)
        let navigationController = UINavigationController(rootViewController: mainViewController)
        navigationController.navigationBar.tintColor = UIColor().primaryColor()
        window?.rootViewController = navigationController
        
        setBarButtonItemFontStyle()
    }
    
    func setLoginRootViewController(isUserExists: Bool) {
        let loginViewController = isUserExists ? InitialPermissionController(nibName: "InitialPermissionController", bundle: nil) : LoginViewController(nibName: "LoginViewController", bundle: nil)
        window?.rootViewController = loginViewController
        
        setBarButtonItemFontStyle()
    }
    
    private func setBarButtonItemFontStyle() {
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName : MeetUpAttributedString.sharedInstance.getCustomFont(MeetUpAttributedString.CustomFontTypeface.semiBold, size: 17.0)], forState: .Normal)
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        PushNotification.sharedInstance.requestLocationWithTimer(appActive: false)
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        PushNotification.sharedInstance.requestLocationWithTimer(appActive: true)
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    //MARK: PUSH NOTIFICATION
    func registerForPushNotifications(application: UIApplication) {
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Sound, .Alert], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != .None {
            application.registerForRemoteNotifications()
        } else {
            let rootVc = self.window?.rootViewController!.childViewControllers[0] as! BaseViewController
            rootVc.showAlert(NSLocalizedString(GlobalString.push_denied_title,
                comment: "push notification denied title"),
                             message: NSLocalizedString(GlobalString.push_denied_msg, comment: "push permission denied message"),
                             buttons: [NSLocalizedString(GlobalString.alert_button_ok, comment: "button_ok")], onOkClicked: {_ in},
                             onSecondButtonClicked: nil)
        }
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        ModelFactory.sharedInstance.providePushChannelModel().registerPushChannel(deviceToken)
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        PushNotification.sharedInstance.receivePushMessage(userInfo)
        completionHandler(.NoData)
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.estimeet.MeetUp" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("MeetUp", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

