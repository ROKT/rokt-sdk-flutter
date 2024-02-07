//
//  PlacementConfigurableKeys.swift
//  Pods
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

typealias ConfigKey = String

// MARK: Title
let MobilePlacementTitleContent: ConfigKey =
    "MobileSdk.Placement.Title.Content"
let MobilePlacementTitleFontFamily: ConfigKey =
    "MobileSdk.Placement.Title.Font.Family"
let MobilePlacementTitleFontSize: ConfigKey =
    "MobileSdk.Placement.Title.Font.Size"
let MobilePlacementTitleFontColorLight: ConfigKey =
    "MobileSdk.Placement.Title.Font.Color.Light"
let MobilePlacementTitleFontColorDark: ConfigKey =
    "MobileSdk.Placement.Title.Font.Color.Dark"
let MobilePlacementTitleBackgroundColorLight: ConfigKey =
    "MobileSdk.Placement.Title.BackgroundColor.Light"
let MobilePlacementTitleBackgroundColorDark: ConfigKey =
    "MobileSdk.Placement.Title.BackgroundColor.Dark"
let MobilePlacementTitleCloseButtonColorLight: ConfigKey =
    "MobileSdk.Placement.Title.CloseButton.Color.Light"
let MobilePlacementTitleCloseButtonColorDark: ConfigKey =
    "MobileSdk.Placement.Title.CloseButton.Color.Dark"
let MobilePlacementTitleCloseButtonCircleColorLight: ConfigKey =
    "MobileSdk.Placement.Title.CloseButtonCircle.Color.Light"
let MobilePlacementTitleCloseButtonCircleColorDark: ConfigKey =
    "MobileSdk.Placement.Title.CloseButtonCircle.Color.Dark"
let MobilePlacementTitleCloseButtonThinVariant: ConfigKey =
    "MobileSdk.Placement.Title.CloseButton.ThinVariant"
let MobilePlacementTitleLineSpacing: ConfigKey =
    "MobileSdk.Placement.Title.LineSpacing"
let MobilePlacementTitleAlignment: ConfigKey =
    "MobileSdk.Placement.Title.Alignment"
let MobilePlacementTitleShouldWordWrap: ConfigKey =
    "MobileSdk.Placement.Title.WordWrap"

let MobilePlacementTitlePosition: ConfigKey =
    "MobileSdk.Placement.Title.Position"
let MobilePlacementTitleMargin: ConfigKey =
    "MobileSdk.Placement.Title.Margin"

// MARK: Loading Indicator
let MobilePlacementLoadingIndicatorForegroundColorLight: ConfigKey =
    "MobileSdk.Placement.LoadingIndicator.ForegroundColor.Light"
let MobilePlacementLoadingIndicatorForegroundColorDark: ConfigKey =
    "MobileSdk.Placement.LoadingIndicator.ForegroundColor.Dark"
let MobilePlacementLoadingIndicatorBackgroundColorLight: ConfigKey =
    "MobileSdk.Placement.LoadingIndicator.BackgroundColor.Light"
let MobilePlacementLoadingIndicatorBackgroundColorDark: ConfigKey =
    "MobileSdk.Placement.LoadingIndicator.BackgroundColor.Dark"

// MARK: Launch delay
let MobilePlacementLaunchDelayMilliseconds: ConfigKey =
    "MobileSdk.Placement.LaunchDelayMilliseconds"

// MARK: End Message
let MobilePlacementEndOfJourneyBehavior: ConfigKey =
    "MobileSdk.Placement.EndOfJourneyBehavior"
let MobilePlacementEndMessageTitleContent: ConfigKey =
    "MobileSdk.Placement.EndMessage.Title.Content"
let MobilePlacementEndMessageTitleFontFamily: ConfigKey =
    "MobileSdk.Placement.EndMessage.Title.Font.Family"
let MobilePlacementEndMessageTitleFontSize: ConfigKey =
    "MobileSdk.Placement.EndMessage.Title.Font.Size"
let MobilePlacementEndMessageTitleFontColorLight: ConfigKey =
    "MobileSdk.Placement.EndMessage.Title.Font.Color.Light"
let MobilePlacementEndMessageTitleFontColorDark: ConfigKey =
    "MobileSdk.Placement.EndMessage.Title.Font.Color.Dark"
let MobilePlacementEndMessageTitleLineSpacing: ConfigKey =
    "MobileSdk.Placement.EndMessage.Title.LineSpacing"
let MobilePlacementEndMessageTitleAlignment: ConfigKey =
    "MobileSdk.Placement.EndMessage.Title.Alignment"
let MobilePlacementEndMessageBodyContent: ConfigKey =
    "MobileSdk.Placement.EndMessage.Body.Content"
let MobilePlacementEndMessageBodyFontFamily: ConfigKey =
    "MobileSdk.Placement.EndMessage.Body.Font.Family"
let MobilePlacementEndMessageBodyFontSize: ConfigKey =
    "MobileSdk.Placement.EndMessage.Body.Font.Size"
let MobilePlacementEndMessageBodyFontColorLight: ConfigKey =
    "MobileSdk.Placement.EndMessage.Body.Font.Color.Light"
let MobilePlacementEndMessageBodyFontColorDark: ConfigKey =
    "MobileSdk.Placement.EndMessage.Body.Font.Color.Dark"
