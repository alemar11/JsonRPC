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

/// A JSON-RPC params field.
public enum Parameters {
  case positional(array: [Any])
  case named(object: [String: Any]) //TODO: rename object?
}


// https://github.com/RLovelett/langserver-swift/blob/79ddd88a8ac7a2b3ff86c0e25ab8154da963ba0f/Sources/BaseProtocol/Types/Request.swift

extension Parameters: Codable {
  enum CodingError: Error { case decoding(String) } //TODO: Is it needed?
  enum CodingKeys: String, CodingKey { case params }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    //print(values.contains(.params)) //check in the future maybe not here?


    if let params = try? values.decodeDynamic(Array<Any>.self, forKey: .params) {
      self = .positional(array: params)

    } else if let params: [String: Any] = try? values.decodeDynamic([String: Any].self, forKey: .params) {
      self = .named(object: params)

    } else {
      let context =  DecodingError.Context(codingPath: [Parameters.CodingKeys.params], debugDescription: "Expected '[String: Any] or [Any]' for the 'params' key.")
      throw DecodingError.dataCorrupted(context)
    }

  }

  public func encode(to encoder: Encoder) throws {

    switch self {
    case .positional(let array):
      var container = encoder.unkeyedContainer()
      try container.encode(array)

    case .named(let object):
      var container = encoder.container(keyedBy: DynamicCodingKey.self)
      try container.encodeDynamicDictionary(object)
    }
  }

}





// ???: https://gist.github.com/paulofaria/339ffa172cc84b2725f2b5a598f4fda9
