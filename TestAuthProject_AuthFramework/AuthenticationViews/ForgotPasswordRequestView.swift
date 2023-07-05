//
//  ForgotPasswordRequestView.swift
//  TestAuthProject_AuthFramework
//
//  Created by Andrew Fairchild on 6/28/23.
//

import Foundation
import SwiftUI
import Amplify
import Combine

struct ForgotPasswordRequestView: View {
    @State private var isUsernameValid = false
    @State private var authErrorMessage = ""
    @State private var errorMessage = ""
    @State private var showAuthError = false
    @State private var showError = false
    
    @EnvironmentObject var athm: AuthManager
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 40) {
                Group {
                    TextField("Email", text: $athm.userAccount.email)
                        .padding()
                        .font(.body)
                        .foregroundColor(.primary)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isUsernameValid ? Color.green.opacity(0.3) : Color.red.opacity(0.8), lineWidth: 2)
                        )
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .onChange(of: athm.userAccount.email) { newValue in
                            isUsernameValid = athm.isValidEmail(newValue)
                        }
                    
                    if showAuthError {
                        VStack(spacing: 20) {
                            Text(authErrorMessage)
                        }
                    }
                    
                    if showError {
                        VStack(spacing: 20) {
                            Text(errorMessage)
                        }
                    }
                }
                
                HStack {
                    Button(action: {
                        showAuthError = false
                        showError = false
                        forgotPassword()
                    })
                    {
                        Text("Confirm")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                }
                .padding(.leading, 40)
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            print("View appeared")
        }
    }
    
    func forgotPassword() {
        Task{
            do {
                try await athm.resetPassword(username: athm.userAccount.email)
                athm.authState = .forgotConfirm
            } catch let error as AuthError {
                authErrorMessage = error.errorDescription
                showAuthError = true
                print("❌ \(error)")
            } catch {
                errorMessage = error.localizedDescription
                showError = true
                print("❌ Unexpected error: \(error)")
            }
        }
    }
}

