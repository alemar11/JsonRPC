//
// JsonRPC
//
// Copyright © 2016-2017 Tinrobots.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

struct DynamicCodingKey: CodingKey {
  var stringValue: String

  init?(stringValue: String) {
    self.stringValue = stringValue
  }

  var intValue: Int?

  init?(intValue: Int) {
    self.init(stringValue: "\(intValue)")
    self.intValue = intValue
  }
}

// MARK: - Decoding

extension KeyedDecodingContainer {

  func decodeDynamicDictionary(_ type: Dictionary<String, Any>.Type, forKey key: K) throws -> Dictionary<String, Any> {
    let container = try nestedContainer(keyedBy: DynamicCodingKey.self, forKey: key)
    return try container.decodeDynamicDictionary(type)
  }

  func decodeIfPresent(_ type: Dictionary<String, Any>.Type, forKey key: K) throws -> Dictionary<String, Any>? {
    guard contains(key) else { return nil }

    return try decode(type, forKey: key)
  }

  func decodeDynamicArray(_ type: Array<Any>.Type, forKey key: K) throws -> Array<Any> {
    var container = try nestedUnkeyedContainer(forKey: key)

    return try container.decode(type)
  }

  func decodeIfPresent(_ type: Array<Any>.Type, forKey key: K) throws -> Array<Any>? {
    guard contains(key) else { return nil }

    return try decode(type, forKey: key)
  }

  func decodeDynamicDictionary(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {
    var dictionary = Dictionary<String, Any>()

    for key in allKeys {
      if let boolValue = try? decode(Bool.self, forKey: key) {
        dictionary[key.stringValue] = boolValue
      } else if let stringValue = try? decode(String.self, forKey: key) {
        dictionary[key.stringValue] = stringValue
      } else if let intValue = try? decode(Int.self, forKey: key) {
        dictionary[key.stringValue] = intValue
      } else if let doubleValue = try? decode(Double.self, forKey: key) {
        dictionary[key.stringValue] = doubleValue
      } else if (try? decodeNil(forKey: key)) != nil {
        continue
      } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self, forKey: key) {
        dictionary[key.stringValue] = nestedDictionary
      } else if let nestedArray = try? decode(Array<Any>.self, forKey: key) {
        dictionary[key.stringValue] = nestedArray
      } else if try decodeNil(forKey: key) {
        //TODO: test this, add Float
        //dictionary[key.stringValue] = nil
      }
    }

    return dictionary
  }

  func decodeDynamicType(forKey key: K) throws -> Any {
    if let value = try? decode(Bool.self, forKey: key) {
        return value
    } else if let value = try? decode(String.self, forKey: key) {
       return value
    } else if let value = try? decode(Int.self, forKey: key) {
       return value
    } else if let value = try? decode(Double.self, forKey: key) {
      return value
    } else if let value = try? decodeDynamicArray([Any].self, forKey: key) {
      return value
    } else if let value = try? decodeDynamicDictionary([String: Any].self, forKey: key) {
      return value
    } else {
      let context = DecodingError.Context(codingPath: codingPath, debugDescription: "The decoding operation for \(key) is not yet supported.")
      throw DecodingError.dataCorrupted(context)
    }

  }
}

extension UnkeyedDecodingContainer {

//  mutating func decode(_ type: Array<Any?>.Type) throws -> Array<Any?> {
//    var array: [Any?] = []
//
//    while isAtEnd == false {
//      if (try? decodeNil()) != nil {
//        array.append(nil) //to keep the position integrity
//      } else if let value = try? decode(Bool.self) {
//        array.append(value)
//      } else if let value = try? decode(String.self) {
//        array.append(value)
//      } else if let value = try? decode(Int.self) {
//        array.append(value)
//      } else if let value = try? decode(Double.self) {
//        array.append(value)
//      } else if (try? decodeNil()) != nil {
//        array.append("null") //to keep the position integrity, TODO null
//      } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self) {
//        array.append(nestedDictionary)
//      } else if let nestedArray = try? decode(Array<Any>.self) {
//        array.append(nestedArray)
//      }
//    }
//    return array
//  }
  
