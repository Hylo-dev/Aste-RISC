//
//  WelcomeView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 14/08/25.
//

import SwiftUI

/// List contains most all important ide features
private let ideFeatures: [FeatureItem] = [
    FeatureItem(
        id: 0,
        title: "Assembler",
        description: "For the asm program compilation",
        icon: "terminal",
        colorBgIcon: .accentColor
        
    ),
    
    FeatureItem(
        id: 1,
        title: "RISC-V Emulator",
        description: "Execute RISC-V machine code",
        icon: "desktopcomputer",
        colorBgIcon: .green
        
    ),
    
    FeatureItem(
        id: 2,
        title: "Grapdical data",
        description: "Graphical view of the stack and registers",
        icon: "play.desktopcomputer",
        colorBgIcon: .purple
        
    )
]

struct WelcomeView: View {
    
    /// Contains the prinripal state's app
    @EnvironmentObject private var appState: AppState
    
    /// ViewModel manage WelcomeView logic
    @StateObject private var welcomeViewModel = WelcomeViewModel()
            
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            informationIdeColumn
            
            Divider()
                .padding(.trailing, 15)
            
            featuresIdeColumn
            
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            welcomeViewModel.computeGlowIfNeeded()
        }
    }
    
    // MARK: - Left Column, contains description IDE
    private var informationIdeColumn: some View {
        
        // Body column
        VStack(alignment: .leading, spacing: 20) {
            
            // Header column, contains logo app and title
            HStack(alignment: .top, spacing: 10) {
                
                // Logo app
                Image(nsImage: NSApplication.shared.applicationIconImage!)
                    .resizable()
                    .frame(width: 80, height: 80)
                    .shadow(color: welcomeViewModel.glowColor.opacity(0.6), radius: 10, x: 0, y: 0)
                
                // Welcome and title
                VStack(alignment: .leading, spacing: 6) {
                    
                    Text("Welcome to RISKit")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                    
                    Text("Open Source Native MacOS RISC-V Assembly IDE")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                }
                .padding(.top, 13)
            }
            
            // Description IDE
            VStack(alignment: .leading, spacing: 20) {
                
                Text("This is your new professional development environment for RISC-V Assembly.\nA modern IDE designed specifically for macOS.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    Text("Main Features:")
                        .font(.headline).bold()
                    
                    VStack(alignment: .leading, spacing: 7) {
                        Text("\t• Advanced code editor with syntax highlighting")
                        Text("\t• Integrated assembly project management")
                        Text("\t• Native macOS interface with Liquid Glass design")
                        Text("\t• Compilation and direct execution from the IDE")
                    }
                    .foregroundStyle(.secondary)
                    
                }
            }
            .padding(.leading, 10)
        }
        .frame(minWidth: 300, maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    // MARK: - Right Column, contains features IDE
    
    private var featuresIdeColumn: some View {
        
        // Body column
        VStack(alignment: .leading, spacing: 25) {
            
            // Header
            HStack(spacing: 5) {
                Image(systemName: "gearshape")
                    .foregroundStyle(.placeholder)
                    .font(.title2)
                
                Text("System requirements")
                    .font(.title2)
            }
            
            // All features list
            VStack(spacing: 15) {
                
                ForEach(ideFeatures, id: \.id) { singleFeature in
                    FeatureRow(feature: singleFeature)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                }
                
            }
            .padding()
            .background(backgroundView)
            
            // Note IDE
            VStack(alignment: .leading) {
                
                Text("Note:").bold()
                
                Text("If you haven't installed these tools, you can do so via Homebrew or Xcode Command Line Tools.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.background)
            .overlay(RoundedRectangle(cornerRadius: 24)
            .stroke(.placeholder.opacity(0.18), lineWidth: 1))
            
            Spacer()
            
            // Set right bottom to next conficure screen
            HStack {
                Spacer()
                
                Button("Understand") {
                    let _ = SettingsManager() // Init settings
                    appState.navigationState.setPrincipalNavigation(principalNavigation: .home)
                    
                }
                .buttonStyle(.glassProminent)
                
            }
            .frame(maxWidth: .infinity)
        }
        .frame(minWidth: 300, idealWidth: 300, maxWidth: 350, maxHeight: .infinity, alignment: .topLeading)
    }
    
    // Background column
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 26)
            .fill(.ultraThinMaterial)
            .shadow(color: .black.opacity(0.18), radius: 18, x: 0, y: 4)
    }
}
