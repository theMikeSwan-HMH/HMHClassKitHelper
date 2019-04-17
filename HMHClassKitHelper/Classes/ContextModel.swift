//
//  ContextModel.swift
//  HMHClassKitHelper
//
//  Created by Swan, Michael on 3/5/19.
//  Copyright © 2019 Houghton Mifflin Harcourt. All rights reserved.
//

import Foundation
import ClassKit

/// A struct designed to facilitate converting JSON data in to `CLSContext` instances.
@available(iOS 11.3, *)
public struct ContextModel: Codable {
    
    /// App-assigned identifier. This identifier should work across users and devices and be unique with regards to its siblings within its parent.
    ///
    /// The identifier could be used to embed information later used for deep linking. For example: @em hydrogen-element, or @em chapter-1.
    public let identifier: String
    
    /// Title of this context.
    ///
    /// For example: @em Level 1 @em.
    let title: String
    
    /// The displayOrder is by default sorted ascending.
    ///
    /// Set the displayOrder if you want your contexts to be displayed in a particular order. The sort key is used as a way to sort sibling contexts in a particular order.
    let displayOrder: Int
    
    /// An Int with the raw value for the `type` property. See `CLSContextType` for possible values that will convert to something other than `.none`.
    let typeInt: Int
    
    /// A string with the raw value for the `topic` property. See `CLSContextType` for possible values that will convert to an actual `CLSContextTopic`.
    let topicString: String?
    
    public let children: [ContextModel]?
    
    /// Alternative deep link URL using universal links.
    ///
    /// If your app supports universal links, you can supply them here to link the content this context represents.
    let universalLink: URL?
    
    /// Type of this context
    ///
    /// The type that best describes this context. Computed from `typeInt`. See `CLSContextType` for possible values.
    var type: CLSContextType {
        get {
            return CLSContextType.init(rawValue: typeInt) ?? .none
        }
    }
    
    /// Topic associated with this context.
    ///
    /// See `CLSContextTopic` for valid, predefined topics. Computed from `topicString`.
    var topic: CLSContextTopic? {
        get {
            guard let topicName = topicString else { return nil }
            return CLSContextTopic.init(rawValue: topicName)
        }
    }
}
