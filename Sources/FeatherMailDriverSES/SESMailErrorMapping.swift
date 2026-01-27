//
//  SESMailErrorMapping.swift
//  feather-mail-driver-ses
//
//  Created by gerp83 on 2025. 01. 16..
//

import Foundation
import FeatherMail
import SotoCore
import SotoSESv2

/// Maps Amazon SES errors to `MailError` values.
func mapSESError(_ error: Error) -> MailError {
    
    // MARK: - SES service-level errors (returned by SES)

    if let awsError = error as? AWSErrorType {
        return .custom("AWSErrorType - \(awsError.errorCode)")
    }

    // MARK: - Transport / networking

    if error is URLError {
        return .custom("SES - Transport/networking error")
    }
    
    

    return .unknown(error)
}
