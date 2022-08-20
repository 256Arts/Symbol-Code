//
//  SFCodeProject.swift
//  Symbol Code
//
//  Created by Jayden Irwin on 2022-06-10.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static var symbolCodeProject: UTType {
        UTType(importedAs: "com.jaydenirwin.symbolcode")
    }
}

struct SFCodeProject: FileDocument, Codable {
    
    static var readableContentTypes: [UTType] { [.symbolCodeProject] }
    
    var fileVersion = 1
    var canvas: [Position: Symbol] = [:]
    
    init() { }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        let project = try JSONDecoder().decode(SFCodeProject.self, from: data)
        
        fileVersion = project.fileVersion
        canvas = project.canvas
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(self)
        return .init(regularFileWithContents: data)
    }
    
}
