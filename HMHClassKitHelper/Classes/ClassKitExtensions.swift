//
//  ClassKitExtensions.swift
//  HMHClassKitHelper
//
//  Created by Swan, Michael on 3/29/19.
//

import Foundation
import ClassKit

public protocol ClassKitDataStore {
    var mainAppContext: CLSContext { get }
    func save(completion: ((Error?) -> Void)?)
}

extension CLSDataStore: ClassKitDataStore { }

/// An extension to provide a complete identifier path for a given ClassKit context.
public extension CLSContext {
    /// The complete identifier path of the ClassKit context.
    var identifierPath: [String] {
        var pathComponents: [String] = [identifier]
        
        if let parent = self.parent {
            pathComponents = parent.identifierPath + pathComponents
        }
        
        return pathComponents
    }
}
