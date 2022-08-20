//
//  InputView.swift
//  Symbol Code
//
//  Created by Jayden Irwin on 2021-05-24.
//

import SwiftUI

struct InputView: View {
    
    @ObservedObject var projectExecuter: ProjectExecuter
    
    var body: some View {
        NavigationView {
            Form {
                Section(footer: Text("You are asked for input every time a variable (\(Image(systemName: "questionmark.circle.fill"))) moves onto a \(Image(systemName: "keyboard")).")) {
                    ForEach(projectExecuter.variablesWaitingForInput, id: \.index) { (index, variable) in
                        HStack {
                            Text("\(Image(systemName: "questionmark.circle.fill")) =")
                            TextField("Value", text: Binding(get: {
                                String(projectExecuter.variables[index].value)
                            }, set: { newValue in
                                projectExecuter.variables[index].value = min(max(0, Int(newValue) ?? 0), 50)
                            }))
                            .keyboardType(.numberPad)
                        }
                    }
                }
            }
            .navigationTitle("Enter Input")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Enter") {
                        projectExecuter.variablesWaitingForInput.removeAll()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Stop") {
                        projectExecuter.stop()
                    }
                }
            }
        }
    }
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        InputView(projectExecuter: .init(project: .constant(.init())))
    }
}
