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

import XCTest
@testable import JsonRPC

extension ResponseTests {
  static var allTests = [
    ("testDecodingInvalidResponse", testDecodingInvalidResponse),
    ("testDecodingSuccessResponse", testDecodingSuccessResponse),
    ("testDecodingErrorResponse", testDecodingErrorResponse),
    ("testEncodingSuccessResponse", testEncodingSuccessResponse),
    ("testEncodingErrorResponse", testEncodingErrorResponse),
    ("testEncodingErrorResponseWithPredefinedCase", testEncodingErrorResponseWithPredefinedCase)
  ]
}

class ResponseTests: XCTestCase {
  
  // MARK: - Decoding
  
  func testDecodingInvalidResponse() throws {
    /// missing result and error at the same time
    do {
      let json = """
          {"jsonrpc": "2.0", "id": 4}
      """.data(using: .utf8)!
      XCTAssertThrowsError(try JSONDecoder().decode(Response.self, from: json))
    }
    
    /// error and result populated at the same time
    do {
      let json = """
          {"jsonrpc": "2.0", "id": 4, "result": 1, "error": {"code": -32601, "message": "Method not found"} }
      """.data(using: .utf8)!
      XCTAssertThrowsError(try JSONDecoder().decode(Response.self, from: json))
    }
  }
  
  func testDecodingSuccessResponse() throws {
    
    /// int result
    do {
      let json = """
          {"jsonrpc": "2.0", "result": 19, "id": 4}
      """.data(using: .utf8)!
      let response = try JSONDecoder().decode(Response.self, from: json)
      XCTAssertTrue(response.id == Id.number(4))
      XCTAssertTrue(response.result as! Int == 19)
      XCTAssertNil(response.error)
      
      switch response {
      case .success(id: let id, result: let result):
        XCTAssertTrue(id == Id.number(4))
        XCTAssertTrue(result as! Int == 19)
      default:
        XCTFail("Expected a success response.")
      }
    }
    
    /// string result
    do {
      let json = """
          {"jsonrpc": "2.0", "result": 19.19, "id": "test"}
      """.data(using: .utf8)!
      let response = try JSONDecoder().decode(Response.self, from: json)
      XCTAssertTrue(response.id == Id.string("test"))
      XCTAssertTrue(response.result as! Double == 19.19)
      XCTAssertNil(response.error)
      
      switch response {
      case .success(id: let id, result: let result):
        XCTAssertTrue(id == Id.string("test"))
        XCTAssertTrue(result as! Double == 19.19)
      default:
        XCTFail("Expected a success response.")
      }
    }
    
    /// invalid jsonrpc
    do {
      let json = """
          {"jsonrpc": "2.1", "result": 19.19, "id": "test"}
      """.data(using: .utf8)!
      XCTAssertThrowsError(try JSONDecoder().decode(Response.self, from: json))
    }
    
    /// array result
    do {
      let json = """
          {"jsonrpc": "2.0", "result": ["hello", 5], "id": "9"}
      """.data(using: .utf8)!
      let response = try JSONDecoder().decode(Response.self, from: json)
      XCTAssertTrue(response.id == Id.string("9"))
      XCTAssertTrue((response.result as! [Any]).count == 2)
      XCTAssertTrue((response.result as! [Any])[0] as! String == "hello")
      XCTAssertTrue((response.result as! [Any])[1] as! Int == 5)
      XCTAssertNil(response.error)
      
      switch response {
      case .success(id: let id, result: let result):
        XCTAssertTrue(id == Id.string("9"))
        XCTAssertTrue((result as! [Any]).count == 2)
        XCTAssertTrue((result as! [Any])[0] as! String == "hello")
        XCTAssertTrue((result as! [Any])[1] as! Int == 5)
      default:
        XCTFail("Expected a success response.")
      }
    }
    
    /// dictionary result
    do {
      let json = """
          {"jsonrpc": "2.0", "result": {"key1": 2}, "id": 1}
      """.data(using: .utf8)!
      let response = try JSONDecoder().decode(Response.self, from: json)
      XCTAssertTrue(response.id == Id.number(1))
      XCTAssertTrue((response.result as! [String: Any]).count == 1)
      XCTAssertTrue((response.result as! [String: Any])["key1"] as! Int == 2)
      XCTAssertNil(response.error)
      
      switch response {
      case .success(id: let id, result: let result):
        XCTAssertTrue(id == Id.number(1))
        XCTAssertTrue((result as! [String: Any]).count == 1)
        XCTAssertTrue((result as! [String: Any])["key1"] as! Int == 2)
      default:
        XCTFail("Expected a success response.")
      }
    }
    
  }
  