let MobilePlacementEndMessageBodyLineSpacing: ConfigKey =
    "MobileSdk.Placement.EndMessage.Body.LineSpacing"
let MobilePlacementEndMessageBodyAlignment: ConfigKey =
    "MobileSdk.Placement.EndMessage.Body.Alignment"

// MARK: Footer
let MobilePlacementFooterBackgroundColorLight: ConfigKey =
    "MobileSdk.Placement.Footer.BackgroundColor.Light"
let MobilePlacementFooterBackgroundColorDark: ConfigKey =
    "MobileSdk.Placement.Footer.BackgroundColor.Dark"
let MobilePlacementFooterRoktPrivacyPolicyContent: ConfigKey =
    "MobileSdk.Placement.Footer.RoktPrivacyPolicy.Content"
let MobilePlacementFooterRoktPrivacyPolicyLink: ConfigKey =
    "MobileSdk.Placement.Footer.RoktPrivacyPolicy.Link"
let MobilePlacementFooterRoktPrivacyPolicyFontFamily: ConfigKey =
    "MobileSdk.Placement.Footer.RoktPrivacyPolicy.Font.Family"
let MobilePlacementFooterRoktPrivacyPolicyFontSize: ConfigKey =
    "MobileSdk.Placement.Footer.RoktPrivacyPolicy.Font.Size"
let MobilePlacementFooterRoktPrivacyPolicyFontColorLight: ConfigKey =
    "MobileSdk.Placement.Footer.RoktPrivacyPolicy.Font.Color.Light"
let MobilePlacementFooterRoktPrivacyPolicyFontColorDark: ConfigKey =
    "MobileSdk.Placement.Footer.RoktPrivacyPolicy.Font.Color.Dark"
let MobilePlacementFooterRoktPrivacyPolicyBackgroundColorLight: ConfigKey =
    "MobileSdk.Placement.Footer.RoktPrivacyPolicy.BackgroundColor.Light"
let MobilePlacementFooterRoktPrivacyPolicyBackgroundColorDark: ConfigKey =
    "MobileSdk.Placement.Footer.RoktPrivacyPolicy.BackgroundColor.Dark"
let MobilePlacementFooterRoktPrivacyPolicyLineSpacing: ConfigKey =
    "MobileSdk.Placement.Footer.RoktPrivacyPolicy.LineSpacing"
let MobilePlacementFooterRoktPrivacyPolicyAlignment: ConfigKey =
    "MobileSdk.Placement.Footer.RoktPrivacyPolicy.Alignment"
let MobilePlacementFooterPartnerPrivacyPolicyContent: ConfigKey =
    "MobileSdk.Placement.Footer.PartnerPrivacyPolicy.Content"
let MobilePlacementFooterPartnerPrivacyPolicyLink: ConfigKey =
    "MobileSdk.Placement.Footer.PartnerPrivacyPolicy.Link"
let MobilePlacementFooterPartnerPrivacyPolicyFontFamily: ConfigKey =
    "MobileSdk.Placement.Footer.PartnerPrivacyPolicy.Font.Family"
let MobilePlacementFooterPartnerPrivacyPolicyFontSize: ConfigKey =
    "MobileSdk.Placement.Footer.PartnerPrivacyPolicy.Font.Size"
let MobilePlacementFooterPartnerPrivacyPolicyFontColorLight: ConfigKey =
    "MobileSdk.Placement.Footer.PartnerPrivacyPolicy.Font.Color.Light"
let MobilePlacementFooterPartnerPrivacyPolicyFontColorDark: ConfigKey =
    "MobileSdk.Placement.Footer.PartnerPrivacyPolicy.Font.Color.Dark"
let MobilePlacementFooterPartnerPrivacyPolicyBackgroundColorLight: ConfigKey =
    "MobileSdk.Placement.Footer.PartnerPrivacyPolicy.BackgroundColor.Light"
let MobilePlacementFooterPartnerPrivacyPolicyBackgroundColorDark: ConfigKey =
    "MobileSdk.Placement.Footer.PartnerPrivacyPolicy.BackgroundColor.Dark"
let MobilePlacementFooterPartnerPrivacyPolicyLineSpacing: ConfigKey =
    "MobileSdk.Placement.Footer.PartnerPrivacyPolicy.LineSpacing"
let MobilePlacementFooterPartnerPrivacyPolicyAlignment: ConfigKey =
    "MobileSdk.Placement.Footer.PartnerPrivacyPolicy.Alignment"
let MobilePlacementFooterDividerBackgroundColorLight: ConfigKey =
    "MobileSdk.Placement.Footer.Divider.BackgroundColor.Light"
let MobilePlacementFooterDividerBackgroundColorDark: ConfigKey =
    "MobileSdk.Placement.Footer.Divider.BackgroundColor.Dark"
let MobilePlacementFooterDividerShow: ConfigKey =
    "MobileSdk.Placement.Footer.Divider.Show"
let MobilePlacementFooterDividerMargin: ConfigKey =
    "MobileSdk.Placement.Footer.Divider.Margin"
let MobilePlacementFooterDividerHeight: ConfigKey =
    "MobileSdk.Placement.Footer.Divider.Height"
let MobilePlacementFooterAlignment: ConfigKey =
    "MobileSdk.Placement.Footer.Alignment"

