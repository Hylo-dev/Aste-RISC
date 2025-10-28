//
//  LSPClient.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 21/08/25.
//

import Foundation

// Simple Language Server Protocol (LSP) client for communicating with clangd over stdio.
// Responsibilities:
// - Launch clangd as a subprocess
// - Encode/decode JSON-RPC 2.0 messages with proper LSP headers (Content-Length)
// - Send requests and notifications (initialize, didOpen, didChange, completion, etc.)
// - Read and parse responses/notifications (including diagnostics)
// - Dispatch completion results and initialization callback
final class LSPClient {
    // Subprocess and IO handles
    private var process: Process?
    private var stdinHandle: FileHandle?
    private var stdoutHandle: FileHandle?

    // Queues to keep reads/writes off the main thread
    private var readQueue = DispatchQueue(label: "lsp.read", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem, target: nil)
    private var writeQueue = DispatchQueue(label: "lsp.write", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem, target: nil)

    // JSON-RPC bookkeeping
    private var nextId: Int = 1
    private let jsonEncoder = JSONEncoder()
    private var responseHandlers: [Int: (Data?) -> Void] = [:]

    // Incoming message framing buffer
    private var readBuffer = Data()
    private var expectedContentLength: Int?
    
    // Called on main thread after successful initialize/initialized handshake
    var onInitialized: (() -> Void)?

    // JSON-RPC request wrapper
    private struct JSONRPCRequest<T: Encodable>: Encodable {
        let jsonrpc: String = "2.0"
        let id: Int
        let method: String
        let params: T?
    }

    // JSON-RPC notification wrapper
    private struct JSONRPCNotification<T: Encodable>: Encodable {
        let jsonrpc: String = "2.0"
        let method: String
        let params: T?
    }

    private struct EmptyParams: Encodable {}

    // Starts clangd and begins the LSP initialize sequence
    // - clangdPath: path to clangd binary
    // - projectRoot: used to point clangd to compile_commands.json directory (build)
    func start(clangdPath: String = "/usr/bin/clangd", projectRoot: URL) throws {
        stop() // ensure clean state
        let fileManager = FileManager.default

        guard fileManager.fileExists(atPath: clangdPath) else {
            print("Error: clangd not found at \(clangdPath)")
            return
        }

        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: clangdPath)
        proc.arguments = [
            // "--log=verbose",
            "--compile-commands-dir=\(projectRoot.appendingPathComponent("build").path)"
        ]
        // Prefer responsive scheduling for editor-like interactions
        proc.qualityOfService = .userInitiated

        // Pipes for stdio
        let inPipe = Pipe()
        let outPipe = Pipe()
        let errorPipe = Pipe()

        proc.standardInput = inPipe
        proc.standardOutput = outPipe
        proc.standardError = errorPipe

        // Helper to log clangd stdout/stderr line-by-line
        func attachReader(_ handle: FileHandle, prefix: String) {
            var buffer = ""
            
            handle.readabilityHandler = { fh in
                let data = fh.availableData
                
                if data.count == 0 {
                    // EOF
                    fh.readabilityHandler = nil
                    return
                }
                
                if let chunk = String(data: data, encoding: .utf8) {
                    buffer += chunk
                    let lines = buffer.components(separatedBy: "\n")

                    buffer = lines.last ?? ""
                    for i in 0..<(lines.count - 1) {
                        let line = lines[i].trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        if !line.isEmpty {
                            print("\(prefix) \(line)")
                        }
                    }
                } else {
                    print("\(prefix) <non-utf8 data: \(data.count) bytes>")
                }
            }
        }

        // Log clangd output for debugging
        attachReader(outPipe.fileHandleForReading, prefix: "clangd out:")
        attachReader(errorPipe.fileHandleForReading, prefix: "clangd err:")

        try proc.run()

        // Keep references
        self.process = proc
        self.stdinHandle = inPipe.fileHandleForWriting
        self.stdoutHandle = outPipe.fileHandleForReading