  mutating func decode(_ type: Array<Any>.Type) throws -> Array<Any> {
    var array: [Any] = []

    while isAtEnd == false {
      if let value = try? decode(Bool.self) {
        array.append(value)
      } else if let value = try? decode(String.self) {
        array.append(value)
      } else if let value = try? decode(Int.self) {
        array.append(value)
      } else if let value = try? decode(Double.self) {
        array.append(value)
      } else if (try? decodeNil()) != nil {
        array.append("Null") //to keep the position integrity
      } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self) {
        array.append(nestedDictionary)
      } else if let nestedArray = try? decode(Array<Any>.self) {
        array.append(nestedArray)
      }
    }
    return array
  }

  mutating func decode(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {
    let nestedContainer = try nestedContainer(keyedBy: DynamicCodingKey.self)

    return try nestedContainer.decodeDynamicDictionary(type)
  }
}

// MARK: - Encoding

extension KeyedEncodingContainer {
  
  mutating func encodeAny(_ value: Any, forKey key: Key) throws {
    switch value {
    case let element as Bool:
      try encode(element, forKey: key)
    case let value as String:
      try encode(value, forKey: key)
    case let value as Int:
      try encode(value, forKey: key)
    case let value as Double:
      try encode(value, forKey: key)
    case let value as Dictionary<String, Any>:
      var nestedKeyedContainer = nestedContainer(keyedBy: DynamicCodingKey.self, forKey: key)
      try nestedKeyedContainer.encodeDynamicDictionary(value)
    case let value as Array<Any>:
      var nestedContainer = nestedUnkeyedContainer(forKey: key)
      try nestedContainer.encode(value)
    default:
      let context = EncodingError.Context(codingPath: codingPath, debugDescription: "The encoding operation for \(value) is not yet supported.")
      throw EncodingError.invalidValue(value, context)
    }
  }
  
}

extension KeyedEncodingContainer where Key == DynamicCodingKey { //TODO: the where clause should be defined?

  mutating func encodeDynamicDictionary(_ dictionary: Dictionary<String, Any>) throws {

    for (key, value) in dictionary {
      let key = DynamicCodingKey(stringValue: key)!
      switch value {
      case let bool as Bool:
        try encode(bool, forKey: key)
      case let string as String:
        try encode(string, forKey: key)
      case let int as Int:
        try encode(int, forKey: key)
      case let double as Double:
        try encode(double, forKey: key)
      case let dictionary as Dictionary<String, Any>:
        var nestedKeyedContainer = nestedContainer(keyedBy: Key.self, forKey: key)
        try nestedKeyedContainer.encodeDynamicDictionary(dictionary)
      case let array as Array<Any>:
        var nestedContainer = nestedUnkeyedContainer(forKey: key)
        try nestedContainer.encode(array)
        continue
      default:
        continue
      }
    }
  }
  
}

extension UnkeyedEncodingContainer {

  mutating func encode(_ value: Array<Any>) throws {
    for element in value {
      switch element {
      case let bool as Bool:
        try encode(bool)
      case let string as String:
        try encode(string)
      case let int as Int:
        try encode(int)
      case let double as Double:
        try encode(double)
      case let dictionary as Dictionary<String, Any>:
        var nestedKeyedContainer = nestedContainer(keyedBy: DynamicCodingKey.self)
        try nestedKeyedContainer.encodeDynamicDictionary(dictionary)
      case let array as Array<Any>:
        var nestedContainer = nestedUnkeyedContainer()
        try nestedContainer.encode(array)
      default:
        continue
      }
    }
  }

}

extension SingleValueEncodingContainer {
  
  mutating func encodeAny(_ value: Any) throws {
    switch value {
    case let value as Bool:
      try encode(value)
    case let value as String:
      try encode(value)
    case let value as Int:
      try encode(value)
    case let value as Double:
      try encode(value)
    default:
      let context = EncodingError.Context(codingPath: codingPath, debugDescription: "The encoding operation for \(value) is not yet supported.")
      throw EncodingError.invalidValue(value, context)
    }
  }
  
}
