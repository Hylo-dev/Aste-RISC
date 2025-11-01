//
//  CodeEditorView.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 25/10/25.
//

import Foundation
import CodeEditTextView
@preconcurrency import CodeEditSourceEditor
import CodeEditLanguages
import SwiftUI

struct CodeSourceEditorView: View {
	@Environment(\.colorScheme) var colorScheme
	@EnvironmentObject private var bodyEditorViewModel: BodyEditorViewModel

	@Binding var document: CodeEditSourceEditorDocument
	
	@State private var language: CodeLanguage = .default
	@State private var theme   : EditorTheme = .dark
	
	@State private var editorState = SourceEditorState(
		cursorPositions: [
			CursorPosition(line: 9, column: 6),
			CursorPosition(line: 10, column: 6)
		],
	)
	@StateObject private var suggestions     : MockCompletionDelegate       = MockCompletionDelegate()
	@StateObject private var jumpToDefinition: MockJumpToDefinitionDelegate = MockJumpToDefinitionDelegate()

	@State private var font: NSFont = NSFont.monospacedSystemFont(ofSize: 12, weight: .medium)
	
	@AppStorage("wrapLines")    private var wrapLines      : Bool = true
	@AppStorage("systemCursor") private var useSystemCursor: Bool = false

	@State private var indentOption: IndentOption = .spaces(count: 4)
	
	@AppStorage("reformatAtColumn") private var reformatAtColumn: Int = 80

	@AppStorage("showGutter") private var showGutter: Bool = true
	@AppStorage("showMinimap") private var showMinimap: Bool = true
	@AppStorage("showReformattingGuide") private var showReformattingGuide: Bool = false
	@AppStorage("showFoldingRibbon") private var showFoldingRibbon: Bool = true
	
	@State private var invisibleCharactersConfig: InvisibleCharactersConfiguration = .empty
	@State private var warningCharacters: Set<UInt16> = []

	@State private var isInLongParse = false
	@State private var settingsIsPresented: Bool = false
	
	private func contentInsets(proxy: GeometryProxy) -> NSEdgeInsets {
		NSEdgeInsets(top: 25, left: showGutter ? 0 : 1, bottom: 28.0, right: 0)
	}
	
	static private let highlightRiscV = [
		RISCVCommentHighlightProvider(),
		RISCVNumberHighlightProvider(),
		RISCVTokenHighlightProvider(),
		RISCVLabelHighlightProvider(),
		RISCVKeywordHighlightProvider()
	]

	init(document: Binding<CodeEditSourceEditorDocument>) {
		self._document = document
	}

	var body: some View {
		GeometryReader { proxy in
			SourceEditor(
				document.text,
				language: language,
				configuration: SourceEditorConfiguration(
					appearance: .init(theme: theme, font: font, wrapLines: wrapLines),
					behavior: .init(
						isEditable: self.bodyEditorViewModel.editorState != .running,
						indentOption: indentOption,
						reformatAtColumn: reformatAtColumn
					),
					layout: .init(contentInsets: contentInsets(proxy: proxy)),
					peripherals: .init(
						showGutter: showGutter,
						showMinimap: showMinimap,
						showReformattingGuide: showReformattingGuide,
						invisibleCharactersConfiguration: invisibleCharactersConfig,
						warningCharacters: warningCharacters
					)
				),
				state: $editorState,
				highlightProviders: Self.highlightRiscV,
				completionDelegate: suggestions,
				jumpToDefinitionDelegate: jumpToDefinition
				
			)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.clipShape(RoundedRectangle(cornerRadius: 26))
			.onReceive(NotificationCenter.default.publisher(for: TreeSitterClient.Constants.longParse)) { _ in
				withAnimation(.easeIn(duration: 0.1)) {
					isInLongParse = true
				}
			}
			.onReceive(NotificationCenter.default.publisher(for: TreeSitterClient.Constants.longParseFinished)) { _ in
				withAnimation(.easeIn(duration: 0.1)) {
					isInLongParse = false
				}
			}
		}
	}
}
