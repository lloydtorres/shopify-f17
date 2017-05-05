//
//  ViewController.swift
//  Shopify-F17
//
//  Created by Lloyd Torres on 2017-05-04.
//  Copyright © 2017 Lloyd Torres. All rights reserved.
//

import Alamofire
import UIKit

class ViewController: UIViewController {
    
    // MARK: Constants
    let LOCALE_EN_US = Locale(identifier: "en_US")
    let ENDPOINT = "https://shopicruit.myshopify.com/admin/orders.json?page=1&access_token=c32313df0d0ef512ca64d5b336a0d7c6"
    let AERO_COTTON_KEYBOARD_TITLE = "Aerodynamic Cotton Keyboard"

    // MARK: Outlets
    @IBOutlet weak var totalOrderRevenueLabel: UILabel!
    @IBOutlet weak var aeroCottonKeyboardSoldLabel: UILabel!
    
    // MARK: Lifecycle Callbacks
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getOrders()
    }
    
    // MARK: Helpers
    func getUSNumberFormatter(numberStyle: NumberFormatter.Style) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = self.LOCALE_EN_US
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = numberStyle
        return formatter
    }
    
    // MARK: Outlet Setters
    func setTotalOrderRevenue(totalOrderRevenue: Double) {
        let formatter = getUSNumberFormatter(numberStyle: .currency)
        self.totalOrderRevenueLabel.text = formatter.string(from: NSNumber(value: totalOrderRevenue))
    }
    
    func setAerodynamicCottonKeyboardsSold(keyboardsSold: Int) {
        let formatter = getUSNumberFormatter(numberStyle: .none)
        self.aeroCottonKeyboardSoldLabel.text = formatter.string(from: NSNumber(value: keyboardsSold))
    }
    
    // MARK: Networking
    func getOrders() {
        Alamofire.request(self.ENDPOINT).responseJSON { response in
            if let json = response.result.value as? NSDictionary, let orders = json["orders"] as? NSArray {
                self.processOrders(orders: orders)
            }
        }
    }
    
    func processOrders(orders: NSArray) {
        // Start calculation of total order revenue and the number of aerodynamic cotton keyboards sold.
        var totalOrderRevenue = 0.0
        var aeroCottonKeyboardSales = 0
        
        // Loop and unwrap order items.
        for rawOrder in orders {
            if let order = rawOrder as? NSDictionary {
                // Unwrap and add the total price for one order.
                if let rawTotalPrice = order["total_price"] as? String, let totalPrice = Double(rawTotalPrice) {
                    totalOrderRevenue += totalPrice
                }
                
                // Unwrap the line items in one order.
                if let lineItems = order["line_items"] as? NSArray {
                    aeroCottonKeyboardSales += self.processLineItems(lineItems: lineItems)
                }
            }
        }
        
        self.setTotalOrderRevenue(totalOrderRevenue: totalOrderRevenue)
        self.setAerodynamicCottonKeyboardsSold(keyboardsSold: aeroCottonKeyboardSales)
    }
    
    // Given an array of line items, return the number of aerodynamic cotton keyboards.
    func processLineItems(lineItems: NSArray) -> Int {
        var aeroCottonKeyboardSalesInLineItems = 0
        for rawLineItem in lineItems {
            if let lineItem = rawLineItem as? NSDictionary,
               let lineItemTitle = lineItem["title"] as? String,
               lineItemTitle == self.AERO_COTTON_KEYBOARD_TITLE {
                aeroCottonKeyboardSalesInLineItems += 1
            }
        }
        return aeroCottonKeyboardSalesInLineItems
    }
}