// MARK: Placement excluding footer
let MobilePlacementWithoutFooterBackgroundColorLight: ConfigKey =
    "MobileSdk.Placement.WithoutFooter.BackgroundColor.Light"
let MobilePlacementWithoutFooterBackgroundColorDark: ConfigKey =
    "MobileSdk.Placement.WithoutFooter.BackgroundColor.Dark"
let MobilePlacementWithoutFooterCornerRadius: ConfigKey =
    "MobileSdk.Placement.WithoutFooter.CornerRadius"
let MobilePlacementWithoutFooterBorderThickness: ConfigKey =
    "MobileSdk.Placement.WithoutFooter.BorderThickness"
let MobilePlacementWithoutFooterBorderColorLight: ConfigKey =
    "MobileSdk.Placement.WithoutFooter.BorderColor.Light"
let MobilePlacementWithoutFooterBorderColorDark: ConfigKey =
    "MobileSdk.Placement.WithoutFooter.BorderColor.Dark"
let MobilePlacementWithoutFooterPadding: ConfigKey =
    "MobileSdk.Placement.WithoutFooter.Padding"

// MARK: Background
let MobilePlacementBackgroundColorLight: ConfigKey =
    "MobileSdk.Placement.BackgroundColor.Light"
let MobilePlacementBackgroundColorDark: ConfigKey =
    "MobileSdk.Placement.BackgroundColor.Dark"

// MARK: Page indicator
let MobilePlacementPageIndicatorType: ConfigKey =
    "MobileSdk.Placement.PageIndicator.Type"
let MobilePlacementPageIndicatorStartingPosition: ConfigKey =
    "MobileSdk.Placement.PageIndicator.StartingPosition"
let MobilePlacementPageIndicatorCountPos1: ConfigKey =
    "MobileSdk.Placement.PageIndicator.CountPos1"
let MobilePlacementPageIndicatorSeenColorLight: ConfigKey =
    "MobileSdk.Placement.PageIndicator.Seen.Color.Light"
let MobilePlacementPageIndicatorSeenColorDark: ConfigKey =
    "MobileSdk.Placement.PageIndicator.Seen.Color.Dark"
let MobilePlacementPageIndicatorUnseenColorLight: ConfigKey =
    "MobileSdk.Placement.PageIndicator.Unseen.Color.Light"
let MobilePlacementPageIndicatorUnseenColorDark: ConfigKey =
    "MobileSdk.Placement.PageIndicator.Unseen.Color.Dark"
let MobilePlacementPageIndicatorSeenFontFamily: ConfigKey =
    "MobileSdk.Placement.PageIndicator.Seen.Font.Family"
let MobilePlacementPageIndicatorSeenFontSize: ConfigKey =
    "MobileSdk.Placement.PageIndicator.Seen.Font.Size"
let MobilePlacementPageIndicatorSeenFontColorLight: ConfigKey =
    "MobileSdk.Placement.PageIndicator.Seen.Font.Color.Light"
let MobilePlacementPageIndicatorSeenFontColorDark: ConfigKey =
    "MobileSdk.Placement.PageIndicator.Seen.Font.Color.Dark"
let MobilePlacementPageIndicatorUnseenFontFamily: ConfigKey =
    "MobileSdk.Placement.PageIndicator.Unseen.Font.Family"
let MobilePlacementPageIndicatorUnseenFontSize: ConfigKey =
    "MobileSdk.Placement.PageIndicator.Unseen.Font.Size"
let MobilePlacementPageIndicatorUnseenFontColorLight: ConfigKey =
    "MobileSdk.Placement.PageIndicator.Unseen.Font.Color.Light"
let MobilePlacementPageIndicatorUnseenFontColorDark: ConfigKey =
    "MobileSdk.Placement.PageIndicator.Unseen.Font.Color.Dark"
let MobilePlacementPageIndicatorPadding: ConfigKey =
    "MobileSdk.Placement.PageIndicator.Padding"
let MobilePlacementPageIndicatorDiameter: ConfigKey =
    "MobileSdk.Placement.PageIndicator.Diameter"
let MobilePlacementPageIndicatorStartNumberCounter: ConfigKey =
    "MobileSdk.Placement.PageIndicator.StartNumberCounter"
let MobilePlacementPageIndicatorLocation: ConfigKey =
    "MobileSdk.Placement.PageIndicator.Location"
let MobilePlacementPageIndicatorDashesWidth: ConfigKey =
    "MobileSdk.Placement.PageIndicator.Dashes.Width"
let MobilePlacementPageIndicatorDashesHeight: ConfigKey =
    "MobileSdk.Placement.PageIndicator.Dashes.Height"
let MobilePlacementPageIndicatorMargin: ConfigKey =
    "MobileSdk.Placement.PageIndicator.Margin"
let MobilePlacementPageIndicatorTextContent: ConfigKey =
    "MobileSdk.Placement.PageIndicator.Text.Content"
let MobilePlacementPageIndicatorTextFontFamily: ConfigKey =
    "MobileSdk.Placement.PageIndicator.Text.Font.Family"
let MobilePlacementPageIndicatorTextFontSize: ConfigKey =
    "MobileSdk.Placement.PageIndicator.Text.Font.Size"
