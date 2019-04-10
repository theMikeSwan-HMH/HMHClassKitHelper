//
//  DataModel.swift
//  HMHClassKitHelper_Example
//
//  Created by Swan, Michael on 3/21/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit


struct Play: Codable {
    let title: String
    let identifier: String
    let acts: [Act]
    
    enum CodingKeys: String, CodingKey {
        case title
        case identifier
        case acts = "children"
    }
}

struct Act: Codable {
    let title: String
    let identifier: String
    let scenes: [Scene]
    var number: Int {
        return Int(title.replacingOccurrences(of: "Act ", with: "")) ?? 1
    }
    var displayTitle: String {
        return "Act \(number.romanNumeral)"
    }
    
    enum CodingKeys: String, CodingKey {
        case title
        case identifier
        case scenes = "children"
    }
}

struct Scene: Codable {
    let title: String
    let identifier: String
    var number: Int {
        return Int(title.replacingOccurrences(of: "Scene ", with: "")) ?? 1
    }
    let contentPath: String
    
    var contents: NSAttributedString {
        let data = Data(adaptedHTML().utf8)
        if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
            return attributedString
        }
        return NSAttributedString(string: "Unable to load scene text!")
    }
    
    private func adaptedHTML() -> String {
        guard let url = URL(string: contentPath), let source = try? String(contentsOf: url) else { return "" }
        let parts = source.components(separatedBy: "<table")
        var intermediate = ""
        for part in parts {
            let x = part.components(separatedBy: "</table>")
            intermediate.append(x.last ?? "")
        }
        var y = intermediate.components(separatedBy: "</body>")
        if let scheme = url.scheme, let base = url.baseURL {
            y.insert("<p>Script text courtesy of <a href=\"\(scheme)\(base)\">\(base)</a></p>\n</body>", at: 1)
        } else {
            y.insert("\n</body>", at: 1)
        }
        let final = y.joined(separator: "")
        return final
    }
}
