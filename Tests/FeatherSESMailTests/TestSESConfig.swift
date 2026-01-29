//
//  TestSESConfig.swift
//  feather-ses-mail
//
//  Created by Binary Birds on 2026. 01. 26..
//

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

struct TestSESConfig {
    let accessKeyId: String
    let secretAccessKey: String
    let region: String
    let from: String
    let to: String

    static func load() -> TestSESConfig {
        // NOTE: Tests read from environment variables first and then fall back
        // to hardcoded values below.
        //
        // Environment variables (preferred):
        //   SES_ACCESS_KEY_ID
        //   SES_SECRET_ACCESS_KEY
        //   SES_REGION
        //   SES_FROM
        //   SES_TO
        //
        // To run integration tests locally without env vars, fill in the values
        // below. Keep secrets out of source control.
        let env = ProcessInfo.processInfo.environment
        return TestSESConfig(
            accessKeyId: env["SES_ACCESS_KEY_ID"] ?? "",
            secretAccessKey: env["SES_SECRET_ACCESS_KEY"] ?? "",
            region: env["SES_REGION"] ?? "",
            from: env["SES_FROM"] ?? "",
            to: env["SES_TO"] ?? ""
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
