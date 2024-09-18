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
// swiftlint:disable implicit_getter
var kBaseURL: String {get {config.environment.baseURL}}

// MARK: - Library details

let kLibraryVersion = "4.4.0"
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
let kEventResourceVersion = "v2"
var kEventResourceUrl: String {get { "\(kBaseURL)/\(kEventResourceVersion)/\(kEventResource)"}}
let kEventAPIFailureMsg = "response: %@ ,statusCode: %@ ,error: %@"

// MARK: - Diagnostics resource

let kDiagnosticsResource = "diagnostics"
let kDiagnosticsResourceVersion = "v1"
var kDiagnosticsResourceUrl: String {get { "\(kBaseURL)/\(kDiagnosticsResourceVersion)/\(kDiagnosticsResource)"}}

// MARK: - Timings resource

let kTimingsResource = "timings"
let kTimingsResourceVersion = "v1"
var kTimingsResourceUrl: String {get { "\(kBaseURL)/\(kTimingsResourceVersion)/\(kTimingsResource)"}}
let kTimingsAPIFailureMsg = "response: %@, statusCode: %@, error: %@"

// MARK: - Timings API keys
let BE_TIMINGS_EVENT_TIME_KEY = "eventTime"
let BE_TIMINGS_TIMING_METRICS_KEY = "timingMetrics"
let BE_TIMINGS_PLUGIN_ID_KEY = "pluginId"
let BE_TIMINGS_PLUGIN_NAME_KEY = "pluginName"

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
let BE_SDK_FRAMEWORK_TYPE = "rokt-sdk-framework-type"
let BE_HEADER_INTEGRATION_TYPE_KEY = "rokt-integration-type"
let BE_HEADER_PAGE_INSTANCE_GUID_KEY = "rokt-page-instance-guid"
let BE_HEADER_PAGE_ID_KEY = "rokt-page-id"

// MARK: - API keys

let HTTP_ERROR_UNAUTHORIZED = 401
let HTTP_ERROR_INTERNAL = 500
let HTTP_ERROR_BAD_GATEWAY = 502
let HTTP_ERROR_SERVER_NOT_AVAILABLE = 503
let BE_ATTRIBUTES_KEY = "attributes"
let BE_ATTRIBUTES_PAGE_INIT_KEY = "pageinit"
let BE_VIEW_NAME_KEY = "pageIdentifier"
let BE_SESSION_ID_KEY = "sessionId"
let BE_PAGE_INSTANCE_GUID_KEY = "pageInstanceGuid"
let BE_LAUNCH_DELAY_KEY = "launchDelayMilliseconds"
let BE_FONT_NAME_KEY = "fontName"
let BE_FONT_URL_KEY = "fontUrl"
let BE_FONT_POSTSCRIPT_NAME_KEY = "fontPostScriptName"
let BE_CLIENT_TIMEOUT_KEY = "clientTimeoutMilliseconds"
let BE_DEFAULT_LAUNCH_DELAY_KEY = "defaultLaunchDelayMilliseconds"
let BE_CLIENT_SESSION_TIMEOUT_KEY = "clientSessionTimeoutMilliseconds"
let BE_LOG_FONT_KEY = "shouldLogFontHappyPath"
let BE_USE_FONT_REGISTERY_URL_KEY = "shouldUseFontRegisterWithUrl"
let BE_ROKT_FLAG_KEY = "roktTrackingStatus"
let BE_FEATURE_FLAG_KEY = "featureFlags"
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
let BE_PAGE_SIGNAL_COMPLETE = "pageSignalLoadComplete"
let BE_PAGE_RENDER_ENGINE = "pageRenderEngine"
let BE_RENDER_ENGINE_LAYOUTS = "Layouts"
let BE_RENDER_ENGINE_PLACEMENTS = "Placements"
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
let BE_JWT_TOKEN = "token"
let kDownloadingFonts = "downloadingFonts"
let kFinishedDownloadingFonts = "finishedDownloadingFonts"
let kProgressIndicatorTypeCircleWithText = 1
let kEventTimeStamp = "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'"
let kUTCTimeStamp = "UTC"
let kBaseLocale = "en"
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
let kTrackError = "tracking consent not authorised"
let kNoWidgetErrorMessage = "No Widget!"
let kEmbeddedLayoutDoesntExistMessage = "Error embedded layout doesn't exist "
let kLayoutDoesNotSupported = "Error layout type does not supported "
let kLayoutDoesNotMatch = "Error layout object does not match the Layout code"
let kAPIInvalidButtonTemplate = "Error invalid button template"
let kAPIFontErrorMessage = "Error downloading font: "
let kUIFontErrorMessage = "Font family not found: "
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
let kColorInvalid = "The color is invalid: "
let kLayoutInvalid = "The layout is invalid"
let kResponseOptionAction = "responseOption.action"
let kPlacementLayoutCode = "PlacementLayoutCode "
let kOfferLayout = "OfferLayout "
let kExternalBrowserError = "External browser can't be opened: "
let kEmptyOffersError = "Error getting current offer: Offers empty"
let kInvalidOfferIndexError = "Error getting current offer at index: %d and total offers: %d"
let kHttpPrefix = "http://"
let kHttpsPrefix = "https://"
let kLoadingText = "Loading..."
let kSpaceHTML = "&nbsp;"
let kBreakHTML = "</br>"
let kInitFailedError = "INIT_FAILED"
let kFontFailedError = "FONT_FAILED"

