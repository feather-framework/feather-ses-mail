# Feather Mail Driver SES

Amazon SES-backed mail driver for Feather Mail.

![Release: 1.0.0-beta.1](https://img.shields.io/badge/Release-1%2E0%2E0--beta%2E1-F05138)

## Features

- SES v2 delivery via Soto
- MIME message encoding using Feather Mail raw encoder
- Validates mail before delivery
- Supports text, HTML, and attachments

## Requirements

![Swift 6.1+](https://img.shields.io/badge/Swift-6%2E1%2B-F05138)
![Platforms: macOS](https://img.shields.io/badge/Platforms-macOS-F05138)

- Swift 6.1+
- Platforms:
    - macOS 10.15+

## Installation

Use Swift Package Manager; add the dependency to your `Package.swift` file:

```swift
.package(url: "https://github.com/feather-framework/feather-mail-driver-ses", .upToNextMinor(from: "1.0.0-beta.1")),
```

Then add `FeatherMailDriverSES` to your target dependencies:

```swift
.product(name: "FeatherMailDriverSES", package: "feather-mail-driver-ses"),
```

## Usage

![DocC API documentation](https://img.shields.io/badge/DocC-API_documentation-F05138)

API documentation is available at the official site:
https://feather-framework.github.io/feather-mail-driver-ses/

> [!WARNING]
> This repository is a work in progress, things can break until it reaches v1.0.0.


## Related repositories

- [Feather Mail](https://github.com/feather-framework/feather-mail)
- [Feather Mail Driver SMTP](https://github.com/feather-framework/feather-mail-driver-smtp)
- [Feather Mail Driver Memory](https://github.com/feather-framework/feather-memory-mail)

## Development

- Build: `swift build`
- Test:
    - local: `make test`
    - using Docker: `make docker-test`
- Format: `make format`
- Check: `make check`

## Contributing

[Pull requests](https://github.com/feather-framework/feather-mail-driver-ses/pulls) are welcome. Please keep changes focused and include tests for new logic.
