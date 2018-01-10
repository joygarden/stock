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
    
    let rowType = "rowType"
    
    override func viewDidLoad() {
        let alpha = StockService.sharedInstance.readAlpha()
        alphaSlider.floatValue = (10 - Float(alpha)*10)
        codeArray = StockService.sharedInstance.readStockData();
        self.stockEditTableView.dataSource = self
        self.stockEditTableView.delegate = self
        stockEditTableView.registerForDraggedTypes([NSPasteboard.PasteboardType(rawValue: rowType)])
    }
    
    @IBAction func savePressed(_ sender: NSButton) {
        StockService.sharedInstance.writeStockData(codeArray)
        StockService.sharedInstance.writeAlpha(1-alphaSlider.floatValue/10)
        if (self.presenting != nil) {
            self.presenting?.dismissViewController(self)
        }
    }
    
    @IBAction func cancelPressed(_ sender: NSButton) {
        if (self.presenting != nil) {
            self.presenting?.dismissViewController(self)
        }
        updateAlpha(StockService.sharedInstance.readAlpha())
    }
    
    func updateAlpha(_ alpha : CGFloat)  {
        NSApplication.shared.keyWindow!.alphaValue = CGFloat(alpha)
    }
    
    @IBAction func valueChanged(_ sender: NSSlider) {
        updateAlpha(CGFloat(1-sender.floatValue/10))
    }
    
    @objc func delPressed(_ sender : NSButton)  {
        let code = sender.identifier?.rawValue
        for index in 0 ..< codeArray.count {
            if(codeArray[index]["code"] == code) {
                codeArray.remove(at: index)
                stockEditTableView.reloadData()
                break
            }
        }
    }
}



extension EditViewController: NSTableViewDataSource, NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let curr = self.codeArray[row]
        let id = tableColumn?.identifier
        
        if id?.rawValue == "name" {
            let result : NameTableCell = tableView.makeView(withIdentifier: id!, owner: self) as! NameTableCell
            let code = curr["code"]
            result.itemField.stringValue = curr["name"]!
            result.itemLabel.stringValue = code!.substring(from: code!.characters.index(code!.startIndex, offsetBy: 2))
            return result
        }
        let result : NSTableCellView = tableView.makeView(withIdentifier: id!, owner: self) as! NSTableCellView
        if id?.rawValue == "del" {
            let btn = result.viewWithTag(0) as! NSButton
            btn.identifier = curr["code"].map { NSUserInterfaceItemIdentifier(rawValue: $0) }
            btn.action = #selector(EditViewController.delPressed)
        }
        return result
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.codeArray.count
    }
    
    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
        let data = NSKeyedArchiver.archivedData(withRootObject: rowIndexes)
        pboard.declareTypes([NSPasteboard.PasteboardType(rawValue: rowType)], owner: self)
        pboard.setData(data, forType: NSPasteboard.PasteboardType(rawValue: rowType))
        return true
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        tableView.setDropRow(row, dropOperation: NSTableView.DropOperation.above)
        return NSDragOperation.move
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        let pasteboard = info.draggingPasteboard()
        let rowData = pasteboard.data(forType: NSPasteboard.PasteboardType(rawValue: rowType))
        if rowData != nil {
            let indexSet = NSKeyedUnarchiver.unarchiveObject(with: rowData!) as! IndexSet
            let movingFromIndex = indexSet.first
            let item = codeArray[movingFromIndex!]
            _moveItem(item, from: movingFromIndex!, to: row)
            return true
        }
        return false
    }
    
    func _moveItem(_ item : Dictionary<String,String>, from: Int, to: Int) {
        codeArray.remove(at: from)
        if(to > codeArray.endIndex) {
            codeArray.append(item)
        } else {
            codeArray.insert(item, at: to)
        }
        stockEditTableView.reloadData()
    }

    
}
