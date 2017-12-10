////
////  ErrorObjectTests.swift
////  swift-language-server
////
////  Created by Alessandro Marzoli on 06/12/17.
////
//
//import XCTest
//@testable import JsonRPC
//
//extension ErrorObjectTests {
//
//  static var allTests = [
//    ("testDecodingErrorObject", testDecodingErrorObject),
//    ("testEncodingErrorObjectWithoutErrorData", testEncodingErrorObjectWithoutErrorData),
//    ("testEncodingErrorObjectWithPrimitiveErrorData", testEncodingErrorObjectWithPrimitiveErrorData)
//  ]
//
//}
//
//class ErrorObjectTests: XCTestCase {
//
//  // MARK: - Decoding
//
//  func testDecodingErrorObject() throws {
//
//    /// defined
//    do {
//      let json = """
//          {"code": -32601, "message": "Method not found"}
//          """.data(using: .utf8)!
//
//      let error = try JSONDecoder().decode(ErrorObject.self, from: json)
//      switch error {
//      case .methodNotFound(message: let message, data: let errorData):
//        XCTAssertTrue(error.code == -32601)
//        XCTAssertTrue(message == "Method not found")
//        XCTAssertNil(errorData)
//      default:
//        XCTFail("Unexpected error type.")
//      }
//    }
//
//    /// defined with primitive error data
//    do {
//      let json = """
//          {"code": -32600, "message": "Invalid Request", "data": "hello"}
//          """.data(using: .utf8)!
//
//      let error = try JSONDecoder().decode(ErrorObject.self, from: json)
//      switch error {
//      case .invalidRequest(message: let message, data: let errorData):
//        XCTAssertTrue(error.code == -32600)
//        XCTAssertTrue(message == "Invalid Request")
//        XCTAssertNotNil(errorData)
//        switch errorData! {
//        case .primitive(value: let value):
//          XCTAssert(value as! String == "hello")
//        default:
//          XCTFail("Unexpected error data type.")
//        }
//      default:
//        XCTFail("Unexpected error type.")
//      }
//    }
//
//    /// defined with structured error data
//    do {
//      let json = """
//          {"code": -32600, "message": "Invalid Request", "data": {"value": 23, "nilValue": null}}
//          """.data(using: .utf8)!
//
//      let error = try JSONDecoder().decode(ErrorObject.self, from: json)
//      switch error {
//      case .invalidRequest(message: let message, data: let errorData):
//        XCTAssertTrue(error.code == -32600)
//        XCTAssertTrue(message == "Invalid Request")
//        XCTAssertNotNil(errorData)
//        switch errorData! {
//        case .structured(object: let value):
//          XCTAssert(value["value"] as! Int == 23)
//        default:
//          XCTFail("Unexpected error data type.")
//        }
//      default:
//        XCTFail("Unexpected error type.")
//      }
//    }
//
//    /// custom
//    do {
//      let json = """
//          {"code": -32098, "message": "Custom error"}
//          """.data(using: .utf8)!
//
//      let error = try JSONDecoder().decode(ErrorObject.self, from: json)
//      switch error {
//      case .raw(code: let code, message: let message, data: let errorData):
//        XCTAssertTrue(code == -32098)
//        XCTAssertTrue(message == "Custom error")
//        XCTAssertNil(errorData)
//      default:
//        XCTFail("Unexpected error type.")
//      }
//    }
//
//    /// invalid
//    do {
//      let json = """
//          {"code": -42098, "message": "Custom error"}
//          """.data(using: .utf8)!
//
//      XCTAssertThrowsError(try JSONDecoder().decode(ErrorObject.self, from: json))
//    }
//
//    /// invalid with data
//    do {
//      let json = """
//          {"code": -42098, "message": "Custom error", "data": {"value": 23}}
//          """.data(using: .utf8)!
//
//      XCTAssertThrowsError(try JSONDecoder().decode(ErrorObject.self, from: json))
//    }
//
//  }
//
//  // MARK: - Encoding
//
//  func testEncodingErrorObjectWithPrimitiveErrorData() throws {
//
//    /// with primitive error data
//    do {
//      let error = ErrorObject.internalError(message: "Internal error", data: ErrorData.primitive(value: 10))
//      let encoder = JSONEncoder()
//      let errorData = try encoder.encode(error)
//
//      guard let json = String(data: errorData, encoding: .utf8) else {
//        XCTFail("Failed while converting Data to String.")
//        return
//      }
//
//      XCTAssertTrue(json.contains("\"message\":\"Internal error\""))
//      XCTAssertTrue(json.contains("\"data\":10"))
//      XCTAssertTrue(json.contains("\"code\":-32603"))
//    }
//
//    /// invalid code
//    do {
//      let error = ErrorObject.raw(code: 11, message: "invalid valid", data: nil)
//      let encoder = JSONEncoder()
//      XCTAssertThrowsError(try encoder.encode(error))
//    }
//  }
//
//  func testEncodingErrorObjectWithoutErrorData() throws {
//    /// without error data
//    do {
//      let error = ErrorObject.parseError(message: "", data: nil)
//      let encoder = JSONEncoder()
//      let errorData = try encoder.encode(error)
//
//      guard let json = String(data: errorData, encoding: .utf8) else {
//        XCTFail("Failed while converting Data to String.")
//        return
//      }
//
//      XCTAssertTrue(json.contains("\"message\":\"\""))
//      XCTAssertFalse(json.contains("data"))
//      XCTAssertTrue(json.contains("\"code\":-32700"))
//    }
//  }
//
//
//  func testEncodingErrorObjectWithStructuredErrorData() throws {
//
//    /// with structured error data
//    do {
//      let error = ErrorObject.internalError(message: "Internal error", data: ErrorData.structured(object: ["key1": true, "key2": 3]))
//      let encoder = JSONEncoder()
//      let errorData = try encoder.encode(error)
//
//      guard let json = String(data: errorData, encoding: .utf8) else {
//        XCTFail("Failed while converting Data to String.")
//        return
//      }
//
//      XCTAssertTrue(json.contains("\"message\":\"Internal error\""))
//      XCTAssertTrue(json.contains("\"data\":{"))
//      XCTAssertTrue(json.contains("\"key1\":true"))
//      XCTAssertTrue(json.contains("\"key2\":3"))
//      XCTAssertTrue(json.contains("\"code\":-32603"))
//    }
//
//    /// invalid code
//    do {
//      let error = ErrorObject.raw(code: 11, message: "invalid valid", data: ErrorData.structured(object: ["key1": true, "key2": 3]))
//      let encoder = JSONEncoder()
//      XCTAssertThrowsError(try encoder.encode(error))
//    }
//  }
//
//}

