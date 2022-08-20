//
//  SettingsView.swift
//  Symbol Code
//
//  Created by Jayden Irwin on 2022-01-09.
//

import SwiftUI

struct SettingsView: View {
    
    enum Page {
        case help
    }
    
    @AppStorage(UserDefaults.Key.alwaysPrintNewline) var alwaysPrintNewline = true
    
    @Environment(\.dismiss) var dismiss
    
    @State var showHelp = false
    @State private var presentedPages: [Page] = []
    
    var body: some View {
        NavigationStack(path: $presentedPages) {
            List {
                Section {
                    Toggle("Always print on a newline", isOn: $alwaysPrintNewline)
                }
                Section {
                    NavigationLink("Help", value: Page.help)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .navigationDestination(for: Page.self) { page in
                switch page {
                case .help:
                    HelpView()
                }
            }
            .onAppear {
                if showHelp {
                    presentedPages = [.help]
                    showHelp = false
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
