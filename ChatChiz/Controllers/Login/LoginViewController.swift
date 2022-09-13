//
//  LoginViewController.swift
//  ChatChiz
//
//  Created by Ngoc Ban on 08/09/2022.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import JGProgressHUD

class LoginViewController: UIViewController {
    
    private let spinner : JGProgressHUD = {
        let spinner = JGProgressHUD()
        spinner.style = .dark
        return spinner
    }()

    private let imageView : UIImageView = {
        let imageView = UIImageView()
        
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let scrollView:UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let emailField:UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.gray.cgColor
        field.placeholder = "Email Address..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let passwordField:UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.gray.cgColor
        field.placeholder = "Password..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    }()
    
    private let logginButton:UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .systemPink
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20,weight:.bold)
        return button
    }()
    
    private let facebookLoginButton:FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["email","public_profile"]
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Log In"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        
        logginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        facebookLoginButton.delegate = self
               
        // add sub view
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(logginButton)
        scrollView.addSubview(facebookLoginButton)
       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        let size = scrollView.width/3
        let frameSize = scrollView.width

        imageView.frame = CGRect(
            x: (frameSize - size)/2,
            y: 20,
            width: size,
            height: size
        )
        
        emailField.frame = CGRect(
            x: 30,
            y: imageView.bottom + 10,
            width: scrollView.width - 60,
            height: 52
        )
        
        passwordField.frame = CGRect(
            x: 30,
            y: emailField.bottom + 10,
            width: scrollView.width - 60,
            height: 52
        )
        
        logginButton.frame = CGRect(
            x: 30,
            y: passwordField.bottom + 10,
            width: scrollView.width - 60,
            height: 52
        )
        
        facebookLoginButton.center = scrollView.center
        facebookLoginButton.frame.origin.y = logginButton.bottom + 20
    }
    
    @objc private func loginButtonTapped(){
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        guard let email = emailField.text,let password = passwordField.text,
              !email.isEmpty,!password.isEmpty else{
            alertUserLoginError()
            return
        }
        
        spinner.show(in: view)
        
        //Firebase log in
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) {
            [weak self]AuthDataResult, Error in
            
            guard let strongSelf = self else{
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard let result = AuthDataResult , Error == nil
            
            else{
                print("Failed to log in with email: \(email)")
                return
            }
            
            let user = result.user
            print("Log in user: \(user)")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func alertUserLoginError(   ){
        let alert = UIAlertController(title: "Woops", message: "Plese enter infomation to login.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel,handler: nil))
        
        present(alert, animated: true)
        
    }
    
    @objc private func didTapRegister(){
        let vc = RegisterViewController()
        
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField :UITextField)->Bool{
        if textField == emailField{
            passwordField.becomeFirstResponder()
        } else if textField == passwordField{
            loginButtonTapped()
        }
        
        return true
    }
}


extension LoginViewController:LoginButtonDelegate{
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        guard let token = result?.token?.tokenString else{
            print("User failed to log in with facebook.")
            return
        }
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(
            graphPath: "me",
            parameters: ["fields":"email,name"],
            tokenString: token,
            version: nil,
            httpMethod: .get)
        
        facebookRequest.start(completion: {_, result,error in
            guard let result = result as? [String:Any] , error == nil
            else{
                print("Failed to make facebook graph request.")
                return
            }
            
            
            guard let userName = result["name"] as? String,
                  let email = result["email"] as? String else{
                print("Failed to get email and name from facebook result.")
                return
            }
            
            let nameComponents = userName.components(separatedBy: " ")
            guard nameComponents.count == 2 else{
                return
            }
            
            let firstName = nameComponents[0]
            let lastName = nameComponents[nameComponents.count - 1]
            
            DatabaseManager.shared.userExists(with: email, completion: {exists in
                if !exists {
                    DatabaseManager.shared.insertUser(with: ChatAppUser(
                        firstName: firstName, lastName: lastName, emailAddress: email))
                }
            })
            
            let cridential = FacebookAuthProvider.credential(withAccessToken: token)
      
            FirebaseAuth.Auth.auth().signIn(with: cridential) {
                [weak self]AuthDataResult, Error in
                
                guard let strongSelf = self else{
                    return
                }
        
                guard AuthDataResult != nil , Error == nil else{
                    if let error = Error {
                        print("Facebook credential is failed, MFA can be needed -\(error)")
                    }
                    
                    return
                }
                
                print("Successfully logged in.")
                strongSelf.navigationController?.dismiss(animated: true,completion: nil)
            }
        })
        
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        /// no operation
    }
    
    
}
