// Copyright 2025-present 650 Industries. All rights reserved.

import CoreGraphics
import ExpoModulesJSI

// `JavaScriptCodable` conformances for leaf primitive types — `Bool`, `String`, and the integer
// and floating-point families. Each reads a JavaScript value directly via the corresponding
// accessor with no recursion and no element conversion.
//
// `Data` is intentionally not here: it maps to a JS `Uint8Array`, not a scalar, and belongs with
// the typed-array conversions rather than these scalar primitives.
//
// Each conformance overrides the zero-copy `JavaScriptUnownedValue` decode overload so an
// argument is read straight from the borrowed value, never materializing a `JavaScriptValue`.

// MARK: - Bool

extension Bool: JavaScriptCodable {
  @JavaScriptActor
  @inlinable
  public static func decode(_ value: JavaScriptValue, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> Bool {
    return try value.asBool()
  }

  @JavaScriptActor
  @inlinable
  public static func decode(_ value: borrowing JavaScriptUnownedValue, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> Bool {
    return try value.asBool()
  }

  @JavaScriptActor
  @inlinable
  public static func encode(_ value: Bool, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> JavaScriptValue {
    return value ? .true() : .false()
  }
}

// MARK: - String

extension String: JavaScriptCodable {
  @JavaScriptActor
  @inlinable
  public static func decode(_ value: JavaScriptValue, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> String {
    return try value.asString()
  }

  @JavaScriptActor
  @inlinable
  public static func decode(_ value: borrowing JavaScriptUnownedValue, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> String {
    return try value.asString()
  }

  @JavaScriptActor
  @inlinable
  public static func encode(_ value: String, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> JavaScriptValue {
    // The `JavaScriptValue(_:_:)` initializer takes the runtime by owned convention (it stores it),
    // so an owned copy is needed from the borrowed parameter.
    return JavaScriptValue(copy runtime, value)
  }
}

// MARK: - Floating-point types

// Both overloads use the throwing `as*` accessors, never the non-throwing `get*`. Even though the
// Swift signature names a concrete type, the JavaScript caller is untyped and may pass anything, so
// the value's actual JS type is unknown until checked. `as*` turns a type mismatch into a thrown
// `TypeError`; `get*` only asserts (compiled out in release), so on a wrong-typed value it would be
// undefined behavior — a native crash, not a catchable error.

extension Double: JavaScriptCodable {
  @JavaScriptActor
  @inlinable
  public static func decode(_ value: JavaScriptValue, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> Double {
    return try value.asDouble()
  }

  @JavaScriptActor
  @inlinable
  public static func decode(_ value: borrowing JavaScriptUnownedValue, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> Double {
    return try value.asDouble()
  }

  @JavaScriptActor
  @inlinable
  public static func encode(_ value: Double, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> JavaScriptValue {
    return .number(value)
  }
}

extension Float: JavaScriptCodable {
  @JavaScriptActor
  @inlinable
  public static func decode(_ value: JavaScriptValue, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> Float {
    return try Float(value.asDouble())
  }

  @JavaScriptActor
  @inlinable
  public static func decode(_ value: borrowing JavaScriptUnownedValue, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> Float {
    return try Float(value.asDouble())
  }

  @JavaScriptActor
  @inlinable
  public static func encode(_ value: Float, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> JavaScriptValue {
    return .number(Double(value))
  }
}

extension CGFloat: JavaScriptCodable {
  @JavaScriptActor
  @inlinable
  public static func decode(_ value: JavaScriptValue, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> CGFloat {
    return try CGFloat(value.asDouble())
  }

  @JavaScriptActor
  @inlinable
  public static func decode(_ value: borrowing JavaScriptUnownedValue, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> CGFloat {
    return try CGFloat(value.asDouble())
  }

  @JavaScriptActor
  @inlinable
  public static func encode(_ value: CGFloat, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> JavaScriptValue {
    return .number(Double(value))
  }
}

// MARK: - Integer types
//
// JavaScript numbers are doubles; integers are read through the throwing `asInt()` accessor (both
// overloads, see the floating-point note on why `get*` is unsafe here) and narrowed to the concrete
// width. Encoding widens back to `Double` for `.number`.
//
// TODO: A non-finite (`NaN`, `Infinity`) or out-of-range JS number traps instead of throwing:
// `asInt()` only checks `isNumber()`, then `Int(Double)` (and the narrowing inits like `Int8(...)`)
// crash on overflow. Replace with a checked, throwing narrowing that rejects non-finite and
// out-of-range values (mind that `Double(Int64.max)` is lossy when computing 64-bit bounds). This
// trap is pre-existing in the `asInt()` path; left as a follow-up rather than widened here.

extension Int: JavaScriptCodable {
  @JavaScriptActor
  @inlinable
  public static func decode(_ value: JavaScriptValue, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> Int {
    return try value.asInt()
  }

  @JavaScriptActor
  @inlinable
  public static func decode(_ value: borrowing JavaScriptUnownedValue, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> Int {
    return try value.asInt()
  }

  @JavaScriptActor
  @inlinable
  public static func encode(_ value: Int, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> JavaScriptValue {
    return .number(Double(value))
  }
}

extension Int8: JavaScriptCodable {
  @JavaScriptActor
  @inlinable
  public static func decode(_ value: JavaScriptValue, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> Int8 {
    return try Int8(value.asInt())
  }

  @JavaScriptActor
  @inlinable
  public static func decode(_ value: borrowing JavaScriptUnownedValue, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> Int8 {
    return try Int8(value.asInt())
  }

  @JavaScriptActor
  @inlinable
  public static func encode(_ value: Int8, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> JavaScriptValue {
    return .number(Double(value))
  }
}

extension Int16: JavaScriptCodable {
  @JavaScriptActor
  @inlinable
  public static func decode(_ value: JavaScriptValue, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> Int16 {
    return try Int16(value.asInt())
  }

  @JavaScriptActor
  @inlinable
  public static func decode(_ value: borrowing JavaScriptUnownedValue, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> Int16 {
    return try Int16(value.asInt())
  }

  @JavaScriptActor
  @inlinable
  public static func encode(_ value: Int16, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> JavaScriptValue {
    return .number(Double(value))
  }
}

extension Int32: JavaScriptCodable {
  @JavaScriptActor
  @inlinable
  public static func decode(_ value: JavaScriptValue, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> Int32 {
    return try Int32(value.asInt())
  }

  @JavaScriptActor
  @inlinable
  public static func decode(_ value: borrowing JavaScriptUnownedValue, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> Int32 {
    return try Int32(value.asInt())
  }

  @JavaScriptActor
  @inlinable
  public static func encode(_ value: Int32, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> JavaScriptValue {
    return .number(Double(value))
  }
}

extension Int64: JavaScriptCodable {
  @JavaScriptActor
  @inlinable
  public static func decode(_ value: JavaScriptValue, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> Int64 {
    return try Int64(value.asInt())
  }

  @JavaScriptActor
  @inlinable
  public static func decode(_ value: borrowing JavaScriptUnownedValue, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> Int64 {
    return try Int64(value.asInt())
  }

  @JavaScriptActor
  @inlinable
  public static func encode(_ value: Int64, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> JavaScriptValue {
    return .number(Double(value))
  }
}

extension UInt: JavaScriptCodable {
  @JavaScriptActor
  @inlinable
  public static func decode(_ value: JavaScriptValue, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> UInt {
    return try UInt(value.asInt())
  }

  @JavaScriptActor
  @inlinable
  public static func decode(_ value: borrowing JavaScriptUnownedValue, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> UInt {
    return try UInt(value.asInt())
  }

  @JavaScriptActor
  @inlinable
  public static func encode(_ value: UInt, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> JavaScriptValue {
    return .number(Double(value))
  }
}

extension UInt8: JavaScriptCodable {
  @JavaScriptActor
  @inlinable
  public static func decode(_ value: JavaScriptValue, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> UInt8 {
    return try UInt8(value.asInt())
  }

  @JavaScriptActor
  @inlinable
  public static func decode(_ value: borrowing JavaScriptUnownedValue, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> UInt8 {
    return try UInt8(value.asInt())
  }

  @JavaScriptActor
  @inlinable
  public static func encode(_ value: UInt8, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> JavaScriptValue {
    return .number(Double(value))
  }
}

extension UInt16: JavaScriptCodable {
  @JavaScriptActor
  @inlinable
  public static func decode(_ value: JavaScriptValue, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> UInt16 {
    return try UInt16(value.asInt())
  }

  @JavaScriptActor
  @inlinable
  public static func decode(_ value: borrowing JavaScriptUnownedValue, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> UInt16 {
    return try UInt16(value.asInt())
  }

  @JavaScriptActor
  @inlinable
  public static func encode(_ value: UInt16, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> JavaScriptValue {
    return .number(Double(value))
  }
}

extension UInt32: JavaScriptCodable {
  @JavaScriptActor
  @inlinable
  public static func decode(_ value: JavaScriptValue, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> UInt32 {
    return try UInt32(value.asInt())
  }

  @JavaScriptActor
  @inlinable
  public static func decode(_ value: borrowing JavaScriptUnownedValue, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> UInt32 {
    return try UInt32(value.asInt())
  }

  @JavaScriptActor
  @inlinable
  public static func encode(_ value: UInt32, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> JavaScriptValue {
    return .number(Double(value))
  }
}

extension UInt64: JavaScriptCodable {
  @JavaScriptActor
  @inlinable
  public static func decode(_ value: JavaScriptValue, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> UInt64 {
    return try UInt64(value.asInt())
  }

  @JavaScriptActor
  @inlinable
  public static func decode(_ value: borrowing JavaScriptUnownedValue, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> UInt64 {
    return try UInt64(value.asInt())
  }

  @JavaScriptActor
  @inlinable
  public static func encode(_ value: UInt64, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> JavaScriptValue {
    return .number(Double(value))
  }
}
