//
//  DataService.swift
//  stock
//
//  Created by liaozhisong on 7/3/16.
//  Copyright © 2016 liaozhisong. All rights reserved.
//

import Foundation

class StockService {
    
//    private static var __once: () = {
//            Static.instance = StockService()
//        }()
    
    //    class var sharedInstance : StockService{
    //        struct Static {
    //            static var instance: StockService?
    //            static var token: Int = 0
    //        }
    //        _ = StockService.__once
    //        return Static.instance!
    //    }
    
    static let sharedInstance = StockService()
    
    //sh603398,sz300440...
    static var codes = ""
    
    static let ALPHA_KEY = "alpha"

    static let STOCKS_KEY = "stocks"
    

    
    func initCodes()  {
        var code = ""
        let codeArray = self.readStockData();
        if !codeArray.isEmpty {
            for stock in codeArray {
                code += stock["code"]!+","
            }
            if code.contains(","){
                let index = code.characters.index(code.endIndex, offsetBy: -1)
                code = code.substring(to: index)
            }
        }
        StockService.codes = code
    }

    func readStockData() -> Array<Dictionary<String,String>> {
        let defaults = UserDefaults.standard
        let data = defaults.array(forKey: StockService.STOCKS_KEY)
        if data != nil {
            return data as! Array<Dictionary<String,String>>
        }
        return Array()
        
//        let filePath = NSBundle.mainBundle().pathForResource("data.plist", ofType:nil )
//        let listData = NSDictionary(contentsOfFile: filePath!)!
//        return listData["stocks"] as! Array<Dictionary<String,String>>
    }
    
    func writeStockData(_ codeDict : Array<Dictionary<String,String>>) {
        
        
        let defaults = UserDefaults.standard
        defaults.set(codeDict, forKey: StockService.STOCKS_KEY)
        initCodes()
//
//        let filePath = NSBundle.mainBundle().pathForResource("data.plist", ofType:nil )
//        let listData = NSDictionary(contentsOfFile: filePath!)!
//        listData.setValue(codeDict, forKeyPath: "stocks")
//        listData.writeToFile(filePath!, atomically: true)
        
        
    }
    
    func readAlpha() -> CGFloat {
        let defaults = UserDefaults.standard
        let alpha = defaults.string(forKey: StockService.ALPHA_KEY)
        return alpha == nil ? CGFloat(0.8) : CGFloat(Float(alpha!)!)
    }
    
    func writeAlpha(_ alpha : Float)  {
        let defaults = UserDefaults.standard
        defaults.set(alpha, forKey: StockService.ALPHA_KEY)
    }
    
    func addStock(_ code : String)  {
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
        
        let url = URL(string: "http://qt.gtimg.cn/q="+addCode!)
        let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, resp, error) in
            if data != nil {
                if let text = NSString(data:data!, encoding: enc) {
                    let stockDict = self.generateStockArrayForString(text as String)[0]
                    stockData.append(["name":stockDict["name"]!,"code":stockDict["code"]!])
                    self.writeStockData(stockData)
                    if StockService.codes.isEmpty {
                        StockService.codes = addCode!
                    } else {
                        if StockService.codes.components(separatedBy: addCode!).count > 1 {
                            return
                        }
                        StockService.codes += ","+(addCode!)
                    }
                }
            }
        }) .resume()
    }
    
    func generateStockArrayForString(_ text:String) -> Array<Dictionary<String,String>> {
        var stockData = Array<Dictionary<String,String>>()
        if !text.isEmpty {
            let result = text.replacingOccurrences(of: "\"", with: "")
                .replacingOccurrences(of: "\n", with: "")
            let stocks = result.components(separatedBy: ";")
            for stock in stocks {
                if stock.contains("=") {
                    let tmp1 = stock.components(separatedBy: "=")
                    let tmp2 = tmp1[1].components(separatedBy: "~")
                    var data = Dictionary<String,String>()
                    let code = tmp1[0]
                    data["name"] = tmp2[1]
                    data["code"] = code.substring(from: code.characters.index(code.startIndex, offsetBy: 2))
                    data["price"] = tmp2[3]
                    data["rate"] = tmp2[32]
                    stockData.append(data)
                }
            }
        }
        return stockData
    }
    

}