        // Start reading LSP messages and kick off initialization
        startReadingLoop()
        initialize()
    }

    // Stops the LSP client and terminates the server process
    func stop() {
        stdinHandle?.closeFile()
        stdoutHandle?.closeFile()
        process?.terminate()
        process = nil
        stdinHandle = nil
        stdoutHandle = nil
    }

    // Encodes and writes a JSON-RPC object with LSP headers on the write queue
    private func send<T: Encodable>(_ obj: T) {
        writeQueue.async {
            guard let handle = self.stdinHandle else { return }
            
            do {
                let data = try self.jsonEncoder.encode(obj)
                let header = "Content-Length: \(data.count)\r\n\r\n"
                let headerData = header.data(using: .utf8)!
                handle.write(headerData)
                handle.write(data)
            } catch {
                print("LSP encode error: \(error)")
            }
        }
    }

    // Sends a JSON-RPC request, stores a completion handler keyed by id
    private func sendRequest<T: Encodable>(_ method: String, params: T?, completion: ((Data?) -> Void)? = nil) {
        let id = nextId
        nextId += 1
        if let completion = completion { responseHandlers[id] = completion }
        
        let req = JSONRPCRequest(id: id, method: method, params: params)
        send(req)
    }

    // Sends a JSON-RPC notification (no response expected)
    private func sendNotification<T: Encodable>(_ method: String, params: T?) {
        let note = JSONRPCNotification(method: method, params: params)
        send(note)
    }

    // Minimal initialize params used for clangd
    private struct InitializeParams: Encodable {
        let processId: Int?
        let rootUri: String?
    }

    // Sends initialize, waits for response, then sends initialized and notifies client code
    private func initialize() {
        let params = InitializeParams(processId: Int(ProcessInfo.processInfo.processIdentifier), rootUri: nil)
        
        sendRequest("initialize", params: params) { [weak self] _ in
            guard let self = self else { return }
            // LSP requires a follow-up "initialized" notification after successful initialize
            self.sendNotification("initialized", params: EmptyParams())
            
            // Inform UI / client on main thread
            DispatchQueue.main.async {
                self.onInitialized?()
            }
        }
    }

    // MARK: - Text document lifecycle (open/change)

    // LSP TextDocumentItem used for didOpen
    private struct TextDocumentItem: Codable {
        let uri: String
        let languageId: String
        let version: Int
        let text: String
    }
    
    private struct DidOpenTextDocumentParams: Codable {
        let textDocument: TextDocumentItem
    }
    
    // Notifies server that a document is opened with initial content
    func openDocument(uri: String, languageId: String, text: String) {
        let item = TextDocumentItem(uri: uri, languageId: languageId, version: 1, text: text)
        let params = DidOpenTextDocumentParams(textDocument: item)
        sendNotification("textDocument/didOpen", params: params)
    }

    // LSP change params for full-text change (simplified)
    private struct VersionedTextDocumentIdentifier: Codable {
        let uri: String
        let version: Int
    }
    
    private struct TextDocumentContentChangeEvent: Codable {
        let text: String
    }
    
    private struct DidChangeTextDocumentParams: Codable {
        let textDocument: VersionedTextDocumentIdentifier
        let contentChanges: [TextDocumentContentChangeEvent]
    }

    // Notifies server that a document content changed (sends full text)
    func changeDocument(uri: String, text: String, version: Int = 1) {
        let textDocument = VersionedTextDocumentIdentifier(uri: uri, version: version)
        let change = TextDocumentContentChangeEvent(text: text)
        let params = DidChangeTextDocumentParams(textDocument: textDocument, contentChanges: [change])
        sendNotification("textDocument/didChange", params: params)
    }

    // MARK: - Completion requests

    private struct TextDocumentIdentifier: Codable {
        let uri: String
    }
    
    private struct Position: Codable {
        let line: Int
        let character: Int
    }
    
    private struct CompletionParams: Codable {
        let textDocument: TextDocumentIdentifier
        let position: Position
    }
    
    // Requests completions at a given document position.
    // Calls completion with an array of LSPCompletionItem (empty on failure).
    func requestCompletions(uri: String, line: Int, character: Int, completion: (([LSPCompletionItem]) -> Void)? = nil) {
        // Local params model to match server expectations
        struct Params: Codable {
            struct TextDocument: Codable { let uri: String }
            struct Position: Codable { let line: Int; let character: Int }
            let textDocument: TextDocument
            let position: Position
        }

        let params = Params(textDocument: .init(uri: uri), position: .init(line: line, character: character))

        sendRequest("textDocument/completion", params: params) { data in
            guard let data = data else {
                DispatchQueue.main.async { completion?([]) }
                return
            }

            do {
                // Completion can be either array or { items: [...] } (CompletionList)
                let root = try JSONSerialization.jsonObject(with: data, options: [])
                var itemsJSON: Any?

                if let dict = root as? [String: Any] {
                    if let result = dict["result"] {
                        itemsJSON = result
                    } else if let arr = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                        itemsJSON = arr
                    }
                } else if let arr = root as? [[String: Any]] {
                    itemsJSON = arr
                }

                guard let itemsNode = itemsJSON else {
                    DispatchQueue.main.async { completion?([]) }
                    return
                }

                // Decode as either array or CompletionList
                let itemsData = try JSONSerialization.data(withJSONObject: itemsNode, options: [])
                let decoder = JSONDecoder()
                
                if let items = try? decoder.decode([LSPCompletionItem].self, from: itemsData) {
                    DispatchQueue.main.async { completion?(items) }
                    return
                }
                
                struct CompletionList: Codable { let items: [LSPCompletionItem] }
                if let list = try? decoder.decode(CompletionList.self, from: itemsData) {
                    DispatchQueue.main.async { completion?(list.items) }
                    return
                }

                DispatchQueue.main.async { completion?([]) }
            } catch {
                DispatchQueue.main.async { completion?([]) }
            }
        }
    }

    // MARK: - Reading and parsing LSP messages

    // Sets up readability handler to receive server output and feed the parser
    private func startReadingLoop() {
        guard let handle = stdoutHandle else { return }
        
        readQueue.async { [weak self] in
            guard let self = self else { return }
            
            handle.readabilityHandler = { [weak self] handle in
                guard let self = self else { return }
                let data = handle.availableData
                if data.isEmpty { return }
                
                self.processIncomingData(data)
            }
        }
    }

    // Accumulates data and extracts message bodies based on Content-Length headers
    private func processIncomingData(_ data: Data) {
        readBuffer.append(data)

        while true {
            // Parse header when we don't yet know the content length
            if expectedContentLength == nil {
                if let headerEndRange = readBuffer.range(of: Data("\r\n\r\n".utf8)) {
                    let headerData = readBuffer.subdata(in: 0..<headerEndRange.lowerBound)
                    
                    if let headerString = String(data: headerData, encoding: .utf8) {
                        let lines = headerString.split(separator: "\r\n")
                        
                        if let clLine = lines.first(where: { $0.lowercased().hasPrefix("content-length:") }) {
                            let parts = clLine.split(separator: ":")
                            
                            if parts.count >= 2, let contentLength = Int(parts[1].trimmingCharacters(in: .whitespaces)) {
                                expectedContentLength = contentLength
                                readBuffer.removeSubrange(0..<headerEndRange.upperBound)
                            } else {
                                // Malformed header; reset buffer
                                readBuffer.removeAll()
                                break
                            }
                        } else {
                            // Missing Content-Length; reset buffer
                            readBuffer.removeAll()
                            break
                        }
                    } else {
                        // Non-UTF8 header; reset buffer
                        readBuffer.removeAll()
                        break
                    }
                } else {
                    // Not enough data to read full header yet
                    break
                }
            }

            // If we know the body length and have enough data, extract it
            if let contentLength = expectedContentLength, readBuffer.count >= contentLength {
                let messageBody = readBuffer.prefix(contentLength)
                
                readBuffer.removeSubrange(0..<contentLength)
                expectedContentLength = nil
                
                handleMessageBody(Data(messageBody))
            } else {
                // Wait for more data
                break
            }
        }
    }

    // Dispatches responses to waiting handlers or posts notifications for server pushes
    private func handleMessageBody(_ body: Data) {
        do {
            let obj = try JSONSerialization.jsonObject(with: body, options: []) as? [String: Any]
            if let obj = obj {
                // Response: match by id and call completion
                if let id = obj["id"] as? Int, let handler = responseHandlers[id] {
                    handler(body)
                    responseHandlers.removeValue(forKey: id)
                  
                  // Notification: handle known methods (diagnostics)
                } else if let method = obj["method"] as? String {
                    if method == "textDocument/publishDiagnostics" {
                        
                        // Forward diagnostics to interested listeners
                        NotificationCenter.default.post(name: .lspDiagnosticsReceived, object: obj)
                    }
                }
            }
        } catch {
            print("LSP parse error: \(error)")
        }
    }
}
