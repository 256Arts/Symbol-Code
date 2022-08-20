//
//  HelpView.swift
//  Symbol Code
//
//  Created by Jayden Irwin on 2021-05-23.
//

import SwiftUI

struct HelpView: View {
    
    let allSymbols: [SymbolType] = [
        .varInt, .convertInt, .right, .duplicate, .toggle, .noEntry, .trash, .add, .modulo, .equal, .constInt, .die, .input, .print, .sound, .stop
    ]
    
    var body: some View {
        Form {
            Section {
                ForEach(allSymbols) { symbol in
                    HStack {
                        Image(systemName: symbol.imageName)
                            .foregroundColor(symbol.color)
                            .font(.system(size: 24, weight: .semibold))
                            .frame(width: 44)
                        Text({ () -> String in
                            switch symbol {
                            case .varInt:
                                return "Variables store numbers (0-50) or letters, and move around the grid. (Initially move right.)"
                            case .convertInt:
                                return "Convert variables to a number or letter."
                            case .right:
                                return "Arrows change the direction of variables."
                            case .duplicate:
                                return "Double arrows duplicate variables in the 2 perpendicular directions."
                            case .noEntry:
                                return "Blocks variables from moving onto this position when enabled. Variables wait on adjacent positions. (See \"Toggle\".)"
                            case .trash:
                                return "Deletes variables."
                            case .add:
                                return "Adds all variables on this position, and all adjacent constants."
                            case .modulo:
                                return "Modulo all variables on this position, and all adjacent constants."
                            case .equal:
                                return "Points variables in the direction of an adjacent constant of equal value. If no equal constant is found, the variable is compared to all other variables on this position, and pointed right if they are all equal, otherwise a (0) is sent left."
                            case .constInt:
                                return "Constant number (0-50) or letter. (Does not move.)"
                            case .die:
                                return "Die generate a number 1-6 every time they are read."
                            case .input:
                                return "Asks the user to input a new value for the variable."
                            case .print:
                                return "Prints the variable to the output."
                            case .sound:
                                return "Plays a sound."
                            case .toggle:
                                return "Toggles adjacent \"blocks\", and flips adjacent arrows. If there is a constant next to the toggle, a variable will be spawned with that value, and sent in the direction away from the toggle."
                            case .stop:
                                return "Stops the program."
                            default:
                                return ""
                            }
                        }())
                    }
                }
            }
            Section {
                Text("Multiple variables can share the same position as long as they are going different directions. If multiple variables share position and direction, they are combined using the math operation at the position. If there is no math operation at the position, the variables are added.")
            } header: {
                Text("Variable Position-Sharing")
            }
            Section {
                Text("Variables can store numbers 0-50. If the result of an operation is less than 0, the variable will be set to 0. If the result is greater than 50, the variable will be set to 50.")
            } header: {
                Text("Number Limits")
            }
        }
        .imageScale(.large)
        .symbolVariant(.fill)
        .navigationTitle("Help")
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}
