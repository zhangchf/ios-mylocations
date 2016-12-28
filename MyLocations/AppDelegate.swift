//
//  AppDelegate.swift
//  MyLocations
//
//  Created by Chaofan Zhang on 12/16/16.
//  Copyright © 2016 Chaofan Zhang. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let managedObjectContext = gManagedObjectContext
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print("appDocumentsDirectory: \(gApplicationDocumentsDirectory)")
        print("applibraryDirectory: \(gAppLibraryDirectory)")
        customizeAppearance()
        
        listenForFatalCoreDataNotifications()
        
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
    }
    
    // Private functions
    func listenForFatalCoreDataNotifications() {
        NotificationCenter.default.addObserver(forName: gManagedObjectContextSaveDidFailNotificationName, object: nil, queue: OperationQueue.main, using: { notification in
            let alert = UIAlertController(title: "Internal Error", message:
                "There was a fatal error in the app and it cannot continue. \n\n"
                + "Press OK to terminate the app. Sorry for the inconvenience.", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
                let exception = NSException(name: .internalInconsistencyException, reason: "Fatal Core Data Error", userInfo: nil)
                exception.raise()
            })
            alert.addAction(alertAction)
            
            self.topViewController().present(alert, animated: true, completion: nil)
            
            
        })
    }
    
    func topViewController() -> UIViewController {
        let rootViewController = window!.rootViewController!
        if let topViewController = rootViewController.presentedViewController {
            return topViewController
        } else {
            return rootViewController
        }
    }
    
    func customizeAppearance() {
        UINavigationBar.appearance().barTintColor = UIColor.black
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    
        UITabBar.appearance().barTintColor = UIColor.black
        UITabBar.appearance().tintColor = UIColor(red: 255/255.0, green: 238/255.0, blue: 136/255.0, alpha: 1.0)
    }

}

