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

public struct ForgotPasswordRequestView: View {
    @State private var isUsernameValid = false
    @State private var authErrorMessage = ""
    @State private var errorMessage = ""
    
    @EnvironmentObject var athm: AuthManager
    
    public var body: some View {
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
                    
                    if !authErrorMessage.isEmpty {
                        HStack(spacing: 20) {
                            Text(authErrorMessage)
                            Spacer()
                        }
                        .padding(.leading, 40)
                    }
                    
                    if !errorMessage.isEmpty {
                        HStack(spacing: 20) {
                            Text(errorMessage)
                            Spacer()
                        }
                        .padding(.leading, 40)
                    }
                }
                
                HStack {
                    Button(action: {
                        Task {
                            do {
                                try await forgotPassword()
                            } catch let error as AuthError {
                                authErrorMessage = error.localizedDescription
                                print("❌ \(error)")
                            } catch {
                                errorMessage = error.localizedDescription
                                print("❌ Unexpected error: \(error)")
                            }
                        }
                    }) {
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
    
    func forgotPassword() async throws {
        do {
            try await athm.resetPassword(username: athm.userAccount.email)
            authErrorMessage = ""
            errorMessage = ""
            athm.authState = .forgotConfirm
        } catch let error as AuthError {
            authErrorMessage = error.localizedDescription
            print("❌ \(error)")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Unexpected error: \(error)")
        }
    }
}

