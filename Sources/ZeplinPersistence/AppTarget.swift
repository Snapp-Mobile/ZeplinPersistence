//
//  AppTarget.swift
//  
//
//  Created by Ilian Konchev on 5.10.21.
//

import Foundation

public enum AppTarget: String, CaseIterable, Sendable {
    case macOSApp
    case macOSWidget
    case iOSApp
    case iOSBackgroundTask
    case iOSWidget
    case watchOSApp
    case watchOSComplication

    public var transactionAuthor: String {
        switch self {
        case .macOSApp:
            return "Zeplin.App.macOS"
        case .macOSWidget:
            return "Zeplin.Widget.macOS"
        case .iOSApp:
            return "Zeplin.App.iOS"
        case .iOSBackgroundTask:
            return "Zeplin.BackgroundTask.iOS"
        case .iOSWidget:
            return "Zeplin.Widget.iOS"
        case .watchOSApp:
            return "Zeplin.App.watchOS"
        case .watchOSComplication:
            return "Zeplin.Complication.watchOS"
        }
    }

    public var groupIdentifier: String {
        switch self {
        case .macOSApp, .macOSWidget:
            return "5KLV3M3ZXD.io.snappmobile.ZeplinApp.group"
        case .iOSApp, .iOSWidget, .iOSBackgroundTask:
            return "group.io.snappmobile.ZeplinApp"
        default:
            return ""
        }
    }

    public var userDefaults: UserDefaults? {
        return UserDefaults(suiteName: groupIdentifier)
    }

    public var widgetKind: String? {
        switch self {
        case .macOSApp:
            return "ZeplinWidget"
        case .iOSApp:
            return "ZeplinAppWidget"
        default:
            return nil
        }
    }
}
