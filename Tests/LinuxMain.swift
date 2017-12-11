import XCTest
@testable import JsonRPCTests

XCTMain([
  testCase(RequestTests.allTests),
  testCase(ResponseTests.allTests),
  testCase(IdTests.allTests),
  testCase(ErrorOjectTests.allTests)
  ])
