//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Christopher Ponce Mendez on 11/26/19.
//  Copyright © 2019 none. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    //MARK: Specifies the coredata model 
    let dataController = DataController(modelName: "VirtualTourist")
    
    func saveViewContext() {
        try? dataController.viewContext.save()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        dataController.load()
        //        let navigationController = window?.rootViewController as! UINavigationController
        //        let travelLocationsVC = navigationController.topViewController as! TravelLocationsMapView
        //
        //        travelLocationsVC.dataController = self.dataController
        return true
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        saveViewContext()
    }
    func applicationWillTerminate(_ application: UIApplication) {
        saveViewContext()
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

