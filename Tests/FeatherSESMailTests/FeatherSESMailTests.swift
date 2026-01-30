//
//  FeatherSESMailTests.swift
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

@Suite
struct FeatherSESMailTests {

    // MARK: - Environment

    private let config = TestSESConfig.load()

    // MARK: - Helpers

    private func makeDriver() -> SESMailDriver {
        let client = AWSClient(
            credentialProvider: .static(
                accessKeyId: config.accessKeyId,
                secretAccessKey: config.secretAccessKey
            ),
            logger: .init(label: "aws.ses")
        )

        let driver = SESMailDriver(
            client: client,
            region: .init(rawValue: config.region)
        )

        return driver
    }

    // MARK: - Tests

    @Test
    func sendPlainTextMail() async throws {
        let driver = makeDriver()
        defer { Task { try? await driver.shutdown() } }

        let mail = Mail(
            from: .init(config.from),
            to: [.init(config.to)],
            subject: "SES Plain Text Test",
            body: .plainText("Hello from Feather SES driver.")
        )

        try await driver.send(mail)
    }

    @Test
    func sendHTMLMail() async throws {
        let driver = makeDriver()
        defer { Task { try? await driver.shutdown() } }

        let mail = Mail(
            from: .init(config.from),
            to: [.init(config.to)],
            subject: "SES HTML Test",
            body: .html("<strong>Hello</strong> from Feather SES driver.")
        )

        try await driver.send(mail)
    }

    @Test
    func sendMailWithAttachment() async throws {
        let driver = makeDriver()
        defer { Task { try? await driver.shutdown() } }

        let data = Array("Test attachment contents.\n".utf8)

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

        try await driver.send(mail)
    }

    @Test
    func invalidMailFailsBeforeSending() async {
        let driver = makeDriver()
        defer { Task { try? await driver.shutdown() } }

        let mail = Mail(
            from: .init(" "),
            to: [.init(config.to)],
            subject: "Invalid sender",
            body: .plainText("This should not be sent.")
        )
        do {
            try await driver.send(mail)
            #expect(Bool(false))
        }
        catch {
            if case let .validation(validationError) = error,
                validationError == .invalidSender
            {
                #expect(true)
            }
            else {
                #expect(Bool(false))
            }
        }
    }

    @Test
    func validateInvalidSenderThrows() async {
        let driver = makeDriver()
        defer { Task { try? await driver.shutdown() } }

        let mail = Mail(
            from: .init(" "),
            to: [.init("test@example.com")],
            subject: "Invalid sender",
            body: .plainText("This should not be sent.")
        )

        await #expect(throws: MailValidationError.invalidSender) {
            try await driver.validate(mail)
        }
    }

    @Test
    func validateValidMailSucceeds() async throws {
        let driver = makeDriver()
        defer { Task { try? await driver.shutdown() } }

        let mail = Mail(
            from: .init("valid@example.com"),
            to: [.init("to@example.com")],
            subject: "Valid mail",
            body: .plainText("Body")
        )

        try await driver.validate(mail)
    }
}