  func testDecodingErrorResponse() throws {
    /// error without data
    do {
      let json = """
          {"jsonrpc": "2.0", "error": {"code": -32601, "message": "Method not found"}, "id": "1"}
      """.data(using: .utf8)!
      let response = try JSONDecoder().decode(Response.self, from: json)
      XCTAssertTrue(response.id == Id.string("1"))
      XCTAssertTrue(response.error?.code == -32601)
      XCTAssertTrue(response.error?.message == "Method not found")
      XCTAssertNil(response.error?.data)
      XCTAssertNil(response.result)
      
      switch response {
      case .error(id: let id, error: let error):
        XCTAssertNotNil(id)
        XCTAssertTrue(id == Id.string("1"))
        XCTAssertTrue(error.code == -32601)
        XCTAssertTrue(error.message == "Method not found")
        XCTAssertNil(error.data)
      default:
        XCTFail("Expected an error response.")
      }
    }
    
    /// error with data
    do {
      let json = """
          {"jsonrpc": "2.0", "error": {"code": -32601, "message": "Method not found", "data": true}, "id": 12}
      """.data(using: .utf8)!
      let response = try JSONDecoder().decode(Response.self, from: json)
      XCTAssertTrue(response.id == Id.number(12))
      XCTAssertTrue(response.error?.code == -32601)
      XCTAssertTrue(response.error?.message == "Method not found")
      XCTAssertNotNil(response.error?.data)
      XCTAssertNil(response.result)
      
      switch response {
      case .error(id: let id, error: let error):
        XCTAssertNotNil(id)
        XCTAssertTrue(id == Id.number(12))
        XCTAssertTrue(error.code == -32601)
        XCTAssertTrue(error.message == "Method not found")
        XCTAssertNotNil(error.data)
        switch error {
        case .methodNotFound(message: let message, data: let errorData):
          XCTAssertTrue(message == "Method not found")
          switch errorData! {
          case .primitive(value: let data):
            XCTAssertTrue(data as! Bool == true)
          default:
            XCTFail("Wrong error data type.")
          }
        default:
          XCTFail("Wrong error type.")
        }
      default:
        XCTFail("Expected an error response.")
      }
    }
    
    /// defined with structured error data
    do {
      let json = """
           {"jsonrpc": "2.0", "error": {"code": -32600, "message": "Invalid Request", "data": {"value": 23, "nilValue": null} }, "id": 11}
          """.data(using: .utf8)!
      let response = try JSONDecoder().decode(Response.self, from: json)
      XCTAssertTrue(response.id == Id.number(11))
      XCTAssertTrue(response.error?.code == -32600)
      XCTAssertTrue(response.error?.message == "Invalid Request")
      XCTAssertNotNil(response.error?.data)
      XCTAssertNil(response.result)
      
      switch response {
      case .error(id: let id, error: let error):
        XCTAssertNotNil(id)
        XCTAssertTrue(id == Id.number(11))
        XCTAssertTrue(error.code == -32600)
        XCTAssertTrue(error.message == "Invalid Request")
        XCTAssertNotNil(error.data)
        switch error {
        case .invalidRequest(message: let message, data: let errorData):
          XCTAssertTrue(message == "Invalid Request")
          switch errorData! {
          case .structured(object: let dictionary):
            XCTAssertTrue(dictionary["value"] as! Int == 23)
            XCTAssertNil(dictionary["nilValue"])
          default:
            XCTFail("Wrong error data type.")
          }
        default:
          XCTFail("Wrong error type.")
        }
      default:
        XCTFail("Expected an error response.")
      }
    }
    
    /// defined with structured error data
    do {
      let json = """
           {"jsonrpc": "2.0", "error": {"code": -32010, "message": "Server Error", "data": {"value": 23, "nilValue": null} }, "id": 110}
          """.data(using: .utf8)!
      let response = try JSONDecoder().decode(Response.self, from: json)
      XCTAssertTrue(response.id == Id.number(110))
      XCTAssertTrue(response.error?.code == -32010)
      XCTAssertTrue(response.error?.message == "Server Error")
      XCTAssertNotNil(response.error?.data)
      XCTAssertNil(response.result)
      
      switch response {
      case .error(id: let id, error: let error):
        XCTAssertNotNil(id)
        XCTAssertTrue(id == Id.number(110))
        XCTAssertTrue(error.code == -32010)
        XCTAssertTrue(error.message == "Server Error")
        XCTAssertNotNil(error.data)
        switch error {
        case .raw(code: let code, message: let message, data: let data):
          XCTAssertTrue(code == -32010)
          XCTAssertTrue(message == "Server Error")
          switch data! {
          case .structured(object: let dictionary):
            XCTAssertTrue(dictionary["value"] as! Int == 23)
            XCTAssertNil(dictionary["nilValue"])
          default:
            XCTFail("Wrong error data type.")
          }
        default:
          XCTFail("Wrong error type.")
        }
      default:
        XCTFail("Expected an error response.")
      }
    }
    
    /// invalid error id
    do {
      let json = """
          {"jsonrpc": "2.0", "error": {"code": -1, "message": "Custom"}, "id": "1"}
      """.data(using: .utf8)!
      XCTAssertThrowsError(try JSONDecoder().decode(Response.self, from: json))
    }
    
    /// invalid error id
    do {
      let json = """
          {"jsonrpc": "2.0", "error": {"code": "fakeId", "message": "Custom"}, "id": "1"}
      """.data(using: .utf8)!
      XCTAssertThrowsError(try JSONDecoder().decode(Response.self, from: json))
    }
    
  }
  
