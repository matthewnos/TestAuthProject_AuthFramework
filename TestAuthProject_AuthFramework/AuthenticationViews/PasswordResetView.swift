//
//  PasswordResetView.swift
//  TestAuthProject_AuthFramework
//
//  Created by Andrew Fairchild on 6/28/23.
//

import Foundation
import SwiftUI
import Amplify
import Combine

struct PasswordResetView: View {
    @State var backgroundColor: Color = .red
    @State var show: Bool = false
    @State var width: CGFloat = UIScreen.main.bounds.width * 0.7
    @State var newPassword: String = ""
    @State var showAuthError: Bool = false
    @State var showError: Bool = false
    @State private var isPasswordValid = false
    @State private var isNewPasswordValid = false
    @State var authErrorMessage: String = ""
    @State var errorMessage: String = ""
    
    @EnvironmentObject var athm: AuthManager
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            SecureField("Old Password", text: $athm.userAccount.password)
                .padding()
                .font(.body)
                .foregroundColor(.primary)
                .background(RoundedRectangle(cornerRadius: 8).fill(isPasswordValid ? Color.gray.opacity(0.1) : Color.red.opacity(0.2)))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(isPasswordValid ? Color.green.opacity(0.3) : Color.red.opacity(0.8), lineWidth: 2))
                .onChange(of: athm.userAccount.password) { newValue in
                    isPasswordValid = athm.isValidPassword(newValue)
                    print(isPasswordValid)
                }
            
                SecureField("New Password", text: $newPassword)
                    .padding()
                    .font(.body)
                    .foregroundColor(.primary)
                    .background(RoundedRectangle(cornerRadius: 8).fill(isNewPasswordValid ? Color.gray.opacity(0.1) : Color.red.opacity(0.2)))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(isNewPasswordValid ? Color.green.opacity(0.3) : Color.red.opacity(0.8), lineWidth: 2))
                    .onChange(of: newPassword) { newValue in
                        isNewPasswordValid = athm.isValidPassword(newValue)
                        print(isNewPasswordValid)
                    }
            
                if showAuthError {
                    VStack {
                        Text(authErrorMessage)
                            .font(.system(size: 11))
                    }
                } else if showError {
                    VStack {
                        Text(errorMessage)
                            .font(.system(size: 11))
                    }
                } else {
                    VStack {
                        Text(" ")
                            .font(.system(size: 11))
                    }
                }
                
            VStack {
                Button(action: {
                    Task {
                        do {
                            try await resetPassword()
                        } catch {
                            print("Error:", error)
                        }
                    }
                }) {
                    Text("Confirm")
                        .font(.headline)
                        .frame(height: 25)
                        .frame(maxWidth: .infinity)
                }
                .cornerRadius(8)
                .buttonStyle(.borderedProminent)
                .disabled(!isNewPasswordValid && !isPasswordValid)
            }
            .frame(maxWidth: 200)

        }
        .frame(maxWidth: 500)
        .padding()
    }
    
    func resetPassword() async throws {
        do {
            try await athm.changePassword(oldPassword: athm.userAccount.password, newPassword: newPassword)
            showAuthError = false
            showError = false
            authErrorMessage = ""
            errorMessage = ""
            athm.userAccount.password = newPassword
            athm.signOut()
            athm.authState = .login
        } catch let error as AuthError {
            authErrorMessage = error.errorDescription
            showAuthError = true
            print("Change password failed with error \(error)")
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("Unexpected error: \(error)")
        }
    }
}


