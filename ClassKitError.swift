//
//  ClassKitError.swift
//  HMHClassKitHelper
//
//  Created by Swan, Michael on 3/29/19.
//

import Foundation


/// Possible errors from the default implementations of `ClassKitEnabled` methods.
///
/// - contextNotFound: No context was found at the given identifier path
/// - classKitError: Error from ClassKit itself
/// - noActivity: No activity attached to the given identifier path
public enum ClassKitError: Error {
    case contextNotFound(identifierPath: [String])
    case classKitError(underlyingError: Error)
    case noActivity(identifierPath: [String])
}
