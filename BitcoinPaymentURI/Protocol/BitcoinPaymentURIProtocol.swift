//
//  BitcoinPaymentURIProtocol.swift
//  BitcoinPaymentURI
//
//  Created by Sandro Machado on 12/07/16.
//  Copyright © 2016 Sandro. All rights reserved.
//

import Foundation

protocol BitcoinPaymentURIProtocol {
    
    var address: String? { get }
    
    var amount: Double? { get }
    
    var label: String? { get }
    
    var message: String? { get }
    
    var parameters: [String: Parameter]? { get }
    
}