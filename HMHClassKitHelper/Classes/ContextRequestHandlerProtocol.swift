//  ContextRequestHandlerProtocol.swift
//  HMHClassKitHelper
//
//  Created by Swan, Michael on 3/5/19.
//  Copyright © 2019 Houghton Mifflin Harcourt. All rights reserved.
//

import Foundation
import ClassKit
import os

public protocol ContextRequestHandlerProtocol: CLSContextProvider {
    var helper: ClassKitHelper { get }
    var log: OSLog { get }
    
    func hmh_updateDescendants(of context: CLSContext, completion: @escaping (Error?) -> Void)
}

public extension ContextRequestHandlerProtocol {
    func hmh_updateDescendants(of context: CLSContext, completion: @escaping (Error?) -> Void) {
        var error: Error? = nil
        
        guard let model = helper.contextModel(for: Array(context.identifierPath.dropFirst())) else {
            // TODO: Need to set the error to something non-nil here
            error = ClassKitError.contextNotFound(identifierPath: Array(context.identifierPath.dropFirst()))
            os_log(.error, log: self.log, "Unable to find a context model matching the path: %@", context.identifierPath)
            completion(error)
            return
        }
        guard let kids = model.children else {
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
