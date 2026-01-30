//
//  SESMailErrorMappingTests.swift
//  feather-ses-mail
//
//  Created by Binary Birds on 2026. 01. 27..
//

import Foundation
import Testing
import FeatherMail
import SotoCore
@testable import FeatherSESMail

@Suite
struct SESMailErrorMappingTests {

    struct DummyError: Error {}

    @Test
    func mapsAWSErrorTypeToCustom() {
        let error = AWSResponseError(errorCode: "BadRequestException")
        let mapped = mapSESError(error)
        if case let .custom(message) = mapped,
            message == "AWSErrorType - BadRequestException"
        {
            #expect(true)
        }
        else {
            #expect(Bool(false))
        }
    }

    @Test
    func mapsURLErrorToCustom() {
        let error = URLError(.timedOut)
        let mapped = mapSESError(error)
        if case let .custom(message) = mapped,
            message == "SES - Transport/networking error"
        {
            #expect(true)
        }
        else {
            #expect(Bool(false))
        }
    }

    @Test
    func mapsUnknownErrorToUnknown() {
        let mapped = mapSESError(DummyError())
        switch mapped {
        case .unknown:
            #expect(true)
        default:
            #expect(Bool(false))
        }
    }
}
