//
//  OptionsAssemblerWrapper.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 24/10/25.
//

import Foundation
internal import Combine

class OptionsAssemblerWrapper: ObservableObject {
	@Published var opts: UnsafeMutablePointer<options_t>? = nil
	
	deinit {
		free_options(self.opts)
		self.opts = nil
	}
	
}
