//
//  Constants.swift
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
// MARK: - API environment

var config = Configuration()
var kBaseURL: String {get {config.environment.baseURL}}

// MARK: - Library details

let kLibraryVersion = "4.0.0"
let kOSType = "iOS"

// MARK: - Init resource

let kInitResource = "init"
let kInitResourceVersion = "v1"
var kInitResourceUrl: String {get { "\(kBaseURL)/\(kInitResourceVersion)/\(kInitResource)"}}

// MARK: - Placement resource

let kPlacementResource = "placements"
let kPlacementResourceVersion = "v1"
var kPlacementResourceUrl: String {get { "\(kBaseURL)/\(kPlacementResourceVersion)/\(kPlacementResource)"}}

// MARK: - Experiences resouce
let kExperiencesResource = "experiences"
let kExperiencesResourceVersion = "v1"
var kExperiencesResourceURL: String { "\(kBaseURL)/\(kExperiencesResourceVersion)/\(kExperiencesResource)" }

// MARK: - Event resource

let kEventResource = "events"
let kEventResourceVersion = "v1"
var kEventResourceUrl: String {get { "\(kBaseURL)/\(kEventResourceVersion)/\(kEventResource)"}}

// MARK: - Diagnostics resource

let kDiagnosticsResource = "diagnostics"
let kDiagnosticsResourceVersion = "v1"
var kDiagnosticsResourceUrl: String {get { "\(kBaseURL)/\(kDiagnosticsResourceVersion)/\(kDiagnosticsResource)"}}

// MARK: - Common Headers

let BE_SDK_VERSION_KEY = "rokt-sdk-version"
let BE_OS_TYPE_KEY = "rokt-os-type"
let BE_OS_VERSION_KEY = "rokt-os-version"
let BE_DEVICE_MODEL_KEY = "rokt-device-model"
let BE_PACKAGE_NAME_KEY = "rokt-package-name"
let BE_PACKAGE_VERSION_KEY = "rokt-package-version"
let BE_HEADER_SESSION_ID_KEY = "rokt-session-id"
let BE_TAG_ID_KEY = "rokt-tag-id"
let BE_ADVERTISING_ID_KEY = "rokt-advertising-id"
let BE_UI_LOCALE_KEY = "rokt-ui-locale"
let BE_TRACKING_CONSENT = "rokt-apple-tracking-consent"

// MARK: - API keys

let HTTP_ERROR_UNAUTHORIZED = 401
let HTTP_ERROR_INTERNAL = 500
let HTTP_ERROR_BAD_GATEWAY = 502
let HTTP_ERROR_SERVER_NOT_AVAILABLE = 503
let BE_ATTRIBUTES_KEY = "attributes"
let BE_VIEW_NAME_KEY = "pageIdentifier"
let BE_SESSION_ID_KEY = "sessionId"
let BE_PAGE_INSTANCE_GUID_KEY = "pageInstanceGuid"
let BE_LAUNCH_DELAY_KEY = "launchDelayMilliseconds"
let BE_FONT_NAME_KEY = "fontName"
let BE_FONT_URL_KEY = "fontUrl"
let BE_CLIENT_TIMEOUT_KEY = "clientTimeoutMilliseconds"
let BE_DEFAULT_LAUNCH_DELAY_KEY = "defaultLaunchDelayMilliseconds"
let BE_CLIENT_SESSION_TIMEOUT_KEY = "clientSessionTimeoutMilliseconds"
let BE_ROKT_FLAG_KEY = "roktTrackingStatus"
let BE_FONTS_KEY = "fonts"
let BE_TRAFFIC_REFERRAL_TYPE = 3
let BE_HYBRID_REFERRAL_TYPE = 4
let BE_EVENT_TYPE_KEY = "eventType"
let BE_INSTANCE_GUID = "instanceGuid"
let BE_PARENT_GUID_KEY = "parentGuid"
let BE_CLIENT_TIME_STAMP = "clientTimeStamp"
let BE_METADATA_KEY = "metadata"
let BE_NAME = "name"
let BE_VALUE = "value"
let BE_CAPTURE_METHOD = "captureMethod"
let BE_PAGE_SIGNAL_LOAD = "pageSignalLoadStart"
let BE_MODULE_ID_KEY = "moduleId"
let BE_CREATIVE_ID_KEY = "creativeId"
let BE_CREATIVE_STATE_BAG_KEY = "creativeStateBag"
let BE_CANONICAL_ATTRIBUTES_KEY = "canonicalAttributes"
let BE_ERROR_CODE_KEY = "code"
let BE_ERROR_STACK_TRACE_KEY = "stackTrace"
let BE_ERROR_SEVERITY_KEY = "severity"
let BE_ERROR_ADDITIONAL_KEY = "additionalInformation"
let BE_ERROR_SESSIONID_KEY = "sessionId"
let BE_ERROR_CAMPAIGNID_KEY = "campaignId"
let kDownloadingFonts = "downloadingFonts"
let kFinishedDownloadingFonts = "finishedDownloadingFonts"
let kProgressIndicatorTypeCircleWithText = 1
let kEventTimeStamp = "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'"
let kUTCTimeStamp = "UTC"
let kClientProvided = "ClientProvided"
let kInitiator = "initiator"
let kCloseButton = "CLOSE_BUTTON"
let kNoMoreOfferToShow = "NO_MORE_OFFERS_TO_SHOW"
let kCollapsed = "COLLAPSED"
let kEndMessage = "END_MESSAGE"
let kDismissed = "DISMISSED"
let kPartnerTriggered = "PARTNER_TRIGGERED"
let kNegativeButtonDismissal = "NEGATIVE_BUTTON"
let kNavigateBackToAppButton = "NAVIGATE_BACK_TO_APP_BUTTON"

