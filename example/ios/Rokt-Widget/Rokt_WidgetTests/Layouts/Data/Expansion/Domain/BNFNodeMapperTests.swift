//
//  BNFNodeMapperTests.swift
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

import XCTest

@available(iOS 15, *)
final class BNFNodeMapperTests: XCTestCase {
    var sut: BNFNodeMapper? = BNFNodeMapper()
    var bnfColumn: ColumnModel<LayoutSchemaModel, WhenPredicate>?
    var firstOffer: OfferModel?

    override func setUp() {
        super.setUp()

        sut = BNFNodeMapper()

        let bnfPageModel = ModelTestData.PageModelData.withBNF()
        let firstSlot = bnfPageModel.layoutPlugins?.first?.slots[0]
        let bnfChildren = firstSlot?.layoutVariant?.layoutVariantSchema
        firstOffer = firstSlot?.offer

        if case .column(let myColumn) = bnfChildren {
            bnfColumn = myColumn
        }
    }

    override func tearDown() {
        firstOffer = nil
        bnfColumn = nil
        sut = nil

        super.tearDown()
    }

    // MARK: - BasicText

    func test_basicText_parsesSingleValue() {
        // %^DATA.creativeCopy.creative.termsAndConditions.link^%
        assertBasicTextDataExpansion(
            childIndex: 0,
            expectedValue: "my_t_and_cs_link "
        )
    }

    func test_basicText_invalidFirstValueValidSecondValue_parsesSecondValue() {
        // %^DATA.creativeCopy.nonexistent | DATA.creativeCopy.creative.termsAndConditions.link^%
        assertBasicTextDataExpansion(
            childIndex: 11,
            expectedValue: "my_t_and_cs_link"
        )
    }

    func test_basicText_invalidFirstValueWithDefaultValue_parsesSecondValue() {
        // %^DATA.creativeCopy.nonexistent | my default^%
        assertBasicTextDataExpansion(
            childIndex: 12,
            expectedValue: "my default"
        )
    }

    func test_basicText_chainOfValues_parsesAllValues() {
        // %^DATA.creativeCopy.creative.termsAndConditions.link^% this is my sentence %^DATA.creativeCopy.creative.termsAndConditions.link^%
        assertBasicTextDataExpansion(
            childIndex: 13,
            expectedValue: "my_t_and_cs_link this is my sentence my_t_and_cs_link"
        )
    }

    // MARK: - RichText

    func test_richText_chainOfValues_parsesAllValues() {
        // %^DATA.creativeCopy.title^%%^DATA.creativeCopy.description^%%^DATA.creativeCopy.creative.termsAndConditions.link^%
        assertRichTextDataExpansion(
            childIndex: 1,
            expectedValue: "My Offer TitleOffer description goes heremy_t_and_cs_link"
        )
    }

    func test_richText_withHTMLTags_performsDataExpansionAndRetainsTags() {
        // <b>%^DATA.creativeCopy.title^%</b>
        assertRichTextDataExpansion(
            childIndex: 2,
            expectedValue: "<b>My Offer Title</b>"
        )

        // <u>%^DATA.creativeCopy.title^%</u>
        assertRichTextDataExpansion(
            childIndex: 3,
            expectedValue: "<u>My Offer Title</u>"
        )
    }

    func test_richText_firstValueDoesNotExist_secondValueExists_shouldReturnSecondValue() {
        // %^DATA.creativeCopy.nonexistent | DATA.creativeCopy.title^%
        assertRichTextDataExpansion(
            childIndex: 4,
            expectedValue: "My Offer Title"
        )
    }

    func test_richText_sentenceWithMultipleValidDataExpansion_parsesAll() {
        // This is my sentence with %^DATA.creativeCopy.title^% and %^DATA.creativeCopy.subtitle^%
        assertRichTextDataExpansion(
            childIndex: 5,
            expectedValue: "This is my sentence with My Offer Title and Test Subtitle"
        )
    }

    func test_richText_multipleValidDataExpansion_returnsFirsMatch() {
        // %^DATA.creativeCopy.title | DATA.creativeCopy.subtitle^%
        assertRichTextDataExpansion(
            childIndex: 9,
            expectedValue: "My Offer Title"
        )
    }

    func test_richText_multipleInvalidDataExpansionWithDefault_returnsDefault() {
        // No data expansion
        assertRichTextDataExpansion(
            childIndex: 14,
            expectedValue: "my default value after 2 invalids"
        )
    }

    func test_richText_withNoDataExpansion_returnsNormalText() {
        // No data expansion
        assertRichTextDataExpansion(
            childIndex: 6,
            expectedValue: "No data expansion"
        )
    }

    func test_richText_withNonExistentDataExpansionAndDefaultValue_usesDefaultValue() {
        // %^DATA.creativeCopy.nonexistent | my default value^%
        assertRichTextDataExpansion(
            childIndex: 7,
            expectedValue: "my default value"
        )
    }

    func test_richText_withValidDataExpansionAndDefaultValue_usesDataExpansion() {
        // %^DATA.creativeCopy.title | my default value^%
        assertRichTextDataExpansion(
            childIndex: 8,
            expectedValue: "My Offer Title"
        )
    }

