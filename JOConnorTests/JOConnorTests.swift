//
//  JOConnorTests.swift
//  JOConnorTests
//
//  Created by Matt Sencenbaugh on 6/16/17.
//  Copyright © 2017 mattsencenbaugh. All rights reserved.
//

import XCTest
import JOConnor

class User : Authable {
    func authorizationHeader() -> String? {
        return "TestJWTToken"
    }
}

class MockDecodable: Codable {
    let id: String?
    let content: String
    
    public init(id: String?, content: String) {
        self.id = id
        self.content = content
    }
}

class JOConnorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSharedInstanceInit() {
        let server = APIServer.sharedInstance
        XCTAssertNotNil(server)
    }
    
    func testAuthable() {
        let user = User.init()
        XCTAssertEqual("TestJWTToken", user.authorizationHeader())
    }
    
    func testInitializeApiRequest() {
        let request = APIRequest<MockDecodable>.init(absolutePath: "https://localhost:3000", verb: APIRequestVerb.get, postData: nil, user: nil);
        XCTAssertNotNil(request)
    }
    
}
