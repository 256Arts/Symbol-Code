//
//  Symbols.swift
//  Symbol Code
//
//  Created by Jayden Irwin on 2021-05-22.
//

import SwiftUI

struct Symbol: Codable {
    
    static let characters: [String] = [" ", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "@", "#", "$", "-", "+", "÷", "=", "/", "^", ".", "!", "?", "<", ">", "bookmark", "heart", "star", "flag", "tag", "bolt", "eye", "lock", "pin", "\n"]
    
    var type: SymbolType
    var intValue: Int?
    
    var value: Any? {
        switch type {
        case .varInt, .constInt, .die:
            return intValue
        case .varCharacter, .constCharacter:
            return Self.characters[intValue!]
        default:
            return nil
        }
    }
    var imageName: String {
        
        func characterImageNamePrefix(character: String) -> String {
            switch character {
            case " ":
                return "viewfinder"
            case "@":
                return "at"
            case "#":
                return "number"
            case "$":
                return "dollarsign"
            case "*":
                return "asterisk"
            case "%":
                return "percent"
            case "-":
                return "minus"
            case "+":
                return "plus"
            case "÷":
                return "divide"
            case "=":
                return "equal"
            case "/":
                return "slash"
            case "^":
                return "chevron.up"
            case ".":
                return "smallcircle.filled"
            case "!":
                return "exclamationmark"
            case "?":
                return "questionmark"
            case "<":
                return "lessthan"
            case ">":
                return "greaterthan"
            case "\n":
                return "arrow.backward.to.line"
            default:
                return character.lowercased()
            }
        }
        
        switch type {
        case .varInt:
            return "\(intValue!).circle"
        case .varCharacter:
            return "\(characterImageNamePrefix(character: (value! as! String))).circle"
        case .constInt:
            return "\(intValue!).square"
        case .constCharacter:
            return "\(characterImageNamePrefix(character: (value! as! String))).square"
        case .die:
            return "die.face.\(intValue!)"
        default:
            return type.imageName
        }
    }
    
}

enum SymbolType: String, CaseIterable, Identifiable, Codable {
    
    case empty
    
    // Variables
    case varInt
    case varCharacter
    case convertInt
    case convertCharacter
    
    // Movement
    case up
    case down
    case left
    case right
    case duplicate
    case toggle
    case noEntryDisabled
    case noEntry
    case trash
    
    // Math
    case add
    case subtract
    case multiply
    case divide
    case modulo
    case equal
    
    // Constants
    case constInt
    case constCharacter
    case die
    
    // Actions
    case input
    case print
    case sound
    case stop
    
    var id: Self { self }
    
    var color: Color? {
        switch self {
        case .empty, .noEntryDisabled:
            return Color(UIColor.systemFill)
        case .convertInt, .convertCharacter:
            return .purple
        case .up, .down, .left, .right, .duplicate:
            return .cyan
        case .add, .subtract, .multiply, .divide, .modulo, .equal:
            return .orange
        case .noEntry, .trash, .stop:
            return .red
        case .constInt, .constCharacter, .die:
            return .gray
        case .input, .print, .sound, .toggle:
            return .green
        default:
            return nil
        }
    }
    
    var imageName: String {
        switch self {
        case .empty:
            return "square"
        
        // Variables
        case .varInt:
            return "1.circle"
        case .varCharacter:
            return "a.circle"
        case .convertInt:
            return "number"
        case .convertCharacter:
            return "textformat"
        
        // Movement
        case .up:
            return "arrowtriangle.up"
        case .down:
            return "arrowtriangle.down"
        case .left:
            return "arrowtriangle.left"
        case .right:
            return "arrowtriangle.right"
        case .duplicate:
            return "diamond"
        case .equal:
            return "equal"
        case .noEntry:
            return "nosign"
        case .noEntryDisabled:
            return "nosign"
        case .trash:
            return "xmark.bin"
        
        // Math
        case .add:
            return "plus"
        case .subtract:
            return "minus"
        case .multiply:
            return "multiply"
        case .divide:
            return "divide"
        case .modulo:
            return "percent"
        
        // Constants
        case .constInt:
            return "1.square"
        case .constCharacter:
            return "a.square"
        case .die:
            return "die.face.5"
        
        // Actions
        case .input:
            return "keyboard"
        case .print:
            return "printer"
        case .sound:
            return "music.note"
        case .toggle:
            return "switch.2"
        case .stop:
            return "xmark.octagon"
        }
    }
    
}
