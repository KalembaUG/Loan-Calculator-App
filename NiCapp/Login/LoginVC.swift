//
//  LoginVC.swift
//  calculator
//
//  Created by bird on 5/11/21.
//

import Alamofire
import AuthenticationServices
import JTMaterialSpinner
import Toast_Swift
import UIKit

class LoginVC: UIViewController {
    var signupVC: SignupVC!
    var forgotVC: ForgotVC!
    var homeVC: HomeVC!
    var discloserVC: DiscloserVC!
    var confirmEmailVC: ConfirmEmailVC!

    @IBOutlet var LoginStack: UIStackView!
    var spinnerView = JTMaterialSpinner()
    @IBOutlet var passwordView: UIView!
    @IBOutlet var usernameView: UIView!

    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    @IBOutlet var showBtn: UIButton!

    var password_status = "no"
    var username = ""
    var password = ""
    var user_id = ""
    var loginstatus = "no"
    var emailValidated = "0"
    var termsAccepted = "0"

    override func viewDidLoad() {
        super.viewDidLoad()
        user_id = UserDefaults.standard.string(forKey: "userID") ?? ""
        loginstatus = UserDefaults.standard.string(forKey: "loginstatus") ?? "no"
        emailValidated = UserDefaults.standard.string(forKey: "emailValidated") ?? "0"
        termsAccepted = UserDefaults.standard.string(forKey: "termsAccepted") ?? "0"
        setShadow()
        setupProviderLoginView()
    }

    override func viewDidAppear(_: Bool) {
        super.viewDidAppear(true)
        if loginstatus == "no" {
            return
        }
        redirectToNextView()
    }

    /// - Tag: add_appleid_button
    func setupProviderLoginView() {
        let authorizationButton = ASAuthorizationAppleIDButton()
        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        LoginStack.addArrangedSubview(authorizationButton)
    }

    /// - Tag: perform_appleid_request
    @objc
    func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    func redirectToNextView() {
        if emailValidated == "0" {
            // open confirmEmailVC
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            confirmEmailVC = storyboard.instantiateViewController(withIdentifier: "confirmEmailVC") as? ConfirmEmailVC
            confirmEmailVC.modalPresentationStyle = .fullScreen
            present(confirmEmailVC, animated: true, completion: nil)
            return
        }
        if termsAccepted == "0" {
            discloserVC = storyboard?.instantiateViewController(withIdentifier: "discloserVC") as? DiscloserVC
            discloserVC.modalPresentationStyle = .fullScreen
            present(discloserVC, animated: true, completion: nil)
            return
        }
        // open homeVC
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        homeVC = storyboard.instantiateViewController(withIdentifier: "homeVC") as? HomeVC
        homeVC.modalPresentationStyle = .fullScreen
        present(homeVC, animated: true, completion: nil)
    }

    func setShadow() {
        usernameView.layer.shadowOffset = CGSize(width: 3, height: 3)
        usernameView.layer.shadowRadius = 5
        usernameView.layer.shadowOpacity = 0.3
        passwordView.layer.shadowOffset = CGSize(width: 3, height: 3)
        passwordView.layer.shadowRadius = 5
        passwordView.layer.shadowOpacity = 0.3
    }

    @IBAction func onForgotPassword(_: Any) {
        forgotVC = storyboard?.instantiateViewController(withIdentifier: "forgotVC") as? ForgotVC
        forgotVC.modalPresentationStyle = .fullScreen
        present(forgotVC, animated: true, completion: nil)
    }

    @IBAction func onLoginBtn(_: Any) {
        username = usernameTxt.text!
        password = passwordTxt.text!
        if !isValid() {
            return
        }
        view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height - 50) / 2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        let parameters: Parameters = ["username": username, "password": password]
        AF.request(Global.baseUrl + "api/login", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { [self] response in
            self.spinnerView.endRefreshing()
            if let value = response.value as? [String: AnyObject] {
                let status = value["result"] as! String

                if status != "ok" {
                    self.view.makeToast("You entered an incorrect username or password", duration: 3.0, position: .bottom)
                    return
                }

                let userInfo = value["user"] as? [String: AnyObject]
                let user_id = userInfo!["id"] as! String
                self.emailValidated = userInfo!["emailValidated"] as! String
                self.termsAccepted = userInfo!["termsAccepted"] as! String

                self.saveUserDetails(userId: user_id, emailValidated: self.emailValidated, termsAccepted: self.termsAccepted)

                self.redirectToNextView()
            }
        }
    }

    func saveUserDetails(userId: String, emailValidated: String, termsAccepted: String) {
        AppDelegate.shared().userID = userId
        UserDefaults.standard.set(userId, forKey: "userID")
        UserDefaults.standard.set("yes", forKey: "loginstatus")
        UserDefaults.standard.set(emailValidated, forKey: "emailValidated")
        UserDefaults.standard.set(termsAccepted, forKey: "termsAccepted")
        UserDefaults.standard.synchronize()
    }

    @IBAction func onSignupBtn(_: Any) {
        signupVC = storyboard?.instantiateViewController(withIdentifier: "signupVC") as? SignupVC
        signupVC.modalPresentationStyle = .fullScreen
        present(signupVC, animated: true, completion: nil)
    }

    func isValid() -> Bool {
        if username == "" {
            view.makeToast("Input Username")
            return false
        }
        if password == "" {
            view.makeToast("Input password")
            return false
        }
        return true
    }

    @IBAction func onShowPasswordBtn(_: Any) {
        if password_status == "no" {
            password_status = "yes"
//            showBtn.setImage(UIImage(named: "eye.slash.fill"), for: .normal)
            showBtn.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
            passwordTxt.isSecureTextEntry = false
        } else {
            password_status = "no"
            showBtn.setImage(UIImage(systemName: "eye.fill"), for: .normal)
            passwordTxt.isSecureTextEntry = true
        }
    }
}

extension LoginVC: ASAuthorizationControllerDelegate {
    /// - Tag: did_complete_authorization
    func authorizationController(controller _: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        print("didCompleteWithAuthorization")
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            print("Apple ID Credential state: \(appleIDCredential.state)")

            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            let email = appleIDCredential.email ?? ""

            view.addSubview(spinnerView)
            spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height - 50) / 2, width: 50, height: 50)
            spinnerView.circleLayer.lineWidth = 2.0
            spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
            spinnerView.beginRefreshing()
            let parameters: Parameters = ["username": userIdentifier, "email": email]
            print(parameters)
            AF.request(Global.baseUrl + "api/signupAppleId", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { [self] response in
                print(response)
                self.spinnerView.endRefreshing()
                if let value = response.value as? [String: AnyObject] {
                    let status = value["result"] as! String
                    print(status)

                    if status != "ok" {
                        self.view.makeToast(status, duration: 3.0, position: .bottom)
                        return
                    }

                    let userInfo = value["user"] as? [String: AnyObject]
                    let user_id = userInfo!["id"] as! String
                    self.emailValidated = userInfo!["emailValidated"] as! String
                    self.termsAccepted = userInfo!["termsAccepted"] as! String

                    self.saveUserDetails(userId: user_id, emailValidated: self.emailValidated, termsAccepted: self.termsAccepted)

                    self.redirectToNextView()
                }
            }

        default:
            print("Authorization not supported")
        }

        /// - Tag: did_complete_error
        func authorizationController(controller _: ASAuthorizationController, didCompleteWithError _: Error) {
            // Handle error.
            print("didCompleteWithError")
        }
    }
}

extension LoginVC: ASAuthorizationControllerPresentationContextProviding {
    /// - Tag: provide_presentation_anchor
    func presentationAnchor(for _: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}
