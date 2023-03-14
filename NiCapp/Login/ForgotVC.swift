//
//  ForgotVC.swift
//  calculator
//
//  Created by bird on 5/12/21.
//

import Alamofire
import JTMaterialSpinner
import Toast_Swift
import UIKit
class ForgotVC: UIViewController {
    @IBOutlet var emailView: UIView!
    @IBOutlet var usernameView: UIView!

    @IBOutlet var emailTxt: UITextField!
    @IBOutlet var usernameTxt: UITextField!

    var spinnerView = JTMaterialSpinner()
    var email = ""
    var username = ""
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func setShadow() {
        usernameView.layer.shadowOffset = CGSize(width: 3, height: 3)
        usernameView.layer.shadowRadius = 5
        usernameView.layer.shadowOpacity = 0.3
        emailView.layer.shadowOffset = CGSize(width: 3, height: 3)
        emailView.layer.shadowRadius = 5
        emailView.layer.shadowOpacity = 0.3
    }

    func showMessageBox(messageTitle: String, messageAlert: String, messageBoxStyle: UIAlertController.Style, alertActionStyle: UIAlertAction.Style, completionHandler: @escaping () -> Void)
    {
        let alert = UIAlertController(title: messageTitle, message: messageAlert, preferredStyle: messageBoxStyle)

        let okAction = UIAlertAction(title: "Ok", style: alertActionStyle) { _ in
            completionHandler() // This will only get called after okay is tapped in the alert
        }

        alert.addAction(okAction)

        present(alert, animated: true, completion: nil)
    }

    @IBAction func onUpdatePasswordBtn(_: Any) {
        email = emailTxt.text!
        username = usernameTxt.text!
        if !isValid() {
            return
        }
        view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height - 50) / 2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        let parameters: Parameters = ["username": username, "email": email]
        AF.request(Global.baseUrl + "api/forgotpassword", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { [self] response in
            self.spinnerView.endRefreshing()
            if let value = response.value as? [String: AnyObject] {
                let status = value["result"] as? String
                if status == "ok" {
                    self.showMessageBox(messageTitle: "Success", messageAlert: "Please check your email", messageBoxStyle: .alert, alertActionStyle: .default, completionHandler: {
                        dismiss(animated: true, completion: nil)
                    })

                } else {
                    self.view.makeToast("We can't find your account", duration: 3.0, position: .center)
                }
            }
        }
    }

    @IBAction func onLoginBtn(_: Any) {
        dismiss(animated: true, completion: nil)
    }

    func isValid() -> Bool {
        if email == "" {
            view.makeToast("Input Email Address")
            return false
        } else {
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
            if !emailPred.evaluate(with: email) {
                view.makeToast("Input correct email address")
                return false
            }
        }
        if username == "" {
            view.makeToast("Input Username")
            return false
        }
        return true
    }
}
