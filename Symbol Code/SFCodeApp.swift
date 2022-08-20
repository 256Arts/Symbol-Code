//
//  SymbolCodeApp.swift
//  Symbol Code
//
//  Created by Jayden Irwin on 2021-05-22.
//

import SwiftUI

@main
struct SymbolCodeApp: App {
    
    static let appWhatsNewVersion = 1
    
    init() {
        UserDefaults.standard.register()
    }
    
    var body: some Scene {
        DocumentGroup(newDocument: SFCodeProject()) { file in
            ContentView(projectExecuter: ProjectExecuter(project: file.$document))
        }
    }
}
