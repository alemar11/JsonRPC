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
  extension RequestTests {
    static var allTests = [
      ("testDecodingRequestWithInvalidJsonRPCVersion", testDecodingRequestWithInvalidJsonRPCVersion),
      ("testDecodingRequestWithInvalidMethod", testDecodingRequestWithInvalidMethod),
      ("testDecodingRequestWithPositionalParameters", testDecodingRequestWithPositionalParameters),
      ("testDecodingRequestWithNamedParameters", testDecodingRequestWithNamedParameters),
      ("testDecodingNotificationWithPositionalParameters", testDecodingNotificationWithPositionalParameters),
      ("testDecodingNotificationWithNamedParameters", testDecodingNotificationWithNamedParameters),
      ("testEncodingRequestWithPositionalParameters", testEncodingRequestWithPositionalParameters),
      ("testEncodingNotificationWithoutParameters", testEncodingNotificationWithoutParameters),
      ("testEncodingNotificationWithNamedParameters", testEncodingNotificationWithNamedParameters)
    ]
  }
#endif

class RequestTests: XCTestCase {
  
  // MARK: - Decoding
  
  func testDecodingRequestWithInvalidJsonRPCVersion() throws {
    let json = """
          {"jsonrpc": "1.0", "method": "subtract", "params": [42, 23], "id": 1}
      """.data(using: .utf8)!
    
    XCTAssertThrowsError(try JSONDecoder().decode(Request.self, from: json))
  }
  
  func testDecodingRequestWithInvalidMethod() throws {
    do {
      let json = """
          {"jsonrpc": "2.0", "method": "", "params": [42, 23], "id": 1}
      """.data(using: .utf8)!
      XCTAssertThrowsError(try JSONDecoder().decode(Request.self, from: json))
    }
    
    do {
      let json = """
          {"jsonrpc": "2.0", "params": [42, 23], "id": 1}
      """.data(using: .utf8)!
      XCTAssertThrowsError(try JSONDecoder().decode(Request.self, from: json))
    }
  }
  
  func testDecodingRequestWithPositionalParameters() throws {
    let json = """
          {"jsonrpc": "2.0", "method": "subtract", "params": [42, 23], "id": 1}
      """.data(using: .utf8)!
    
    let request = try JSONDecoder().decode(Request.self, from: json)
    
    XCTAssertTrue(request.id == Id.number(1))
    XCTAssertTrue(request.method == "subtract")
    
    guard let parameters = request.params else {
      XCTAssertNotNil(request.params)
      return
    }
    
    switch parameters {
    case .positional(let parameters):
      XCTAssertTrue(parameters.count == 2)
      XCTAssertTrue(parameters.first! as! Int == 42)
      XCTAssertTrue(parameters.last! as! Int == 23)
    default:
      XCTFail()
    }
    
  }
  
  func testDecodingRequestWithNamedParameters() throws {
    do {
      let json = """
        {"jsonrpc": "2.0", "method": "subtract", "params": {"subtrahend": 23, "minuend": 42}, "id": 3}
    """.data(using: .utf8)!
      
      let request = try JSONDecoder().decode(Request.self, from: json)
      
      XCTAssertTrue(request.id == Id.number(3))
      XCTAssertTrue(request.method == "subtract")
      
      guard let parameters = request.params else {
        XCTAssertNotNil(request.params)
        return
      }
      
      switch parameters {
      case .named(let parameters):
        XCTAssertTrue(parameters["subtrahend"] as! Int == 23)
        XCTAssertTrue(parameters["minuend"] as! Int == 42)
      default:
        XCTFail()
      }
    }
    
    do {
      let json = """
        {"jsonrpc": "2.0", "method": "subtract", "params": {"value": 23, "text": "hello world", "bool": true}, "id": 3}
    """.data(using: .utf8)!
      
      let request = try JSONDecoder().decode(Request.self, from: json)
      
      XCTAssertTrue(request.id == Id.number(3))
      XCTAssertTrue(request.method == "subtract")
      
      guard let parameters = request.params else {
        XCTAssertNotNil(request.params)
        return
      }
      
      switch parameters {
      case .named(let parameters):
        XCTAssertTrue(parameters["value"] as! Int == 23)
        XCTAssertTrue(parameters["text"] as! String == "hello world")
        XCTAssertTrue(parameters["bool"] as! Bool == true)
      default:
        XCTFail()
      }
    }
    
  }
  
