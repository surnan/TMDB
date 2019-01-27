//
//  LoginViewController.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginViaWebsiteButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTextField.text = ""
        passwordTextField.text = ""
        
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        TMDBClient.getRequestToken(completion: handleGetRequestToken(success:error:))
    }
    
    @IBAction func loginViaWebsiteTapped() {
        TMDBClient.getRequestToken { (success, err) in
            if success {
                let url = TMDBClient.Endpoints.webAuth.url
                //opening browser for user is interacting with AI
                DispatchQueue.main.async {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            } else {
                print("Error in loginViaWebsiteTapped \(String(describing: err?.localizedDescription))")
            }
        }
        
    }
    
    
    func handleSessionResponse(success: Bool, error: Error?){
        if success {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "completeLogin", sender: nil)
            }
        } else {
            print("failure in handleSessionResponse \(error ?? "" as! Error)")
        }
    }
    
    
    func handleGetRequestToken(success: Bool, error: Error?){
        if success {
            DispatchQueue.main.async {
                TMDBClient.getLogin(name: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "", completion: self.handleLoginResponse(success:error:))
            }
        } else {
            print("failure in handleGetRequestToken \(error ?? "" as! Error)")
        }
    }
    
    func handleLoginResponse(success: Bool, error: Error?){
        if success {
            TMDBClient.createSessionId(completion: handleSessionResponse(success:error:))
        } else {
            print("failure in handleLogin \(error ?? "" as! Error)")
        }
    }
}
