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
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBAction func loginTapped(_ sender: UIButton) {
        setLoggingIn(true)
        TMDBClient.getRequestToken(completion: handleGetRequestToken(success:error:))
    }
    
    @IBAction func loginViaWebsiteTapped() {
        setLoggingIn(true)
        TMDBClient.getRequestToken { (success, err) in
            if success {
                let url = TMDBClient.Endpoints.webAuth.url
                //opening browser for user is interacting with AI
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                self.showLoginFailure(message: err?.localizedDescription ?? "")
                self.setLoggingIn(false)
            }
        }
    }
    
    
    func handleSessionResponse(success: Bool, error: Error?){
        setLoggingIn(false)
        if success {
                self.performSegue(withIdentifier: "completeLogin", sender: nil)
        } else {
            showLoginFailure(message: error?.localizedDescription ?? "")
        }
    }
    
    
    func handleGetRequestToken(success: Bool, error: Error?){
        if success {
                TMDBClient.getLogin(name: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "", completion: self.handleLoginResponse(success:error:))
        } else {
            showLoginFailure(message: error?.localizedDescription ?? "")
            self.setLoggingIn(false)
        }
    }
    
    func handleLoginResponse(success: Bool, error: Error?){
        setLoggingIn(true)
        if success {
            TMDBClient.createSessionId(completion: handleSessionResponse(success:error:))
        } else {
            showLoginFailure(message: error?.localizedDescription ?? "")
            self.setLoggingIn(false)
        }
    }
    
    
    func setLoggingIn(_ loggingIn: Bool){
        if loggingIn {
            activityIndicator.startAnimating()
            emailTextField.isEnabled = false
            passwordTextField.isEnabled = false
            loginButton.isEnabled = false
            loginViaWebsiteButton.isEnabled = false
        } else {
            activityIndicator.stopAnimating()
            emailTextField.isEnabled = true
            passwordTextField.isEnabled = true
            loginButton.isEnabled = true
            loginViaWebsiteButton.isEnabled = true
        }
    }

    func showLoginFailure(message: String){
        let alertVC = UIAlertController(title: "Login Failed", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
}
