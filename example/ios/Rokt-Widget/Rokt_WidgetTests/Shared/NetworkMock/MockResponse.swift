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
        NetworkingHelper.shared.manager = SessionManager(configuration: configuration)
        
        let originalURL = URL(string: kEventResourceUrl)!
        
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
                                       attributes: json[BE_ATTRIBUTES_KEY] as? [[String: String]]))
                    }
                }catch{
                }
            }
        }
        mock.register()
        
    }
    
    func stubDiagnostics(onDiagnosticsReceive: ((String) -> Void)? = nil){
        var mock = Mock(url: URL(string: kDiagnosticsResourceUrl)!,
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
}