let MobilePlacementPageIndicatorTextFontColorLight: ConfigKey =
    "MobileSdk.Placement.PageIndicator.Text.Font.Color.Light"
let MobilePlacementPageIndicatorTextFontColorDark: ConfigKey =
    "MobileSdk.Placement.PageIndicator.Text.Font.Color.Dark"
let MobilePlacementPageIndicatorTextLineSpacing: ConfigKey =
    "MobileSdk.Placement.PageIndicator.Text.LineSpacing"
let MobilePlacementPageIndicatorTextAlignment: ConfigKey =
    "MobileSdk.Placement.PageIndicator.Text.Alignment"

// MARK: Before offer
let MobilePlacementBeforeOfferShowPosition1: ConfigKey =
    "MobileSdk.Placement.BeforeOffer.Show.Position1"
let MobilePlacementBeforeOfferShowPosition2Plus: ConfigKey =
    "MobileSdk.Placement.BeforeOffer.Show.Position2+"
let MobilePlacementBeforeOfferMargin: ConfigKey =
    "MobileSdk.Placement.BeforeOffer.Margin"
let MobilePlacementBeforeOfferCopyContent: ConfigKey =
    "MobileSdk.Placement.BeforeOffer.Copy.Content"
let MobilePlacementBeforeOfferCopyFontFamily: ConfigKey =
    "MobileSdk.Placement.BeforeOffer.Copy.Font.Family"
let MobilePlacementBeforeOfferCopyFontSize: ConfigKey =
    "MobileSdk.Placement.BeforeOffer.Copy.Font.Size"
let MobilePlacementBeforeOfferCopyFontColorLight: ConfigKey =
    "MobileSdk.Placement.BeforeOffer.Copy.Font.Color.Light"
let MobilePlacementBeforeOfferCopyFontColorDark: ConfigKey =
    "MobileSdk.Placement.BeforeOffer.Copy.Font.Color.Dark"
let MobilePlacementBeforeOfferCopyLineSpacing: ConfigKey =
    "MobileSdk.Placement.BeforeOffer.Copy.LineSpacing"
let MobilePlacementBeforeOfferCopyAlignment: ConfigKey =
    "MobileSdk.Placement.BeforeOffer.Copy.Alignment"

// MARK: Confirmation Message
let MobileCreativeConfirmationMessageShowPosition1: ConfigKey =
    "MobileSdk.Creative.ConfirmationMessage.Show.Position1"
let MobileCreativeConfirmationMessageShowPosition2Plus: ConfigKey =
    "MobileSdk.Creative.ConfirmationMessage.Show.Position2+"
let MobileCreativeConfirmationMessageFontFamily: ConfigKey =
    "MobileSdk.Creative.ConfirmationMessage.Font.Family"
let MobileCreativeConfirmationMessageFontSize: ConfigKey =
    "MobileSdk.Creative.ConfirmationMessage.Font.Size"
let MobileCreativeConfirmationMessageFontColorLight: ConfigKey =
    "MobileSdk.Creative.ConfirmationMessage.Font.Color.Light"
let MobileCreativeConfirmationMessageFontColorDark: ConfigKey =
    "MobileSdk.Creative.ConfirmationMessage.Font.Color.Dark"
let MobileCreativeConfirmationMessageLineSpacing: ConfigKey =
    "MobileSdk.Creative.ConfirmationMessage.LineSpacing"
let MobileCreativeConfirmationMessageAlignment: ConfigKey =
    "MobileSdk.Creative.ConfirmationMessage.Alignment"
let MobileCreativeConfirmationMessagePadding: ConfigKey =
    "MobileSdk.Creative.ConfirmationMessage.Padding"
let MobileCreativeConfirmationMessageMargin: ConfigKey =
    "MobileSdk.Creative.ConfirmationMessage.Margin"

// MARK: After offer
let MobilePlacementAfterOfferShowPosition1: ConfigKey =
    "MobileSdk.Placement.AfterOffer.Show.Position1"
let MobilePlacementAfterOfferShowPosition2Plus: ConfigKey =
    "MobileSdk.Placement.AfterOffer.Show.Position2+"
let MobilePlacementAfterOfferCopyPosition1Content: ConfigKey =
    "MobileSdk.Placement.AfterOffer.Copy.Position1.Content"
let MobilePlacementAfterOfferCopyPosition2PlusContent: ConfigKey =
    "MobileSdk.Placement.AfterOffer.Copy.Position2+.Content"
let MobilePlacementAfterOfferCopyFontFamily: ConfigKey =
    "MobileSdk.Placement.AfterOffer.Copy.Font.Family"
let MobilePlacementAfterOfferCopyFontSize: ConfigKey =
    "MobileSdk.Placement.AfterOffer.Copy.Font.Size"
let MobilePlacementAfterOfferCopyFontColorLight: ConfigKey =
    "MobileSdk.Placement.AfterOffer.Copy.Font.Color.Light"
let MobilePlacementAfterOfferCopyFontColorDark: ConfigKey =
    "MobileSdk.Placement.AfterOffer.Copy.Font.Color.Dark"
let MobilePlacementAfterOfferCopyLineSpacing: ConfigKey =
    "MobileSdk.Placement.AfterOffer.Copy.LineSpacing"
