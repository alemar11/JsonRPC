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

// https://stackoverflow.com/questions/44603248/how-to-decode-a-property-with-type-of-json-dictionary-in-swift-4-decodable-proto/46049763#46049763
// https://gist.github.com/bocato/0afb0aaf96f045f6cde5401359efc3bd
// https://gist.github.com/alemar11/5704a234e52c3a5078b6d7f4a5f6eac9

//TODO: ----> encode nil

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

extension KeyedDecodingContainer {

  func decodeDynamic(_ type: Dictionary<String, Any>.Type, forKey key: K) throws -> Dictionary<String, Any> {
    let container = try self.nestedContainer(keyedBy: DynamicCodingKey.self, forKey: key)
    return try container.decodeDynamic(type)
  }

  func decodeIfPresent(_ type: Dictionary<String, Any>.Type, forKey key: K) throws -> Dictionary<String, Any>? {
    guard contains(key) else { return nil }

    return try decode(type, forKey: key)
  }

  func decodeDynamic(_ type: Array<Any>.Type, forKey key: K) throws -> Array<Any> {
    var container = try self.nestedUnkeyedContainer(forKey: key)

    return try container.decode(type)
  }

  func decodeIfPresent(_ type: Array<Any>.Type, forKey key: K) throws -> Array<Any>? {
    guard contains(key) else { return nil }

    return try decode(type, forKey: key)
  }

  func decodeDynamic(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {
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
        //dictionary[key.stringValue] = nil //TODO: test this, add Float
      }
    }

    return dictionary
  }

  func decodeDynamicType(forKey key: K) throws -> Any? {
    if let value = try? decode(Bool.self, forKey: key) {
        return value
    } else if let value = try? decode(String.self, forKey: key) {
       return value
    } else if let value = try? decode(Int.self, forKey: key) {
       return value
    } else if let value = try? decode(Double.self, forKey: key) {
      return value
    } else if let value = try? decodeDynamic([Any].self, forKey: key) {
      return value
    } else if let value = try? decodeDynamic([String: Any].self, forKey: key) {
      return value
    } else {
      return nil
    }

  }
}


extension KeyedEncodingContainer where Key == DynamicCodingKey {

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
        //TODO: test
        var nestedKeyedContainer = self.nestedContainer(keyedBy: Key.self, forKey: key)
        try nestedKeyedContainer.encodeDynamicDictionary(dictionary)
      case let array as Array<Any>:
        var nestedContainer = self.nestedUnkeyedContainer(forKey: key)
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
        var nestedKeyedContainer = self.nestedContainer(keyedBy: DynamicCodingKey.self)
        try nestedKeyedContainer.encodeDynamicDictionary(dictionary)
      case let array as Array<Any>:
        var nestedContainer = self.nestedUnkeyedContainer()
        try nestedContainer.encode(array)
      default:
        continue
      }
    }
  }

}

extension UnkeyedDecodingContainer {

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
        array.append("null") //to keep the position integrity
      } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self) {
        array.append(nestedDictionary)
      } else if let nestedArray = try? decode(Array<Any>.self) {
        array.append(nestedArray)
      }
    }
    return array
  }

  mutating func decode(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {
    let nestedContainer = try self.nestedContainer(keyedBy: DynamicCodingKey.self)

    return try nestedContainer.decodeDynamic(type)
  }
}