  // MARK: - Encoding
  
  func testEncodingSuccessResponse() throws {
    
    /// string result
    do {
      let response = Response.success(id: Id.number(10), result: "Success")
      let encoder = JSONEncoder()
      let jsonData = try encoder.encode(response)
      
      guard let json = String(data: jsonData, encoding: .utf8) else {
        XCTFail("Failed while converting Data to String.")
        return
      }
      
      XCTAssertTrue(json.contains("\"jsonrpc\":\"2.0\""))
      XCTAssertTrue(json.contains("\"id\":10"))
      XCTAssertTrue(json.contains("\"result\":\"Success\""))
    }
    
    /// [int] result
    do {
      let response = Response.success(id: Id.number(0), result: [1,2,3])
      let encoder = JSONEncoder()
      let jsonData = try encoder.encode(response)
      
      guard let json = String(data: jsonData, encoding: .utf8) else {
        XCTFail("Failed while converting Data to String.")
        return
      }
      
      XCTAssertTrue(json.contains("\"jsonrpc\":\"2.0\""))
      XCTAssertTrue(json.contains("\"id\":0"))
      XCTAssertTrue(json.contains("\"result\":[1,2,3"))
    }
    
    /// [Any] result
    do {
      let response = Response.success(id: Id.string("10"), result: [1,false,3, "four"])
      let encoder = JSONEncoder()
      let jsonData = try encoder.encode(response)
      
      guard let json = String(data: jsonData, encoding: .utf8) else {
        XCTFail("Failed while converting Data to String.")
        return
      }
      
      XCTAssertTrue(json.contains("\"jsonrpc\":\"2.0\""))
      XCTAssertTrue(json.contains("\"id\":\"10\""))
      XCTAssertTrue(json.contains("\"result\":[1,false,3,\"four\""))
    }
    
    /// [String: Any] result
    do {
      let response = Response.success(id: Id.string("0"), result: ["key1": true, "key2": 11.83])
      let encoder = JSONEncoder()
      let jsonData = try encoder.encode(response)
      
      guard let json = String(data: jsonData, encoding: .utf8) else {
        XCTFail("Failed while converting Data to String.")
        return
      }
      
      XCTAssertTrue(json.contains("\"jsonrpc\":\"2.0\""))
      XCTAssertTrue(json.contains("\"id\":\"0\""))
      XCTAssertTrue(json.contains("\"key1\":true"))
      XCTAssertTrue(json.contains("\"key2\":11.83"))
    }
    
    /// nested [String: Any] result
    do {
      let response = Response.success(id: Id.string("0"), result: ["key1": true, "key2": ["subkey1":[false, 0]]])
      let encoder = JSONEncoder()
      let jsonData = try encoder.encode(response)
      
      guard let json = String(data: jsonData, encoding: .utf8) else {
        XCTFail("Failed while converting Data to String.")
        return
      }
      
      XCTAssertTrue(json.contains("\"jsonrpc\":\"2.0\""))
      XCTAssertTrue(json.contains("\"id\":\"0\""))
      XCTAssertTrue(json.contains("\"key1\":true"))
      XCTAssertTrue(json.contains("\"key2\":{"))
      XCTAssertTrue(json.contains("\"subkey1\":[false,0]"))
    }
    
  }
  
