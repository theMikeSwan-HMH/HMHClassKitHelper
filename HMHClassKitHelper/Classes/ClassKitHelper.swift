//
//  ClassKitHelper.swift
//  HMHClassKitHelper
//
//  Created by Swan, Michael on 4/17/18.
//  Copyright © 2018 Houghton Mifflin Harcourt. All rights reserved.
//

import UIKit
import ClassKit
//#if canImport(os)
import os
//#endif

/// `ClassKitHelper` takes care of declaring and suppling all `CLSContext`s.
///
/// At present this version is designed to be given one JSON file with all of the infomation needed to create _all_ the `ContextModel`s that need to be decalared. In the future it will likely need to be updated to handle multiple sources that come in at different times.
/// Need to have a single JSON file for each root level item in the app. For example if the app has three grades of content there should be a JSON file for each of those grades.
@available(iOS 11.3, *)
public class ClassKitHelper: NSObject, CLSDataStoreDelegate {
    
    @objc public static let shared = ClassKitHelper()
    
    private let timingLog: OSLog
    private let subsystem = Bundle.main.bundleIdentifier! + ".ClassKitHelper"
    
    override init() {
        #if DEBUG
        timingLog = OSLog(subsystem: subsystem, category: "Timing")
        #else
        timingLog = .disabled
        #endif
        super.init()
        CLSDataStore.shared.delegate = self
    }
    
    /// Array of all current JSON file paths
    private var jsonFiles = [String]()
    /// Array holding the root `ContextModel` from each JSON file known to `ClassKitHelper`.
    private var rootModels = [ContextModel]()
    
    /// Tells `ClassKitHelper` about a new JSON file it should use when declaring and looking for contexts.
    ///
    /// Note: The JSON file will only be read when it is first added. Later changes to the file will not be noticed.
    ///
    /// If the JSON file has been previously added or if there is already a root `ContextModel` with the same identifier `ClassKitHelper` will ignore the file.
    ///
    /// - Parameter file: Path to the JSON file
    @objc(addJSONFile:) public func addJSON(file: String) {
        guard !jsonFiles.contains(file) else { return }
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: file)) else { return }
        jsonFiles.append(file)
        let decoder = JSONDecoder()
        guard let root = try? decoder.decode(ContextModel.self, from: data) else { return }
        guard !rootModels.contains(where: { $0.identifier == root.identifier }) else { return }
        rootModels.append(root)
    }
    
    /// Supplies ClassKit with a new context with the given identifier for the given parent context as specified by the `CLSDataStoreDelegate` protocol.
    ///
    /// Pulls the required information from the `ContextModel` with the matching identifier path (provided there is one).
    ///
    /// - Parameters:
    ///   - identifier: The identifier of the new context.
    ///   - parentContext: The parent of the new context.
    ///   - parentIdentifierPath: The identifier path of the parent context.
    /// - Returns: The new context.
    public func createContext(forIdentifier identifier: String, parentContext: CLSContext, parentIdentifierPath: [String]) -> CLSContext? {
        var identifierPath = parentContext.identifierPath
        identifierPath = Array(identifierPath.dropFirst())
        identifierPath.append(identifier)
        guard let modelObject = contextModel(for: identifierPath, in: rootModels) else { return nil }
        
        let context = CLSContext(type: modelObject.type, identifier: identifier, title: modelObject.title)
        context.displayOrder = modelObject.displayOrder
        context.topic = modelObject.topic
        context.universalLinkURL = modelObject.universalLink
        return context
    }
    
    /// Starts the context declaration process. The time it takes is a combination of the number of context and their depth.
    ///
    /// Given that this method may take a noticable amount of time it is best to call it on a background thread.
    @objc public func declareContexts() {
//        let start = CFAbsoluteTimeGetCurrent()
        for model in rootModels {
            declareContexts(with: model, rootIDPath: [model.identifier])
        }
//        let end = CFAbsoluteTimeGetCurrent() - start
//        if #available(iOS 12.0, *) {
//            os_log(.info, log: timingLog, "Declaring contexts took %l seconds.", end)
//        } else {
//            #if DEBUG
//            print("Declaring contexts took \(end) seconds.")
//            #endif
//        }
    }
    
    /// Recursively traverses a `ContextModel` tree starting with the one passed in, reaching down to the deepest model of each path. Once the deepest model has been found it is declared to ClassKit. Obviously, the more complex the data the longer this will take.
    ///
    /// Starts with the passed in `ContextModel` and then recursively travels through the items in `children` until it finds the bottom. Once at the bottom of a branch it declares that context and moves to any siblings that exist. Once all siblings have been exhausted it moves up one level and repeats the process.
    ///
    /// - Parameters:
    ///   - model: The ContextModel that should be traversed and have its contexts declared
    ///   - rootIDPath: The identifier path of the passed in ContextModel
    private func declareContexts(with model: ContextModel, rootIDPath: [String]) {
        if let kids = model.children {
            for kid in kids {
                var newIDPath = rootIDPath
                newIDPath.append(kid.identifier)
                declareContexts(with: kid, rootIDPath: newIDPath)
            }
        } else {
            CLSDataStore.shared.mainAppContext.descendant(matchingIdentifierPath: rootIDPath) { (_, _) in }
        }
    }
    
    /// Gets the ContextModel object for the given path recursively.
    ///
    /// - Parameter identifierPath: Array of Strings describing the identifier path to take to get to the context model.
    /// - Parameter models: Array of `ContextModel`s within which to search.
    /// - Returns: The `ContextModel` at the specified identifier path if one exists.
    private func contextModel(for identifierPath: [String], in models: [ContextModel]) -> ContextModel? {
        if models.isEmpty { return nil }
        let filteredModels = models.filter({ $0.identifier == identifierPath[0] })
        guard let model = filteredModels.first else { return nil }
        if identifierPath.count == 1 { return model }
        guard let kids = model.children else { return nil }
        return contextModel(for: Array(identifierPath.dropFirst()), in: kids)
    }
    
    /// Returns the `ContextModel` with the given identifier path, provided one exists.
    ///
    /// - Parameter identifierPath: Array of strings pointing to the desired `ContextModel`.
    /// - Returns: The desired `ContextModel` if one was found, `nil` if not.
    public func contextModel(for identifierPath: [String]) -> ContextModel? {
        if identifierPath.isEmpty {
            // We are at the root level, need to build a context that has all of our root models as children and return that.
            let context = ContextModel(identifier: "", title: "", displayOrder: 0, typeInt: 1, topicString: nil, children:rootModels, universalLink: nil)
            return context
        }
        return contextModel(for: identifierPath, in: rootModels)
    }
    
}
