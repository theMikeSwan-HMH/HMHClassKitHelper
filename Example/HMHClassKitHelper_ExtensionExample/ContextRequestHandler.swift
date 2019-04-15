//
//  ContextRequestHandler.swift
//  HMHClassKitHelper_ExtensionExample
//
//  Created by Swan, Michael on 4/11/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import ClassKit
import HMHClassKitHelper
import os

class ContextRequestHandler: NSObject, NSExtensionRequestHandling, CLSContextProvider, ContextRequestHandlerProtocol {
    
    internal let helper = ClassKitHelper.shared
    internal let log = OSLog(subsystem: Bundle.main.bundleIdentifier! + ".ContextRequestHandler", category: "ClassKit")

    func beginRequest(with context: NSExtensionContext) {
        // This is a required function defined by the NSExtensionRequestHandling protocol. This function
        // will be called once per connection from a host. Therefore, it may be called several times, if
        // the host disconnects and reconnects several times. This is where you can have code that performs
        // one-time initialization.
        
        // Need to tell our instance of the helper what files to work with.
        let files = contentFiles()
        for file in files {
            helper.addJSON(file: file)
        }
    }

    func updateDescendants(of context: CLSContext, completion: @escaping (Error?) -> Void) {
        // We have to do it this way because we cannot provide a default implementation of an Objective-C protocol method in an extension. This is pretty easy to do though.
        // The default implementation takes care of all the heavy lifting for us.
        hmh_updateDescendants(of: context, completion: completion)
    }
}
