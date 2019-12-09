//
//  SigninViewController.swift
//  Dialogue
//
//  Created by Michael Wlodawsky on 10/17/19.
//  Copyright © 2019 CS371L. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import FacebookLogin
import FacebookCore
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit


class SigninViewController: UIViewController, LoginButtonDelegate {
    
    
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    
    @IBOutlet weak var FacebookButton: FBLoginButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var googleLoginButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.object(forKey: "user_uid_key") != nil {
            self.performSegue(withIdentifier: "signinToDialogue", sender: nil)
        }
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        // Automatically sign in the user.
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        
        FacebookButton.delegate = self
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        loginButton.layer.cornerRadius = 20
        signUpButton.layer.cornerRadius = 20
        googleLoginButton.layer.cornerRadius = 20
        FacebookButton.layer.cornerRadius = 20
        
        
        let frame = self.view.safeAreaLayoutGuide.layoutFrame
        let margins = view.layoutMarginsGuide
        
        FacebookButton.translatesAutoresizingMaskIntoConstraints = false
        googleLoginButton.translatesAutoresizingMaskIntoConstraints = false
        
        for lc in FacebookButton.constraints {
            if (lc.constant == 28) {
                lc.isActive = false
                break
            }
        }
        
        FacebookButton.frame.size = CGSize(width: frame.width * 0.75, height: 40)
        //        googleLoginButton.frame.size = CGSize(width: frame.width * 0.75, height: 30)
        
        NSLayoutConstraint.activate([
            FacebookButton.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 40),
            FacebookButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -40),
            //            FacebookButton.widthAnchor.constraint(equalToConstant: frame.width * 0.75),
            FacebookButton.heightAnchor.constraint(equalToConstant: 40),
            
            googleLoginButton.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 36),
            googleLoginButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -36)//,
            //            googleLoginButton.widthAnchor.constraint(equalToConstant: frame.width * 0.75),
            //            googleLoginButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    @IBAction func onGoogleSignin(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if error != nil {
            Alerts.singleChoiceAlert(title: "Login Error", message: "There was an error logging in with Facebook", vc: self)
            print("\(error!)")
        } else if result?.isCancelled ?? false {
            // Don't navigate to next view is cancelled
        } else {
            let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
            firebaseSignin(credentials: credential)
        }
        
    }
    
    func firebaseSignin(credentials: AuthCredential) {
        Auth.auth().signIn(with: credentials) { (result, error) in
            if error == nil {
                NetworkHelper.userWritten(userID: Auth.auth().currentUser!.uid) { (userExists, error) in
                    if error != nil {
                        print(error)
                    } else {
                        if userExists {
                            // Set Your home view controller Here as root View Controller
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            
                            // instantiate your desired ViewController
                            let rootController = storyboard.instantiateViewController(withIdentifier: "DialogueTabBarController")
                            
                            self.present(rootController, animated: true, completion: nil)
                        } else {
                            NetworkHelper.writeUser(user: UserStruct(userId: NetworkHelper.getCurrentUser()!.uid, displayName: "Facebook User", groupList: [], followList: []), completion: {
                                // Set Your home view controller Here as root View Controller
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                
                                // instantiate your desired ViewController
                                let rootController = storyboard.instantiateViewController(withIdentifier: "DialogueTabBarController")
                                
                                self.present(rootController, animated: true, completion: nil)
                            })
                        }
                    }
                }
            } else {
                print(error)
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {}
    
    
    
    @IBAction func onSignin(_ sender: Any) {
        let vc = self
        Loading.show()
        if !(EmailTextField.text?.isEmpty ?? true || PasswordTextField.text?.isEmpty ?? true) {
            Auth.auth().signIn(withEmail: EmailTextField.text!, password: PasswordTextField.text!) { (result, error) in
                Loading.hide()
                if error != nil {
                    Alerts.singleChoiceAlert(title: "Error", message: "Email or Password was invalid.", vc: vc)
                } else {
                    vc.performSegue(withIdentifier: "signinToDialogue", sender: nil)
                }
                
            }
        } else {
            Loading.hide()
            Alerts.singleChoiceAlert(title: "Error", message: "Email or Password field is empty.", vc: self)
        }
    }
    
    
    // code to dismiss keyboard when user clicks on background
    
    func textFieldShouldReturn(textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
