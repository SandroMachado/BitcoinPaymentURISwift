//
//  BitcoinPaymentURI.swift
//  BitcoinPaymentURI
//
//  Created by Sandro Machado on 12/07/16.
//  Copyright © 2016 Sandro. All rights reserved.
//

import Foundation

/// The Bitcoin Payment URI.
open class BitcoinPaymentURI: BitcoinPaymentURIProtocol {
    
    /// Closure to do the builder.
    typealias buildBitcoinPaymentURIClosure = (BitcoinPaymentURI) -> Void
    
    fileprivate static let SCHEME = "bitcoin:"
    fileprivate static let PARAMETER_AMOUNT = "amount"
    fileprivate static let PARAMETER_LABEL = "label"
    fileprivate static let PARAMETER_MESSAGE = "message"
    fileprivate static let PARAMETER_REQUIRED_PREFIX = "req-"

    fileprivate var allParameters: [String: Parameter]?

    /// The address.
    open var address: String?
    
    /// The amount.
    open var amount: Double? {
        set(newValue) {
            guard let newValue = newValue else {
                return
            }
            
            self.allParameters?[BitcoinPaymentURI.PARAMETER_AMOUNT] = Parameter(value: String(newValue), required: false)
        }
        
        get {
            guard let parameters = self.allParameters, let amount = parameters[BitcoinPaymentURI.PARAMETER_AMOUNT]?.value else {
                return nil
            }
            
            return Double(amount)
        }
    }
    
    /// The label.
    open var label: String? {
        set(newValue) {
            guard let newValue = newValue else {
                return
            }
            
            self.allParameters?[BitcoinPaymentURI.PARAMETER_LABEL] = Parameter(value: newValue, required: false)
        }
        
        get {
            guard let parameters = self.allParameters, let label = parameters[BitcoinPaymentURI.PARAMETER_LABEL]?.value else {
                return nil
            }
            
            return label
        }
    }
    
    /// The message.
    open var message: String? {
        set(newValue) {
            guard let newValue = newValue else {
                return
            }
            
            self.allParameters?[BitcoinPaymentURI.PARAMETER_MESSAGE] = Parameter(value: newValue, required: false)
        }

        get {
            guard let parameters = self.allParameters, let label = parameters[BitcoinPaymentURI.PARAMETER_MESSAGE]?.value else {
                return nil
            }
            
            return label
        }
    }
    
    /// The parameters.
    open var parameters: [String: Parameter]? {
        set(newValue) {
            var newParameters: [String: Parameter] = [:]

            guard let allParameters = self.allParameters, let newValue = newValue else {
                return
            }
            
            for (key, value) in newValue {
                newParameters[key] = value
            }
            
            for (key, value) in allParameters {
                newParameters[key] = value
            }
            
            self.allParameters = newParameters
        }
        
        get {
            guard var parametersFiltered = self.allParameters else {
                return nil
            }
            
            parametersFiltered.removeValue(forKey: BitcoinPaymentURI.PARAMETER_AMOUNT)
            parametersFiltered.removeValue(forKey: BitcoinPaymentURI.PARAMETER_LABEL)
            parametersFiltered.removeValue(forKey: BitcoinPaymentURI.PARAMETER_MESSAGE)
            
            return parametersFiltered
        }
    }
    
    // The uri.
    open var uri: String? {
        get {
            var urlComponents = URLComponents()
            urlComponents.scheme = BitcoinPaymentURI.SCHEME.replacingOccurrences(of: ":", with: "");
            urlComponents.path = self.address!;
            urlComponents.queryItems = []
            
            guard let allParameters = self.allParameters else {
                return urlComponents.string
            }
            
            for (key, value) in allParameters {
                if (value.required) {
                    urlComponents.queryItems?.append(URLQueryItem(name: "\(BitcoinPaymentURI.PARAMETER_REQUIRED_PREFIX)\(key)", value: value.value))
                    
                    continue
                }
                
                urlComponents.queryItems?.append(URLQueryItem(name: key, value: value.value))
            }
            
            return urlComponents.string
        }
    }
    
    /**
      Constructor.
     
      - parameter build: The builder to generate a BitcoinPaymentURI.
    */
    init(build: buildBitcoinPaymentURIClosure) {
        allParameters = [:]

        build(self)
    }
    
    /**
      Converts a String to a BitcoinPaymentURI.
     
      - parameter bitcoinPaymentURI: The string with the Bitcoin Payment URI.
     
      - returns: a BitcoinPaymentURI.
    */
    open static func parse(_ bitcoinPaymentURI: String) -> BitcoinPaymentURI? {
        let schemeRange = Range<String.Index>(bitcoinPaymentURI.characters.index(bitcoinPaymentURI.startIndex, offsetBy: 0)..<bitcoinPaymentURI.characters.index(bitcoinPaymentURI.startIndex, offsetBy: SCHEME.characters.count))
        let paramReqRange = Range<String.Index>(bitcoinPaymentURI.characters.index(bitcoinPaymentURI.startIndex, offsetBy: 0)..<bitcoinPaymentURI.characters.index(bitcoinPaymentURI.startIndex, offsetBy: PARAMETER_REQUIRED_PREFIX.characters.count))

        guard let _ = bitcoinPaymentURI.range(of: SCHEME, options: NSString.CompareOptions.caseInsensitive, range: schemeRange) else {
            return nil
        }
        
        let urlComponents = URLComponents(string: String(bitcoinPaymentURI))
        
        guard let address = urlComponents?.path, !address.isEmpty else {
            return nil
        }
        
        return BitcoinPaymentURI(build: {
            $0.address = address
            var newParameters: [String: Parameter] = [:]
            
            if let queryItems = urlComponents?.queryItems {
                for queryItem in queryItems {
                    guard let value = queryItem.value else {
                        continue
                    }
                    
                    var required: Bool = true
                    
                    if (queryItem.name.characters.count <= PARAMETER_REQUIRED_PREFIX.characters.count || queryItem.name.range(of: PARAMETER_REQUIRED_PREFIX, options: NSString.CompareOptions.caseInsensitive, range: paramReqRange) == nil) {
                        required = false
                    }
                    
                    newParameters[queryItem.name.replacingOccurrences(of: PARAMETER_REQUIRED_PREFIX, with: "")] = Parameter(value: value, required: required)
                }
            }
            
            $0.parameters = newParameters
        })
    }

}
