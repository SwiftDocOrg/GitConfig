import XCTest
import GitConfig

final class ConfigurationTests: XCTestCase {
    func testExample() throws {
        let example = #"""
        # This is an example .git/config file
        [core]
            repositoryformatversion = 0
            filemode = true
            bare = false
            # equivalent to "blank-at-eol,blank-at-eof"
            whitespace = trailing-space

        # [unused]
        #   should-be-parsed = false

        [remote "origin"]
            url = git@github.com:SwiftDocOrg/GitConfig.git
            fetch = +refs/heads/*:refs/remotes/origin/*
            gh-resolved = base

        """#


        let configuration = try Configuration(example)
        XCTAssertEqual(configuration.sections.count, 2)

        let core = configuration.sections[0]
        XCTAssertEqual(configuration["core"], core)
        XCTAssertEqual(core.settings.count, 4)
        XCTAssertEqual(core.settings.first?.key, "repositoryformatversion")
        XCTAssertEqual(core["repositoryformatversion"], 0)
        XCTAssertEqual(core["filemode"], true)
        XCTAssertEqual(core["bare"], false)
        XCTAssertEqual(core["whitespace"], "trailing-space")

        let remote = configuration.sections[1]
        XCTAssertEqual(configuration["remote \"origin\""], remote)
        XCTAssertEqual(remote.settings.count, 3)
        XCTAssertEqual(remote["url"], "git@github.com:SwiftDocOrg/GitConfig.git")
        XCTAssertEqual(remote["fetch"], "+refs/heads/*:refs/remotes/origin/*")
        XCTAssertEqual(remote["gh-resolved"], "base")
    }

    func testInvalid() throws {
        let invalid = #"""
        # This is an invalid .git/config file
        Ceci n'est pas une configuration

        """#


        XCTAssertThrowsError(try Configuration(invalid)) { (error) in
            guard case Configuration.Error.invalidLine(let n) = error else {
                return XCTFail("should throw Configuration.Error")
            }

            XCTAssertEqual(n, 2)
        }
    }
}
