//
//  SESMailDriver.swift
//  feather-mail-driver-ses
//
//  Created by gerp83 on 2025. 01. 16..
//

import Foundation
import FeatherMail
import SotoCore
import SotoSESv2
import Logging

/// A mail driver implementation backed by Amazon SES.
///
/// `SESMailDriver` is intended to be initialized once during server startup
/// and reused for the lifetime of the application. It validates mails,
/// encodes them into SES-compatible MIME messages, and delivers them using
/// the Amazon SES v2 API.
///
/// The driver owns an underlying `AWSClient` and an `SESv2` client instance.
/// These resources are created during initialization and must be explicitly
/// shut down when the server stops.
public struct SESMailDriver: MailClient, Sendable {
    
    /// Validator used to validate mails before sending.
    private let validator: MailValidator

    /// Encoder used to convert mails into SES-compatible MIME messages.
    private let encoder = SESMailEncoder()

    /// Amazon SES client used for mail delivery.
    private let ses: SESv2

    /// Underlying AWS client.
    private let client: AWSClient

    /// Logger used for Amazon SES operations.
    private let logger: Logger

    /// Creates a new Amazon SES mail driver.
    ///
    /// This initializer should typically be called during server startup.
    /// The resulting driver instance is expected to live for the entire
    /// lifetime of the application.
    ///
    /// - Parameters:
    ///   - client: A configured `AWSClient` instance. The driver takes
    ///     ownership of this client and will shut it down when requested.
    ///   - region: The AWS region where SES is hosted.
    ///   - partition: The AWS partition to use (defaults to `.aws`).
    ///   - endpoint: An optional custom SES endpoint.
    ///   - timeout: An optional request timeout.
    ///   - byteBufferAllocator: Byte buffer allocator used by the AWS client.
    ///   - validator: Validator applied before delivery.
    ///   - logger: Logger used for SES request and transport logging.
    public init(
        client: AWSClient,
        region: Region,
        partition: AWSPartition = .aws,
        endpoint: String? = nil,
        timeout: TimeAmount? = nil,
        byteBufferAllocator: ByteBufferAllocator = .init(),
        validator: MailValidator = BasicMailValidator(maxTotalAttachmentSize: 7_500_000),
        logger: Logger = .init(label: "feather.mail.ses")
    ) {
        self.client = client
        self.validator = validator
        self.logger = logger

        // Construct SES client using the initializer
        self.ses = SESv2(
            client: client,
            region: region,
            partition: partition,
            endpoint: endpoint,
            timeout: timeout,
            byteBufferAllocator: byteBufferAllocator,
            options: []
        )
    }
    
    public func validate(_ mail: Mail) async throws(MailValidationError) {
        try await validator.validate(mail)
    }

    /// Sends a mail using Amazon SES.
    ///
    /// This method performs mail validation, MIME encoding, and delivery
    /// using the internally managed SES client. It does not create or
    /// tear down network resources.
    ///
    /// - Parameter email: The mail to send.
    /// - Throws: `MailError` if validation, encoding, or delivery fails
    public func send(_ mail: Mail) async throws(MailError) {
        do {
            try await validate(mail)
        } catch {
            throw .validation(error)
        }

        let encodedData = try encoder.encode(mail)

        let rawMessage = SESv2.RawMessage(
            data: AWSBase64Data.base64(encodedData)
        )
        let request = SESv2.SendEmailRequest(
            content: .init(
                raw: rawMessage
            )
        )

        do {
            //result is not used for now
            _ = try await ses.sendEmail(
                request,
                logger: logger
            )
        }
        catch {
            throw mapSESError(error)
        }
    }

    /// Shuts down the underlying AWS client.
    ///
    /// Call this when the server is stopping to release network
    /// resources and event loops.
    public func shutdown() async throws {
        try await client.shutdown()
    }
}
