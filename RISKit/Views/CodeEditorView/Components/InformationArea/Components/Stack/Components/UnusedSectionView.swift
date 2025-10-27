//
//  UnusuedSectionView.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 27/10/25.
//

import SwiftUI

// Vista per aree non usate
struct UnusedSectionView: View {
	var body: some View {
		VStack {
			Image(systemName: "circle.slash")
				.font(.system(size: 40))
				.foregroundColor(.secondary)
			Text("Memoria non utilizzata")
				.foregroundColor(.secondary)
		}
	}
}
