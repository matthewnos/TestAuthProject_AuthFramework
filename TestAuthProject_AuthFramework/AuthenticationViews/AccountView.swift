//
//  AccountView.swift
//  TestAuthProject_AuthFramework
//
//  Created by Andrew Fairchild on 6/28/23.
//

import Foundation
import SwiftUI

struct AccountView: View {
    
    @EnvironmentObject var athm: AuthManager
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
                Text("Welcome, \(athm.userAccount.firstName)!")
                    .font(.system(size: 24, weight: .bold))
                Text("What would you like to do today?")
                    .font(.system(size: 15, weight: .bold))
            VStack {
                Button(action: {
                    print("Reset Password")
                    athm.authState = .reset
                }) {
                    Text("Reset Password")
                        .font(.headline)
                        .frame(height: 25)
                        .frame(maxWidth: .infinity)
                }
                .cornerRadius(8)
                .buttonStyle(.borderedProminent)
                
                Button(action: {
                    athm.authState = .forgotRequest
                }) {
                    Text("Forgot Password")
                        .font(.headline)
                        .frame(height: 25)
                        .frame(maxWidth: .infinity)
                }
                .cornerRadius(8)
                .buttonStyle(.borderedProminent)
                
                
                Button(action: {
                    signOut()
                }) {
                    Text("Sign Out")
                        .font(.headline)
                        .frame(height: 25)
                        .frame(maxWidth: .infinity)
                }
                .cornerRadius(8)
                .buttonStyle(.borderedProminent)
                
                
                Button(action: {
                    deleteUserAction()
                }) {
                    Text("Delete Account")
                        .font(.headline)
                        .frame(height: 25)
                        .frame(maxWidth: .infinity)
                }
                .cornerRadius(8)
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: 200)
        }
        .frame(maxWidth: 500)
        .padding()
    }
    
    func deleteUserAction(){
        Task {
            do {
                await athm.deleteUser()
                await athm.signOutGlobally()
                athm.authState = .register
            }
        }
    }
    
    func signOut(){
        Task {
            do {
                await athm.signOutGlobally()
            }
        }
    }
}

