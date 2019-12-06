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
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound], completionHandler: { (success, error) in })
        
        return true
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // Initialize sign-in
        GIDSignIn.sharedInstance().clientID = "164974850189-b94nh3lgsjp0vrtrkqjq49q84u3t362j.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        
        setRootViewController()
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return GIDSignIn.sharedInstance()?.handle(url) ?? false
    }
    
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    func setRootViewController() {
        if NetworkHelper.getCurrentUser() != nil {
            // Set Your home view controller Here as root View Controller
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            // instantiate your desired ViewController
            let rootController = storyboard.instantiateViewController(withIdentifier: "DialogueTabBarController")
            
            // Because self.window is an optional you should check its value first and assign your rootViewController
            if let window = self.window {
                window.rootViewController = rootController
            }
        }
        // Signin view controller will be root otherwise
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if error != nil {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            return
        }
        // Perform any operations on signed in user here.
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if error != nil {
                print("sign in error!")
                return
            } else {
                self.setRootViewController()
            }
        }
    }
}
