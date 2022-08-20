//
//  SymbolKeyboard.swift
//  Symbol Code
//
//  Created by Jayden Irwin on 2021-05-22.
//

import SwiftUI

struct SymbolKeyboard: View {
    
    @Environment(\.horizontalSizeClass) var sizeClass
    
    @Binding var selectedPosition: Position?
    @ObservedObject var projectExecuter: ProjectExecuter
    
    var showingStepper: Bool {
        let symbol = projectExecuter.initialCanvas[selectedPosition ?? Position(row: 0, column: 0)]
        return symbol?.intValue != nil && symbol?.type != .die
    }
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 40, maximum: 50))], spacing: 8, content: {
            ForEach(SymbolType.allCases) { symbol in
                Image(systemName: symbol.imageName)
                    .foregroundColor(symbol.color ?? Color(UIColor.label))
                    .onTapGesture {
                        if let position = selectedPosition {
                            switch symbol {
                            case .empty:
                                projectExecuter.initialCanvas[position] = nil
                            case .varInt, .varCharacter, .constInt, .constCharacter:
                                projectExecuter.initialCanvas[position] = Symbol(type: symbol, intValue: 1)
                            default:
                                projectExecuter.initialCanvas[position] = Symbol(type: symbol, intValue: nil)
                            }
                            
                            if position.column + 1 < projectExecuter.canvasSize.column {
                                selectedPosition?.column += 1
                            }
                        }
                    }
            }
        })
        .padding(sizeClass == .compact ? .bottom : .trailing, sizeClass == .compact ? 40 : 100)
        .overlay(
            showingStepper ?
            Stepper("Value") {
                if let index = selectedPosition {
                    let oldSymbol = projectExecuter.initialCanvas[index]
                    if let oldValue = oldSymbol?.intValue, oldSymbol?.type != .die {
                        let newValue = oldValue + 1
                        let newSymbol = Symbol(type: oldSymbol!.type, intValue: newValue)
                        projectExecuter.initialCanvas[index] = newSymbol
                    }
                }
            } onDecrement: {
                if let index = selectedPosition {
                    let oldSymbol = projectExecuter.initialCanvas[index]
                    if let oldValue = oldSymbol?.intValue, oldSymbol?.type != .die {
                        let newValue = oldValue - 1
                        let newSymbol = Symbol(type: oldSymbol!.type, intValue: newValue)
                        projectExecuter.initialCanvas[index] = newSymbol
                    }
                }
            }
            .labelsHidden()
            : nil
            , alignment: sizeClass == .compact ? .bottom : .trailing)
        .padding()
        .background(Color(UIColor.secondarySystemBackground).ignoresSafeArea())
    }
}

struct SymbolKeyboard_Previews: PreviewProvider {
    static var previews: some View {
        SymbolKeyboard(selectedPosition: .constant(nil), projectExecuter: .init(project: .constant(.init())))
    }
}
