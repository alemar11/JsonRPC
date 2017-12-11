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
  extension ErrorOjectTests {
    static var allTests = [
      ("testPredefinedCase", testPredefinedCase),
      ("testInitializationRawError", testInitializationRawError)
    ]
  }
#endif

class ErrorOjectTests: XCTestCase {
  
  func testPredefinedCase() throws {
    do {
      let error = ErrorObject.parseError(message: "message 1", data: nil)
      XCTAssertTrue(error.code == -32700)
      XCTAssertTrue(error.message == "message 1")
      XCTAssertNil(error.data)
    }
    do {
      let error = ErrorObject.invalidRequest(message: "message 2", data: nil)
      XCTAssertTrue(error.code == -32600)
      XCTAssertTrue(error.message == "message 2")
      XCTAssertNil(error.data)
    }
    do {
      let error = ErrorObject.methodNotFound(message: "message 3", data: nil)
      XCTAssertTrue(error.code == -32601)
      XCTAssertTrue(error.message == "message 3")
      XCTAssertNil(error.data)
    }
    do {
      let error = ErrorObject.invalidParams(message: "message 4", data: nil)
      XCTAssertTrue(error.code == -32602)
      XCTAssertTrue(error.message == "message 4")
      XCTAssertNil(error.data)
    }
    do {
      let error = ErrorObject.internalError(message: "message 4", data: nil)
      XCTAssertTrue(error.code == -32603)
      XCTAssertTrue(error.message == "message 4")
      XCTAssertNil(error.data)
    }
    do {
      let error = ErrorObject.raw(code: -31990, message: "message 4", data: nil)
      XCTAssertTrue(error.code == -31990)
      XCTAssertTrue(error.message == "message 4")
      XCTAssertNil(error.data)
    }
  }
  
  func testInitializationRawError() {
    
    do {
      let error = ErrorObject(code: -32010)
      XCTAssertTrue(error?.message == "Server Error")
    }
    
  }
}
