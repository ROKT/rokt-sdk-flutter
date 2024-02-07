//
//  Configuration.swift
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

import UIKit

internal enum Environment: String {
    case Mock = "MOCK"
    case Stage = "STAGE"
    case Prod = "PROD"
    case ProdDemo = "PRODDEMO"
    case Local
    var baseURL: String {
        switch self {
        case .Mock: return ""
        case .Stage: return "https://mobile-api.stage.rokt.com"
        case .Prod: return "https://mobile-api.rokt.com"
        case .ProdDemo: return "https://mobile-api-demo.rokt.com"
        case .Local: return "http://localhost:9011"
        }
    }
}

internal struct Configuration {
    lazy var environment: Environment = {
        let podBundle = Bundle(for: Rokt.self)
        
        if let configuration = podBundle.object(forInfoDictionaryKey: "Configuration") as? String {
            if configuration.contains(Environment.Stage.rawValue) {
                return Environment.Stage
            } else if configuration.contains(Environment.ProdDemo.rawValue) {
                return Environment.ProdDemo
            } else if configuration.contains(Environment.Mock.rawValue) {
                return Environment.Mock
            }
        }
        
        return Environment.Prod
    }()
    
    static func getEnvironment(_ environment: RoktEnvironment?) -> Environment {
        switch environment {
        case .Stage: return Environment.Stage
        case .Prod: return Environment.Prod
        case .ProdDemo: return Environment.ProdDemo
        case .Local: return Environment.Local
        default: return Environment.Mock
        }
    }
}