let MobilePlacementAfterOfferCopyAlignment: ConfigKey =
    "MobileSdk.Placement.AfterOffer.Copy.Alignment"
let MobilePlacementAfterOfferPadding: ConfigKey =
    "MobileSdk.Placement.AfterOffer.Padding"

// MARK: Padding and Margin
let MobilePlacementPadding: ConfigKey =
    "MobileSdk.Placement.Padding"
let MobilePlacementMargin: ConfigKey =
    "MobileSdk.Placement.Margin"

// MARK: Offer
let MobileOfferBackgroundColorLight: ConfigKey =
    "MobileSdk.Offer.BackgroundColor.Light"
let MobileOfferBackgroundColorDark: ConfigKey =
    "MobileSdk.Offer.BackgroundColor.Dark"
let MobileOfferPadding: ConfigKey =
    "MobileSdk.Offer.Padding"

// MARK: Creative
let MobileCreativeTitle: ConfigKey =
    "creative.title"
let MobileCreativeCopy: ConfigKey =
    "creative.copy"
let MobileCreativeImageSrc: ConfigKey =
    "creative.image.src"
let MobileCreativeInLineCopyWithHeading: ConfigKey =
    "MobileSdk.Creative.InlineCopyWithHeading"
let MobileCreativeFontFamily: ConfigKey =
    "MobileSdk.Creative.Font.Family"
let MobileCreativeFontSize: ConfigKey =
    "MobileSdk.Creative.Font.Size"
let MobileCreativeFontColorLight: ConfigKey =
    "MobileSdk.Creative.Font.Color.Light"
let MobileCreativeFontColorDark: ConfigKey =
    "MobileSdk.Creative.Font.Color.Dark"
let MobileCreativeLineSpacing: ConfigKey =
    "MobileSdk.Creative.LineSpacing"
let MobileCreativeAlignment: ConfigKey =
    "MobileSdk.Creative.Alignment"
let MobileCreativeTitleWithImageArrangement: ConfigKey =
    "MobileSdk.Creative.TitleWithImage.Arrangement"
let MobileCreativeTitleWithImageAlignment: ConfigKey =
    "MobileSdk.Creative.TitleWithImage.Alignment"
let MobileCreativeTitleWithImageSpacing: ConfigKey =
    "MobileSdk.Creative.TitleWithImage.MinSpacing"
let MobileCreativeTitleFontFamily: ConfigKey =
    "MobileSdk.Creative.Title.Font.Family"
let MobileCreativeTitleFontSize: ConfigKey =
    "MobileSdk.Creative.Title.Font.Size"
let MobileCreativeTitleFontColorLight: ConfigKey =
    "MobileSdk.Creative.Title.Font.Color.Light"
let MobileCreativeTitleFontColorDark: ConfigKey =
    "MobileSdk.Creative.Title.Font.Color.Dark"
let MobileCreativeTitleLineSpacing: ConfigKey =
    "MobileSdk.Creative.Title.LineSpacing"
let MobileCreativeTitleAlignment: ConfigKey =
    "MobileSdk.Creative.Title.Alignment"
let MobileCreativeResponseOrder: ConfigKey =
    "MobileSdk.Creative.ResponseOrder"
let MobileCreativeButtonDisplay: ConfigKey =
    "MobileSdk.Creative.ButtonDisplay"
let CreativeConfirmationMessage: ConfigKey =
    "creative.confirmation.message"
let CreativeDisclaimer: ConfigKey =
    "creative.disclaimer"
let CreativePrivacyPolicyTitle: ConfigKey =
    "creative.privacyPolicy.title"
let CreativePrivacyPolicyLink: ConfigKey =
    "creative.privacyPolicy.link"
let CreativeTermsAndConditionsTitle: ConfigKey =
    "creative.termsAndConditions.title"
let CreativeTermsAndConditionsLink: ConfigKey =
    "creative.termsAndConditions.link"

// MARK: Positive button
let MobileCreativePositiveButtonDefaultFontFamily: ConfigKey =
    "MobileSdk.Creative.PositiveButton.Default.Font.Family"
let MobileCreativePositiveButtonDefaultFontSize: ConfigKey =
    "MobileSdk.Creative.PositiveButton.Default.Font.Size"
let MobileCreativePositiveButtonDefaultFontColorLight: ConfigKey =
    "MobileSdk.Creative.PositiveButton.Default.Font.Color.Light"
let MobileCreativePositiveButtonDefaultFontColorDark: ConfigKey =
    "MobileSdk.Creative.PositiveButton.Default.Font.Color.Dark"
let MobileCreativePositiveButtonDefaultBackgroundColorLight: ConfigKey =
    "MobileSdk.Creative.PositiveButton.Default.BackgroundColor.Light"
let MobileCreativePositiveButtonDefaultBackgroundColorDark: ConfigKey =
    "MobileSdk.Creative.PositiveButton.Default.BackgroundColor.Dark"
let MobileCreativePositiveButtonDefaultCornerRadius: ConfigKey =
    "MobileSdk.Creative.PositiveButton.Default.CornerRadius"
let MobileCreativePositiveButtonDefaultBorderThickness: ConfigKey =
    "MobileSdk.Creative.PositiveButton.Default.BorderThickness"
