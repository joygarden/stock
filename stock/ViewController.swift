//
//  ViewController.swift
//  stock
//
//  Created by liaozhisong on 7/1/16.
//  Copyright © 2016 liaozhisong. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var stockTable: NSTableView!
    
    var stockArray = Array<Dictionary<String,String>>()
    
    func requestData() {
        if StockService.codes.isEmpty {
            stockArray = Array<Dictionary<String,String>>()
            stockTable.reloadData()
            return
        }
        let url = NSURL(string: "http://qt.gtimg.cn/q="+StockService.codes)
        let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
        NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, resp, error) in
            if data != nil {
                if let text = NSString(data:data!, encoding: enc) {
                    self.stockArray = StockService.sharedInstance.generateStockArrayForString(text as String)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.stockTable.reloadData()
                    })
                }
            }
        }.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.stockTable.setDataSource(self)
        self.stockTable.setDelegate(self)
        StockService.sharedInstance.initCodes()
        // Do any additional setup after loading the view.
        NSTimer.scheduledTimerWithTimeInterval(2,target:self,selector:#selector(self.requestData),
                                               userInfo:nil,repeats:true)
    }
    
}

extension ViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let curr = stockArray[row]
        let id = tableColumn?.identifier
        
        if id == "name" {
            let result : NameTableCell = tableView.makeViewWithIdentifier(id!, owner: self) as! NameTableCell
            let code = curr["code"]
            result.itemField.stringValue = curr["name"]!
            result.itemLabel.stringValue = code!.substringFromIndex(code!.startIndex.advancedBy(2))
            return result
        } else {
            let result : NSTableCellView = tableView.makeViewWithIdentifier(id!, owner: self) as! NSTableCellView
            let textField = result.textField;
            let rateStr = curr["rate"]! as String
            let rate = Float(rateStr)
            if rate > 0 {
                textField?.textColor = NSColor.redColor()
            }
            if rate < 0 {
                textField?.textColor = NSColor.greenColor()
            }
            textField?.stringValue  = id == "rate" ? (curr[id!]! + "%") : curr[id!]!
            return result
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return stockArray.count
    }
    
}


