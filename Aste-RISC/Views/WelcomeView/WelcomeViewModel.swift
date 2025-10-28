//
//  WelcomeViewModel.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 14/08/25.
//

internal import Combine
import SwiftUI

class WelcomeViewModel: ObservableObject {
    @Published private(set) var glowColor : Color = .white
               private      var didCompute: Bool  = false
    
    func computeGlowIfNeeded() {
        guard !didCompute else { return }
        didCompute = true
        
        guard let icon = NSApplication.shared.applicationIconImage else { return }
        
        Task(priority: .userInitiated) {
            let nsColor = await computeAverageColor(of: icon)
            self.glowColor = Color(nsColor ?? .white)
        }
    }
}
