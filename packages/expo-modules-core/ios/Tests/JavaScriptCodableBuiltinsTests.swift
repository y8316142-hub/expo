// Copyright 2025-present 650 Industries. All rights reserved.

import Testing
import ExpoModulesJSI

@testable import ExpoModulesCore

enum CodableColor: String, Enumerable {
  case red
  case green
}

enum CodablePriority: Int, Enumerable {
  case low = 1
  case high = 2
}

@Suite("JavaScriptCodable+Builtins")
@JavaScriptActor
struct JavaScriptCodableBuiltinsTests {
  let appContext = AppContext.create()

  var runtime: ExpoRuntime {
    get throws {
      try appContext.runtime
    }
  }

  // MARK: - JavaScriptValue passthrough

  @Test
  func `passes a JavaScriptValue through`() throws {
    let runtime = try runtime
    let value = try runtime.eval("123")
    let decoded = try JavaScriptValue.decode(value, appContext: appContext, runtime: runtime)
    #expect(decoded.getInt() == 123)
    let encoded = try JavaScriptValue.encode(decoded, appContext: appContext, runtime: runtime)
    #expect(encoded.getInt() == 123)
  }

  // MARK: - String-backed enum

  @Test
  func `decodes and encodes a string enum`() throws {
    let runtime = try runtime
    let decoded = try CodableColor.decode(runtime.eval("'green'"), appContext: appContext, runtime: runtime)
    #expect(decoded == .green)
    let encoded = try CodableColor.encode(.red, appContext: appContext, runtime: runtime)
    #expect(encoded.getString() == "red")
  }

  // MARK: - Int-backed enum

  @Test
  func `decodes and encodes an int enum`() throws {
    let runtime = try runtime
    let decoded = try CodablePriority.decode(runtime.eval("2"), appContext: appContext, runtime: runtime)
    #expect(decoded == .high)
    let encoded = try CodablePriority.encode(.low, appContext: appContext, runtime: runtime)
    #expect(encoded.getInt() == 1)
  }

  // MARK: - Data <-> Uint8Array

  @Test
  func `decodes Data from a Uint8Array`() throws {
    let runtime = try runtime
    let value = try runtime.eval("new Uint8Array([0, 255, 16])")
    let decoded = try Data.decode(value, appContext: appContext, runtime: runtime)
    #expect(Array(decoded) == [0, 255, 16])
  }

  @Test
  func `encodes Data to a Uint8Array`() throws {
    let runtime = try runtime
    let encoded = try Data.encode(Data([1, 2, 3]), appContext: appContext, runtime: runtime)
    #expect(encoded.isTypedArray() == true)
    let roundTripped = try Data.decode(encoded, appContext: appContext, runtime: runtime)
    #expect(Array(roundTripped) == [1, 2, 3])
  }
}
