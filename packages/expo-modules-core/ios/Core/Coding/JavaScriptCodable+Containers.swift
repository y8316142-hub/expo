// Copyright 2025-present 650 Industries. All rights reserved.

import ExpoModulesJSI

// `JavaScriptCodable` conformances for the standard container and wrapper types — `Array`,
// `Optional`, and `Dictionary` — each conditional on its element/wrapped type conforming, and
// each recursing statically into that element's conversion.
//
// `JavaScriptCodable` is a composition type alias, so a conformance clause spells out both halves:
// `extension Array: JavaScriptDecodable, JavaScriptEncodable where Element: JavaScriptCodable`.

// MARK: - Array

extension Array: JavaScriptDecodable, JavaScriptEncodable where Element: JavaScriptCodable {
  @JavaScriptActor
  @inlinable
  public static func decode(_ value: JavaScriptValue, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> [Element] {
    let jsArray = try value.asArray()
    var result = [Element]()
    result.reserveCapacity(jsArray.length)
    for index in 0..<jsArray.length {
      let element = try jsArray.getValue(at: index)
      result.append(try Element.decode(element, appContext: appContext, runtime: runtime))
    }
    return result
  }

  @JavaScriptActor
  @inlinable
  public static func encode(_ value: [Element], appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> JavaScriptValue {
    let jsArray = runtime.createArray(length: value.count)
    for (index, element) in value.enumerated() {
      try jsArray.set(value: Element.encode(element, appContext: appContext, runtime: runtime), at: index)
    }
    return jsArray.asValue()
  }
}

// MARK: - Optional

extension Optional: JavaScriptDecodable, JavaScriptEncodable where Wrapped: JavaScriptCodable {
  // Optional copies nothing itself, so it overrides the zero-copy overload too and forwards the
  // borrowed value straight through — a wrapped primitive argument stays fully zero-copy.
  @JavaScriptActor
  @inlinable
  public static func decode(_ value: borrowing JavaScriptUnownedValue, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> Wrapped? {
    if value.isNull() || value.isUndefined() {
      return .none
    }
    return try Wrapped.decode(value, appContext: appContext, runtime: runtime)
  }

  @JavaScriptActor
  @inlinable
  public static func decode(_ value: JavaScriptValue, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> Wrapped? {
    if value.isNull() || value.isUndefined() {
      return .none
    }
    return try Wrapped.decode(value, appContext: appContext, runtime: runtime)
  }

  @JavaScriptActor
  @inlinable
  public static func encode(_ value: Wrapped?, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> JavaScriptValue {
    guard let value else {
      // `nil` maps to `null`; mapping to `undefined` is the job of `ValueOrUndefined`.
      return .null
    }
    return try Wrapped.encode(value, appContext: appContext, runtime: runtime)
  }
}

// MARK: - Dictionary

extension Dictionary: JavaScriptDecodable, JavaScriptEncodable where Key == String, Value: JavaScriptCodable {
  @JavaScriptActor
  @inlinable
  public static func decode(_ value: JavaScriptValue, appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> [String: Value] {
    let object = try value.asObject()
    let keys = object.getPropertyNames()
    var result = [String: Value](minimumCapacity: keys.count)
    for key in keys {
      let property = object.getProperty(key)
      result[key] = try Value.decode(property, appContext: appContext, runtime: runtime)
    }
    return result
  }

  @JavaScriptActor
  @inlinable
  public static func encode(_ value: [String: Value], appContext: AppContext, runtime: borrowing JavaScriptRuntime) throws -> JavaScriptValue {
    let object = runtime.createObject()
    for (key, element) in value {
      object.setProperty(key, value: try Value.encode(element, appContext: appContext, runtime: runtime))
    }
    return object.asValue()
  }
}