let kParsingLayoutError = "Error parsing layout, "

// MARK: - Diagnostic error codes
let kAPIInitErrorCode = "[INIT]"
let kAPIExecuteErrorCode = "[EXECUTE]"
let kAPIEventErrorCode = "[EVENT]"
let kAPIFontErrorCode = "[FONT]"
let kAPIFullFontLogCode = "[FULLFONTLOGS]"
let kValidationErrorCode = "[VALIDATION]"
let kWebViewErrorCode = "[WEBVIEW]"
let kUrlErrorCode = "[URL]"
let kLinkErrorCode = "[LINK]"
let kViewErrorCode = "[VIEW]"
let kTrackErrorCode = "[TRACKINGCONSENT]"
let kLayoutHiddenErrorCode = "[LAYOUT_HIDDEN]"
let kLayoutCutoffErrorCode = "[LAYOUT_CUTOFF]"
let kLayoutMissizedErrorCode = "[LAYOUT_MISSIZED]"
let kNotInitializedCode = "[NOT_INITIALIZED]"
let kAPITimingsErrorCode = "[TIMINGS]"

// MARK: - Event Queue
let kEventDelay: Double = 0.25
let kEventQueueLabel = "EventsAccessQueue"

// MARK: Queue
let kSharedDataItemsQueueLabel = "com.rokt.shareddata.items.queue"
let kRoktEventCollectionQueueLabel = "com.rokt.eventcollection.queue"

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

// colormode key
let BE_COLOR_MODE_KEY = "colormode"

// payload keys
let kNoFunctional = "noFunctional"
let kNoTargeting = "noTargeting"
let kDoNotShareOrSell = "doNotShareOrSell"
let kGpcEnabled = "gpcEnabled"

// MARK: - SignalViewed constants
let kSignalViewedIntersectThreshold = 0.5
let kSignalViewedTimeThreshold = 1.0
let kSignalViewedCheckInterval = 0.5

// MARK: - Header to switch between Placement and DCUI
let kExperienceType = "rokt-experience-type"
let kPlacementsValue = "placements"
let kLayoutsValue = "layouts"

let kLayoutsSchemaVersionHeader = "rokt-layout-schema-version"
// to be manually updated whenever we pull in a new schema version
let kLayoutsSchemaVersion = "2.1"

// MARK: - Font error messages
let kRegisterGraphicsFontErrorMsg = "font: %@, error: registerGraphicsFont on device %@"
let kRegisterURLFontErrorMsg = "font: %@, error: registerURLFont on device %@"

// MARK: - Full font log keys
let kFullFontLogCode1 = "[FFL001]"
let kFullFontLogCode2 = "[FFL002]"
let kFullFontLogCode3 = "[FFL003]"
let kFullFontLogCode4 = "[FFL004]"
let kFullFontLogCode5 = "[FFL005]"
let kFullFontLogCode6 = "[FFL006]"
let kFullFontLogCode7 = "[FFL007]"
let kFullFontLogCode8 = "[FFL008]"
let kFullFontLogCode9 = "[FFL009]"
let kLogFontPreloadedType = "pre-loaded"
let kLogFontDownloadedType = "downloaded"

// MARK: - Accessibility
let kPageAnnouncement = "Page %d of %d"
let kOneByOneAnnouncement = "Offer %d of %d"
let kProgressIndicatorAnnouncement = "%d of %d"
let kCloseButtonAnnouncement = "Close button"
let kNextPageButtonAnnouncement = "Next page button"
let kPreviousPageButtonAnnouncement = "Previous page button"

// MARK: - Static feature flag
let kEventsLoggingEnabled = false

// MARK: - Bounding Box
let kBoundingBoxCheckDelay = 1.0
let kBoundingBoxCutoffThreshold = 1.0
// swiftlint:enable implicit_getter

// MARK: - Timings constants
let kTimingsSDKType = "msdk"
