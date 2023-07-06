//
//  WelcomeView.swift
//  TestAuthProject_AuthFramework
//
//  Created by Andrew Fairchild on 7/6/23.
//

import Foundation
import SwiftUI
import Amplify

struct WelcomeView: View {

    @EnvironmentObject var athm: AuthManager
    
    var body: some View {
        VStack(alignment: .center, spacing: 20)  {
            Text("Welcome to the App!")
                .fontWeight(.bold)
                .font(.system(size: 30))
            HStack {
                Button(action: {
                    athm.authState = .login
                }) {
                    Text("Log In")
                        .font(.headline)
                        .frame(height: 25)
                        .frame(maxWidth: .infinity)
                }
                .cornerRadius(8)
                .buttonStyle(.borderedProminent)
                
                Button(action: {
                    athm.authState = .register
                }) {
                    Text("Sign Up")
                        .font(.headline)
                        .frame(height: 25)
                        .frame(maxWidth: .infinity)
                }
                .cornerRadius(8)
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: 500)
        .padding()
        .onAppear {
            Task {
                try await athm.awaitAuthSession()
            }
        }
    }
}



