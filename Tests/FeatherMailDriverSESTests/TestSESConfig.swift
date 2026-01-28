//
//  TestSESConfig.swift
//  feather-ses-mail
//
//  Created by Binary Birds on 2026. 01. 26..
//

struct TestSESConfig {
    let accessKeyId: String
    let secretAccessKey: String
    let region: String
    let from: String
    let to: String

    static func load() -> TestSESConfig {
        // NOTE: This test config is intentionally hardcoded and does not read
        // environment variables or .env files. These tests are integration
        // tests; fill in the values below locally when you want to run them.
        // Keep secrets out of source control.
        return TestSESConfig(
            accessKeyId: "",
            secretAccessKey: "",
            region: "",
            from: "",
            to: ""
        )
    }

    var isComplete: Bool {
        !accessKeyId.isEmpty
            && !secretAccessKey.isEmpty
            && !region.isEmpty
            && !from.isEmpty
            && !to.isEmpty
    }
}
