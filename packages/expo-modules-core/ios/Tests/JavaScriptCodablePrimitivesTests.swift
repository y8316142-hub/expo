// Copyright 2025-present 650 Industries. All rights reserved.

import Testing
import ExpoModulesJSI

@testable import ExpoModulesCore

@Suite("JavaScriptCodable+Primitives")
@JavaScriptActor
struct JavaScriptCodablePrimitivesTests {
  let appContext = AppContext.create()

  var runtime: ExpoRuntime {
    get throws {
      try appContext.runtime
    }
  }

  // MARK: - Double

  @Test
  func `decodes a double from a JS number`() throws {
    let runtime = try runtime
    let value = try runtime.eval("3.5")
    let decoded = try Double.decode(value, appContext: appContext, runtime: runtime)
    #expect(decoded == 3.5)
  }

  @Test
  func `encodes a double to a JS number`() throws {
    let runtime = try runtime
    let encoded = try Double.encode(2.5, appContext: appContext, runtime: runtime)
    #expect(encoded.getDouble() == 2.5)
  }

  @Test
  func `round-trips a double`() throws {
    let runtime = try runtime
    let value = try runtime.eval("42.25")
    let decoded = try Double.decode(value, appContext: appContext, runtime: runtime)
    let reencoded = try Double.encode(decoded, appContext: appContext, runtime: runtime)
    #expect(reencoded.getDouble() == 42.25)
  }

  // MARK: - Int

  @Test
  func `decodes and encodes an int`() throws {
    let runtime = try runtime
    let decoded = try Int.decode(runtime.eval("42"), appContext: appContext, runtime: runtime)
    #expect(decoded == 42)
    let encoded = try Int.encode(-7, appContext: appContext, runtime: runtime)
    #expect(encoded.getInt() == -7)
  }

  // MARK: - Integer family (representative widths)

  @Test
  func `decodes and encodes narrow and unsigned integers`() throws {
    let runtime = try runtime
    #expect(try Int8.decode(runtime.eval("127"), appContext: appContext, runtime: runtime) == 127)
    #expect(try UInt8.decode(runtime.eval("255"), appContext: appContext, runtime: runtime) == 255)
    #expect(try Int64.decode(runtime.eval("1024"), appContext: appContext, runtime: runtime) == 1024)
    #expect(try UInt32.encode(300, appContext: appContext, runtime: runtime).getInt() == 300)
  }

  // MARK: - Float / CGFloat

  @Test
  func `decodes and encodes float and cgfloat`() throws {
    let runtime = try runtime
    #expect(try Float.decode(runtime.eval("1.5"), appContext: appContext, runtime: runtime) == 1.5)
    #expect(try CGFloat.encode(2.5, appContext: appContext, runtime: runtime).getDouble() == 2.5)
  }

  // MARK: - Bool

  @Test
  func `decodes and encodes a bool`() throws {
    let runtime = try runtime
    #expect(try Bool.decode(runtime.eval("true"), appContext: appContext, runtime: runtime) == true)
    #expect(try Bool.encode(false, appContext: appContext, runtime: runtime).getBool() == false)
  }

  // MARK: - String

  @Test
  func `decodes and encodes a string`() throws {
    let runtime = try runtime
    #expect(try String.decode(runtime.eval("'expo'"), appContext: appContext, runtime: runtime) == "expo")
    #expect(try String.encode("modules", appContext: appContext, runtime: runtime).getString() == "modules")
  }
}

@Suite("JavaScriptCodable+Containers")
@JavaScriptActor
struct JavaScriptCodableContainersTests {
  let appContext = AppContext.create()

  var runtime: ExpoRuntime {
    get throws {
      try appContext.runtime
    }
  }

  // MARK: - Array

  @Test
  func `decodes an array of ints`() throws {
    let runtime = try runtime
    let decoded = try [Int].decode(runtime.eval("[1, 2, 3]"), appContext: appContext, runtime: runtime)
    #expect(decoded == [1, 2, 3])
  }

  @Test
  func `encodes an array of strings`() throws {
    let runtime = try runtime
    let encoded = try [String].encode(["a", "b"], appContext: appContext, runtime: runtime)
    let array = encoded.getArray()
    #expect(array.length == 2)
    #expect(try array.getValue(at: 0).getString() == "a")
    #expect(try array.getValue(at: 1).getString() == "b")
  }

  @Test
  func `round-trips a nested array`() throws {
    let runtime = try runtime
    let decoded = try [[Double]].decode(runtime.eval("[[1.5], [2.5, 3.5]]"), appContext: appContext, runtime: runtime)
    #expect(decoded == [[1.5], [2.5, 3.5]])
  }

  // MARK: - Optional

  @Test
  func `decodes a present and absent optional`() throws {
    let runtime = try runtime
    #expect(try Int?.decode(runtime.eval("42"), appContext: appContext, runtime: runtime) == 42)
    #expect(try Int?.decode(runtime.eval("null"), appContext: appContext, runtime: runtime) == nil)
    #expect(try Int?.decode(runtime.eval("undefined"), appContext: appContext, runtime: runtime) == nil)
  }

  @Test
  func `encodes a present optional and nil as null`() throws {
    let runtime = try runtime
    #expect(try Int?.encode(7, appContext: appContext, runtime: runtime).getInt() == 7)
    #expect(try Int?.encode(nil, appContext: appContext, runtime: runtime).isNull() == true)
  }

  @Test
  func `decodes an array of optionals`() throws {
    let runtime = try runtime
    let decoded = try [Int?].decode(runtime.eval("[1, null, 3]"), appContext: appContext, runtime: runtime)
    #expect(decoded == [1, nil, 3])
  }

  // MARK: - Dictionary

  @Test
  func `decodes a string-keyed dictionary`() throws {
    let runtime = try runtime
    let decoded = try [String: Int].decode(runtime.eval("({ a: 1, b: 2 })"), appContext: appContext, runtime: runtime)
    #expect(decoded == ["a": 1, "b": 2])
  }

  @Test
  func `encodes a string-keyed dictionary`() throws {
    let runtime = try runtime
    let encoded = try [String: Int].encode(["x": 9], appContext: appContext, runtime: runtime)
    #expect(encoded.getObject().getProperty("x").getInt() == 9)
  }
}
