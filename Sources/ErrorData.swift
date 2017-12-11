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

public enum ErrorData {
  case primitive(value: Any)
  case structured(object: [String: Any])
}

extension ErrorData: Codable {
  enum CodingKeys: String, CodingKey { case error, data }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self).nestedContainer(keyedBy: CodingKeys.self, forKey: .error)

    if let value = try? container.decodeDynamicDictionary([String: Any].self, forKey: .data) {
      self = .structured(object: value)

    } else if let value = try? container.decodeDynamicType(forKey: .data) {
       self = .primitive(value: value)

    } else {
      let context =  DecodingError.Context(codingPath: [CodingKeys.data], debugDescription: "The key 'data' not found.")
      throw DecodingError.keyNotFound(CodingKeys.data, context)
    }

  }


  public func encode(to encoder: Encoder) throws {

    switch self {
    case .primitive(let value):
     var container = encoder.singleValueContainer()
     try container.encodeAny(value)

    case .structured(let dictionary):
      var container = encoder.container(keyedBy: DynamicCodingKey.self)
      try container.encodeDynamicDictionary(dictionary)
    }
  }
}

