//
//  ProcessedTimingsRequestViewModel.swift
//  Rokt-Widget
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import Foundation

class ProcessedTimingsRequestViewModel {
    private var pageId: String?
    private var pageInstanceGuid: String?
    
    private var initStartTime: Date?
    private var initEndTime: Date?
    private var pageInitTime: Date?
    private var selectionStartTime: Date?
    private var selectionEndTime: Date?
    private var experiencesRequestStartTime: Date?
    private var experiencesRequestEndTime: Date?
    
    private var processedTimingsRequests = Set<ProcessedTimingsRequest>()
    
    internal func setPageProperties(pageId: String?, pageInstanceGuid: String?) {
        self.pageId = pageId
        self.pageInstanceGuid = pageInstanceGuid
    }
    
    internal func setInitStartTime(_ time: Date? = DateHandler.currentDate()) {
        self.initStartTime = time
    }
    
    internal func setInitEndTime() {
        self.initEndTime = DateHandler.currentDate()
    }
    
    internal func getValidPageInitTime(_ timeAsString: String) -> Date? {
        // Validates format
        guard timeAsString.count == 13,
              let timeAsDouble = Double(timeAsString)
        else {
            return nil
        }
        
        let timeAsDate = Date(timeIntervalSince1970: (timeAsDouble / 1000.0))
        
        // Check date within valid range
        guard let selectionStartTime = self.selectionStartTime,
              timeAsDate.isBefore(selectionStartTime)
        else {
            return nil
        }

        return timeAsDate
    }
    
    internal func setPageInitTime(_ time: Date? = DateHandler.currentDate()) {
        self.pageInitTime = time
    }
    
    internal func setSelectionStartTime() {
        self.selectionStartTime = DateHandler.currentDate()
    }
    
    internal func setSelectionEndTime() {
        self.selectionEndTime = DateHandler.currentDate()
    }
    
    internal func setExperiencesRequestStartTime() {
        self.experiencesRequestStartTime = DateHandler.currentDate()
    }
    
    internal func setExperiencesRequestEndTime() {
        self.experiencesRequestEndTime = DateHandler.currentDate()
    }
    
    internal func processTimingsRequest(pluginId: String? = nil,
                                        pluginName: String? = nil,
                                        placementInteractiveTime: Date? = nil,
                                        sessionId: String? = nil) {
        let timingsRequest = buildTimingsRequest(pluginId: pluginId,
                                                 pluginName: pluginName,
                                                 placementInteractiveTime: placementInteractiveTime)
        if isUniqueTimingsRequest(timingsRequest) {
            RoktAPIHelper.sendTimings(timingsRequest, sessionId: sessionId)
        }
    }
    
    internal func resetTimingsOnExecute() {
        self.pageInitTime = nil
        self.selectionStartTime = nil
        self.selectionEndTime = nil
        self.experiencesRequestStartTime = nil
        self.experiencesRequestEndTime = nil
        self.processedTimingsRequests = Set<ProcessedTimingsRequest>()
    }

    private func isUniqueTimingsRequest(_ req: TimingsRequest) -> Bool {
        // Checks if unique timings request (unique per execute or plugin)
        let pendingEvent = ProcessedTimingsRequest(pluginId: req.pluginId)
        return processedTimingsRequests.insert(pendingEvent).inserted
    }
    
    private func buildTimingsRequest(pluginId: String?,
                                     pluginName: String?,
                                     placementInteractiveTime: Date?) -> TimingsRequest {
        return TimingsRequest(pageId: self.pageId,
                              pageInstanceGuid: self.pageInstanceGuid,
                              pluginId: pluginId,
                              pluginName: pluginName,
                              timings: buildTimingMetricArray(placementInteractiveTime))
    }
    
    private func buildTimingMetricArray(_ placementInteractiveTime: Date?) -> [TimingMetric] {
        var timingsMetrics = [TimingMetric]()
        
        if let initStartValue = self.initStartTime {
            timingsMetrics.append(TimingMetric(name: .initStart, value: initStartValue))
        }
        if let initEndValue = self.initEndTime {
            timingsMetrics.append(TimingMetric(name: .initEnd, value: initEndValue))
        }
        if let pageInitValue = self.pageInitTime {
            timingsMetrics.append(TimingMetric(name: .pageInit, value: pageInitValue))
        }
        if let selectionStartValue = self.selectionStartTime {
            timingsMetrics.append(TimingMetric(name: .selectionStart, value: selectionStartValue))
        }
        if let experiencesRequestStartValue = self.experiencesRequestStartTime {
            timingsMetrics.append(
                TimingMetric(name: .experiencesRequestStart, value: experiencesRequestStartValue))
        }
        if let experiencesRequestEndValue = self.experiencesRequestEndTime {
            timingsMetrics.append(
                TimingMetric(name: .experiencesRequestEnd, value: experiencesRequestEndValue))
        }
        if let selectionEndValue = self.selectionEndTime {
            timingsMetrics.append(TimingMetric(name: .selectionEnd, value: selectionEndValue))
        }
        if let placementInteractiveValue = placementInteractiveTime {
            timingsMetrics.append(
                TimingMetric(name: .placementInteractive, value: placementInteractiveValue))
        }
        
        return timingsMetrics
    }
}