  func testEncodingErrorResponse() throws {
    /// raw without error data
    do {
      let error = ErrorObject(code: -32000, message: "Something went wrong.")!
      let response = Response.error(id: Id.string("errorID"), error: error)
      let encoder = JSONEncoder()
      let jsonData = try encoder.encode(response)
      
      guard let json = String(data: jsonData, encoding: .utf8) else {
        XCTFail("Failed while converting Data to String.")
        return
      }
      
      XCTAssertTrue(json.contains("\"jsonrpc\":\"2.0\""))
      XCTAssertTrue(json.contains("\"id\":\"errorID\""))
      XCTAssertTrue(json.contains("\"error\":{"))
      XCTAssertTrue(json.contains("\"message\":\"Something went wrong.\""))
      XCTAssertTrue(json.contains("\"code\":-32000"))
    }
    
    /// raw with error data
    do {
      let errorData = ErrorData.structured(object: ["key1": [1,2,nil]])
      let error = ErrorObject(code: -32000, message: "Something went wrong.", data: errorData)!
      let response = Response.error(id: Id.string("errorID"), error: error)
      let encoder = JSONEncoder()
      let jsonData = try encoder.encode(response)
      
      guard let json = String(data: jsonData, encoding: .utf8) else {
        XCTFail("Failed while converting Data to String.")
        return
      }
      
      XCTAssertTrue(json.contains("\"jsonrpc\":\"2.0\""))
      XCTAssertTrue(json.contains("\"id\":\"errorID\""))
      XCTAssertTrue(json.contains("\"error\":{"))
      XCTAssertTrue(json.contains("\"message\":\"Something went wrong.\""))
      XCTAssertTrue(json.contains("\"code\":-32000"))
      XCTAssertTrue(json.contains("\"data\""))
      XCTAssertTrue(json.contains("\"key1\":[1,2,null]"))
    }
    
    /// empty message and no error data
    do {
      let error = ErrorObject.parseError(message: "", data: nil)
      let response = Response.error(id: Id.string("errorID"), error: error)
      let encoder = JSONEncoder()
      let jsonData = try encoder.encode(response)
      
      guard let json = String(data: jsonData, encoding: .utf8) else {
        XCTFail("Failed while converting Data to String.")
        return
      }
      
      XCTAssertTrue(json.contains("\"jsonrpc\":\"2.0\""))
      XCTAssertTrue(json.contains("\"id\":\"errorID\""))
      XCTAssertTrue(json.contains("\"error\":{"))
      XCTAssertTrue(json.contains("\"message\":\"\""))
      XCTAssertFalse(json.contains("data"))
      XCTAssertTrue(json.contains("\"code\":-32700"))
    }
    
    /// predefined error
    do {
      let error = ErrorObject.invalidRequest(message: "Invalid R.", data: nil)
      let response = Response.error(id: Id.string("errorID"), error: error)
      let encoder = JSONEncoder()
      let jsonData = try encoder.encode(response)
      
      guard let json = String(data: jsonData, encoding: .utf8) else {
        XCTFail("Failed while converting Data to String.")
        return
      }
      
      XCTAssertTrue(json.contains("\"jsonrpc\":\"2.0\""))
      XCTAssertTrue(json.contains("\"id\":\"errorID\""))
      XCTAssertTrue(json.contains("\"error\":{"))
      XCTAssertTrue(json.contains("\"message\":\"Invalid R.\""))
      XCTAssertTrue(json.contains("\"code\":-32600"))
    }
    
    /// primitive error data
    do {
      let error = ErrorObject.internalError(message: "Internal error", data: ErrorData.primitive(value: 10))
      let response = Response.error(id: Id.string("errorID"), error: error)
      let encoder = JSONEncoder()
      let jsonData = try encoder.encode(response)
      
      guard let json = String(data: jsonData, encoding: .utf8) else {
        XCTFail("Failed while converting Data to String.")
        return
      }
      
      XCTAssertTrue(json.contains("\"jsonrpc\":\"2.0\""))
      XCTAssertTrue(json.contains("\"id\":\"errorID\""))
      XCTAssertTrue(json.contains("\"error\":{"))
      XCTAssertTrue(json.contains("\"message\":\"Internal error\""))
      XCTAssertTrue(json.contains("\"data\":10"))
      XCTAssertTrue(json.contains("\"code\":-32603"))
    }
    
    /// structured error data
    do {
      let error = ErrorObject.internalError(message: "Internal error", data: ErrorData.structured(object: ["key1": true, "key2": 3]))
      let encoder = JSONEncoder()
      let response = Response.error(id: Id.string("errorID"), error: error)
      let jsonData = try encoder.encode(response)
      
      guard let json = String(data: jsonData, encoding: .utf8) else {
        XCTFail("Failed while converting Data to String.")
        return
      }
      
      XCTAssertTrue(json.contains("\"jsonrpc\":\"2.0\""))
      XCTAssertTrue(json.contains("\"id\":\"errorID\""))
      XCTAssertTrue(json.contains("\"error\":{"))
      XCTAssertTrue(json.contains("\"message\":\"Internal error\""))
      XCTAssertTrue(json.contains("\"data\":{"))
      XCTAssertTrue(json.contains("\"key1\":true"))
      XCTAssertTrue(json.contains("\"key2\":3"))
      XCTAssertTrue(json.contains("\"code\":-32603"))
    }
    
    /// invalid error id
    do {
      XCTAssertNil(ErrorObject(code: -1, message: "Something went wrong."))
    }
    
  }
  
