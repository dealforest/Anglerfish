//
//  Anglerfish.swift
//
//  Created by Toshihiro Morimoto on 5/14/16.
//  Copyright © 2016 Toshihiro Morimoto. All rights reserved.
//

import AppKit

var sharedPlugin: Anglerfish?

class Anglerfish: NSObject {
    
    var bundle: NSBundle
    
    override class func initialize() {
        var token: dispatch_once_t = 0
        dispatch_once(&token) {
            swizzleClass(NSClassFromString("DVTDeviceManager"),
                         method1: "availableDevices",
                         method2: "af_availableDevices")
            swizzleClass(NSClassFromString("DVTDevice"),
                         method1: "didBecomeActiveDeviceForRunContext:",
                         method2: "af_didBecomeActiveDeviceForRunContext:")
        }
    }

    class func pluginDidLoad(bundle: NSBundle) {
        if
        let appName = NSBundle.mainBundle().infoDictionary?["CFBundleName"] as? NSString
        where appName == "Xcode" {
            sharedPlugin = Anglerfish(bundle: bundle)
        }
    }

    init(bundle: NSBundle) {
        self.bundle = bundle
        super.init()
    }

    private class func swizzleClass(klass: AnyClass!, method1: String, method2: String) {
        // http://nshipster.com/swift-objc-runtime/
        let originalSelector = NSSelectorFromString(method1)
        let swizzledSelector = NSSelectorFromString(method2)
        
        let originalMethod = class_getInstanceMethod(klass, originalSelector)
        let swizzledMethod = class_getInstanceMethod(klass, swizzledSelector)
        
        let didAddMethod = class_addMethod(klass,
                                           originalSelector,
                                           method_getImplementation(originalMethod),
                                           method_getTypeEncoding(swizzledMethod))
        if didAddMethod {
            class_replaceMethod(klass,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod))
        }
        else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
    
}

public class SimulatorHistoryManager: NSObject {
    
    struct Simulator {
        let name: String
        let date: NSDate
    }
    
    public static let sharedInstance = SimulatorHistoryManager()
    
    private let simulatorPath = NSHomeDirectory() + "/Library/Developer/CoreSimulator/Devices"
    private var histories = [String]()
    
    override init() {
        super.init()
        refresh()
    }
    
    public func update(name: String) {
        if let index = histories.indexOf(name) {
            histories.removeAtIndex(index)
        }
        histories.insert(name, atIndex: 0)
    }
    
    public func indexOf(name: String) -> Int {
        return histories.indexOf(name) ?? Int.max
    }
    
    public func refresh() {
        let manager = NSFileManager.defaultManager()
        var deviceData = [Simulator]()
        do {
            try manager.contentsOfDirectoryAtPath(simulatorPath).forEach { name in
                guard !name.hasPrefix(".") else { return }
                
                if
                let attributes = try? manager.attributesOfItemAtPath(simulatorPath + "/\(name)"),
                let date = attributes[NSFileModificationDate] as? NSDate {
                    deviceData.append(Simulator(name: name, date: date))
                }
            }
        }
        catch let error {
            print("failed load simulator: \(simulatorPath)\n\t\(error)")
        }
        
        histories = deviceData
            .sort { $0.date.compare($1.date) == .OrderedDescending }
            .map  { $0.name }
    }
    
}