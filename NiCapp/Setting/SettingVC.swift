//
//  SettingVC.swift
//  calculator
//
//  Created by bird on 5/11/21.
//

import UIKit

class SettingVC: UIViewController {
    var userVC: UserVC!
    var homeVC: HomeVC!
    var calendarVC: CalendarVC!
    var loginVC: LoginVC!
    var changepasswordVC: ChangePasswordVC!

    @IBOutlet var loginBtn: UIButton!
    @IBOutlet var bottomView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setShadow()
        // Do any additional setup after loading the view.
    }

    func setShadow() {
        loginBtn.layer.borderWidth = 1
        loginBtn.layer.borderColor = #colorLiteral(red: 0.007843137255, green: 0.7647058824, blue: 0.6039215686, alpha: 1)

        bottomView.layer.shadowOffset = CGSize(width: 3, height: 3)
        bottomView.layer.shadowRadius = 5
        bottomView.layer.shadowOpacity = 0.3
    }

    @IBAction func onLogoutBtn(_: Any) {
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

    @IBAction func onChangeBtn(_: Any) {
        changepasswordVC = storyboard?.instantiateViewController(withIdentifier: "changepasswordVC") as? ChangePasswordVC
        changepasswordVC.modalPresentationStyle = .fullScreen
        present(changepasswordVC, animated: true, completion: nil)
    }

    @IBAction func onUserBtn(_: Any) {
        userVC = storyboard?.instantiateViewController(withIdentifier: "userVC") as? UserVC
        userVC.modalPresentationStyle = .fullScreen
        present(userVC, animated: true, completion: nil)
    }

    @IBAction func onCalendarBtn(_: Any) {
        calendarVC = storyboard?.instantiateViewController(withIdentifier: "calendarVC") as? CalendarVC
        calendarVC.modalPresentationStyle = .fullScreen
        present(calendarVC, animated: true, completion: nil)
    }

    @IBAction func onHomeBtn(_: Any) {
        homeVC = storyboard?.instantiateViewController(withIdentifier: "homeVC") as? HomeVC
        homeVC.modalPresentationStyle = .fullScreen
        present(homeVC, animated: true, completion: nil)
    }
}
