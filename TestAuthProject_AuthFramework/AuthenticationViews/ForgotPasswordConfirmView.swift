//
//  ForgotPasswordConfirmView.swift
//  TestAuthProject_AuthFramework
//
//  Created by Andrew Fairchild on 6/28/23.
//

import Foundation
import SwiftUI
import Amplify
import Combine



public struct ForgotPasswordConfirmationView: View {
    @State var newPassword: String = ""
    @State var showAuthError: Bool = false
    @State var showError: Bool = false
    @State private var isUsernameValid = false
    @State private var isPasswordValid = false
    @State var authErrorMessage: String = ""
    @State var errorMessage: String = ""
    @State var confirmationCode: String = ""
    
    @EnvironmentObject var athm: AuthManager
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            TextField("Email", text: $athm.userAccount.email)
                .padding()
                .frame(maxWidth: .infinity)
                .font(.body)
                .foregroundColor(.primary)
                .background(isUsernameValid ? Color.gray.opacity(0.1) : Color.red.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isUsernameValid ? Color.green.opacity(0.3) : Color.red.opacity(0.8), lineWidth: 2)
                )
                .cornerRadius(8)
                .onChange(of: athm.userAccount.email) { newValue in
                    isUsernameValid = athm.isValidEmail(newValue)
                    print(isUsernameValid)
                }
                .padding(.horizontal)
            
            SecureField("Password", text: $newPassword)
                .padding()
                .frame(maxWidth: .infinity)
                .font(.body)
                .foregroundColor(.primary)
                .background(isPasswordValid ? Color.gray.opacity(0.1) : Color.red.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isPasswordValid ? Color.green.opacity(0.3) : Color.red.opacity(0.8), lineWidth: 2)
                )
                .cornerRadius(8)
                .onChange(of: newPassword) { newValue in
                    isPasswordValid = athm.isValidPassword(newValue)
                    print(isPasswordValid)
                }
                .padding(.horizontal)
            
            TextField("Confirmation Code", text: $confirmationCode)
                .padding()
                .frame(maxWidth: .infinity)
                .font(.body)
                .foregroundColor(.primary)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
            
            VStack(spacing: 20) {
                if showAuthError {
                    HStack(spacing: 20) {
                        Text(authErrorMessage)
                        Spacer()
                    }.padding(.leading)
                }
                
                if showError {
                    HStack(spacing: 20) {
                        Text(errorMessage)
                        Spacer()
                    }.padding(.leading)
                }
            }
            
            Button(action: {
                Task {
                    do {
                        try await forgotPasswordConfirm()
                    } catch {
                        print("Error:", error)
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
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(8)
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
    
    func forgotPasswordConfirm() async throws {
        do {
            try await athm.confirmResetPassword(username: athm.userAccount.email, newPassword: newPassword, confirmationCode: confirmationCode)
            showError = false
            authErrorMessage = ""
            errorMessage = ""
            athm.userAccount.password = newPassword
            athm.signOut()
            athm.authState = .login
        } catch let error as AuthError {
            // Handle specific AuthError
            authErrorMessage = error.localizedDescription
            showAuthError = true
            print("❌ \(error)")
        } catch {
            // Handle other errors
            errorMessage = error.localizedDescription
            showError = true
            print("❌ Unexpected error: \(error)")
        }
    }
}

