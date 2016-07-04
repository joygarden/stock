//
//  DataService.swift
//  stock
//
//  Created by liaozhisong on 7/3/16.
//  Copyright © 2016 liaozhisong. All rights reserved.
//

import Foundation

class StockService {
    
    //sh603398,sz300440...
    static var codes = ""

    class var sharedInstance : StockService{
        struct Static {
            static var instance: StockService?
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token) {
            Static.instance = StockService()
        }
        return Static.instance!
    }
    
    func initCodes()  {
        var code = ""
        let codeArray = self.readStockData();
        if !codeArray.isEmpty {
            for stock in codeArray {
                code += stock["code"]!+","
            }
            if code.containsString(","){
                let index = code.endIndex.advancedBy(-1)
                code = code.substringToIndex(index)
            }
        }
        StockService.codes = code
    }
    
    func readStockData() -> Array<Dictionary<String,String>> {
        let filePath = NSBundle.mainBundle().pathForResource("data.plist", ofType:nil )
        let listData = NSDictionary(contentsOfFile: filePath!)!
        return listData["stocks"] as! Array<Dictionary<String,String>>
    }
    
    func writeStockData(codeDict : Array<Dictionary<String,String>>) {
        let filePath = NSBundle.mainBundle().pathForResource("data.plist", ofType:nil )
        let listData = NSDictionary(contentsOfFile: filePath!)!
        listData.setValue(codeDict, forKeyPath: "stocks")
        listData.writeToFile(filePath!, atomically: true)
        initCodes()
    }
    
    func writeAllData(codeDict : Array<Dictionary<String,String>>, alpha : NSNumber ) {
        let filePath = NSBundle.mainBundle().pathForResource("data.plist", ofType:nil )
        let listData = NSDictionary(contentsOfFile: filePath!)!
        listData.setValue(codeDict, forKeyPath: "stocks")
        listData.setValue(alpha, forKey: "alpha")
        listData.writeToFile(filePath!, atomically: true)
        initCodes()
    }
    
    
    
    func readAlpha() -> CGFloat {
        let filePath = NSBundle.mainBundle().pathForResource("data.plist", ofType:nil )
        let listData = NSDictionary(contentsOfFile: filePath!)!
        return CGFloat(listData["alpha"] as! Float)
    }
    
    func addStock(code : String)  {
        if(code.characters.count != 6) {
            return
        }
        var addCode : String?
        if code[code.startIndex] == "0" || code[code.startIndex] == "3" {
            addCode = "sz"+code
        } else if code[code.startIndex] == "6" {
            addCode = "sh" + code
        } else if code == "999999"{
            addCode = "sh000001"
        } else {
            return
        }
        var stockData = self.readStockData()
        for stock in stockData {
            if stock["code"] == "addCode" {
                return
            }
        }
        
        let url = NSURL(string: "http://qt.gtimg.cn/q="+addCode!)
        let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
        NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, resp, error) in
            if data != nil {
                if let text = NSString(data:data!, encoding: enc) {
                    let stockDict = self.generateStockArrayForString(text as String)[0]
                    stockData.append(["name":stockDict["name"]!,"code":stockDict["code"]!])
                    self.writeStockData(stockData)
                    if StockService.codes.isEmpty {
                        StockService.codes = addCode!
                    } else {
                        if StockService.codes.componentsSeparatedByString(addCode!).count > 1 {
                            return
                        }
                        StockService.codes += ","+(addCode!)
                    }
                }
            }
        }.resume()
    }
    
    
    
    func generateStockArrayForString(text:String) -> Array<Dictionary<String,String>> {
        var stockData = Array<Dictionary<String,String>>()
        if !text.isEmpty {
            let result = text.stringByReplacingOccurrencesOfString("\"", withString: "")
                .stringByReplacingOccurrencesOfString("\n", withString: "")
            let stocks = result.componentsSeparatedByString(";")
            for stock in stocks {
                if stock.containsString("=") {
                    let tmp1 = stock.componentsSeparatedByString("=")
                    let tmp2 = tmp1[1].componentsSeparatedByString("~")
                    var data = Dictionary<String,String>()
                    let code = tmp1[0]
                    data["name"] = tmp2[1]
                    data["code"] = code.substringFromIndex(code.startIndex.advancedBy(2))
                    data["price"] = tmp2[3]
                    data["rate"] = tmp2[32]
                    stockData.append(data)
                }
            }
        }
        return stockData
    }
    

}