let MobileCreativePositiveButtonDefaultBorderColorLight: ConfigKey =
    "MobileSdk.Creative.PositiveButton.Default.BorderColor.Light"
let MobileCreativePositiveButtonDefaultBorderColorDark: ConfigKey =
    "MobileSdk.Creative.PositiveButton.Default.BorderColor.Dark"
let MobileCreativePositiveButtonPressedFontFamily: ConfigKey =
    "MobileSdk.Creative.PositiveButton.Pressed.Font.Family"
let MobileCreativePositiveButtonPressedFontSize: ConfigKey =
    "MobileSdk.Creative.PositiveButton.Pressed.Font.Size"
let MobileCreativePositiveButtonPressedFontColorLight: ConfigKey =
    "MobileSdk.Creative.PositiveButton.Pressed.Font.Color.Light"
let MobileCreativePositiveButtonPressedFontColorDark: ConfigKey =
    "MobileSdk.Creative.PositiveButton.Pressed.Font.Color.Dark"
let MobileCreativePositiveButtonPressedBackgroundColorLight: ConfigKey =
    "MobileSdk.Creative.PositiveButton.Pressed.BackgroundColor.Light"
let MobileCreativePositiveButtonPressedBackgroundColorDark: ConfigKey =
    "MobileSdk.Creative.PositiveButton.Pressed.BackgroundColor.Dark"
let MobileCreativePositiveButtonPressedCornerRadius: ConfigKey =
    "MobileSdk.Creative.PositiveButton.Pressed.CornerRadius"
let MobileCreativePositiveButtonPressedBorderThickness: ConfigKey =
    "MobileSdk.Creative.PositiveButton.Pressed.BorderThickness"
let MobileCreativePositiveButtonPressedBorderColorLight: ConfigKey =
    "MobileSdk.Creative.PositiveButton.Pressed.BorderColor.Light"
let MobileCreativePositiveButtonPressedBorderColorDark: ConfigKey =
    "MobileSdk.Creative.PositiveButton.Pressed.BorderColor.Dark"
let MobileCreativePositiveButtonTextCaseOption: ConfigKey =
    "MobileSdk.Creative.PositiveButton.TextCaseOption"

// MARK: Negative button
let MobileCreativeNegativeButtonDefaultFontFamily: ConfigKey =
    "MobileSdk.Creative.NegativeButton.Default.Font.Family"
let MobileCreativeNegativeButtonDefaultFontSize: ConfigKey =
    "MobileSdk.Creative.NegativeButton.Default.Font.Size"
let MobileCreativeNegativeButtonDefaultFontColorLight: ConfigKey =
    "MobileSdk.Creative.NegativeButton.Default.Font.Color.Light"
let MobileCreativeNegativeButtonDefaultFontColorDark: ConfigKey =
    "MobileSdk.Creative.NegativeButton.Default.Font.Color.Dark"
let MobileCreativeNegativeButtonDefaultBackgroundColorLight: ConfigKey =
    "MobileSdk.Creative.NegativeButton.Default.BackgroundColor.Light"
let MobileCreativeNegativeButtonDefaultBackgroundColorDark: ConfigKey =
    "MobileSdk.Creative.NegativeButton.Default.BackgroundColor.Dark"
let MobileCreativeNegativeButtonDefaultCornerRadius: ConfigKey =
    "MobileSdk.Creative.NegativeButton.Default.CornerRadius"
let MobileCreativeNegativeButtonDefaultBorderThickness: ConfigKey =
    "MobileSdk.Creative.NegativeButton.Default.BorderThickness"
let MobileCreativeNegativeButtonDefaultBorderColorLight: ConfigKey =
    "MobileSdk.Creative.NegativeButton.Default.BorderColor.Light"
let MobileCreativeNegativeButtonDefaultBorderColorDark: ConfigKey =
    "MobileSdk.Creative.NegativeButton.Default.BorderColor.Dark"
let MobileCreativeNegativeButtonPressedFontFamily: ConfigKey =
    "MobileSdk.Creative.NegativeButton.Pressed.Font.Family"
let MobileCreativeNegativeButtonPressedFontSize: ConfigKey =
    "MobileSdk.Creative.NegativeButton.Pressed.Font.Size"
let MobileCreativeNegativeButtonPressedFontColorLight: ConfigKey =
    "MobileSdk.Creative.NegativeButton.Pressed.Font.Color.Light"
let MobileCreativeNegativeButtonPressedFontColorDark: ConfigKey =
    "MobileSdk.Creative.NegativeButton.Pressed.Font.Color.Dark"
let MobileCreativeNegativeButtonPressedBackgroundColorLight: ConfigKey =
    "MobileSdk.Creative.NegativeButton.Pressed.BackgroundColor.Light"
let MobileCreativeNegativeButtonPressedBackgroundColorDark: ConfigKey =
    "MobileSdk.Creative.NegativeButton.Pressed.BackgroundColor.Dark"
let MobileCreativeNegativeButtonPressedCornerRadius: ConfigKey =
    "MobileSdk.Creative.NegativeButton.Pressed.CornerRadius"
let MobileCreativeNegativeButtonPressedBorderThickness: ConfigKey =
    "MobileSdk.Creative.NegativeButton.Pressed.BorderThickness"
let MobileCreativeNegativeButtonPressedBorderColorLight: ConfigKey =
    "MobileSdk.Creative.NegativeButton.Pressed.BorderColor.Light"
