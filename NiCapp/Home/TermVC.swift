//
//  TermVC.swift
//  calculator
//
//  Created by bird on 5/11/21.
//

import UIKit
import Alamofire

class TermVC: UIViewController {
    var homeVC: HomeVC!
    var user_id = ""
    @IBOutlet var termView: UIView!


    override func viewDidLoad() {
        user_id = UserDefaults.standard.string(forKey: "userID") ?? "1"
        super.viewDidLoad()
        setShadow()
    }

    func setShadow() {
        termView.layer.shadowOffset = CGSize(width: 3, height: 3)
        termView.layer.shadowRadius = 5
        termView.layer.shadowOpacity = 0.3
    }

    func acceptTerms() {
        let parameters: Parameters = ["user_id": user_id]
        AF.request(Global.baseUrl + "api/acceptterms", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { [self] response in
            if let value = response.value as? [String: AnyObject] {
                let status = value["result"] as? String
                if status != "ok" {
                    return
                }
                UserDefaults.standard.set("1", forKey: "termsAccepted")
                UserDefaults.standard.synchronize()
            }
        }
    }

    @IBAction func onContinueBtn(_: Any) {
        acceptTerms()
        homeVC = storyboard?.instantiateViewController(withIdentifier: "homeVC") as? HomeVC
        homeVC.modalPresentationStyle = .fullScreen
        present(homeVC, animated: true, completion: nil)
    }
}
