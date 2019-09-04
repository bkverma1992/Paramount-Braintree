//
//  PaymentVC.swift
//  Paramount
//
//  Created by Yugasalabs-28 on 27/05/2019.
//  Copyright © 2019 Yugasalabs. All rights reserved.
//

import UIKit
import BraintreeDropIn
import Braintree

class PaymentVC: UIViewController,UITextFieldDelegate
{
    let currencyConverter = CurrencyConverter()
    let service = ServerHandler()

    var appd = AppDelegate()
    var braintree = String()
    
    @IBOutlet var amountTF: UITextField!
    @IBOutlet var netAmoutTF: UITextField!
    @IBOutlet var menuBTN: UIButton!

    @IBOutlet var hundredBTN: UIButton!
    @IBOutlet var fiftyBTN: UIButton!
    @IBOutlet var foutyFiveBTN: UIButton!
    @IBOutlet var twentyFiveBTN: UIButton!
    @IBOutlet var zeroBTN: UIButton!
    @IBOutlet var payBTN: UIButton!

    @IBOutlet var netAmtCurrencyLBL: UILabel!
    @IBOutlet var currencyButton: UIButton!
    @IBOutlet var resetBTN: UIButton!
    var atcualAmnt:String!
    let items:NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appd = UIApplication.shared.delegate as! AppDelegate
        self .didiloadData()
    }
    
    func didiloadData()  {
        self.setButton(button: hundredBTN, width: 1, radius: 10, borderColor: UIColor.lightGray)
        self.setButton(button: fiftyBTN, width: 1, radius: 10, borderColor: UIColor.lightGray)
        self.setButton(button: foutyFiveBTN, width: 1, radius: 10, borderColor: UIColor.lightGray)
        self.setButton(button: twentyFiveBTN, width: 1, radius: 10, borderColor: UIColor.lightGray)
        self.setButton(button: zeroBTN, width: 1, radius: 10, borderColor: UIColor.lightGray)
        self.setButton(button: payBTN, width: 0, radius: payBTN.frame.height/2, borderColor: UIColor.clear)
        self.setButton(button: payBTN, width: 0, radius: resetBTN.frame.height/2, borderColor: UIColor.clear)
        
        amountTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        netAmoutTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        netAmoutTF.placeHolderColor = UIColor.white
        amountTF.placeHolderColor = UIColor.white
        
        payBTN.clipsToBounds = true;
        resetBTN.clipsToBounds = true
        
        self .setDoneOnKeyboard()
        self.buttonRounded()
        
        // add padding in text filed
        addPaddingAndBorder(to: netAmoutTF)
        addPaddingAndBorder(to: amountTF)
        amountTF .becomeFirstResponder()

    }
    
    func addPaddingAndBorder(to textfield: UITextField) {

        textfield.textAlignment = NSTextAlignment.left
        let leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 5.0, height: 2.0))
        textfield.leftView = leftView
        textfield.leftViewMode = .always
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationReceived(_:)), name: .myNotificationKey, object: nil)
    }
    
    @objc func notificationReceived(_ notification: Notification)
    {
        guard let text = notification.userInfo?["currency"] as? String else { return }
        guard let textSymble = notification.userInfo?["symble"] as? String else { return }
        guard let cntryCode = notification.userInfo?["countryCode"] as? String else { return }
//countryCode
        DispatchQueue.main.async
            {
                self.currencyButton.setTitle(textSymble,for: .normal)
                self.amountTF.text = text
                self.buttonClearBG()
                self.netAmoutTF.text = ""
                self.appd.formCurrencyStr = cntryCode
                self.netAmtCurrencyLBL.text = textSymble
                self.netAmoutTF.text = text
                self.zeroPercentAddNetAmnt()
        }
    }
    func setDoneOnKeyboard() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        amountTF.inputAccessoryView = keyboardToolbar
        netAmoutTF.inputAccessoryView = keyboardToolbar
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
        if amountTF.text!.isEmpty
        {
            netAmoutTF.text  = ""
            self.buttonClearBG()
        }
        else
        {
            self.zeroPercentAddNetAmnt()
        }
    }
    
    func buttonRounded()  {
        
        if UIDevice().userInterfaceIdiom == .phone
        {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                payBTN.layer.cornerRadius = 20
                resetBTN.layer.cornerRadius = 20
            case 1334:
                payBTN.layer.cornerRadius = 25
                resetBTN.layer.cornerRadius = 25

            case 1920, 2208:
                payBTN.layer.cornerRadius = 27
                resetBTN.layer.cornerRadius = 27

            case 2436:
                payBTN.layer.cornerRadius = 29
                resetBTN.layer.cornerRadius = 29

            case 2688:
                payBTN.layer.cornerRadius = 29
                resetBTN.layer.cornerRadius = 29

            case 1792:
                payBTN.layer.cornerRadius = 29
                resetBTN.layer.cornerRadius = 29

            default:
                payBTN.layer.cornerRadius = 29
                resetBTN.layer.cornerRadius = 29

            }
        }
    }
    // textField Delegate Method

