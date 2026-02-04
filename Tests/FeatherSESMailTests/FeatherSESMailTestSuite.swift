//
//  FeatherSESMailTestSuite.swift
//  feather-ses-mail
//
//  Created by Tibor Bödecs on 2023. 01. 16..
//

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
import Testing
import FeatherMail
import FeatherSESMail
import SotoCore
import SotoSESv2

@Suite
struct FeatherSESMailTestSuite {

    // MARK: - Environment

    private let config = TestSESConfig.load()

    // MARK: - Helpers

    private func buildSES(
        accessKeyId: String? = nil,
        secretAccessKey: String? = nil,
        endpoint: String? = nil
    ) -> (SESv2, AWSClient) {
        let awsClient = AWSClient(
            credentialProvider: .static(
                accessKeyId: accessKeyId ?? config.accessKeyId,
                secretAccessKey: secretAccessKey ?? config.secretAccessKey
            ),
            logger: .init(label: "feather.ses.mail")
        )

        let ses = SESv2(
            client: awsClient,
            region: .init(rawValue: config.region),
            partition: .aws,
            endpoint: endpoint,
            timeout: nil,
            byteBufferAllocator: .init(),
            options: []
        )

        return (ses, awsClient)
    }

    private func runClient(
        accessKeyId: String? = nil,
        secretAccessKey: String? = nil,
        endpoint: String? = nil,
        _ closure: @escaping @Sendable (SESMailClient) async throws -> Void
    ) async throws {
        let (ses, awsClient) = buildSES(
            accessKeyId: accessKeyId,
            secretAccessKey: secretAccessKey,
            endpoint: endpoint
        )
        let client = SESMailClient(ses: ses)

        try await closure(client)
        try await awsClient.shutdown()
    }

    // MARK: - Tests

    @Test
    func sendPlainTextMail() async throws {
        try await runClient { client in

            let mail = Mail(
                from: .init(config.from),
                to: [.init(config.to)],
                subject: "SES Plain Text Test",
                body: .plainText("Hello from Feather SES client.")
            )

            try await client.send(mail)
        }
    }

    @Test
    func sendHTMLMail() async throws {
        try await runClient { client in

            let mail = Mail(
                from: .init(config.from),
                to: [.init(config.to)],
                subject: "SES HTML Test",
                body: .html("<strong>Hello</strong> from Feather SES client.")
            )

            try await client.send(mail)
        }
    }

    @Test
    func sendMailWithAttachment() async throws {
        try await runClient { client in

            let data = Array("Test attachment contents.".utf8)

            let mail = Mail(
                from: .init(config.from),
                to: [.init(config.to)],
                subject: "SES Attachment Test",
                body: .plainText("This mail contains an attachment."),
                attachments: [
                    .init(
                        name: "test.txt",
                        contentType: "text/plain",
                        data: data
                    )
                ]
            )

            try await client.send(mail)
        }
    }

    @Test
    func invalidMailFailsBeforeSending() async {
        do {
            try await runClient { client in

                let mail = Mail(
                    from: .init(" "),
                    to: [.init(config.to)],
                    subject: "Invalid sender",
                    body: .plainText("This should not be sent.")
                )
                do {
                    try await client.send(mail)
                    Issue.record("Expected validation error for invalid sender.")
                }
                catch {
                    if case let .validation(validationError) = error
                        as? MailError,
                        validationError == .invalidSender
                    {
                        #expect(true)
                    }
                    else {
                        Issue.record("Expected MailError.validation(.invalidSender).")
                    }
                }
            }
        }
        catch {
            Issue.record("Unexpected error from test setup.")
        }
    }

    @Test
    func validateInvalidSenderThrows() async {
        do {
            try await runClient { client in

                let mail = Mail(
                    from: .init(" "),
                    to: [.init("test@example.com")],
                    subject: "Invalid sender",
                    body: .plainText("This should not be sent.")
                )

                await #expect(throws: MailValidationError.invalidSender) {
                    try await client.validate(mail)
                }
            }
        }
        catch {
            Issue.record("Unexpected error from test setup.")
        }
    }

    @Test
    func invalidCredentialsMapToCustomMailError() async {
        do {
            try await runClient(
                accessKeyId: "invalid",
                secretAccessKey: "invalid"
            ) { client in
                let mail = Mail(
                    from: .init(config.from),
                    to: [.init(config.to)],
                    subject: "Invalid credentials",
                    body: .plainText("This should not be sent.")
                )

                do {
                    try await client.send(mail)
                    Issue.record("Expected invalid credentials error.")
                }
                catch {
                    if case let .custom(message) = error as? MailError,
                        message.hasPrefix("AWSErrorType - ")
                    {
                        #expect(true)
                    }
                    else {
                        Issue.record("Expected MailError.custom with AWSErrorType prefix.")
                    }
                }
            }
        }
        catch {
            Issue.record("Unexpected error from test setup.")
        }
    }

    @Test
    func validateValidMailSucceeds() async throws {
        try await runClient { client in

            let mail = Mail(
                from: .init("valid@example.com"),
                to: [.init("to@example.com")],
                subject: "Valid mail",
                body: .plainText("Body")
            )

            try await client.validate(mail)
        }
    }
}