  func testEncodingErrorResponseWithPredefinedCase() throws {
    do {
      let error = ErrorObject.parseError(message: "parse error", data: nil)
      let encoder = JSONEncoder()
      let response = Response.error(id: Id.number(1), error: error)
      let jsonData = try encoder.encode(response)
      
      guard let json = String(data: jsonData, encoding: .utf8) else {
        XCTFail("Failed while converting Data to String.")
        return
      }
      
      XCTAssertTrue(json.contains("\"jsonrpc\":\"2.0\""))
      XCTAssertTrue(json.contains("\"id\":1"))
      XCTAssertTrue(json.contains("\"error\":{"))
      XCTAssertTrue(json.contains("\"code\":-32700"))
      
    }
    
    do {
      let error = ErrorObject.invalidRequest(message: "invalid request", data: nil)
      let encoder = JSONEncoder()
      let response = Response.error(id: Id.number(1), error: error)
      let jsonData = try encoder.encode(response)
      
      guard let json = String(data: jsonData, encoding: .utf8) else {
        XCTFail("Failed while converting Data to String.")
        return
      }
      
      XCTAssertTrue(json.contains("\"jsonrpc\":\"2.0\""))
      XCTAssertTrue(json.contains("\"id\":1"))
      XCTAssertTrue(json.contains("\"error\":{"))
      XCTAssertTrue(json.contains("\"code\":-32600"))
    }
    
    do {
      let error = ErrorObject.methodNotFound(message: "method not found", data: nil)
      let encoder = JSONEncoder()
      let response = Response.error(id: Id.number(1), error: error)
      let jsonData = try encoder.encode(response)
      
      guard let json = String(data: jsonData, encoding: .utf8) else {
        XCTFail("Failed while converting Data to String.")
        return
      }
      
      XCTAssertTrue(json.contains("\"jsonrpc\":\"2.0\""))
      XCTAssertTrue(json.contains("\"id\":1"))
      XCTAssertTrue(json.contains("\"error\":{"))
      XCTAssertTrue(json.contains("\"code\":-32601"))
    }
    
    do {
      let error = ErrorObject.invalidParams(message: "invalid params", data: nil)
      let encoder = JSONEncoder()
      let response = Response.error(id: Id.number(1), error: error)
      let jsonData = try encoder.encode(response)
      
      guard let json = String(data: jsonData, encoding: .utf8) else {
        XCTFail("Failed while converting Data to String.")
        return
      }
      
      XCTAssertTrue(json.contains("\"jsonrpc\":\"2.0\""))
      XCTAssertTrue(json.contains("\"id\":1"))
      XCTAssertTrue(json.contains("\"error\":{"))
      XCTAssertTrue(json.contains("\"code\":-32602"))
    }
    
    do {
      let error = ErrorObject.internalError(message: "internal error", data: nil)
      let encoder = JSONEncoder()
      let response = Response.error(id: Id.number(1), error: error)
      let jsonData = try encoder.encode(response)
      
      guard let json = String(data: jsonData, encoding: .utf8) else {
        XCTFail("Failed while converting Data to String.")
        return
      }
      
      XCTAssertTrue(json.contains("\"jsonrpc\":\"2.0\""))
      XCTAssertTrue(json.contains("\"id\":1"))
      XCTAssertTrue(json.contains("\"error\":{"))
      XCTAssertTrue(json.contains("\"code\":-32603"))
    }
    
    do {
      let error = ErrorObject.raw(code: -1, message: "raw error", data: nil)
      let encoder = JSONEncoder()
      let response = Response.error(id: Id.number(1), error: error)
      XCTAssertThrowsError(try encoder.encode(response))
    }
  }
  
}
