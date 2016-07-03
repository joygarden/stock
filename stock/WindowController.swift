//
//  WindowController.swift
//  stock
//
//  Created by liaozhisong on 7/3/16.
//  Copyright © 2016 liaozhisong. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window!.opaque = false;
        self.window!.alphaValue = StockService.sharedInstance.readAlpha()
    }
}