func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool { // return NO to not change text
        
        switch string {
        case "0","1","2","3","4","5","6","7","8","9":
            return true
        case ".":
            let array = Array(amountTF.text!)
            var decimalCount = 0
            for character in array {
                if character == "." {
                    decimalCount += 1
                }
            }

            if decimalCount == 1 {
                return false
            } else {
                return true
            }
        default:
            let array = Array(string)
            if array.count == 0 {
                return true
            }
            return false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if UIDevice().userInterfaceIdiom == .phone
        {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                print("IPHONE 5,5S,5C")
                if textField==netAmoutTF
                {
                    animateViewMoving(up: true, moveValue: 180)
                }
               
            case 1334:
                print("IPHONE 6,7,8 IPHONE 6S,7S,8S ")
                if textField==netAmoutTF
                {
                    animateViewMoving(up: true, moveValue: 160)
                }
               
            case 1920, 2208:
                print("IPHONE 6PLUS, 6SPLUS, 7PLUS, 8PLUS")
                if textField==netAmoutTF
                {
                    animateViewMoving(up: true, moveValue: 160)
                }
               
            case 2436:
                print("IPHONE X, IPHONE XS")
                
                if textField==netAmoutTF
                {
                    animateViewMoving(up: true, moveValue: 190)
                }
              
            case 2688:
                print("IPHONE XS_MAX")
                if textField==netAmoutTF
                {
                    animateViewMoving(up: true, moveValue: 190)
                }
            
            case 1792:
                print("IPHONE XR")
            default:
                if textField==netAmoutTF
                {
                    animateViewMoving(up: true, moveValue: 190)
                }
            
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                print("IPHONE 5,5S,5C")
                if textField==netAmoutTF
                {
                    self.animateViewMoving(up: false, moveValue: 180)
                }
                
            case 1334:
                print("IPHONE 6,7,8 IPHONE 6S,7S,8S ")
                if textField==netAmoutTF
                {
                    animateViewMoving(up: false, moveValue: 160)
                }
              
            case 1920, 2208:
                print("IPHONE 6PLUS, 6SPLUS, 7PLUS, 8PLUS")
                if textField==netAmoutTF
                {
                    animateViewMoving(up: false, moveValue: 160)
                }
             
            case 2436:
                print("IPHONE X, IPHONE XS")
                if textField==netAmoutTF
                {
                    animateViewMoving(up: false, moveValue: 190)
                }
               
            case 2688:
                print("IPHONE XS_MAX")
                if textField==netAmoutTF
                {
                    animateViewMoving(up: false, moveValue: 190)
                }
              
            case 1792:
                print("IPHONE XR")
            default:
                print("UNDETERMINED")
                if textField==netAmoutTF
                {
                    animateViewMoving(up: false, moveValue: 190)
                }
            }
        }

    //    self.zeroPercentAddNetAmnt()
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField)
    {
            // Some locales use different punctuations.
            var textFormatted = textField.text?.replacingOccurrences(of: ",", with: "")
           // textFormatted = textFormatted?.replacingOccurrences(of: ".", with: "")
            
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            if let text = textFormatted, let textAsInt = Int(text) {
                textField.text = numberFormatter.string(from: NSNumber(value: textAsInt))
            }
    }
    
    @IBAction func paymenyBTN(_ sender: UIButton)
    {
        if amountTF.text == ""
        {
            self.showAlertMessage(titleStr: "Paramount", messageStr: "Please enter amount first.")
        }
      else if netAmoutTF.text == ""
        {
            self.showAlertMessage(titleStr: "Paramount", messageStr: "Please enter amount first.")
        }
        else
        {
            print(appd.formCurrencyStr)
            if appd.formCurrencyStr.isEmpty
            {
                appd.formCurrencyStr = "EUR"
            }
            else if appd.formCurrencyStr == "EUR"
            {
                appd.formCurrencyStr = "EUR"
            }
            else
            {
                appd.formCurrencyStr = appd.toCurrencyStr
            }
            print(appd.formCurrencyStr)
            atcualAmnt =  netAmoutTF.text!
            atcualAmnt = atcualAmnt.replacingOccurrences(of: ",", with: "")
            
            if ConnectionCheck.isConnectedToNetwork()
            {
                self.oldCurrencyData()
            }
            else
            {
                self.showAlertMessage(titleStr: "Paramount", messageStr: "Internet Connection not Available!")
            }
        }
    }
    
    func checkIfAchualAmt()
    {
        guard let actualAmt = amountTF.text, actualAmt != ""  else {
            self.showAlertMessage(titleStr: "Paramount", messageStr: "Please enter your bill amount first.")
            return
        }
        
        if amountTF.text == ""
        {
            self.showAlertMessage(titleStr: "Paramount", messageStr: "Please enter your bill amount first.")
        }
    }

    @IBAction func getHundredPrcentBTN(_ sender: UIButton) {
        if amountTF.text == ""
        {
            self.showAlertMessage(titleStr: "Paramount", messageStr: "Please enter your bill amount first.")
        }
        else
        {
            hundredBTN.backgroundColor = UIColor(red: 32.0/255.0, green: 83.0/255.0, blue: 161.0/255.0, alpha: 1.0)
            fiftyBTN.backgroundColor = UIColor.clear
            foutyFiveBTN.backgroundColor = UIColor.clear
            twentyFiveBTN.backgroundColor = UIColor.clear
            zeroBTN.backgroundColor = UIColor.clear
       
            var calculatePaypalCharge = String()
            calculatePaypalCharge = self.getPaypalChargeAmount()
            var str:String =  amountTF.text!
            str = str.replacingOccurrences(of: ",", with: "")
            
            self.calculateNetAmout(netAmount: str, withPayCharge: calculatePaypalCharge, percentChargeValue: "100")
        }
    }
    
    @IBAction func fiftyPrcntBTN(_ sender: Any) {
        
        if amountTF.text == ""
        {
            self.showAlertMessage(titleStr: "Paramount", messageStr: "Please enter your bill amount first.")
        }
        else
        {
            fiftyBTN.backgroundColor = UIColor(red: 32.0/255.0, green: 83.0/255.0, blue: 161.0/255.0, alpha: 1.0)
            hundredBTN.backgroundColor = UIColor.clear
            foutyFiveBTN.backgroundColor = UIColor.clear
            twentyFiveBTN.backgroundColor = UIColor.clear
            zeroBTN.backgroundColor = UIColor.clear
            var calculatePaypalCharge = String()
            calculatePaypalCharge = self.getPaypalChargeAmount()
            var str:String =  amountTF.text!
            str = str.replacingOccurrences(of: ",", with: "")
            self.calculateNetAmout(netAmount: str, withPayCharge: calculatePaypalCharge, percentChargeValue: "50")
        }
    }
    
    func getPaypalChargeAmount() -> String  {
     
        var str:String =  amountTF.text!
        str = str.replacingOccurrences(of: ",", with: "")
        
        var amount = Double()
        amount = Double(str) ?? 1
        let tax = Double(amount) * 4.4
        
        let finalTaxAmount = tax/100
        let paypalCharge = String(format:"%.2f", finalTaxAmount)
      return paypalCharge
    }
    @IBAction func fourtyFivePrcntBTN(_ sender: Any) {
        if amountTF.text == ""
        {
            self.showAlertMessage(titleStr: "Paramount", messageStr: "Please enter your bill amount first.")
        }
        else
        {
            foutyFiveBTN.backgroundColor = UIColor(red: 32.0/255.0, green: 83.0/255.0, blue: 161.0/255.0, alpha: 1.0)
            fiftyBTN.backgroundColor = UIColor.clear
            hundredBTN.backgroundColor = UIColor.clear
            twentyFiveBTN.backgroundColor = UIColor.clear
            zeroBTN.backgroundColor = UIColor.clear
            var calculatePaypalCharge = String()
            calculatePaypalCharge = self.getPaypalChargeAmount()
            var str:String =  amountTF.text!
            str = str.replacingOccurrences(of: ",", with: "")
            self.calculateNetAmout(netAmount: str, withPayCharge: calculatePaypalCharge, percentChargeValue: "45")
        }
    }
    
    @IBAction func twntyFivePrcntBTN(_ sender: Any) {
        if amountTF.text == ""
        {
            self.showAlertMessage(titleStr: "Paramount", messageStr: "Please enter your bill amount first.")
        }
        else
        {
            twentyFiveBTN.backgroundColor = UIColor(red: 32.0/255.0, green: 83.0/255.0, blue: 161.0/255.0, alpha: 1.0)
            fiftyBTN.backgroundColor = UIColor.clear
            foutyFiveBTN.backgroundColor = UIColor.clear
            hundredBTN.backgroundColor = UIColor.clear
            zeroBTN.backgroundColor = UIColor.clear
            var calculatePaypalCharge = String()
            calculatePaypalCharge = self.getPaypalChargeAmount()
            var str:String =  amountTF.text!
            str = str.replacingOccurrences(of: ",", with: "")
            self.calculateNetAmout(netAmount: str, withPayCharge: calculatePaypalCharge, percentChargeValue: "25")
        }
    }
    
    @IBAction func zeroPrcntBTN(_ sender: Any) {
        self.zeroPercentAddNetAmnt()
    }
    
    func zeroPercentAddNetAmnt()  {
        if amountTF.text == ""
        {
            self.showAlertMessage(titleStr: "Paramount", messageStr: "Please enter your bill amount first.")
        }
        else
        {
            zeroBTN.backgroundColor = UIColor(red: 32.0/255.0, green: 83.0/255.0, blue: 161.0/255.0, alpha: 1.0)
            fiftyBTN.backgroundColor = UIColor.clear
            foutyFiveBTN.backgroundColor = UIColor.clear
            twentyFiveBTN.backgroundColor = UIColor.clear
            hundredBTN.backgroundColor = UIColor.clear
            var calculatePaypalCharge = String()
            calculatePaypalCharge = self.getPaypalChargeAmount()
            var str:String =  amountTF.text!
            str = str.replacingOccurrences(of: ",", with: "")
            self.calculateNetAmout(netAmount: str, withPayCharge: calculatePaypalCharge, percentChargeValue: "0")
        }
    }
    
    @IBAction func resetButton(_ sender: UIButton)
    {
        self.buttonClearBG()
        self.allResetData()
    }
   
    func allResetData()
    {
        appd.formCurrencyStr = "EUR"
        amountTF.text = ""
        netAmoutTF.text = ""
        appd.toCurrencyStr = ""
        self.currencyButton.setTitle("€",for: .normal)
        self.netAmtCurrencyLBL.text = "€"
    }
    func buttonClearBG()  {
        fiftyBTN.backgroundColor = UIColor.clear
        hundredBTN.backgroundColor = UIColor.clear
        foutyFiveBTN.backgroundColor = UIColor.clear
        twentyFiveBTN.backgroundColor = UIColor.clear
        zeroBTN.backgroundColor = UIColor.clear
    }
    
    @IBAction func currencyBTN(_ sender: UIButton) {
        
        amountTF .resignFirstResponder()
        if amountTF.text == "" {
            self.showAlertMessage(titleStr: "Paramount", messageStr: "Please enter amount first.")
        }
        else
        {

        if appd.formCurrencyStr .isEmpty
         {
            appd.formCurrencyStr = "EUR"//EUR
        }
            else if (appd.toCurrencyStr .isEmpty)
        {
            appd.formCurrencyStr = "EUR"
        }
            else
         {
             appd.formCurrencyStr = appd.toCurrencyStr
            }
       print(appd.formCurrencyStr)
            
            var str:String =  amountTF.text!
            str = str.replacingOccurrences(of: ",", with: "")
            
            if let myd:Double = Double(str)
            {
                print(myd)
                appd.amountCurrency = myd
            }

            if ConnectionCheck.isConnectedToNetwork()
            {
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CurrencyConvertVC") as? CurrencyConvertVC
                self.navigationController?.pushViewController(vc!, animated: true)            }
            else
            {
                self.showAlertMessage(titleStr: "Paramount", messageStr: "Internet Connection not Available!")
            }
        }
    }
    
    @IBAction func menuBTN(_ sender: UIButton)
    {
        let alertController = UIAlertController(title: "Paramount", message: "Are you sure, you want to logout?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        // Create the actions
        let okAction = UIAlertAction(title: "Logout", style: UIAlertAction.Style.default) {
            UIAlertAction in
            NSLog("OK Pressed")
            UserDefaults.standard .setValue("UserLogOut", forKey: "checkLogin")
            self.navigationController?.popViewController(animated: true)
        }
        // Add the actions
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)

        self.present(alertController, animated: true, completion: nil)
    }
    
    func calculateNetAmout(netAmount: String, withPayCharge: String, percentChargeValue: String)
    {
        amountTF .resignFirstResponder()
        netAmoutTF .resignFirstResponder()
        var amount = Double()
        amount = Double(netAmount) ?? 1
    
        var intPayCharge = Double()
        intPayCharge = Double(withPayCharge) ?? 1
        
        var discount = Double()
        discount = Double(percentChargeValue) ?? 1
        
        let billBeforeTax = intPayCharge
        let taxPercentage = discount
        let tax = Double(billBeforeTax) * taxPercentage
        
        let finalTaxAmount = tax/100
        
        let finalPayableAmount = amount + finalTaxAmount
        print(finalPayableAmount)
        let final:String = String(format:"%.2f", finalPayableAmount)
        netAmoutTF.text = final
       
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        if netAmoutTF.text!.count >= 1 {
            let number = Double(netAmoutTF.text!.replacingOccurrences(of: ",", with: ""))
            let result = formatter.string(from: NSNumber(value: number!))
            netAmoutTF.text = result
        }
    }
  
    func oldCurrencyData()  {
        var amnt = String()
        amnt = amountTF.text!
        appd.amountCurrency = Double(amnt) as! Double
        currencyConverter.updateExchangeRates(completion: {
        
            let formattedResult = self.currencyConverter.convertAndFormat(Double(self.appd.amountCurrency), valueCurrency: self.appd.formCurrencyStr, outputCurrency: "USD", numberStyle: .decimal, decimalPlaces: 3)
            print(formattedResult as Any)
            var calculateStr = String()
            calculateStr = formattedResult!
            self.braintree = calculateStr
            
            DispatchQueue.main.async {
                self.fetchClientToken()
            }
        })
    }

    func fetchClientToken() {

        let clientTokenURL = NSURL(string: "http://203.92.41.131:3000/client_token")!
        let clientTokenRequest = NSMutableURLRequest(url: clientTokenURL as URL)
        clientTokenRequest.setValue("text/plain", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: clientTokenRequest as URLRequest) { (data, response, error) -> Void in
            // TODO: Handle errors
            guard let data = data else {
                self.show(message: error!.localizedDescription)
                return
            }
            let clientToken = String(data: data, encoding: String.Encoding.utf8)
            DispatchQueue.main.async {
                self.showDropIn(clientTokenOrTokenizationKey: clientToken!)
            }
            }.resume()
    }
    
    func showDropIn(clientTokenOrTokenizationKey: String)
    {
        let request =  BTDropInRequest()
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
        { [unowned self] (controller, result, error) in
         
            var amountDobl = Double()
            amountDobl = Double(self.braintree) as! Double
            
            var amountStr = String()
            amountStr = String(format: "%.2f", amountDobl)
            print(amountStr)
            
            if let error = error {
                self.show(message: error.localizedDescription)
                
            } else if (result?.isCancelled == true) {
                self.show(message: "Transaction Cancelled")
                
            } else if let nonce = result?.paymentMethod?.nonce {
                let amt = amountStr
                self.sendRequestPaymentToServer(nonce: nonce, amount: amt)
            }
            controller.dismiss(animated: true, completion: nil)
        }
        
        self.present(dropIn!, animated: true, completion: nil)
    }
    
    func sendRequestPaymentToServer(nonce: String, amount: String) {
        
        print(nonce)
        print(amount)
        
        var strrr = String()
        strrr = String(format: "http://203.92.41.131:3000/checkout?payment_method_nonce=%@&amount=%@", nonce,amount)
        
        let paymentURL = URL(string: strrr)!
        var request = URLRequest(url: paymentURL)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) -> Void in
            guard let data = data else {
                self?.show(message: error!.localizedDescription)
                return
            }
            
            guard let result = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let success = result["success"] as? Bool, success == true else {
                    
                    self?.show(message: "Transaction failed. Please try again.")
                    return
            }
            
            self?.show(message: "Successfully charged. Thanks So Much :)")

            DispatchQueue.main.async {
                self?.buttonClearBG()
                self?.allResetData()
            }
            
            }.resume()
    }
    
    func show(message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: message, message: "", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

extension  UIViewController {
    
    func setButton(button: UIButton, width: CGFloat, radius: CGFloat, borderColor: UIColor)
    {
    button.layer.borderWidth = width
    button.layer.borderColor = borderColor.cgColor
    button.layer.cornerRadius = radius
    }
}

extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
}
