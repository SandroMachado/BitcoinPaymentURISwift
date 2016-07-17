//
//  BitcoinPaymentURI.swift
//  BitcoinPaymentURI
//
//  Created by Sandro Machado on 12/07/16.
//  Copyright © 2016 Sandro. All rights reserved.
//

import Foundation

/// The Bitcoin Payment URI.
public class BitcoinPaymentURI: BitcoinPaymentURIProtocol {
    
    /// Closure to do the builder.
    typealias buildBitcoinPaymentURIClosure = (BitcoinPaymentURI) -> Void
    
    private static let SCHEME = "bitcoin:"
    private static let PARAMETER_AMOUNT = "amount"
    private static let PARAMETER_LABEL = "label"
    private static let PARAMETER_MESSAGE = "message"
    private static let PARAMETER_REQUIRED_PREFIX = "req-"

    private var allParameters: [String: Parameter]?

    /// The address.
    public var address: String?
    
    /// The amount.
    public var amount: Double? {
        set(newValue) {
            guard let newValue = newValue else {
                return
            }
            
            self.allParameters?[BitcoinPaymentURI.PARAMETER_AMOUNT] = Parameter(value: String(newValue), required: false)
        }
        
        get {
            guard let parameters = self.allParameters, amount = parameters[BitcoinPaymentURI.PARAMETER_AMOUNT]?.value else {
                return nil
            }
            
            return Double(amount)
        }
    }
    
    /// The label.
    public var label: String? {
        set(newValue) {
            guard let newValue = newValue else {
                return
            }
            
            self.allParameters?[BitcoinPaymentURI.PARAMETER_LABEL] = Parameter(value: newValue, required: false)
        }
        
        get {
            guard let parameters = self.allParameters, label = parameters[BitcoinPaymentURI.PARAMETER_LABEL]?.value else {
                return nil
            }
            
            return label
        }
    }
    
    /// The message.
    public var message: String? {
        set(newValue) {
            guard let newValue = newValue else {
                return
            }
            
            self.allParameters?[BitcoinPaymentURI.PARAMETER_MESSAGE] = Parameter(value: newValue, required: false)
        }

        get {
            guard let parameters = self.allParameters, label = parameters[BitcoinPaymentURI.PARAMETER_MESSAGE]?.value else {
                return nil
            }
            
            return label
        }
    }
    
    /// The parameters.
    public var parameters: [String: Parameter]? {
        set(newValue) {
            var newParameters: [String: Parameter] = [:]

            guard let allParameters = self.allParameters, newValue = newValue else {
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
            
            parametersFiltered.removeValueForKey(BitcoinPaymentURI.PARAMETER_AMOUNT)
            parametersFiltered.removeValueForKey(BitcoinPaymentURI.PARAMETER_LABEL)
            parametersFiltered.removeValueForKey(BitcoinPaymentURI.PARAMETER_MESSAGE)
            
            return parametersFiltered
        }
    }
    
    // The uri.
    public var uri: String? {
        get {
            let urlComponents = NSURLComponents()
            urlComponents.scheme = BitcoinPaymentURI.SCHEME.stringByReplacingOccurrencesOfString(":", withString: "");
            urlComponents.path = self.address;
            urlComponents.queryItems = []
            
            guard let allParameters = self.allParameters else {
                return urlComponents.string
            }
            
            for (key, value) in allParameters {
                if (value.required) {
                    urlComponents.queryItems?.append(NSURLQueryItem(name: "\(BitcoinPaymentURI.PARAMETER_REQUIRED_PREFIX)\(key)", value: value.value))
                    
                    continue
                }
                
                urlComponents.queryItems?.append(NSURLQueryItem(name: key, value: value.value))
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
    public static func parse(bitcoinPaymentURI: String) -> BitcoinPaymentURI? {
        let schemeRange = Range<String.Index>(bitcoinPaymentURI.startIndex.advancedBy(0)..<bitcoinPaymentURI.startIndex.advancedBy(SCHEME.characters.count))
        let paramReqRange = Range<String.Index>(bitcoinPaymentURI.startIndex.advancedBy(0)..<bitcoinPaymentURI.startIndex.advancedBy(PARAMETER_REQUIRED_PREFIX.characters.count))

        guard let _ = bitcoinPaymentURI.rangeOfString(SCHEME, options: NSStringCompareOptions.CaseInsensitiveSearch, range: schemeRange) else {
            return nil
        }
        
        let urlComponents = NSURLComponents(string: String(bitcoinPaymentURI))
        
        guard let address = urlComponents?.path where !address.isEmpty else {
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
                    
                    if (queryItem.name.characters.count <= PARAMETER_REQUIRED_PREFIX.characters.count || queryItem.name.rangeOfString(PARAMETER_REQUIRED_PREFIX, options: NSStringCompareOptions.CaseInsensitiveSearch, range: paramReqRange) == nil) {
                        required = false
                    }
                    
                    newParameters[queryItem.name.stringByReplacingOccurrencesOfString(PARAMETER_REQUIRED_PREFIX, withString: "")] = Parameter(value: value, required: required)
                }
            }
            
            $0.parameters = newParameters
        })
    }

}