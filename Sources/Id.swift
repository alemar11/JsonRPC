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

/// A JSON-RPC id field.
public enum Id {
  case string(String)
  case number(Int)
}


// https://github.com/RLovelett/langserver-swift/blob/79ddd88a8ac7a2b3ff86c0e25ab8154da963ba0f/Sources/BaseProtocol/Types/Request.swift

extension Id: Codable {
  enum CodingKeys: String, CodingKey { case id }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    if let id = try? values.decode(Int.self, forKey: .id) {
      self = .number(id)
    } else if let id = try? values.decode(String.self, forKey: .id) {
      self = .string(id)
    } else {
      throw TestError.invalid
    }

  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .number(let number):
      try container.encode(number)
    case .string(let string):
      try container.encode(string)
    }
  }

}

extension Id : Equatable {

  /// Returns a Boolean value indicating whether two Id are equal.
  public static func ==(lhs: Id, rhs: Id) -> Bool {
    switch (lhs, rhs) {
    case (.string(let lhss), .string(let rhss)) where lhss == rhss:
      return true
    case (.number(let lhsn), .number(let rhsn)) where lhsn == rhsn:
      return true
    default:
      return false
    }
  }

}

