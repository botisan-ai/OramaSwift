import Foundation
import JavaScriptCore
import WasmInterpreter

struct BreakIteratorResult {
    var start: Int32
    var end: Int32
    var type: Int32
}

@objc protocol BreakIteratorJSExport: JSExport {
    func utf8BreakIterator(breakType: Int, locale: String, textToBreak: String) -> [[AnyHashable: Any]]
    static func create() -> BreakIterator
}

class BreakIterator: NSObject, BreakIteratorJSExport {
    private var vm: WasmInterpreter?

    private func initialize() throws {
        let URL = Bundle.module.url(forResource: "break_iterator_cja", withExtension: "wasm", subdirectory: "Wasm")!
        let bytesData = try Data(contentsOf: URL)
        let bytes = [UInt8](bytesData)
        vm = try WasmInterpreter(module: bytes)
    }

    public func utf8BreakIterator(breakType: Int, locale: String, textToBreak: String) -> [[AnyHashable: Any]] {
        let callbackId = Int32(1)
        var resultsCache: [BreakIteratorResult] = []

        let push: (Int32, Int32, Int32, Int32) -> Void = { start, end, type, callbackId in
            resultsCache.append(BreakIteratorResult(start: start, end: end, type: type))
        }

        try! vm?.addImportHandler(named: "push", namespace: "env", block: push)

        // write string into memory with malloc
        let textByteLength = Int32(textToBreak.utf8.count)
        let textPtr: Int32 = try! vm!.call("malloc", Int32(textByteLength + 1)) as Int32
        try! vm?.writeToHeap(string: textToBreak, byteOffset: Int(textPtr))

        let localeByteLength = Int32(locale.utf8.count)
        let localePtr: Int32 = try! vm!.call("malloc", Int32(localeByteLength + 1)) as Int32
        try! vm?.writeToHeap(string: locale, byteOffset: Int(localePtr))

        // call function
        try! vm?.call("utf8_break_iterator", Int32(breakType), localePtr, textPtr, textByteLength, callbackId)

        // free memory
        try! vm?.call("free", localePtr)
        try! vm?.call("free", textPtr)

        return resultsCache.map {
            [
                "start": $0.start,
                "end": $0.end,
                "type": $0.type,
            ]
        }
    }

    class func create() -> BreakIterator {
        let instance = BreakIterator()
        try? instance.initialize()
        return instance
    }
}
