# InitMacro

Read my article on Macros in [TradeRepublic](https://github.com/traderepublic)'s engineering blog: [Get Ready for Swift Macros](https://engineering.traderepublic.com/get-ready-for-swift-macros-fe21d3867e02)

This repo showcases a Swift Macro implementation that generates initializers for classes and structs. It's intended as a playground to explore this fantastic new feature in Swift.

I'm not an expert, so this implementation might not cover all possible cases. If you come across an unsupported case, please create an issue to let us know.

Contributions are highly encouraged and warmly welcomed. Feel free to contribute!

## Parameters

### `defaults: [String: Any]`

Set this if there are properties that will have an initial value.

### `wildcards: [String]`

Set this if there are properties that will have an underscore before their name. 

### `public: Bool`

In case the initializer needs to be internal, set this to `false`.

Originally, this macro was built with public initializers in mind, since internal generators can be implicit in certain cases. 

## Signature

```swift
@Init(
	defaults: [String: Any], // default [:]
	wildcards: [String], // default []
	public: Bool // default true
)
```

## Usage

https://github.com/LeonardoCardoso/InitMacro/assets/1775157/db17cc39-a8cf-4340-9876-04d0c09e8ebe

## Testing

Open the example app and use your creativity.

## Known Issues

1. It doesn't support adding a default closure
2. The compiler can complain about `Undefined symbol: ___llvm_profile_runtime`. This is a bug in the current betas:
	- It can be bypassed for now by adding `linkerSettings: [.unsafeFlags(["-fprofile-instr-generate"])]` to your macro target.

## Installation

```swift
import PackageDescription

let package = Package(
  name: "Your Target Name",
  dependencies: [
  	// ...
    .package(url: "https://github.com/LeonardoCardoso/InitMacro.git", branch: "main")
  	// ...
  ]
)
```

## License

```
The MIT License (MIT)

Copyright (c) 2023 Leonardo Cardoso

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
