// Created 12/05/21

import Alamofire
import iOSDropDown
import JTMaterialSpinner
import UIKit
class SetAmountVC: UIViewController {
    @IBOutlet var repeatView: UIView!
    @IBOutlet var priceTxt: UITextField!
    @IBOutlet var priceView: UIView!
    @IBOutlet var titleView: UIView!
    @IBOutlet var durationDV: DropDown!
    @IBOutlet var nameTxt: UITextField!
    var allDurationCategory = Global.allDurationCategory
    var spinnerView = JTMaterialSpinner()
    var price = ""
    var note = ""
    var sel_duration = 100
    var user_id = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        user_id = UserDefaults.standard.string(forKey: "userID") ?? "1"
        setShadow()
        setCategory()
        // Do any additional setup after loading the view.
    }

    func setShadow() {
        titleView.layer.shadowOffset = CGSize(width: 3, height: 3)
        titleView.layer.shadowRadius = 5
        titleView.layer.shadowOpacity = 0.3
        priceView.layer.shadowOffset = CGSize(width: 3, height: 3)
        priceView.layer.shadowRadius = 5
        priceView.layer.shadowOpacity = 0.3
        repeatView.layer.shadowOffset = CGSize(width: 3, height: 3)
        repeatView.layer.shadowRadius = 5
        repeatView.layer.shadowOpacity = 0.3
    }

    @IBAction func onCancelBtn(_: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onSetBtn(_: Any) {
        price = priceTxt.text!
        note = nameTxt.text!
        if !isValid() {
            return
        }
        view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height - 50) / 2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        let parameters: Parameters = ["id": user_id, "name": note, "value": price, "type": sel_duration]
        AF.request(Global.baseUrl + "api/setgoal", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            print(response)
            self.spinnerView.endRefreshing()
            if let value = response.value as? [String: AnyObject] {
                let status = value["status"] as? String
                if status == "ok" {
                    self.view.makeToast("Set a goal Success!")
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.view.makeToast("Fail set")
                }
            } else {
                self.view.makeToast("Fail set")
            }
        }
    }

    func setCategory() {
        durationDV.optionArray = allDurationCategory
        durationDV.didSelect { _, index, _ in
            self.sel_duration = index
            print("\(index)")
        }
    }

    func isValid() -> Bool {
        if price == "" {
            view.makeToast("Input Price")
            return false
        }
        if note == "" {
            view.makeToast("Input Name")
            return false
        }
        if sel_duration == 100 {
            view.makeToast("Select Duration")
            return false
        }
        return true
    }
}
