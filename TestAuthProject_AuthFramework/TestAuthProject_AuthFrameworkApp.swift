//
//  TestAuthProject_AuthFrameworkApp.swift
//  TestAuthProject_AuthFramework
//
//  Created by Andrew Fairchild on 6/26/23.
//

import SwiftUI
import Amplify
import AWSCognitoIdentity
import AWSCognitoAuthPlugin

@main
struct TestAuthProject_AuthFrameworkApp: App {
    
    @StateObject var authManager = AuthManager.shared
    
    init() {
        do {
            
//            Amplify.Logging.logLevel = .verbose
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.configure()
            print("🟢 Amplify configured with auth plugin.")
            
        } catch {
            print("🛑 Failed to initialize Amplify with \(error)")
        }
    }
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(authManager)        }
    }
}
