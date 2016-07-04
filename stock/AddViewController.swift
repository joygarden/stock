//
//  AddViewController.swift
//  stock
//
//  Created by liaozhisong on 7/2/16.
//  Copyright © 2016 liaozhisong. All rights reserved.
//

import Cocoa

class AddViewController: NSViewController {
    
    @IBOutlet weak var codeField: NSTextField!
    
    @IBAction func addStock(sender : AnyObject)  {
        let code = codeField.stringValue;
        StockService.sharedInstance.addStock(code)
    }
}