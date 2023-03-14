//
//  UpdateIncomeVC.swift
//  NiCapp
//
//  Created by bird on 6/7/21.
//

import UIKit
import Alamofire
import JTMaterialSpinner
import Toast_Swift

class UpdateIncomeVC: UIViewController {

    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var categoryImg: UIImageView!
    @IBOutlet weak var categoryTxt: UILabel!
    @IBOutlet weak var dateTxt: UILabel!
    @IBOutlet weak var priceTxt: UITextField!
    
    var price = ""
    let allIncomeCategory = Global.allIncomeCategory
    var spinnerView = JTMaterialSpinner()
    var sel_payid = "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sel_payid = AppDelegate.shared().sel_payid
        print(sel_payid)
        setShadow()
        getData()
    }
    
    func setShadow(){
        self.categoryView.layer.shadowOffset = CGSize(width: 3, height: 3)
        self.categoryView.layer.shadowRadius = 5
        self.categoryView.layer.shadowOpacity = 0.3
        self.dateView.layer.shadowOffset = CGSize(width: 3, height: 3)
        self.dateView.layer.shadowRadius = 5
        self.dateView.layer.shadowOpacity = 0.3
        self.priceView.layer.shadowOffset = CGSize(width: 3, height: 3)
        self.priceView.layer.shadowRadius = 5
        self.priceView.layer.shadowOpacity = 0.3
    }
    
    func getData(){
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        let parameters: Parameters = ["id": sel_payid]
        AF.request(Global.baseUrl + "api/getHistoryInfo", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
            print(response)
            self.spinnerView.endRefreshing()
            if let value = response.value as? [String: AnyObject] {
                let historyInfo = value["historyInfo"] as? [String: AnyObject]
                let date_string = historyInfo!["date"] as! String
                let categoryid = historyInfo!["categoryid"] as! String
                let price = historyInfo!["price"] as! String
                self.dateTxt.text = date_string
                self.priceTxt.text = price
                let category_title = self.allIncomeCategory[Int(categoryid)!].title
                let category_image = self.allIncomeCategory[Int(categoryid)!].imageUrl
                self.categoryImg.image = UIImage(named: category_image)
                self.categoryTxt.text = category_title
                
            }else {
                self.view.makeToast("Fail set")
            }
        }
    }
    func deleteData(){
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        let parameters: Parameters = ["id": sel_payid]
        AF.request(Global.baseUrl + "api/deletehistoryinfo", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
            print(response)
            self.spinnerView.endRefreshing()
            if let value = response.value as? [String: AnyObject] {
                let status = value["status"] as? String
                if status == "ok"{
                    self.dismiss(animated: true, completion: nil)
                }else {
                    self.view.makeToast("Fail delete")
                }
            }else {
                self.view.makeToast("Fail delete")
            }
        }
        
    }
    func updateData(){
        price = priceTxt.text!
        if(!isValid()){
            return
        }
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        let parameters: Parameters = ["id": sel_payid , "price" : price]
        AF.request(Global.baseUrl + "api/updatehistoryinfo", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
            print(response)
            self.spinnerView.endRefreshing()
            if let value = response.value as? [String: AnyObject] {
                let status = value["status"] as? String
                if status == "ok"{
                    self.view.makeToast("Update Success!")
                }else {
                    self.view.makeToast("Fail update")
                }
            }else {
                self.view.makeToast("Fail update")
            }
        }
        
    }
    
    @IBAction func onUpdateBtn(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "Do you want to update this item?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            self.updateData()
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onDeleteBtn(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "Do you want to delete this item?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            self.deleteData()
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onCancelBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func isValid() -> Bool {
        if price == ""{
            self.view.makeToast("Input Price")
            return false
        }
        return true
    }
}
