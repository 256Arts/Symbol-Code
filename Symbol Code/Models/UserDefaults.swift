//
//  UserDefaults.swift
//  Symbol Code
//
//  Created by Jayden Irwin on 2021-05-22.
//

import Foundation

extension UserDefaults {
    
    struct Key {
        static let whatsNewVersion = "whatsNewVersion"
        static let alwaysPrintNewline = "consoleAlwaysPrintNewline"
    }
    
    func register() {
        register(defaults: [
            Key.whatsNewVersion: 0,
            Key.alwaysPrintNewline: true
        ])
    }
    
}
