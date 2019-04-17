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

class ContextRequestHandler: NSObject, NSExtensionRequestHandling, CLSContextProvider/*, ContextRequestHandlerProtocol*/ {
    
    internal let helper = ClassKitHelper.shared
//    internal let handler = HMHContextRequestHandler.shared
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
        
        
        var error: Error? = nil
        
        guard let model = helper.contextModel(for: Array(context.identifierPath.dropFirst())) else {
            error = ClassKitError.contextNotFound(identifierPath: Array(context.identifierPath.dropFirst()))
            os_log(.error, log: self.log, "Unable to find a context model matching the path: %@", context.identifierPath)
            completion(error)
            return
        }
        guard let kids = model.children, kids.count > 0 else {
            os_log(.info, log: self.log, "The identifier path, %@, has no children.", context.identifierPath)
            completion(error)
            return
        }
        
        let predicate = NSPredicate(format: "%K = %@", CLSPredicateKeyPath.parent as CVarArg, context)
        CLSDataStore.shared.contexts(matching: predicate) { (childContexts, _) in
            for childNode in kids {
                if !childContexts.contains(where: { (context) -> Bool in
                    context.identifier == childNode.identifier
                }), let childContext = self.helper.createContext(forIdentifier: childNode.identifier, parentContext: context, parentIdentifierPath: context.identifierPath) {
                    context.addChildContext(childContext)
                }
            }
            CLSDataStore.shared.save(completion: { (error) in
                if let error = error {
                    os_log(.error, log: self.log, "Save error: %s", error.localizedDescription)
                } else {
                    os_log(.info, log: self.log, "Saved contexts")
                }
                completion(error)
            })
        }
    }
}
