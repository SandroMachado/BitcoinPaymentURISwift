# BitcoinPaymentURISwift

[![Build Status](https://travis-ci.org/SandroMachado/BitcoinPaymentURISwift.svg?branch=master)](https://travis-ci.org/SandroMachado/BitcoinPaymentURISwift)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

BitcoinPaymentURISwift is an open source library to handle the Bitcoin payment URI based on the [BIT 21](https://github.com/bitcoin/bips/blob/master/bip-0021.mediawiki). The purpose of this library is to provide a simpler way to the developers to integrate in their applications support for this URI Scheme to easily make payments.

# Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate BitcoinPaymentURISwift into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "SandroMachado/BitcoinPaymentURISwift" ~> 1.0.0
```

Run `carthage update` to build the framework and drag the built `BitcoinPaymentURI.framework` into your Xcode project.

# Usage

## Code

Parse the URI `bitcoin:175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W?amount=50&label=Luke-Jr&message=Donation%20for%20project%20xyz`.

```Swift
guard let bpuri = BitcoinPaymentURI.parse("bitcoin:175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W?amount=50&label=Luke-Jr&message=Donation%20for%20project%20xyz") else {
    return
}

bpuri.address? \\ 175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W
bpuri.amount? \\ 50
bpuri.label? \\ "Luke-Jr"
bpuri.message? \\ "Donation for project xyz"
bpuri.parameters?.count \\ 0
```

Generate the following URI `bitcoin:175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W?label=Luke-Jr&foo=bar&amount=50.0&message=Donation%20for%20project%20xyz&req-fiz=biz`

```Swift
let bpuri: BitcoinPaymentURI = BitcoinPaymentURI(build: {
            $0.address = "175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W"
            $0.amount = 50.0
            $0.label = "Luke-Jr"
            $0.message = "Donation for project xyz"

            var newParameters: [String: Parameter] = [:]

            newParameters["foo"] = Parameter(value: "bar", required: false)
            newParameters["fiz"] = Parameter(value: "biz", required: true)

            $0.parameters = newParameters
        })
```