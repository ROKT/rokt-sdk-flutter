//
//  BNFPayloadExpander.swift
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

@available(iOS 15, *)
protocol PayloadExpander {
    associatedtype T

    // `parent` is required to match `OneByOne` indices
    // `creativeParent` is required by elements nested in `CreativeResponse`
    func expand(
        layoutVariant: LayoutSchemaUIModel?,
        parent: (any DomainMappableParent)?,
        creativeParent: CreativeResponseUIModel?,
        using dataSource: T?,
        dataSourceIndex: Int,
        usesDataSourceIndex: Bool?
    )
}

/// Takes a Page entity and expands all BNF-formatted Strings in its inner layout schema
@available(iOS 15, *)
struct BNFPayloadExpander<Mapper: DomainMapper>: PayloadExpander where Mapper.T == OfferModel {
    let mapper: Mapper

    init(mapper: Mapper = BNFNodeMapper()) {
        self.mapper = mapper
    }

    func expand(
        layoutVariant: LayoutSchemaUIModel?,
        parent: (any DomainMappableParent)?,
        creativeParent: CreativeResponseUIModel?,
        using dataSource: OfferModel?,
        dataSourceIndex: Int,
        usesDataSourceIndex: Bool?
    ) {
        guard let layoutVariant,
              let dataSource
        else { return }

        switch layoutVariant {
        case .overlay(let overlay):
            updateChildren(
                parent: overlay,
                creativeParent: creativeParent,
                offer: dataSource,
                offerIndex: dataSourceIndex,
                useOfferIndex: usesDataSourceIndex
            )
        case .bottomSheet(let bottomSheet):
            updateChildren(
                parent: bottomSheet,
                creativeParent: creativeParent,
                offer: dataSource,
                offerIndex: dataSourceIndex,
                useOfferIndex: usesDataSourceIndex
            )
        case .row(let row):
            updateChildren(
                parent: row,
                creativeParent: creativeParent,
                offer: dataSource,
                offerIndex: dataSourceIndex,
                useOfferIndex: usesDataSourceIndex
            )
        case .column(let column):
            updateChildren(
                parent: column,
                creativeParent: creativeParent,
                offer: dataSource,
                offerIndex: dataSourceIndex,
                useOfferIndex: usesDataSourceIndex
            )
        case .when(let when):
            updateChildren(
                parent: when,
                creativeParent: creativeParent,
                offer: dataSource,
                offerIndex: dataSourceIndex,
                useOfferIndex: usesDataSourceIndex
            )
        case .oneByOne(let oneByOne):
            // only children of OneByOne need to be aware of the offer's index
            updateChildren(
                parent: oneByOne,
                creativeParent: creativeParent,
                offer: dataSource,
                offerIndex: dataSourceIndex,
                useOfferIndex: true
            )
        case .carousel(let carousel):
            // only children of OneByOne need to be aware of the offer's index
            updateChildren(
                parent: carousel,
                creativeParent: creativeParent,
                offer: dataSource,
                offerIndex: dataSourceIndex,
                useOfferIndex: true
            )
        case .creativeResponse(let creativeResponse):
            updateChildren(
                parent: creativeResponse,
                creativeParent: creativeResponse,
                offer: dataSource,
                offerIndex: dataSourceIndex,
                useOfferIndex: usesDataSourceIndex
            )
        case .basicText, .richText:
            mapChild(
                child: layoutVariant,
                creativeParent: creativeParent,
                offer: dataSource,
                shouldMapUsingOffer: usesDataSourceIndex ?? false
            )
        case .progressIndicator:
            mapChild(
                child: layoutVariant,
                creativeParent: creativeParent,
                offer: dataSource,
                shouldMapUsingOffer: true
            )
        default:
            break
        }
    }

    // recursively attempt to expand children
    // if we have multiple innerLayout models inside OneByOne - those children
    // are the only ones that need to be expanded
    private func updateChildren<P: DomainMappableParent>(
        parent: P,
        creativeParent: CreativeResponseUIModel?,
        offer: OfferModel,
        offerIndex: Int,
        useOfferIndex: Bool?
    ) {
        guard let children = parent.children else { return }

        if let oneByOne = parent as? OneByOneUIModel {
            guard let oneByOneChildren = oneByOne.children else { return }

            for (childIndex, child) in oneByOneChildren.enumerated() {
                guard childIndex == offerIndex else { continue }

                expand(
                    layoutVariant: child,
                    parent: parent,
                    creativeParent: creativeParent,
                    using: offer,
                    dataSourceIndex: offerIndex,
                    usesDataSourceIndex: useOfferIndex
                )
            }
        } else if let carousel = parent as? CarouselUIModel {
            guard let children = carousel.children else { return }

            for (childIndex, child) in children.enumerated() {
                guard childIndex == offerIndex else { continue }

                expand(
                    layoutVariant: child,
                    parent: parent,
                    creativeParent: creativeParent,
                    using: offer,
                    dataSourceIndex: offerIndex,
                    usesDataSourceIndex: useOfferIndex
                )
            }
        } else {
            for child in children {
                expand(
                    layoutVariant: child,
                    parent: parent,
                    creativeParent: creativeParent,
                    using: offer,
                    dataSourceIndex: offerIndex,
                    usesDataSourceIndex: useOfferIndex
                )
            }
        }
    }

    // children that can utilise `OfferModel`
    private func mapChild<P: DomainMappable>(
        child: P,
        creativeParent: CreativeResponseUIModel?,
        offer: OfferModel,
        shouldMapUsingOffer: Bool
    ) {
        guard let domain = child as? LayoutSchemaUIModel,
              shouldMapUsingOffer
        else { return }

        mapper.map(
            consumer: domain,
            creativeParent: creativeParent,
            dataSource: offer
        )
    }
}
