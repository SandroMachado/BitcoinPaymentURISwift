//
//  BitcoinPaymentURITests.swift
//  BitcoinPaymentURITests
//
//  Created by Sandro Machado on 12/07/16.
//  Copyright © 2016 Sandro. All rights reserved.
//

import XCTest
@testable import BitcoinPaymentURI

class BitcoinPaymentURITests: XCTestCase {
    
    func testParseForAddressMethod() {
        let bpuri = BitcoinPaymentURI.parse("bitcoin:175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W")
        
        XCTAssertEqual(bpuri?.address!, "175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W", "Failed: Wrong value.")
        XCTAssertNil(bpuri?.amount)
        XCTAssertNil(bpuri?.label)
        XCTAssertNil(bpuri?.message)
        XCTAssertEqual(bpuri?.parameters?.count, 0, "Failed: Wrong value.")
    }
    
    func testParseForAddressWithNameMethod() {
        let bpuri = BitcoinPaymentURI.parse("bitcoin:175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W?label=Luke-Jr")
        
        XCTAssertEqual(bpuri?.address!, "175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W", "Failed: Wrong value.")
        XCTAssertNil(bpuri?.amount)
        XCTAssertEqual(bpuri?.label, "Luke-Jr", "Failed: Wrong value.")
        XCTAssertNil(bpuri?.message)
        XCTAssertEqual(bpuri?.parameters?.count, 0, "Failed: Wrong value.")
    }
    
    func testParseForAddressWithAmountAndNameMethod() {
        let bpuri = BitcoinPaymentURI.parse("bitcoin:175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W?amount=20.3&label=Luke-Jr")
        
        XCTAssertEqual(bpuri?.address!, "175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W", "Failed: Wrong value.")
        XCTAssertEqual(bpuri?.amount, 20.3, "Failed: Wrong value.")
        XCTAssertEqual(bpuri?.label, "Luke-Jr", "Failed: Wrong value.")
        XCTAssertNil(bpuri?.message)
        XCTAssertEqual(bpuri?.parameters?.count, 0, "Failed: Wrong value.")
    }
    
    func testParseForAddressWithAmountAndNameAndMessageMethod() {
        let bpuri = BitcoinPaymentURI.parse("bitcoin:175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W?amount=50&label=Luke-Jr&message=Donation%20for%20project%20xyz")
        
        XCTAssertEqual(bpuri?.address!, "175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W", "Failed: Wrong value.")
        XCTAssertEqual(bpuri?.amount, 50, "Failed: Wrong value.")
        XCTAssertEqual(bpuri?.label, "Luke-Jr", "Failed: Wrong value.")
        XCTAssertEqual(bpuri?.message, "Donation for project xyz", "Failed: Wrong value.")
        XCTAssertEqual(bpuri?.parameters?.count, 0, "Failed: Wrong value.")
    }
    
    func testParseForAddressWithAmountAndNameAndMessageAndParametersMethod() {
        let bpuri = BitcoinPaymentURI.parse("bitcoin:175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W?somethingyoudontunderstand=50&somethingelseyoudontget=999&r=https%3A%2F%2Ffoo.com%2Fi%2F7BpFbVsnh5PUisfh&req-app=appname")
        
        XCTAssertEqual(bpuri?.address!, "175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W", "Failed: Wrong value.")
        XCTAssertNil(bpuri?.amount)
        XCTAssertNil(bpuri?.label)
        XCTAssertNil(bpuri?.message)
        XCTAssertEqual(bpuri?.parameters?.count, 4, "Failed: Wrong value.")
        XCTAssertEqual(bpuri?.parameters?["somethingyoudontunderstand"]?.value, "50", "Failed: Wrong value.")
        XCTAssertEqual(bpuri?.parameters?["somethingelseyoudontget"]?.value, "999", "Failed: Wrong value.")
        XCTAssertEqual(bpuri?.parameters?["r"]?.value, "https://foo.com/i/7BpFbVsnh5PUisfh", "Failed: Wrong value.")
        XCTAssertEqual(bpuri?.parameters?["app"]?.value, "appname", "Failed: Wrong value.")
        XCTAssertEqual(bpuri?.parameters?["app"]?.required, true, "Failed: Wrong value.")
    }
    
    func testParseForInvalidAddressesMethod() {
        let bpuri1 = BitcoinPaymentURI.parse("bitcoinX:175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W?somethingyoudontunderstand=50")
        let bpuri2 = BitcoinPaymentURI.parse("bitcoin175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W?somethingyoudontunderstand=50")
        let bpuri3 = BitcoinPaymentURI.parse("bitcoin:?somethingyoudontunderstand=50")

        XCTAssertNil(bpuri1)
        XCTAssertNil(bpuri2)
        XCTAssertNil(bpuri3)
    }
    
    func testBuilder() {
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
        
        XCTAssertEqual(bpuri.address!, "175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W", "Failed: Wrong value.")
        XCTAssertEqual(bpuri.amount, 50, "Failed: Wrong value.")
        XCTAssertEqual(bpuri.label, "Luke-Jr", "Failed: Wrong value.")
        XCTAssertEqual(bpuri.message, "Donation for project xyz", "Failed: Wrong value.")
        XCTAssertEqual(bpuri.parameters?.count, 2, "Failed: Wrong value.")
        XCTAssertEqual(bpuri.parameters?["foo"]?.value, "bar", "Failed: Wrong value.")
        XCTAssertEqual(bpuri.parameters?["foo"]?.required, false, "Failed: Wrong value.")
        XCTAssertEqual(bpuri.parameters?["fiz"]?.value, "biz", "Failed: Wrong value.")
        XCTAssertEqual(bpuri.parameters?["fiz"]?.required, true, "Failed: Wrong value.")
        XCTAssertEqual(bpuri.uri, "bitcoin:175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W?label=Luke-Jr&foo=bar&message=Donation%20for%20project%20xyz&amount=50.0&req-fiz=biz", "Failed: Wrong value.")
    }
    
}
