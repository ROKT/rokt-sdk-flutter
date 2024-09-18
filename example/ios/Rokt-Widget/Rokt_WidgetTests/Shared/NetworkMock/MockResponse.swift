//
//  MockResponse.swift
//  Rokt_WidgetTests
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
import Mocker

extension XCTestCase{
    func stubEvents(onEventReceive: ((EventModel) -> Void)? = nil) {
        let configuration = URLSessionConfiguration.default
            configuration.protocolClasses = [MockingURLProtocol.self] + (configuration.protocolClasses ?? [])
        NetworkingHelper.shared.httpClient = RoktHTTPClient(sessionConfiguration: configuration)

        guard let originalURL = URL(string: kEventResourceUrl) else { return }
        
        var mock = Mock(url: originalURL,
                        dataType: .json, statusCode: 200, data: [.post :  Data()])
        
        mock.onRequest = { request , httpBodyArguments in
            if let reqestDatas = request.httpBodyStream?.readfully() {
                do{
                    let jsonArray = try JSONSerialization.jsonObject(with: reqestDatas, options: []) as? [[String : Any]]
                    for json in jsonArray! {
                        onEventReceive?(
                            EventModel(eventType: json[BE_EVENT_TYPE_KEY] as! String,
                                       parentGuid: json[BE_PARENT_GUID_KEY] as! String,
                                       pageInstanceGuid: json[BE_PAGE_INSTANCE_GUID_KEY] as? String,
                                       metadata: json[BE_METADATA_KEY] as? [[String: String]],
                                       attributes: json[BE_ATTRIBUTES_KEY] as? [[String: String]],
                                       jwtToken: json["token"] as! String))
                    }
                }catch{
                }
            }
        }
        mock.register()
        
    }
    
    func stubDiagnostics(onDiagnosticsReceive: ((String) -> Void)? = nil){
        let configuration = URLSessionConfiguration.default
            configuration.protocolClasses = [MockingURLProtocol.self] + (configuration.protocolClasses ?? [])
        NetworkingHelper.shared.httpClient = RoktHTTPClient(sessionConfiguration: configuration)
        
        guard let originalURL = URL(string: kDiagnosticsResourceUrl) else { return }
        var mock = Mock(url: originalURL,
                        dataType: .json, statusCode: 200, data: [.post :  Data()])

        mock.onRequest = { request , httpBodyArguments in
            if let reqestDatas = request.httpBodyStream?.readfully(){
                do{
                    let json = try JSONSerialization.jsonObject(with: reqestDatas, options: []) as? [String : Any]
                    onDiagnosticsReceive?(json![BE_ERROR_CODE_KEY] as! String)
                }catch{
                }
            }
        }
        mock.register()
    }
    
    func stubTimings(onTimingsRequestReceive: ((MockTimingsRequest) -> Void)? = nil){
        let configuration = URLSessionConfiguration.default
            configuration.protocolClasses = [MockingURLProtocol.self] + (configuration.protocolClasses ?? [])
        NetworkingHelper.shared.httpClient = RoktHTTPClient(sessionConfiguration: configuration)

        guard let originalURL = URL(string: kTimingsResourceUrl) else { return }
        
        var mock = Mock(url: originalURL,
                        dataType: .json, statusCode: 200, data: [.post :  Data()])
        
        mock.onRequest = { request , httpBodyArguments in
            if let requestBodyStream = request.httpBodyStream?.readfully(),
               let requestHeaders = request.allHTTPHeaderFields {
                do{
                    let requestBody = try JSONSerialization.jsonObject(with: requestBodyStream, options: []) as! [String: Any]
                    onTimingsRequestReceive?(
                        MockTimingsRequest(eventTime: requestBody[BE_TIMINGS_EVENT_TIME_KEY] as! String,
                                           pageId: requestHeaders[BE_HEADER_PAGE_ID_KEY],
                                           pageInstanceGuid: requestHeaders[BE_HEADER_PAGE_INSTANCE_GUID_KEY],
                                           pluginId: requestBody[BE_TIMINGS_PLUGIN_ID_KEY] as? String,
                                           pluginName: requestBody[BE_TIMINGS_PLUGIN_NAME_KEY] as? String,
                                           timings: requestBody[BE_TIMINGS_TIMING_METRICS_KEY] as! [[String: String]])
                    )
                }catch{
                }
            }
        }
        mock.register()
    }
}
