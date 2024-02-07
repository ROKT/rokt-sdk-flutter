//
//  BNFPlaceholderValidator.swift
//  Rokt-Widget
//
//  Copyright 2020 Rokt Pte Ltd
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import Foundation

protocol DataValidator {
    associatedtype T

    func isValid(data: T) -> Bool
}

/// Checks if a BNF-formatted String is correctly formatted
struct BNFPlaceholderValidator<Sanitiser: DataSanitiser>: DataValidator where Sanitiser.T == String {
    private let sanitiser: Sanitiser
    private let parser: PropertyChainDataParser

    init(
        sanitiser: Sanitiser = BNFDataSanitiser(),
        parser: PropertyChainDataParser = BNFPropertyChainDataParser()
    ) {
        self.sanitiser = sanitiser
        self.parser = parser
    }

    func isValid(data: String) -> Bool {
        // if the last character is '|', we exclude it from format validation
        var dataToCheck = data

        if let lastChar = dataToCheck.last, String(lastChar) == BNFSeparator.alternative.rawValue  {
            dataToCheck = String(dataToCheck.dropLast(1))
        }

        return areAllBindingsValid(placeholder: dataToCheck)
    }

    private func areAllBindingsValid(placeholder: String) -> Bool {
        let bindings = placeholder.components(separatedBy: BNFSeparator.alternative.rawValue)

        guard !bindings.isEmpty else { return false }

        var isValid = true
        for (index, binding) in bindings.enumerated() {
            // remove namespace
            // split by .
            if index == 0 {
                isValid = isValid &&
                            parser.namespaceIn(placeholder: binding) != nil &&
                            hasValidCharactersAndNamespace(binding: binding)
            }

            isValid = isValid && hasValidCharactersAndNamespace(binding: binding)
        }

        return isValid
    }

    private func hasValidCharactersAndNamespace(binding: String) -> Bool {
        var sanitisedBinding = sanitiser.sanitiseDelimiters(data: binding)
        if let namespace = parser.namespaceIn(placeholder: binding) {
            sanitisedBinding = sanitiser.sanitiseNamespace(data: sanitisedBinding, namespace: namespace)
        }

        let wordsInBinding = sanitisedBinding.components(separatedBy: BNFSeparator.namespace.rawValue)

        return wordsInBinding.reduce(true) { partialResult, word in
            partialResult && hasOnlyAlphaNumericOrSpace(binding: word)
        }
    }

    private func hasOnlyAlphaNumericOrSpace(binding: String) -> Bool {
        guard !binding.isEmpty else { return false }

        return binding.range(of: "[^a-zA-Z0-9 ]", options: .regularExpression) == nil
    }
}
