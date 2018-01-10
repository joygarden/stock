//
//  ViewController.swift
//  stock
//
//  Created by liaozhisong on 7/1/16.
//  Copyright © 2016 liaozhisong. All rights reserved.
//

import Cocoa
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class ViewController: NSViewController {
    
    @IBOutlet weak var stockTable: NSTableView!
    
    var stockArray = Array<Dictionary<String,String>>()
    
    @objc func requestData() {
        if StockService.codes.isEmpty {
            stockArray = Array<Dictionary<String,String>>()
            stockTable.reloadData()
            return
        }
        let url = URL(string: "http://qt.gtimg.cn/q="+StockService.codes)
        let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, resp, error) in
            if data != nil {
                if let text = NSString(data:data!, encoding: enc) {
                    self.stockArray = StockService.sharedInstance.generateStockArrayForString(text as String)
                    DispatchQueue.main.async(execute: {
                        self.stockTable.reloadData()
                    })
                }
            }
            }) .resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.stockTable.dataSource = self
        self.stockTable.delegate = self
        StockService.sharedInstance.initCodes()
        Timer.scheduledTimer(timeInterval: 2,target:self,selector:#selector(self.requestData),
                                               userInfo:nil,repeats:true)
    }
    
}

extension ViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let curr = stockArray[row]
        let id = tableColumn?.identifier
        
        if id?.rawValue == "name" {
            let code = curr["code"]
            let result : NameTableCell = tableView.makeView(withIdentifier: id!, owner: self) as! NameTableCell
            result.itemField.stringValue = curr["name"]!
            result.itemLabel.stringValue = code!.substring(from: code!.characters.index(code!.startIndex, offsetBy: 2))
            return result
        } else {
            let rateStr = curr["rate"]! as String
            let rate = Float(rateStr)
            let result : NSTableCellView = tableView.makeView(withIdentifier: id!, owner: self) as! NSTableCellView
            let textField = result.textField;
            textField?.textColor = rate > 0 ? NSColor.red : rate < 0 ? NSColor.green : NSColor.black
            let index = id?.rawValue
            textField?.stringValue  = id?.rawValue == "rate" ? (rateStr + "%") : curr[index!]!
            return result
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return stockArray.count
    }
    
}


