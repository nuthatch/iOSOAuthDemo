import UIKit
import XCTest

class SoundCloudAuthenticatorTests: XCTestCase {

    // MARK: - Tests

    func testBuildURL() {
        let url = subject().buildLoginURL()

        XCTAssertEqual(url.absoluteString,
            "https://soundcloud.com/connect?client_id=foo&client_secret=bar&redirect_uri=foo://sample&response_type=token&display=popup",
            "Login URL incorrect")
    }

    func testResultNilIfNotRedirectUrl() {
        let url = NSURL(string: "http://soundcloud.com/foo")!
        let result = subject().resultFromAuthenticationResponse(url)

        XCTAssertTrue(result == nil, "Result should be nil for non redirect URL")
    }

    func testResultSuccessWithToken() {
        let url = NSURL(string: "foo://sample?#access_token=1-91447-152254708-04e9df008828ee&expires_in=21599&scope=%2A")!
        let result = subject().resultFromAuthenticationResponse(url)!

        XCTAssertEqual(result.responseType, OAuthResponseType.Token, "Access token type incorrect")
        XCTAssertEqual(result.value, "1-91447-152254708-04e9df008828ee", "Access token value incorrect")
    }

    func testResultFailedIfNoAccessToken() {
        let url = NSURL(string: "foo://sample?#NOTOKEN=1-91447-152254708-04e9df008828ee&scope=%2A")!
        let result = subject().resultFromAuthenticationResponse(url)

        XCTAssertTrue(result == nil, "Missing token should have no auth result")
    }

    func testResultNilIfReturnURLIsNotFragment() {
        let url = NSURL(string: "foo://sample?access_token=1-91447-152254708-04e9df008828ee&scope=%2A")!
        let result = subject().resultFromAuthenticationResponse(url)

        XCTAssertTrue(result == nil, "Malformed URL should have no auth result")
    }

    func testResultSuccessWithCode() {
        let url = NSURL(string: "foo://scsample?code=e99fa100e527ff5ae932b54c004ba476#")!
        let result = subject(AuthResponseType.Code).resultFromAuthenticationResponse(url)!

        XCTAssertEqual(result.responseType, OAuthResponseType.Code, "Code URL should have code type")
        XCTAssertEqual(result.value, "e99fa100e527ff5ae932b54c004ba476", "Code URL should have code type")
    }

    func testResultFailedWithMalformedCode() {
        let url = NSURL(string: "foo://scsample?NOCODE=e99fa100e527ff5ae932b54c004ba476&blah#")!
        let result = subject(type: ResponseType.Code).resultFromAuthenticationResponse(url)

        XCTAssertTrue(result == nil, "Malformed code URL should return no response")
    }

    func testIsOAuthResponseTrueWithRedirectURL() {
        let url = NSURL(string: "foo://blah")!

        XCTAssertTrue(subject().isOAuthResponse(url), "Redirect URL should be matched")
    }

    func testIsOAuthResponseFalesWithOtherURL() {
        let url = NSURL(string: "http://blah")!

        XCTAssertFalse(subject().isOAuthResponse(url), "Redirect URL should be matched")
    }

    // MARK: - Helpers

    func subject(type: OAuthResponseType = .Token) -> SoundCloudAuthenticator {
        return SoundCloudAuthenticator(oauthState: fixtureOAuthState(type))
    }

    func fixtureOAuthState(type: OAuthResponseType) -> OAuthState {
        return OAuthState(
            clientId: "foo",
            clientSecret: "bar",
            redirectUri: "foo://sample",
            responseType: type)
    }

}
