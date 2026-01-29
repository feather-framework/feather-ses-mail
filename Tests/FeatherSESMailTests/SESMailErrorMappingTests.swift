//
//  SESMailErrorMappingTests.swift
//  feather-ses-mail
//
//  Created by Binary Birds on 2026. 01. 27..
//

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
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
        #expect(mapped == .custom("AWSErrorType - BadRequestException"))
    }

    @Test
    func mapsURLErrorToCustom() {
        let error = URLError(.timedOut)
        let mapped = mapSESError(error)
        #expect(mapped == .custom("SES - Transport/networking error"))
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
