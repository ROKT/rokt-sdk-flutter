//
//  LayoutVariantModel.swift
//  Pods
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import Foundation

struct LayoutVariantModel: Decodable {
    let layoutVariantSchema: LayoutVariantChildren?
    let moduleName: String?
    
    enum CodingKeys: String, CodingKey {
        case layoutVariantSchema
        case moduleName
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        moduleName = try container.decode(String.self, forKey: .moduleName)
        
        let layoutVariantSchemaString = try container.decode(String.self, forKey: .layoutVariantSchema)
        if layoutVariantSchemaString.isEmpty {
            layoutVariantSchema = nil
        } else {
            let layoutVariantSchemaData = layoutVariantSchemaString.data(using: .utf8)
            
            layoutVariantSchema = try JSONDecoder().decode(LayoutVariantChildren.self,
                                                           from: layoutVariantSchemaData ?? Data())
        }
    }
    
    init(layoutVariantSchema: LayoutVariantChildren,
         moduleName: String?) {
        self.layoutVariantSchema = layoutVariantSchema
        self.moduleName = moduleName
    }
}
