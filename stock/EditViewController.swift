//
//  EditViewController.swift
//  stock
//
//  Created by liaozhisong on 7/3/16.
//  Copyright © 2016 liaozhisong. All rights reserved.
//

import Cocoa

class EditViewController: NSViewController {
    
    
    @IBOutlet weak var stockEditTableView: NSTableView!
    
    @IBOutlet weak var alphaSlider: NSSlider!
    
    var codeArray = Array<Dictionary<String,String>>()
    
    override func viewDidLoad() {
        let alpha = StockService.sharedInstance.readAlpha()
        alphaSlider.floatValue = (10 - Float(alpha)*10)
        codeArray = StockService.sharedInstance.readStockData();
        self.stockEditTableView.setDataSource(self)
        self.stockEditTableView.setDelegate(self)
    }
    
    @IBAction func savePressed(sender: NSButton) {
        StockService.sharedInstance.writeAllData(codeArray,alpha: 1-alphaSlider.floatValue/10)
        if (self.presentingViewController != nil) {
            self.presentingViewController?.dismissViewController(self)
        }
    }
    
    @IBAction func cancelPressed(sender: NSButton) {
        if (self.presentingViewController != nil) {
            self.presentingViewController?.dismissViewController(self)
        }
        updateAlpha(StockService.sharedInstance.readAlpha())
    }
    
    func updateAlpha(alpha : CGFloat)  {
        NSApplication.sharedApplication().keyWindow!.alphaValue = CGFloat(alpha)
    }
    
    @IBAction func valueChanged(sender: NSSlider) {
        updateAlpha(CGFloat(1-sender.floatValue/10))
    }
    
    func delPressed(sender : NSButton)  {
        let code = sender.identifier
        for index in 0 ..< codeArray.count {
            if(codeArray[index]["code"] == code) {
                codeArray.removeAtIndex(index)
                stockEditTableView.reloadData()
                break
            }
        }
    }
}



extension EditViewController: NSTableViewDataSource, NSTableViewDelegate {

    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let curr = self.codeArray[row]
        let id = tableColumn?.identifier
        
        if id == "name" {
            let result : NameTableCell = tableView.makeViewWithIdentifier(id!, owner: self) as! NameTableCell
            let code = curr["code"]
            result.itemField.stringValue = curr["name"]!
            result.itemLabel.stringValue = code!.substringFromIndex(code!.startIndex.advancedBy(2))
            return result
        }
        let result : NSTableCellView = tableView.makeViewWithIdentifier(id!, owner: self) as! NSTableCellView
        if id == "del" {
            let btn = result.viewWithTag(0) as! NSButton
            btn.identifier = curr["code"]
            btn.action = #selector(EditViewController.delPressed)
        }
        return result
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self.codeArray.count
    }
    
}
