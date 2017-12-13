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

/// When a rpc call is made, the Server must reply with a Response, except for in the case of Notifications.
public enum Response {
  /// Success response.
  case success(id: Id, result: Any)
  /// Error response: when a rpc call encounters an error, the `ErrorObject` must contain the error member with a value.
  case error(id: Id?, error: ErrorObject)

  /// It must be the same as the value of the id member in the Request Object.
  /// - Note: If there was an error in detecting the id in the Request object (e.g. Parse error/Invalid Request), it must be Null.
  public var id: Id? {
    switch self {
    case .success(let id, _): return id
    case .error(let id, _): return id
    }
  }

  /// This member is **required on success**.
  /// This member must not exist if there was an error invoking the method.
  /// - Note: The value of this member is determined by the method invoked on the Server.
  public var result: Any? {
    switch self {
    case .success(_, let result): return result
    case .error: return nil
    }
  }

  /// This member is **required on error**.
  public var error: ErrorObject? {
    switch self {
    case .success: return nil
    case .error(_, let error): return error
    }
  }
}

// MARK: - Codable

extension Response: Codable {
  enum CodingKeys: String, CodingKey { case jsonrpc, id, result, error }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    guard let jsonrpc = try? container.decode(String.self, forKey: .jsonrpc), jsonrpc == "2.0" else {
      let context = DecodingError.Context(codingPath: [CodingKeys.jsonrpc], debugDescription: "JSON RPC version not supported.")
      throw DecodingError.dataCorrupted(context)
    }
    let id = try Id(from: decoder)
    let error = try? ErrorObject(from: decoder)
    let result = try? container.decodeAny(forKey: .result)

    switch (result, error) {
    case (_?, _?):
      let context = DecodingError.Context(codingPath: [CodingKeys.error, CodingKeys.result], debugDescription: "The keys 'error' and 'result' cannot be populated at the same time.")
      throw DecodingError.dataCorrupted(context)
    case (nil, let error?):
      self = .error(id: id, error: error)
    case (let result?, nil):
      self = .success(id: id, result: result)
    case (nil, nil):
      let context = DecodingError.Context(codingPath: [CodingKeys.error, CodingKeys.result], debugDescription: "The keys 'error' and 'result' cannot be nil at the same time.")
      throw DecodingError.dataCorrupted(context)
    }

  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode("2.0", forKey: .jsonrpc)
    switch self {
    case .success(id: let id, result: let result):
      try container.encode(id, forKey: .id)
      try container.encodeAny(result, forKey: .result)
    case .error(id: let id, error: let error):
      if let id = id {
        // the use of null for id in Requests is discouraged
        try container.encode(id, forKey: .id)
      }
      try container.encode(error, forKey: .error)
    }
  }

}

