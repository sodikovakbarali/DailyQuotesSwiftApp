//
//  DailyQuotesApp.swift
//  DailyQuotes
//
//  Created by Ulugbek Muslitdinov on 4/26/25.
//

import SwiftUI

@main
struct DailyQuotesApp: App {
    init() {
        // App initialization
        
        // Add necessary permissions from Info.plist_data
        if let infoPlistPath = Bundle.main.path(forResource: "Info.plist_data", ofType: nil),
           let plistData = FileManager.default.contents(atPath: infoPlistPath),
           let plist = try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any] {
            
            // Set user defaults for permissions
            if let photoLibraryUsage = plist["NSPhotoLibraryUsageDescription"] as? String {
                print("Photo library permission: \(photoLibraryUsage)")
            }
            
            if let photoLibraryAddUsage = plist["NSPhotoLibraryAddUsageDescription"] as? String {
                print("Photo library add permission: \(photoLibraryAddUsage)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