  func testDecodingNotificationWithPositionalParameters() throws {
    let json = """
              {"jsonrpc": "2.0", "method": "update", "params": [1,2,3,4,5]}
              """.data(using: .utf8)!
    
    let request = try JSONDecoder().decode(Request.self, from: json)
    
    XCTAssertTrue(request.method == "update")
    XCTAssertNil(request.id)
    XCTAssertTrue(request.isNotification)
    
    guard let parameters = request.params else {
      XCTAssertNotNil(request.params)
      return
    }
    
    switch parameters {
    case .positional(let parameters):
      XCTAssertTrue(parameters.count == 5)
      XCTAssertTrue(parameters[0] as! Int == 1)
      XCTAssertTrue(parameters[1] as! Int == 2)
      XCTAssertTrue(parameters[2] as! Int == 3)
      XCTAssertTrue(parameters[3] as! Int == 4)
      XCTAssertTrue(parameters[4] as! Int == 5)
    default:
      XCTFail("It should be a notification.")
    }
    
  }
  
  func testDecodingNotificationWithNamedParameters() throws {
    do {
      let json = """
        {"jsonrpc": "2.0", "method": "subtract", "params": {"subtrahend": 23, "minuend": 42}}
    """.data(using: .utf8)!
      
      let request = try JSONDecoder().decode(Request.self, from: json)
      
      XCTAssertTrue(request.isNotification)
      XCTAssertTrue(request.method == "subtract")
      
      guard let parameters = request.params else {
        XCTAssertNotNil(request.params)
        return
      }
      
      switch parameters {
      case .named(let parameters):
        XCTAssertTrue(parameters["subtrahend"] as! Int == 23)
        XCTAssertTrue(parameters["minuend"] as! Int == 42)
      default:
        XCTFail()
      }
    }
    
    do {
      let json = """
        {"jsonrpc": "2.0", "method": "subtract", "params": {"value": 23, "text": "hello world", "bool": true}}
    """.data(using: .utf8)!
      
      let request = try JSONDecoder().decode(Request.self, from: json)
      
      XCTAssertTrue(request.isNotification)
      XCTAssertTrue(request.method == "subtract")
      
      guard let parameters = request.params else {
        XCTAssertNotNil(request.params)
        return
      }
      
      switch parameters {
      case .named(let parameters):
        XCTAssertTrue(parameters["value"] as! Int == 23)
        XCTAssertTrue(parameters["text"] as! String == "hello world")
        XCTAssertTrue(parameters["bool"] as! Bool == true)
      default:
        XCTFail()
      }
    }
    
  }
  
  // MARK: - Encoding
  