    func test_richText_withEmbeddedLinks_usesDataExpansionAndRetainsHTMLTags() {
        // This is <b>%^DATA.creativeLink.privacyPolicy^%</b> and that is <u>%^DATA.creativeLink.termsAndConditions^%</u>
        assertRichTextDataExpansion(
            childIndex: 15,
            expectedValue: "This is <b><a href=\"https://rokt.com\" target=\"_blank\">Privacy Policy Link</a></b> and that is <u><a href=\"https://google.com\" target=\"_blank\">Terms And Conditions</a></u>"
        )
    }

    func test_richText_withInvalidChainAndEmptyPipe_usesEmptyString() {
        // %^DATA.creativeCopy.nonexistent |^%
        assertRichTextDataExpansion(
            childIndex: 16,
            expectedValue: ""
        )
    }

    func test_richText_withValidChainAndEmptyPipe_usesDataExpansion() {
        // %^DATA.creativeCopy.title |^%
        assertRichTextDataExpansion(
            childIndex: 17,
            expectedValue: "My Offer Title"
        )
    }

    func test_richText_withMultipleInvalidChainAndEmptyPipe_usesEmptyString() {
        // %^DATA.creativeCopy.nonexistent | DATA.creativeCopy.nonexistentv2 |^%
        assertRichTextDataExpansion(
            childIndex: 18,
            expectedValue: ""
        )
    }

    func test_richText_withSecondValidChainAndEmptyPipe_usesDataExpansion() {
        // %^DATA.creativeCopy.nonexistent | DATA.creativeCopy.title |^%
        assertRichTextDataExpansion(
            childIndex: 19,
            expectedValue: "My Offer Title"
        )
    }

    func test_richText_withInvalidChainAndEmptyPipeInSentence_usesEmptyString() {
        // %^DATA.creativeCopy.nonexistent |^% is my sentence
        assertRichTextDataExpansion(
            childIndex: 20,
            expectedValue: " is my sentence"
        )
    }

    // sad path
    func test_richText_withInvalidDataExpansion_returnsEmptyString() {
        // %^DATA.creativeCopy.nonexistent^%
        assertRichTextDataExpansion(
            childIndex: 10,
            expectedValue: ""
        )
    }
    
    // sentence with an invalid mandatory and a valid optional copy should still return empty
    func test_richText_sentenceWithInvalidMandatoryCreativeCopy_returnsEmptyString() {
        // Sentence with %^DATA.creativeCopy.nonexistent^% and %^DATA.creativeCopy.title|^%
        assertRichTextDataExpansion(
            childIndex: 21,
            expectedValue: ""
        )
    }
    
    // sentence with an invalid mandatory and a valid optional link should still return empty
    func test_richText_sentenceWithInvalidMandatoryCreativeLink_returnsEmptyString() {
        // Sentence with %^DATA.creativeLink.nonexistent^% and %^DATA.creativeLink.privacyPolicy|^%
        assertRichTextDataExpansion(
            childIndex: 22,
            expectedValue: ""
        )
    }


    private func assertRichTextDataExpansion(childIndex: Int, expectedValue: String) {
        guard let firstOffer else {
            XCTFail("No data source offer")
            return
        }

        guard case .richText(let textModel) = bnfColumn?.children[childIndex] else {
            XCTFail("RichText does not exist")
            return
        }

        let uiModel = textModel.asUIModel

        guard let mappedUIModel = sut?.map(consumer: .richText(uiModel), creativeParent: nil, dataSource: firstOffer) as? RichTextUIModel
        else {
            XCTFail("Could not perform data mapping on RichText")
            return
        }

        XCTAssertEqual(mappedUIModel.boundValue, expectedValue)
    }

    private func assertBasicTextDataExpansion(childIndex: Int, expectedValue: String) {
        guard let firstOffer else {
            XCTFail("No data source offer")
            return
        }

        guard case .basicText(let textModel) = bnfColumn?.children[childIndex] else {
            XCTFail("BasicText does not exist")
            return
        }

        let uiModel = textModel.asUIModel

        guard let mappedUIModel = sut?.map(consumer: .basicText(uiModel), creativeParent: nil, dataSource: firstOffer) as? BasicTextUIModel
        else {
            XCTFail("Could not perform data mapping on BasicText")
            return
        }

        XCTAssertEqual(mappedUIModel.boundValue, expectedValue)
    }

}

@available(iOS 15, *)
fileprivate extension RichTextModel {
    var asUIModel: RichTextUIModel {
        RichTextUIModel(
            value: self.value,
            defaultStyle: nil,
            linkStyle: nil,
            openLinks: nil,
            stateDataExpansionClosure: nil
        )
    }
}

@available(iOS 15, *)
fileprivate extension BasicTextModel {
    var asUIModel: BasicTextUIModel {
        BasicTextUIModel(
            value: self.value,
            defaultStyle: nil,
            pressedStyle: nil,
            hoveredStyle: nil,
            disabledStyle: nil
        )
    }
}
