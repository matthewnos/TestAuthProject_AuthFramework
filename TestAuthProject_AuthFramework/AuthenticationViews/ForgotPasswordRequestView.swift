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
        VStack {
            VStack(alignment: .center, spacing: 20) {
                Group {
                    TextField("Email", text: $athm.userAccount.email)
                        .padding()
                        .font(.body)
                        .foregroundColor(.primary)
                        .background(RoundedRectangle(cornerRadius: 8).fill(isUsernameValid ? Color.gray.opacity(0.1) : Color.red.opacity(0.2)))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(isUsernameValid ? Color.green.opacity(0.3) : Color.red.opacity(0.8), lineWidth: 2))
                        .cornerRadius(8)
                        .onChange(of: athm.userAccount.email) { newValue in
                            isUsernameValid = athm.isValidEmail(newValue)
                        }
                    
                    if showAuthError {
                        HStack {
                            Text(authErrorMessage)
                                .font(.system(size: 11))
                            Spacer()
                        }
                    } else if showError {
                        HStack {
                            Text(errorMessage)
                                .font(.system(size: 11))
                            Spacer()
                        }
                    } else {
                        HStack {
                            Text(" ")
                                .font(.system(size: 11))
                            Spacer()
                        }
                    }
                }
                
                VStack {
                    Button(action: {
                        showAuthError = false
                        showError = false
                        forgotPassword()
                    })
                    {
                        Text("Confirm")
                            .font(.headline)
                            .frame(height: 25)
                            .frame(maxWidth: .infinity)
                    }
                    .cornerRadius(8)
                    .buttonStyle(.borderedProminent)
                    .disabled(!isUsernameValid)
                }
                .frame(maxWidth: 200)
            }
        }
        .frame(maxWidth: 500)
        .padding()
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

