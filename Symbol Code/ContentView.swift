//
//  ContentView.swift
//  Symbol Code
//
//  Created by Jayden Irwin on 2021-05-22.
//

import SwiftUI
import WelcomeKit
import JaydenCodeGenerator

struct ContentView: View {
    
    let welcomeFeatures = [
        WelcomeFeature(image: Image(systemName: "divide"), title: "Create Programs", body: "Code by placing symbols on the grid."),
        WelcomeFeature(image: Image(systemName: "1.circle.fill"), title: "Variables", body: "Circles represent variables that also move."),
        WelcomeFeature(image: Image(systemName: "play.circle"), title: "Run", body: "Try your code by tapping run.")
    ]
    
    @AppStorage(UserDefaults.Key.whatsNewVersion) var whatsNewVersion = 0
    
    @StateObject var projectExecuter: ProjectExecuter
    @State var selectedPosition: Position? = Position(row: 0, column: 0)
    @State var showingWelcome = false
    @State var showingSettings = false
    @State var showHelp = false
    @State var speed = 1
    @State var updateCounter = 0
    
    var jaydenCode: String {
        JaydenCodeGenerator.generateCode(secret: "2VLUORJ372")
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                DisplayView(selectedPosition: $selectedPosition, projectExecuter: projectExecuter)
                if !projectExecuter.consoleIsEmpty {
                    ScrollView {
                        VStack(alignment: .leading) {
                            Text("Output")
                                .font(.headline)
                                .foregroundColor(Color(UIColor.secondaryLabel))
                            projectExecuter.console
                        }
                        .font(.body)
                        .imageScale(.small)
                        .padding()
                    }
                    .background(Color(UIColor.secondarySystemBackground).ignoresSafeArea())
                    .overlay(Divider(), alignment: .leading)
                    .frame(maxWidth: 120)
                    .transition(.move(edge: .trailing))
                    .animation(Animation.default, value: projectExecuter.console)
                }
            }
            if !projectExecuter.isRunning {
                SymbolKeyboard(selectedPosition: $selectedPosition, projectExecuter: projectExecuter)
                    .overlay(Divider(), alignment: .top)
                    .transition(.move(edge: .bottom))
                    .animation(Animation.default, value: projectExecuter.isRunning)
            }
            
        }
        .imageScale(.large)
        .symbolVariant(.fill)
        .font(.system(size: 28, weight: .semibold))
        .toolbar(id: "editor") {
            ToolbarItem(id: "templates", placement: .secondaryAction) {
                Menu {
                    Button {
                        selectedPosition = Position(row: 0, column: 0)
                        projectExecuter.initialCanvas = [:]
                        projectExecuter.canvasSize = ProjectExecuter.defaultSize
                    } label: {
                        Label("Load Empty", systemImage: "rectangle")
                    }
                    Button {
                        selectedPosition = Position(row: 0, column: 0)
                        projectExecuter.initialCanvas = [:]
                        projectExecuter.canvasSize = ProjectExecuter.largeSize
                    } label: {
                        Label("Load Empty (XL)", systemImage: "rectangle")
                    }
                    Button {
                        loadTemplate(name: "Hello World")
                    } label: {
                        Label("Load Hello World", systemImage: "hand.wave")
                    }
                    Button {
                        loadTemplate(name: "Count to 10")
                    } label: {
                        Label("Load Count to 10", systemImage: "textformat.123")
                    }
                } label: {
                    Image(systemName: "square.grid.3x3")
                }
            }
            ToolbarItem(id: "settings", placement: .secondaryAction) {
                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "switch.2")
                }
                .disabled(projectExecuter.isRunning)
            }
            ToolbarItem(id: "help", placement: .secondaryAction) {
                Button {
                    showHelp = true
                    showingSettings = true
                } label: {
                    Image(systemName: "questionmark.circle")
                }
                .disabled(projectExecuter.isRunning)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button("\(speed)x") {
                    switch speed {
                    case 1:
                        speed = 2
                    case 2:
                        speed = 4
                    default:
                        speed = 1
                    }
                }
                .contextMenu {
                    Button("1x Speed", action: { speed = 1 })
                    Button("2x Speed", action: { speed = 2 })
                    Button("4x Speed", action: { speed = 4 })
                    Button("8x Speed", action: { speed = 8 })
                }
                Button(action: {
                    if projectExecuter.isRunning {
                        projectExecuter.stop()
                    } else {
                        projectExecuter.run()
                    }
                }, label: {
                    Image(systemName: projectExecuter.isRunning ? "stop.fill" : "play.fill")
                })
            }
        }
        .toolbarRole(.editor)
        .onReceive(Timer.publish(every: 0.125, on: .main, in: .default).autoconnect(), perform: { _ in
            guard projectExecuter.isRunning else { return }
            updateCounter += 1
            switch speed {
            case 1:
                if 8 <= updateCounter {
                    updateCounter = 0
                }
            case 2:
                if 4 <= updateCounter {
                    updateCounter = 0
                }
            case 4:
                if 2 <= updateCounter {
                    updateCounter = 0
                }
            default:
                updateCounter = 0
            }
            if updateCounter == 0 {
                projectExecuter.step()
            }
        })
        .sheet(isPresented: $showingWelcome, onDismiss: {
            if whatsNewVersion < SFCodeApp.appWhatsNewVersion {
                whatsNewVersion = SFCodeApp.appWhatsNewVersion
            }
        }, content: {
            WelcomeView(isFirstLaunch: whatsNewVersion == 0, appName: "Symbol Code", features: welcomeFeatures)
        })
        .sheet(isPresented: $showingSettings, content: {
            SettingsView(showHelp: showHelp)
        })
        .sheet(isPresented: Binding(get: { !projectExecuter.variablesWaitingForInput.isEmpty }, set: { _ in projectExecuter.variablesWaitingForInput.removeAll() }), content: {
            InputView(projectExecuter: projectExecuter)
        })
        .alert("Secret Code: \(jaydenCode)", isPresented: $projectExecuter.showingJaydenCode) {
            Button("Copy") {
                UIPasteboard.general.string = jaydenCode
            }
            Button("OK", role: .cancel, action: { })
        }
        .onAppear() {
            if whatsNewVersion < SFCodeApp.appWhatsNewVersion {
                showingWelcome = true
            }
        }
    }
    
    func loadTemplate(name: String) {
        let url = Bundle.main.url(forResource: name, withExtension: "json")!
        do {
            selectedPosition = Position(row: 0, column: 0)
            projectExecuter.initialCanvas = try JSONDecoder().decode([Position: Symbol].self, from: Data(contentsOf: url))
            projectExecuter.canvasSize = ProjectExecuter.defaultSize
        } catch { }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(projectExecuter: .init(project: .constant(.init())))
    }
}
