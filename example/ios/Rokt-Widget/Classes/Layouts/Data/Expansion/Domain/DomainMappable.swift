//
//  DomainMappable.swift
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

/// Entities with properties that can be transformed according to business logic
protocol DomainMappable {}

@available(iOS 15, *)
extension RichTextUIModel: DomainMappable {}

@available(iOS 15, *)
extension BasicTextUIModel: DomainMappable {}

@available(iOS 15, *)
extension LayoutSchemaUIModel: DomainMappable {}

@available(iOS 15, *)
extension ProgressIndicatorUIModel: DomainMappable {}
