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

/// When a rpc call encounters an error, the Response Object MUST contain the error member
public enum ErrorObject: Error {
  /// Invalid JSON was received by the server. An error occurred on the server while parsing the JSON text.
  case parseError(message: String, data: ErrorData?)
  /// The JSON sent is not a valid Request object.
  case invalidRequest(message: String, data: ErrorData?)
  /// The method does not exist / is not available.
  case methodNotFound(message: String, data: ErrorData?)
  /// Invalid method parameter(s).
  case invalidParams(message: String, data: ErrorData?)
  /// Internal JSON-RPC error.
  case internalError(message: String, data: ErrorData?)
  /// Reserved for implementation-defined server-errors.
  /// - Note: code must be between -32000 and -32099
  case raw(code: Int, message: String, data: ErrorData?)
  
  /// A Number that indicates the error type that occurred.
  public var code: Int {
    switch self {
    case .parseError: return -32700
    case .invalidRequest: return -32600
    case .methodNotFound: return -32601
    case .invalidParams: return -32602
    case .internalError: return -32603
    case .raw(let code, _, _): return code
    }
  }
  
  /// A String providing a short description of the error.
  /// - Note: The message SHOULD be limited to a concise single sentence.
  public var message: String {
    switch self {
    case .parseError(let message, _): return message
    case .invalidRequest(let message, _): return message
    case .methodNotFound(let message, _): return message
    case .invalidParams(let message, _): return message
    case .internalError(let message, _): return message
    case .raw(_, let message, _): return message
    }
  }
  
  /// A Primitive or Structured value that contains additional information about the error.
  /// This may be omitted.
  /// The value of this member is defined by the Server (e.g. detailed error information, nested errors etc.).
  public var data: ErrorData? {
    switch self {
    case .parseError(_, let data): return data
    case .invalidRequest(_, let data): return data
    case .methodNotFound(_, let data): return data
    case .invalidParams(_, let data): return data
    case .internalError(_, let data): return data
    case .raw(_ ,_ , let data): return data
    }
  }
  
  /// Creates a new raw error.
  public init?(code: Int, message: String = "Server Error", data: ErrorData? = nil) {
    if type(of: self).isValidImplementationDefinedCode(code) {
      self = .raw(code: code, message: message, data: data)
      return
    }
    return nil
  }
  
}

// MARK - Utility

extension ErrorObject {
  
  /// Returns `true` if the code is defined in the range for the implementation-defined server-errors.
  public static func isValidImplementationDefinedCode(_ code: Int) -> Bool {
    return -32099 ... -32000 ~= code
  }
  
}

// MARK: - Codable

extension ErrorObject: Codable {
  enum CodingKeys: String, CodingKey { case error, code, message, data }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    let components = try values.decodeDictionary(Dictionary<String, Any>.self, forKey: .error)
    guard let codeValue = components[CodingKeys.code.rawValue], let code = codeValue as? Int else {
      let context =  DecodingError.Context(codingPath: [CodingKeys.code], debugDescription: "The key 'code' must be an Int.")
      throw DecodingError.dataCorrupted(context)
    }
    
    let message = components[CodingKeys.message.rawValue] as? String ?? ""
    let errorData = try? ErrorData(from: decoder)
    
    switch code {
    case -32700:
      self =  .parseError(message: message, data: errorData)
    case -32600:
      self = .invalidRequest(message: message, data: errorData)
    case -32601:
      self = .methodNotFound(message: message, data: errorData)
    case -32602:
      self = .invalidParams(message: message, data: errorData)
    case -32603:
      self = .internalError(message: message, data: errorData)
    case -32099 ... -32000:
      self = .raw(code: code, message: message, data: errorData)
    default:
      throw DecodingError.dataCorruptedError(forKey: ErrorObject.CodingKeys.code, in: values, debugDescription: "The code \(code) is not allowed.")
    }
    
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    switch self {
    case .raw(code: let code, message: let message, data: let data):
      guard ErrorObject.isValidImplementationDefinedCode(code) else {
        let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "\(code) is not defined inside the range between -32099 and -32000.")
        throw EncodingError.invalidValue(code, context)
      }
      try container.encode(code, forKey: .code)
      try container.encode(message, forKey: .message)
      if let data = data {
        try container.encode(data, forKey: .data)
      }
    default:
      try container.encode(code, forKey: .code)
      try container.encode(message, forKey: .message)
      if let data = data {
        try container.encode(data, forKey: .data)
      }
    }
    
  }
  
}
