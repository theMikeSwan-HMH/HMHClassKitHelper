//
//  Int+RomanNumeral.swift
//  HMHClassKitHelper_Example
//
//  Created by Swan, Michael on 3/21/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

extension Int {
    var romanNumeral: String {
        var integerValue = self
        var numeralString = ""
        let mappingList: [(Int, String)] = [(1000, "M"), (900, "CM"), (500, "D"), (400, "CD"), (100, "C"), (90, "XC"), (50, "L"), (40, "XL"), (10, "X"), (9, "IX"), (5, "V"), (4, "IV"), (1, "I")]
        for i in mappingList where (integerValue >= i.0) {
            while (integerValue >= i.0) {
                integerValue -= i.0
                numeralString.append(contentsOf: i.1)
            }
        }
        return numeralString
    }
}
