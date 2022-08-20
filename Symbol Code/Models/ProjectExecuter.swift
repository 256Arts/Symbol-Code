//
//  ProjectExecuter.swift
//  Symbol Code
//
//  Created by Jayden Irwin on 2021-05-22.
//

import SwiftUI
import AVFoundation

struct Position: Hashable, Codable {
    var row: Int
    var column: Int
}

class ProjectExecuter: ObservableObject {
    
    class Variable {
        
        enum Representation {
            case int, character
        }
        enum Direction {
            case up, down, left, right
        }
        
        var value: Int {
            didSet {
                if value < 0 {
                    value = 0
                } else if 50 < value {
                    value = 50
                }
            }
        }
        var representation: Representation
        var position: Position
        var direction: Direction
        
        var symbol: Symbol {
            Symbol(type: {
                switch representation {
                case .int:
                    return .varInt
                case .character:
                    return .varCharacter
                }
            }(), intValue: value)
        }
        var printStringApproximation: String {
            switch representation {
            case .int:
                return String(value)
            case .character:
                let character = Symbol.characters[value]
                if character.count == 1 {
                    return character
                } else {
                    return "(\(value))"
                }
            }
        }
        var printText: Text {
            switch representation {
            case .int:
                return Text(String(value))
            case .character:
                let character = Symbol.characters[value]
                if character.count == 1 {
                    return Text(character)
                } else {
                    return Text("\(Image(systemName: character))")
                }
            }
        }
        
        init(value: Int, representation: Representation, position: Position) {
            self.value = value
            self.representation = representation
            self.position = position
            self.direction = .right
        }
        
    }
    
    static let defaultSize: Position = {
        #if targetEnvironment(macCatalyst)
        return Position(row: 16, column: 24)
        #else
        return Position(row: 10, column: 16)
        #endif
    }()
    static let largeSize: Position = {
        #if targetEnvironment(macCatalyst)
        return Position(row: 32, column: 32)
        #else
        return Position(row: 16, column: 24)
        #endif
    }()
    
