//
//  SESMailEncoder.swift
//  feather-mail-driver-ses
//
//  Created by gerp83 on 2025. 01. 16..
//

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
import FeatherMail

/// Encodes `Mail` values into base64-encoded MIME messages for Amazon SES.
///
/// `SESMailEncoder` wraps `RawMailEncoder` from FeatherMail and base64-encodes
/// the resulting raw MIME message, as required by SES raw email sending.
struct SESMailEncoder: Sendable {

    private let rawEncoder = RawMailEncoder()

    /// Encodes a mail into a base64-encoded MIME message.
    ///
    /// - Parameter mail: The mail to encode. The mail must be validated
    ///   before calling this method.
    /// - Returns: A base64-encoded MIME string suitable for SES raw email sending.
    /// - Throws: `MailError.mailEncodeError` if an unrecoverable encoding error
    ///   occurs during message construction.
    func encode(_ mail: Mail) throws(MailError) -> String {
        let dateHeader = formatDateHeader()
        let messageID = createMessageID(for: mail)
        let raw = try rawEncoder.encode(
            mail,
            dateHeader: dateHeader,
            messageID: messageID
        )

        guard let utf8 = raw.data(using: String.Encoding.utf8) else {
            throw MailError.validation(.mailEncodeError)
        }

        return utf8.base64EncodedString()
    }
}

// MARK: - Helpers

private extension SESMailEncoder {

    /// Formats a Date header value in RFC 2822 format.
    func formatDateHeader() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        return dateFormatter.string(from: Date())
    }

    /// Creates a message identifier.
    func createMessageID(for mail: Mail) -> String {
        let time = Date().timeIntervalSince1970
        return "<\(time)\(mail.from.email.drop { $0 != "@" })>"
    }

}
