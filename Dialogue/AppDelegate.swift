//
//  AppDelegate.swift
//  Dialogue
//
//  Created by Michael Wlodawsky on 9/29/19.
//  Copyright © 2019 CS371L. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound], completionHandler: { (success, error) in
            if success {
                print("Permission granted")
            } else {
                print("User denied permission")
            }
        })
        return true
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        setRootViewController()
        return true
    }
    
    func setRootViewController() {
        if NetworkHelper.getCurrentUser() != nil {
            // Set Your home view controller Here as root View Controller
            let storyboard = UIStoryboard(name: "Main", bundle: nil)

            // instantiate your desired ViewController
            let rootController = storyboard.instantiateViewController(withIdentifier: "DialogueTabBarController")

            // Because self.window is an optional you should check it's value first and assign your rootViewController
            if let window = self.window {
               window.rootViewController = rootController
            }
        }
        // Signin view controller will be root otherwise
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


}