    let audioPlayer: AVAudioPlayer? = try? AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "Bell", withExtension: "wav")!)
    
    @AppStorage(UserDefaults.Key.alwaysPrintNewline) var alwaysPrintNewline = true
    
    @Binding var project: SFCodeProject
    @Published var initialCanvas: [Position: Symbol] {
        didSet {
            // Save changes back to file document
            project.canvas = initialCanvas
        }
    }
    
    @Published var runtimeCanvas: [Position: Symbol] = [:]
    @Published var canvasSize = defaultSize
    @Published var variables: [Variable] = []
    @Published var console = Text("")
    @Published var consoleIsEmpty = true
    var consoleStringApproximation = ""
    var stepNumber = 0
    var tempDieNumberValues: [Position: Int?] = [:]
    var tempNeighborsValues: [Position: [Int]] = [:] // Includes variables at the positions
    
    @Published var isRunning = false
    @Published var variablesWaitingForInput: [(index: Int, variable: Variable)] = []
    @Published var showingJaydenCode = false
    var display: [Position: Symbol] {
        if isRunning {
            var display = runtimeCanvas
            for variable in variables {
                display[variable.position] = variable.symbol
            }
            return display
        } else {
            return initialCanvas
        }
    }
    
    init(project: Binding<SFCodeProject>) {
        self._project = project
        self.initialCanvas = project.wrappedValue.canvas
    }
    
    func run() {
        runtimeCanvas = initialCanvas
        for position in runtimeCanvas.keys {
            if let symbol = runtimeCanvas[position], let value = symbol.intValue {
                switch symbol.type {
                case .varInt:
                    runtimeCanvas[position] = Symbol(type: .empty, intValue: nil)
                    variables.append(Variable(value: value, representation: .int, position: position))
                case .varCharacter:
                    runtimeCanvas[position] = Symbol(type: .empty, intValue: nil)
                    variables.append(Variable(value: value, representation: .character, position: position))
                default:
                    break
                }
                
            }
        }
        guard !variables.isEmpty else { return }
        isRunning = true
    }
    
    func stop() {
        isRunning = false
        variables.removeAll()
        console = Text("")
        consoleStringApproximation = ""
        consoleIsEmpty = true
        stepNumber = 0
        variablesWaitingForInput.removeAll()
    }
    
    func step() {
        guard isRunning, variablesWaitingForInput.isEmpty else { return }
        objectWillChange.send()
        stepNumber += 1
        // Move
        for (index, variable) in variables.enumerated().reversed() {
            switch variable.direction {
            case .up:
                var newPos = variable.position
                newPos.row -= 1
                if newPos.row < 0 {
                    variables.remove(at: index)
                    if variables.isEmpty {
                        stop()
                    }
                    continue
                } else if runtimeCanvas[newPos]?.type != .noEntry {
                    variable.position = newPos
                }
            case .down:
                var newPos = variable.position
                newPos.row += 1
                if canvasSize.row <= newPos.row {
                    variables.remove(at: index)
                    if variables.isEmpty {
                        stop()
                    }
                    continue
                } else if runtimeCanvas[newPos]?.type != .noEntry {
                    variable.position = newPos
                }
            case .left:
                var newPos = variable.position
                newPos.column -= 1
                if newPos.column < 0 {
                    variables.remove(at: index)
                    if variables.isEmpty {
                        stop()
                    }
                    continue
                } else if runtimeCanvas[newPos]?.type != .noEntry {
                    variable.position = newPos
                }
            case .right:
                var newPos = variable.position
                newPos.column += 1
                if canvasSize.column <= newPos.column {
                    variables.remove(at: index)
                    if variables.isEmpty {
                        stop()
                    }
                    continue
                } else if runtimeCanvas[newPos]?.type != .noEntry {
                    variable.position = newPos
                }
            }
        }
        
        // Action
        actionLoop:
        for (index, variable) in variables.enumerated().reversed() {
            switch runtimeCanvas[variable.position]?.type {
            case .convertInt:
                variable.representation = .int
            case .convertCharacter:
                variable.representation = .character
            case .up:
                variable.direction = .up
            case .down:
                variable.direction = .down
            case .left:
                variable.direction = .left
            case .right:
                variable.direction = .right
            case .duplicate:
                switch variable.direction {
                case .left, .right:
                    variable.direction = .up
                    let copy = Variable(value: variable.value, representation: variable.representation, position: variable.position)
                    copy.direction = .down
                    variables.append(copy)
                default:
                    variable.direction = .left
                    let copy = Variable(value: variable.value, representation: variable.representation, position: variable.position)
                    copy.direction = .right
                    variables.append(copy)
                }
            case .trash:
                variables.remove(at: index)
                if variables.isEmpty {
                    stop()
                }
                continue
            case .add:
                for otherValue in neighborsValues(for: variable) {
                    variable.value += otherValue
                }
            case .subtract:
                for otherValue in neighborsValues(for: variable) {
                    variable.value -= otherValue
                }
            case .multiply:
                for otherValue in neighborsValues(for: variable) {
                    variable.value *= otherValue
                }
            case .divide:
                for otherValue in neighborsValues(for: variable) {
                    if otherValue != 0 {
                        variable.value /= otherValue
                    }
                }
            case .modulo:
                for otherValue in neighborsValues(for: variable) {
                    if otherValue != 0 {
                        variable.value %= otherValue
                    }
                }
            case .equal:
                neighborLoop:
                for (_, neighbor) in neighborPositions(for: variable.position) {
                    let deltaRow = neighbor.row - variable.position.row
                    let deltaColumn = neighbor.column - variable.position.column
                    
                    if let neighborValue = readNumberValue(at: neighbor) {
                        // Match variable to equal constant
                        if variable.value == neighborValue {
                            if deltaRow == 1 {
                                variable.direction = .down
                            } else if deltaRow == -1 {
                                variable.direction = .up
                            } else if deltaColumn == 1 {
                                variable.direction = .right
                            } else {
                                variable.direction = .left
                            }
                            break actionLoop
                        }
                    }
                }
                
                // If variable was not equal to any constants, check if variable is euqal to other variables at the position
                let otherVars = variables.enumerated().reversed().filter({ $0.1.position == variable.position })
                let otherVarsAreEqual = otherVars.allSatisfy({ $0.1.value == variable.value })
                if otherVarsAreEqual {
                    variable.direction = .right
                } else {
                    variable.value = 0
                    variable.direction = .left
                }
                
            case .print:
                console = console + variable.printText
                if alwaysPrintNewline {
                    console = console + Text("\n")
                }
                consoleStringApproximation += variable.printStringApproximation
                if consoleStringApproximation.localizedCaseInsensitiveContains("JAYDEN") {
                    consoleStringApproximation = ""
                    showingJaydenCode = true
                }
                consoleIsEmpty = false
            case .sound:
                audioPlayer?.play()
            case .toggle:
                for neighbor in neighborPositions(for: variable.position) {
                    switch runtimeCanvas[neighbor.position]?.type {
                    case .noEntry:
                        runtimeCanvas[neighbor.position] = Symbol(type: .noEntryDisabled, intValue: nil)
                    case .noEntryDisabled:
                        runtimeCanvas[neighbor.position] = Symbol(type: .noEntry, intValue: nil)
                    case .up:
                        runtimeCanvas[neighbor.position] = Symbol(type: .down, intValue: nil)
                    case .down:
                        runtimeCanvas[neighbor.position] = Symbol(type: .up, intValue: nil)
                    case .left:
                        runtimeCanvas[neighbor.position] = Symbol(type: .right, intValue: nil)
                    case .right:
                        runtimeCanvas[neighbor.position] = Symbol(type: .left, intValue: nil)
                    case .constInt:
                        let neighborIntValue = runtimeCanvas[neighbor.position]!.intValue!
                        let spawnVar = Variable(value: neighborIntValue, representation: .int, position: neighbor.position)
                        spawnVar.direction = neighbor.direction
                        variables.append(spawnVar)
                    case .constCharacter:
                        let neighborIntValue = runtimeCanvas[neighbor.position]!.intValue!
                        let spawnVar = Variable(value: neighborIntValue, representation: .character, position: neighbor.position)
                        spawnVar.direction = neighbor.direction
                        variables.append(spawnVar)
                    default:
                        break
                    }
                }
            case .stop:
                stop()
                return
            default:
                break
            }
        }
        tempDieNumberValues.removeAll()
        tempNeighborsValues.removeAll()
        
        // Combine
        combineLoop:
        for (index, variable) in variables.enumerated().reversed() {
            for (otherIndex, otherVar) in variables.enumerated() {
                if index != otherIndex, variable.position == otherVar.position && variable.direction == otherVar.direction {
                    switch runtimeCanvas[variable.position]?.type {
                    case .up, .down, .left, .right, .duplicate: // Direction changers
                        otherVar.value += variable.value
                    default: // Includes .equal
                        break
                    }
                    variables.remove(at: index)
                    continue combineLoop
                }
            }
        }
        
        // Get Input
        variablesWaitingForInput = variables.enumerated().filter({ runtimeCanvas[$0.1.position]?.type == .input }).map({ ($0.0, $0.1) })
    }
    
    private func neighborPositions(for position: Position) -> [(direction: Variable.Direction, position: Position)] {
        var neighbors: [(Variable.Direction, Position)] = []
        if 0 < position.row {
            neighbors.append((.up, Position(row: position.row-1, column: position.column)))
        }
        if position.row+1 < canvasSize.row {
            neighbors.append((.down, Position(row: position.row+1, column: position.column)))
        }
        if 0 < position.column {
            neighbors.append((.left, Position(row: position.row, column: position.column-1)))
        }
        if position.column+1 < canvasSize.column {
            neighbors.append((.right, Position(row: position.row, column: position.column+1)))
        }
        return neighbors
    }
    
    private func readNumberValue(at position: Position) -> Int? {
        if let value = tempDieNumberValues[position] {
            return value
        } else if var symbol = runtimeCanvas[position] {
            if symbol.type == .die {
                symbol.intValue = Int.random(in: 1...6)
                runtimeCanvas[position] = symbol
            }
            tempDieNumberValues[position] = symbol.intValue
            return symbol.intValue
        }
        return nil
    }
    
    private func neighborsValues(for variable: Variable) -> [Int] {
        if var values = tempNeighborsValues[variable.position] {
            let selfIndex = values.firstIndex(of: variable.value)!
            values.remove(at: selfIndex)
            return values
        } else {
            var values = neighborPositions(for: variable.position).compactMap({ readNumberValue(at: $0.position) })
                + variables.filter({ $0.position == variable.position }).map({ $0.value })
            tempNeighborsValues[variable.position] = values
            let selfIndex = values.firstIndex(of: variable.value)!
            values.remove(at: selfIndex)
            return values
        }
    }
    
}
