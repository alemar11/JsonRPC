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

/// A JSON-RPC request.
public struct Request {

  /// A String containing the name of the method to be invoked. Method names that begin with the word rpc followed by a period character (U+002E or ASCII 46) are reserved for rpc-internal methods and extensions and MUST NOT be used for anything else.
  public var method: String

  /// An identifier established by the Client that MUST contain a String, Number, or NULL value if included. If it is not included it is assumed to be a notification. The value SHOULD normally not be Null and Numbers SHOULD NOT contain fractional parts.
  public var id: Id?

  /// A Structured value that holds the parameter values to be used during the invocation of the method. This member MAY be omitted.
  public var params: Parameters?

}

extension Request {

  /// A Notification is a Request object without an "id" member. A Request object that is a Notification signifies the Client's lack of interest in the corresponding Response object, and as such no Response object needs to be returned to the client. The Server MUST NOT reply to a Notification, including those that are within a batch request.
  var isNotification: Bool {
    return id == nil
  }

}

//TODO: remove this
enum TestError: Error {
  case invalid
}

// MARK: - Codable

extension Request: Codable {
  enum CodingError: Error { case decoding(String) }
  enum CodingKeys: String, CodingKey { case jsonrpc, id, method, params }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    guard let jsonrpc = try? values.decode(String.self, forKey: .jsonrpc), jsonrpc == "2.0" else { throw TestError.invalid }
    guard let method = try? values.decode(String.self, forKey: .method), method != "" else { throw TestError.invalid }

    let params = try? Parameters(from: decoder)
    let id = try? Id(from: decoder)

    self = Request(method: method, id: id, params: params)

  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode("2.0", forKey: .jsonrpc)
    try container.encode(method, forKey: .method)
    if let params = params {
      try container.encode(params, forKey: .params)
    }
    if let id = id {
      // the use of null for id in Requests is discouraged
      try container.encode(id, forKey: .id)
    }
  }

}


