//
//  ConfirmEmailVC.swift
//  calculator
//
//  Created by bird on 5/11/21.
//

import Alamofire
import JTMaterialSpinner
import Toast_Swift
import UIKit

class ConfirmEmailVC: UIViewController {
    @IBOutlet var discloserView: UIView!

    var discloserVC: DiscloserVC!
    var loginVC: LoginVC!

    var spinnerView = JTMaterialSpinner()
    var user_id = ""
    @IBOutlet var sendEmailButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        user_id = UserDefaults.standard.string(forKey: "userID") ?? "1"
        sendEmailButton.isEnabled = true
        checkEveryFiveSeconds()
        super.viewDidLoad()
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

    @IBAction func onConfirmBtn(_: Any) {
        print("onConfirmBtn")
        view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height - 50) / 2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        let parameters: Parameters = ["user_id": user_id]
        AF.request(Global.baseUrl + "api/resendemailconfirmation", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { [self] response in
            self.spinnerView.endRefreshing()
            if let value = response.value as? [String: AnyObject] {
                let status = value["result"] as? String
                self.showMessageBox(messageTitle: "Success", messageAlert: "Please check your email", messageBoxStyle: .alert, alertActionStyle: .default, completionHandler: {})
            }
        }
    }

    @IBAction func onLogoutBtn(_: Any) {
        print("onLogoutBtn")
        AppDelegate.shared().userID = ""
        UserDefaults.standard.set(nil, forKey: "userID")
        UserDefaults.standard.set("no", forKey: "loginstatus")
        UserDefaults.standard.set("0", forKey: "emailValidated")
        UserDefaults.standard.set("0", forKey: "termsAccepted")
        UserDefaults.standard.synchronize()

        loginVC = storyboard?.instantiateViewController(withIdentifier: "loginVC") as? LoginVC
        loginVC.modalPresentationStyle = .fullScreen
        present(loginVC, animated: true, completion: nil)
    }

    func checkEveryFiveSeconds() {
        let parameters: Parameters = ["user_id": user_id]
        AF.request(Global.baseUrl + "api/getuser", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { [self] response in
            if let value = response.value as? [String: AnyObject] {
                let status = value["result"] as? String
                if status != "ok" {
                    return
                }
                if let data = value["data"] as? [String: AnyObject] {
                    let user = data["user"] as! [String: AnyObject]
                    let email_confirmed = user["emailValidated"] as? String
                    if email_confirmed == "1" {
                        self.showMessageBox(messageTitle: "Success", messageAlert: "Your email has been confirmed", messageBoxStyle: .alert, alertActionStyle: .default, completionHandler: {
                            self.discloserVC = self.storyboard?.instantiateViewController(withIdentifier: "discloserVC") as? DiscloserVC
                            self.discloserVC.modalPresentationStyle = .fullScreen
                            self.present(self.discloserVC, animated: true, completion: nil)
                        })
                        UserDefaults.standard.set("1", forKey: "emailValidated")
                        UserDefaults.standard.synchronize()
                        return
                    }
                }
            }
            // ask again after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.checkEveryFiveSeconds()
            }
        }
    }
}