  func testEncodingRequestWithPositionalParameters() throws {
    do {
      let request = Request(method: "test", id: Id.number(11), params: Parameters.positional(array: [1, 2, true, "hello"]))
      let encoder = JSONEncoder()
      let jsonData = try encoder.encode(request)
      
      guard let json = String(data: jsonData, encoding: .utf8) else {
        XCTFail("Failed while converting Data to String.")
        return
      }
      
      XCTAssertTrue(json.contains("\"jsonrpc\":\"2.0"))
      XCTAssertTrue(json.contains("\"method\":\"test"))
      XCTAssertTrue(json.contains("\"id\":11"))
      XCTAssertTrue(json.contains("\"params\":[1,2,true,\"hello\"]"))
    }
    
    do {
      let request = Request(method: "test2", id: Id.string("customId"), params: Parameters.positional(array: [1, 2, true, ["hello", 3]]))
      let encoder = JSONEncoder()
      let jsonData = try encoder.encode(request)
      
      guard let json = String(data: jsonData, encoding: .utf8) else {
        XCTFail("Failed while converting Data to String.")
        return
      }
      
      XCTAssertTrue(json.contains("\"jsonrpc\":\"2.0"))
      XCTAssertTrue(json.contains("\"method\":\"test2"))
      XCTAssertTrue(json.contains("\"id\":\"customId\""))
      XCTAssertTrue(json.contains("\"params\":[1,2,true,[\"hello\",3]]"))
    }
    
    do {
      let request = Request(method: "test3", id: Id.number(0), params: Parameters.positional(array: [1, 2, true, ["subtrahend": 23, "minuend": 42]]))
      let encoder = JSONEncoder()
      let jsonData = try encoder.encode(request)
      
      guard let json = String(data: jsonData, encoding: .utf8) else {
        XCTFail("Failed while converting Data to String.")
        return
      }
      
      XCTAssertTrue(json.contains("\"jsonrpc\":\"2.0"))
      XCTAssertTrue(json.contains("\"method\":\"test3"))
      XCTAssertTrue(json.contains("\"id\":0"))
      XCTAssertTrue(json.contains("\"params\":"))
      XCTAssertTrue(json.contains("[1,2,true,"))
      XCTAssertTrue(json.contains("\"minuend\":42"))
      XCTAssertTrue(json.contains("\"subtrahend\":23"))
    }
    
    do {
      let request = Request(method: "test3", id: Id.string("0"), params: Parameters.positional(array: [1, true, ["key1": "k1", "key2": 2, "key3": [0,3,["subKey1": true, "subKey2": 12]]]]))
      let encoder = JSONEncoder()
      let jsonData = try encoder.encode(request)
      
      guard let json = String(data: jsonData, encoding: .utf8) else {
        XCTFail("Failed while converting Data to String.")
        return
      }
      
      XCTAssertTrue(json.contains("\"jsonrpc\":\"2.0"))
      XCTAssertTrue(json.contains("\"method\":\"test3"))
      XCTAssertTrue(json.contains("\"id\":\"0\""))
      XCTAssertTrue(json.contains("\"params\":["))
      XCTAssertTrue(json.contains("[1,true"))
      XCTAssertTrue(json.contains("\"key1\":\"k1\""))
      XCTAssertTrue(json.contains("\"key3\":[0,3,{"))
      XCTAssertTrue(json.contains("\"subKey2\":12"))
      XCTAssertTrue(json.contains("\"subKey1\":true"))
      
    }
    
  }
  
  func testEncodingNotificationWithoutParameters() throws {
    do {
      let request = Request(method: "123", id: nil,  params: nil)
      let encoder = JSONEncoder()
      let jsonData = try encoder.encode(request)
      
      guard let json = String(data: jsonData, encoding: .utf8) else {
        XCTFail("Failed while converting Data to String.")
        return
      }
      
      XCTAssertTrue(json.contains("\"jsonrpc\":\"2.0"))
      XCTAssertTrue(json.contains("\"method\":\"123"))
      XCTAssertFalse(json.contains("id"))
      XCTAssertFalse(json.contains("params"))
    }
  }
  
  func testEncodingNotificationWithNamedParameters() throws {
    do {
      let request = Request(method: "123", id: nil,  params: Parameters.named(object: ["subtrahend": 23, "minuend": 42]))
      let encoder = JSONEncoder()
      let jsonData = try encoder.encode(request)
      
      guard let json = String(data: jsonData, encoding: .utf8) else {
        XCTFail("Failed while converting Data to String.")
        return
      }
      
      XCTAssertTrue(json.contains("\"jsonrpc\":\"2.0"))
      XCTAssertTrue(json.contains("\"method\":\"123"))
      XCTAssertFalse(json.contains("id"))
      XCTAssertTrue(json.contains("\"params\":{"))
      XCTAssertTrue(json.contains("\"minuend\":42"))
      XCTAssertTrue(json.contains("\"subtrahend\":23"))
    }
    
    do {
      let request = Request(method: "123", id: nil,  params: Parameters.named(object: ["subtrahend": 23, "minuend": 42, "other":[1,2,3]]))
      let encoder = JSONEncoder()
      let jsonData = try encoder.encode(request)
      
      guard let json = String(data: jsonData, encoding: .utf8) else {
        XCTFail("Failed while converting Data to String.")
        return
      }
      
      XCTAssertTrue(json.contains("\"jsonrpc\":\"2.0"))
      XCTAssertTrue(json.contains("\"method\":\"123"))
      XCTAssertFalse(json.contains("id"))
      XCTAssertTrue(json.contains("\"params\":{"))
      XCTAssertTrue(json.contains("\"other\":[1,2,3]"))
      XCTAssertTrue(json.contains("\"minuend\":42"))
      XCTAssertTrue(json.contains("\"subtrahend\":23"))
    }
  }
  
}