// MARK: - lower Bottomsheet placement impression rate
let kModalPlacementCallErrorCode = "[MODAL]"
let kModalAlreadyExists = "A modal already exists onscreen. Will not render modal placement."

// MARK: - UI keys
let kCreativeHtmlContainerPlaceholder = "[[CREATIVE_HTML]]"
let kDefaultSeparation = 8
let kButtonsHeight = CGFloat(40)
let kButtonsStackedTemplateHeight = CGFloat(95)
let kProgressDotsHeight = CGFloat(18)
let kImageOfferHeight: Float = 120
let kImageOfferBottomSpacing = CGFloat(16)
let kPreOfferBottomSpacing = CGFloat(16)
let kConfirmationMessageSpacing: Float = 16
let kAfterOfferSpacing: Float = 10
let kProgressDotsBottomSpacing = CGFloat(16)
let kOfferAnimationDuration = 0.25
let kOverlayAnimationDelay = 0.4
let kDefaultLineSpacing: Float = 1
let kWidthSpacingThreshold = CGFloat(5)
let kMaxScreenHeight = CGFloat(2500)
let kThinCloseButtonSourceName = "thinClose"

// MARK: - String keys
let kInitBeforeDoKey = "init_before_do"
let kInitBeforeDoComment = "Please initialize the Rokt widget"
let kExecuteIsRunningKey = "execute_is_running"
let kExecuteIsRunningComment = "Execute is already running"
let kAppPrivacyConsentKey = "App_privacy_consent_required"
let kAppPrivacyConsentComment = "App privacy consent required"
let kNetworkErrorKey = "network_error"
let kNetworkErrorComment = "Network connection error"
let kUnauthorizedKey = "unauthorized"
let kUnauthorizedComment = "Unauthorized"
let kApiErrorKey = "api_error"
let kApiErrorC = "API error: No response"
let kApiResponseKey = "api_response"
let kApiResponseComment = "API response"
let kParseErrorKey = "parse_error"
let kParseErrorComment = "Error parsing response"
let kAPIInitErrorCode = "[INIT]"
let kAPIExecuteErrorCode = "[EXECUTE]"
let kAPIEventErrorCode = "[EVENT]"
let kAPIFontErrorCode = "[FONT]"
let kValidationErrorCode = "[VALIDATION]"
let kWebViewErrorCode = "[WEBVIEW]"
let kUrlErrorCode = "[URL]"
let kLinkErrorCode = "[LINK]"
let kViewErrorCode = "[VIEW]"
let kTrackErrorCode = "[TRACKINGCONSENT]"
let kTrackError = "tracking consent not authorised"
let kNoWidgetErrorMessage = "No Widget!"
let kEmbeddedLayoutDoesntExistMessage = "Error embedded layout doesn't exist "
let kLayoutDoesNotSupported = "Error layout type does not supported "
let kLayoutDoesNotMatch = "Error layout object does not match the Layout code"
let kAPIInvalidButtonTemplate = "Error invalid button template"
let kAPIFontErrorMessage = "Error downloading font: "
let kOfferImageError = "Offer Image URL: "
let kStaticPageError = "Error on static page"
let kParsingPlacementError = "Error parsing placement, "
let kKeyMissingError = "Key missing: "
let kValueIsNilError = "Value is nil: "
let kInvalidHTMLFormatError = "Error parsing html: "
let kTypeMissMatch = "Type miss match: "
let kNotSupported = "Not supported: "
let kNoResponse = "No response from API"
let kEmptyResponse = "Empty response from API"
let kLocationDoesNotExist = " location does not exist"
let kUnprocessableData = "Unprocessable data"
let kNegativeButton = "Negative button"
let kPositiveButton = "Positive button"
let kUrlMission = "Url missing in positive response"
let kResponseOptionAction = "responseOption.action"
let kPlacementLayoutCode = "PlacementLayoutCode "
let kOfferLayout = "OfferLayout "
let kExternalBrowserError = "External browser can't be opened: "
let kHttpPrefix = "http://"
let kHttpsPrefix = "https://"
let kLoadingText = "Loading..."
let kSpaceHTML = "&nbsp;"
let kBreakHTML = "</br>"

let kParsingLayoutError = "Error parsing layout, "

// MARK: - Event Queue
let kEventDelay: Double = 0.25
let kEventQueueLabel = "EventsAccessQueue"

// MARK: - Network
let kJsonAccept = "application/json"
let kAcceptHeader = "Accept"
let kContentType = "Content-Type"
let kBundleShort = "CFBundleShortVersionString"
let kArrayResponseKey = "array"
let kMaxRetries = 3
let kPost = "POST"

let kHtmlError = "<div style='display: block; width: 80%; margin:auto;text-align: center; margin-top:10vw;'>"
+ "<h1 style='font-size: 5vw;font-family:Arial;'>Webpage not available</h1>"
+ "<p style='font-size: 4vw;font-family:Arial;'>Please try refreshing, or go back to the previous page</p></div>"

// MARK: - CPRA/Privacy flags in attributes

// top-level key
let BE_PRIVACY_CONTROL_KEY = "privacyControl"

// payload keys
let kNoFunctional = "noFunctional"
let kNoTargeting = "noTargeting"
let kDoNotShareOrSell = "doNotShareOrSell"
let kGpcEnabled = "gpcEnabled"

// MARK: - Header to switch between Placement and DCUI
let kExperienceType = "rokt-experience-type"
let kPlacementsValue = "placements"
let kLayoutsValue = "layouts"

let kLayoutsSchemaVersionHeader = "rokt-layout-schema-version"
// to be manually updated whenever we pull in a new schema version
let kLayoutsSchemaVersion = "1.0"
