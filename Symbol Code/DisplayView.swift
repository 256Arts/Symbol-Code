//
//  DisplayView.swift
//  Symbol Code
//
//  Created by Jayden Irwin on 2021-05-22.
//

import SwiftUI

struct DisplayView: View {
    
    @Binding var selectedPosition: Position?
    @ObservedObject var projectExecuter: ProjectExecuter
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal) {
                Spacer()
                VStack(spacing: 0) {
                    ForEach(0..<projectExecuter.canvasSize.row, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<projectExecuter.canvasSize.column, id: \.self) { column in
                                Image(systemName: projectExecuter.display[Position(row: row, column: column)]?.imageName ?? SymbolType.empty.imageName)
                                    .foregroundColor({
                                        let position = Position(row: row, column: column)
                                        if !projectExecuter.isRunning, position == selectedPosition {
                                            return Color.accentColor
                                        } else {
                                            let symbolType = projectExecuter.display[position]?.type ?? .empty
                                            return symbolType.color ?? Color(UIColor.label)
                                        }
                                    }())
                                    .frame(width: 40, height: 40)
                                    .onTapGesture {
                                        selectedPosition = Position(row: row, column: column)
                                    }
                            }
                        }
                    }
                }
                .padding()
                .frame(minWidth: geometry.size.width)
                Spacer()
            }
        }
        .overlay(
            projectExecuter.isRunning ?
            Text("\(projectExecuter.stepNumber)")
                .font(.body)
                .foregroundColor(Color(UIColor.quaternaryLabel))
                .padding()
            : nil
        , alignment: .bottomTrailing)
    }
}

struct DisplayView_Previews: PreviewProvider {
    static var previews: some View {
        DisplayView(selectedPosition: .constant(nil), projectExecuter: .init(project: .constant(.init())))
    }
}