let MobileCreativeNegativeButtonPressedBorderColorDark: ConfigKey =
    "MobileSdk.Creative.NegativeButton.Pressed.BorderColor.Dark"
let MobileCreativeNegativeButtonTextCaseOption: ConfigKey =
    "MobileSdk.Creative.NegativeButton.TextCaseOption"
let MobileCreativeNegativeButtonCloseOnPress: ConfigKey =
    "MobileSdk.Creative.NegativeButton.CloseOnPress"
let MobileCreativeNegativeButtonShow: ConfigKey =
    "MobileSdk.Creative.NegativeButton.Show"

// MARK: - Navigate Button
let MobilePlacementNavigateButtonShow: ConfigKey =
    "MobileSdk.Placement.NavigateButton.Show"
let MobilePlacementNavigateButtonShouldCloseOnPress: ConfigKey =
    "MobileSdk.Placement.NavigateButton.CloseOnPress"
let MobilePlacementNavigateButtonDefaultFontFamily: ConfigKey =
    "MobileSdk.Placement.NavigateButton.Default.Font.Family"
let MobilePlacementNavigateButtonDefaultFontSize: ConfigKey =
    "MobileSdk.Placement.NavigateButton.Default.Font.Size"
let MobilePlacementNavigateButtonDefaultFontColorLight: ConfigKey =
    "MobileSdk.Placement.NavigateButton.Default.Font.Color.Light"
let MobilePlacementNavigateButtonDefaultFontColorDark: ConfigKey =
    "MobileSdk.Placement.NavigateButton.Default.Font.Color.Dark"
let MobilePlacementNavigateButtonDefaultBackgroundColorLight: ConfigKey =
    "MobileSdk.Placement.NavigateButton.Default.BackgroundColor.Light"
let MobilePlacementNavigateButtonDefaultBackgroundColorDark: ConfigKey =
    "MobileSdk.Placement.NavigateButton.Default.BackgroundColor.Dark"
let MobilePlacementNavigateButtonDefaultCornerRadius: ConfigKey =
    "MobileSdk.Placement.NavigateButton.Default.CornerRadius"
let MobilePlacementNavigateButtonDefaultBorderThickness: ConfigKey =
    "MobileSdk.Placement.NavigateButton.Default.BorderThickness"
let MobilePlacementNavigateButtonDefaultBorderColorLight: ConfigKey =
    "MobileSdk.Placement.NavigateButton.Default.BorderColor.Light"
let MobilePlacementNavigateButtonDefaultBorderColorDark: ConfigKey =
    "MobileSdk.Placement.NavigateButton.Default.BorderColor.Dark"
let MobilePlacementNavigateButtonPressedFontFamily: ConfigKey =
    "MobileSdk.Placement.NavigateButton.Pressed.Font.Family"
let MobilePlacementNavigateButtonPressedFontSize: ConfigKey =
    "MobileSdk.Placement.NavigateButton.Pressed.Font.Size"
let MobilePlacementNavigateButtonPressedFontColorLight: ConfigKey =
    "MobileSdk.Placement.NavigateButton.Pressed.Font.Color.Light"
let MobilePlacementNavigateButtonPressedFontColorDark: ConfigKey =
    "MobileSdk.Placement.NavigateButton.Pressed.Font.Color.Dark"
let MobilePlacementNavigateButtonPressedBackgroundColorLight: ConfigKey =
    "MobileSdk.Placement.NavigateButton.Pressed.BackgroundColor.Light"
let MobilePlacementNavigateButtonPressedBackgroundColorDark: ConfigKey =
    "MobileSdk.Placement.NavigateButton.Pressed.BackgroundColor.Dark"
let MobilePlacementNavigateButtonPressedCornerRadius: ConfigKey =
    "MobileSdk.Placement.NavigateButton.Pressed.CornerRadius"
let MobilePlacementNavigateButtonPressedBorderThickness: ConfigKey =
    "MobileSdk.Placement.NavigateButton.Pressed.BorderThickness"
let MobilePlacementNavigateButtonPressedBorderColorLight: ConfigKey =
    "MobileSdk.Placement.NavigateButton.Pressed.BorderColor.Light"
let MobilePlacementNavigateButtonPressedBorderColorDark: ConfigKey =
    "MobileSdk.Placement.NavigateButton.Pressed.BorderColor.Dark"
let MobilePlacementNavigateButtonMargin: ConfigKey =
    "MobileSdk.Placement.NavigateButton.Margin"
let MobilePlacementNavigateButtonText: ConfigKey =
    "MobileSdk.Placement.NavigateButton.Text.Content"
let MobilePlacementNavigateButtonTextCaseOption: ConfigKey =
    "MobileSdk.Placement.NavigateButton.TextCaseOption"
let MobilePlacementNavigateButtonMinHeight: ConfigKey =
    "MobileSdk.Placement.NavigateButton.MinHeight"

// MARK: - Navigate Button Divider
let MobilePlacementNavigateButtonDividerShow: ConfigKey =
    "MobileSdk.Placement.NavigateButton.Divider.Show"
let MobilePlacementNavigateButtonDividerHeight: ConfigKey =
    "MobileSdk.Placement.NavigateButton.Divider.Height"
