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

#if os(Linux)
  extension ResponseTests {
    static var allTests = [
      ("testDecodingSuccessResponse", testDecodingSuccessResponse),
      ("testDecodingErrorResponse", testDecodingErrorResponse),
      ("testEncodingSuccessResponse", testEncodingSuccessResponse),
      ]
  }
  
#endif

class ResponseTests: XCTestCase {
  
  // MARK: - Decoding
  
  func testDecodingSuccessResponse() throws {
    /// int result
    do {
      let json = """
          {"jsonrpc": "2.0", "result": 19, "id": 4}
      """.data(using: .utf8)!
      let response = try JSONDecoder().decode(Response.self, from: json)
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
  
}
