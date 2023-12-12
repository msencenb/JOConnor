import XCTest
@testable import JOConnor

// Classes needed for testing / mocking
class User : Authable {
    func authorizationHeader() -> String? {
        return "TestJWTToken"
    }
    
    func extraHeaders() -> [Header] {
        return [
            Header.init(name: "SomethingImportant", value: "1")
        ]
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

// This is an example of what a post data object might look like for a login request with Rails strong params
class SessionPostData : PostData {
    let email: String?
    let password: String?
    
    init(email: String?, password: String?) {
        self.email = email
        self.password = password
        super.init()
    }
    
    enum CodingKeys: String, CodingKey {
        case user
    }
    
    enum UserKeys: String, CodingKey {
        case email
        case password
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        var userKeys = container.nestedContainer(keyedBy: UserKeys.self, forKey: .user)
        try userKeys.encode(email, forKey: .email)
        try userKeys.encode(password, forKey: .password)
    }
}


final class JOConnorTests: XCTestCase {
    func testSharedInstanceInit() {
        let server = APIServer.sharedInstance
        XCTAssertNotNil(server)
    }
    
    func testAuthable() {
        let user = User.init()
        XCTAssertEqual("TestJWTToken", user.authorizationHeader())
        let header = user.extraHeaders().first
        XCTAssertEqual(header?.name, "SomethingImportant")
        XCTAssertEqual(header?.value, "1")
    }
    
    func testInitializeApiRequest() {
        let request = APIRequest<MockDecodable>.init(absolutePath: "https://localhost:3000", verb: APIRequestVerb.get, postData: nil, user: nil, decodingStrategy: nil);
        XCTAssertNotNil(request)
    }
    
    func testInitializePostDataSubclass() {
        let sessionPostData = SessionPostData.init(email: "testingtesting", password: "terrible_password")
        XCTAssertNotNil(sessionPostData)
    }
    
    static var allTests = [
        ("testSharedInstanceInit", testSharedInstanceInit),
        ("testAuthable", testAuthable),
        ("testInitializeApiRequest", testInitializeApiRequest),
        ("testInitializePostDataSubclass", testInitializePostDataSubclass)
    ]
}