let MobilePlacementNavigateButtonDividerMargin: ConfigKey =
    "MobileSdk.Placement.NavigateButton.Divider.Margin"
let MobilePlacementNavigateButtonDividerBackgroundColorLight: ConfigKey =
    "MobileSdk.Placement.NavigateButton.Divider.BackgroundColor.Light"
let MobilePlacementNavigateButtonDividerBackgroundColorDark: ConfigKey =
    "MobileSdk.Placement.NavigateButton.Divider.BackgroundColor.Dark"

// MARK: - Divider Below Title
let MobilePlacementTitleDividerShow: ConfigKey =
    "MobileSdk.Placement.Title.Divider.Show"
let MobilePlacementTitleDividerHeight: ConfigKey =
    "MobileSdk.Placement.Title.Divider.Height"
let MobilePlacementTitleDividerMargin: ConfigKey =
    "MobileSdk.Placement.Title.Divider.Margin"
let MobilePlacementTitleDividerBackgroundColorLight: ConfigKey =
    "MobileSdk.Placement.Title.Divider.BackgroundColor.Light"
let MobilePlacementTitleDividerBackgroundColorDark: ConfigKey =
    "MobileSdk.Placement.Title.Divider.BackgroundColor.Dark"

// MARK: Disclaimer
let MobileCreativeDisclaimerFontFamily: ConfigKey =
    "MobileSdk.Creative.Disclaimer.Font.Family"
let MobileCreativeDisclaimerFontSize: ConfigKey =
    "MobileSdk.Creative.Disclaimer.Font.Size"
let MobileCreativeDisclaimerFontColorLight: ConfigKey =
    "MobileSdk.Creative.Disclaimer.Font.Color.Light"
let MobileCreativeDisclaimerFontColorDark: ConfigKey =
    "MobileSdk.Creative.Disclaimer.Font.Color.Dark"
let MobileCreativeDisclaimerLineSpacing: ConfigKey =
    "MobileSdk.Creative.Disclaimer.LineSpacing"
let MobileCreativeDisclaimerAlignment: ConfigKey =
    "MobileSdk.Creative.Disclaimer.Alignment"
let MobileCreativeDisclaimerBackgroundColorLight: ConfigKey =
    "MobileSdk.Creative.Disclaimer.BackgroundColor.Light"
let MobileCreativeDisclaimerBackgroundColorDark: ConfigKey =
    "MobileSdk.Creative.Disclaimer.BackgroundColor.Dark"
let MobileCreativeDisclaimerMargin: ConfigKey =
    "MobileSdk.Creative.Disclaimer.Margin"

// MARK: Creative Privacy policy
let MobileCreativePrivacyPolicyButtonUnderline: ConfigKey =
    "MobileSdk.Creative.PrivacyPolicy.Button.Underline"

// MARK: Creative Terms
let MobileCreativeTermsButtonUnderline: ConfigKey =
    "MobileSdk.Creative.Terms.Button.Underline"

// MARK: Creative Logo Image
let MobileCreativeImageShowPosition1: ConfigKey =
    "MobileSdk.Creative.Image.Show.Position1"
let MobileCreativeImageShowPosition2Plus: ConfigKey =
    "MobileSdk.Creative.Image.Show.Position2+"
let MobileCreativeImageVisibility: ConfigKey =
    "MobileSdk.Creative.Image.Visibility"
let MobileCreativeImageMaxHeight: ConfigKey =
    "MobileSdk.Creative.Image.MaxHeight"
let MobileCreativeImageMaxWidth: ConfigKey =
    "MobileSdk.Creative.Image.MaxWidth"

// MARK: Placement LightBox background
let MobilePlacementLightBoxBackgroundColorLight: ConfigKey =
    "MobileSdk.Placement.Lightbox.BackgroundColor.Light"
let MobilePlacementLightBoxBackgroundColorDark: ConfigKey =
    "MobileSdk.Placement.Lightbox.BackgroundColor.Dark"

// MARK: Overlay placement border
let MobilePlacementCornerRadius: ConfigKey =
    "MobileSdk.Placement.CornerRadius"
let MobilePlacementBorderThickness: ConfigKey =
    "MobileSdk.Placement.BorderThickness"
let MobilePlacementBorderColorLight: ConfigKey =
    "MobileSdk.Placement.BorderColor.Light"
let MobilePlacementBorderColorDark: ConfigKey =
    "MobileSdk.Placement.BorderColor.Dark"

// MARK: BottomSheet Placement configurables
let MobilePlacementBottomSheetExpandable: ConfigKey =
    "MobileSdk.Placement.BottomSheet.Expandable"
let MobilePlacementBottomSheetDismissible: ConfigKey =
    "MobileSdk.Placement.BottomSheet.Dismissible"

// MARK: Default browser
let MobilePlacementActionDefaultMobileBrowser: ConfigKey =
    "MobileSdk.Placement.Action.Default.Mobile.Browser"
let MobilePlacementStaticLinkActionDefaultMobileBrowser: ConfigKey =
    "MobileSdk.Placement.StaticLink.Action.Default.Mobile.Browser"

// MARK: - Placement Behaviour
let MobilePlacementCanLoadNextOffer: ConfigKey =
    "MobileSdk.Placement.CanLoadNextOffer"
