//
//  StringTrimExtension.swift
//  ActiveLabel
//
//  Created by Pol Quintana on 04/09/16.
//  Copyright © 2016 Optonaut. All rights reserved.
//

import Foundation

extension String {
    func trim(to maximumCharacters: Int) -> String {
        guard count > maximumCharacters else { return self }
        let index = self.index(self.startIndex, offsetBy: maximumCharacters)
        return String(self[..<index]) + "..."
    }
}
