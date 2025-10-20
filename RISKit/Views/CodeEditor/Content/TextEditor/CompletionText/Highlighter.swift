//
//  Highlighter.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 04/09/25.
//

import Foundation
internal import Combine
import Highlightr
import SwiftUI

final class Highlighter: ObservableObject {
    static let shared = Highlighter()

    private let queue = DispatchQueue(label: "highlighter.queue", qos: .userInitiated)
    private let highlightr: Highlightr
    private var cache = [String: AttributedString]()
    private var debounceWork: [String: DispatchWorkItem] = [:]

    private init() {
        highlightr = Highlightr()!
        highlightr.setTheme(to: "atom-one-dark")
    }

    /// Async highlight with simple debounce. Returns on main thread.
    func highlight(_ text: String, language: String = "c", debounceMillis: Int = 50, completion: @escaping (AttributedString) -> Void) {
        if let cached = cache[text] {
            completion(cached)
            return
        }

        // Cancel prior work for same text (if any) and debounce
        debounceWork[text]?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            let ns: NSAttributedString
            if let highlighted = self.highlightr.highlight(text, as: language) {
                ns = highlighted
            } else {
                ns = NSAttributedString(string: text)
            }

            // Convert to AttributedString on background (safe) then deliver on main
            let attrStr: AttributedString
            if #available(macOS 12.0, iOS 15.0, *) {
                attrStr = AttributedString(ns)
            } else {
                attrStr = AttributedString(ns.string)
            }

            self.queue.async { // store cache from our queue
                self.cache[text] = attrStr
                DispatchQueue.main.async {
                    completion(attrStr)
                }
            }
        }

        debounceWork[text] = work
        queue.asyncAfter(deadline: .now() + .milliseconds(debounceMillis), execute: work)
    }

    func clearCache() {
        queue.async { self.cache.removeAll() }
    }
}
