# OramaSwift

Swift Binding for [Orama](https://github.com/oramasearch/orama), a lightweight full-text and vector search engine.

## Features

- Create indexes
- Insert, update, and delete documents
- Search documents
- Serialize and deserialize indexes to/from JSON
- Custom multi-lingual tokenizer based on `Intl.Segmenter` (backed by ICU via WASM)

## Motivation

Currently in the age of AI, there isn't a full-fledged embedded search engine that supports both full-text and vector search. The next best thing we could find is Orama, which runs on JavaScript runtimes. The idea is to try to run Orama in Swift using JavaScriptCore.

Another addition in this library is custom tokenizer support. Orama makes use `Intl.Segmenter` to support Chinese and Japanese tokenization. Unfortunately, JavaScriptCore in Swift does not support `Intl.Segmenter`, which can be very helpful for setting up a multi-lingual tokenizer. There is a [polyfill](https://github.com/surferseo/intl-segmenter-polyfill) that provides full support via ICU4C and WebAssembly. Even though JavaScriptCore in Swift does not support WASM either, so [a WASM Interpreter in Swift](https://github.com/shareup/wasm-interpreter-apple) is used to fill in the gap.

Currently the package includes a custom tokenizer that tries to support multiple languages at once using the `Intl.Segmenter` polyfill.

## License

[MIT](./LICENSE)
